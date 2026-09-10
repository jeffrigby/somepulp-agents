---
name: update-deps
description: Update dependencies safely — apply in-range minor/patch updates, then analyze each pending major in parallel and apply only the ones proven safe for this codebase, reporting the rest with justifications.
when_to_use: When the user asks to "update dependencies", "update deps", "upgrade packages", "bump dependencies", or "check what's safe to update".
argument-hint: "[minors-only|majors-only] [dry-run] [sequential]"
allowed-tools:
  - Bash("${CLAUDE_PLUGIN_ROOT}/scripts/dep-outdated.sh" *)
  - Bash(npm update*)
  - Bash(npm install*)
  - Bash(npm view*)
  - Bash(npm run*)
  - Bash(npx tsc*)
  - Bash(pnpm update*)
  - Bash(pnpm run*)
  - Bash(yarn up*)
  - Bash(yarn upgrade*)
  - Bash(yarn run*)
  - Bash(git status*)
  - Bash(git diff*)
  - Glob
  - Grep
  - Read
  - Agent
  - AskUserQuestion
  - TodoWrite
disable-model-invocation: true
---

# Update Dependencies (Orchestrator)

Bring a JavaScript project's dependencies current in two passes: apply everything the declared ranges already permit, then decide **per package** whether each pending major is safe for *this* codebase — and report the ones that aren't, with a reason the user can act on.

You are the conductor. `major-upgrade-analyzer` subagents do the per-major research; you sequence, gate, apply, and verify.

**Modes requested (optional):** "$ARGUMENTS"

## Scope

**JavaScript/TypeScript only** — npm, pnpm, and yarn (classic and berry), detected from the lockfile or the `packageManager` field. If the project has no `package.json`, stop and say so; don't improvise with pip or cargo.

Monorepos are supported: findings are attributed to the workspace that declared them, and upgrades are applied to that workspace rather than the root.

## Modes

Split `$ARGUMENTS` on whitespace:

| Token | Effect |
| --- | --- |
| `minors-only` | Apply in-range updates only. No major analysis. |
| `majors-only` | Skip the in-range pass. Analyze and apply majors against the versions already installed. |
| `dry-run` | Do all the analysis, change nothing. The approval gate is skipped and the plan is the output. |
| `sequential` | Analyze majors one at a time instead of in parallel. Slower; useful for debugging a stuck analyzer. |

Anything else is a scope hint passed to every analyzer (e.g. a path, or "src/ only").

Default: both passes, majors analyzed in parallel, one approval gate covering both.

## Workflow

The order matters: **nothing is written until the single approval gate in step 5.** That means the outdated snapshot is taken *before* any update runs, so the plan and the final report can both name exact `from → to` versions.

### 1. Preconditions

1. Confirm `package.json` exists. If not, stop.
2. Run `git status --porcelain`. **A dirty tree is not a blocker** — this skill never commits and never reverts — but if `package.json` or the lockfile already has uncommitted changes, tell the user before touching them, so they know what's theirs and what's yours.
3. Detect the toolchain:

   ```bash
   "${CLAUDE_PLUGIN_ROOT}"/scripts/dep-outdated.sh --detect
   ```

   Keep `manager`, `updateCommand`, `updateCommandTemplate`, `majorInstallTemplate`, and `workspaceFlagTemplate` — later steps use them instead of hardcoding a command.
4. **Workspaces**: if `workspaces` is true, note the globs. The report covers **every workspace**, not just the root — the script resolves each finding back to the workspace that declared it. What this means for step 7 is in "Workspace targeting" below; the short version is that a bare install at a workspace root writes to the *root* manifest, which is almost never what you want.

### 2. Snapshot what's outdated

```bash
"${CLAUDE_PLUGIN_ROOT}"/scripts/dep-outdated.sh
```

Inject the JSON into your context and work from it. Take this snapshot **first** — it is the only record of the pre-update versions, and both the plan and the report depend on it.

Three fields drive everything, and the first two are **independent axes, not a partition**:

- `upgrade` — the gap from installed to `latest`: `major`, `minor`, `patch`, or `unknown`
- `inRangeUpdate` — whether the declared range already permits a move (`current` → `wanted`)
- `type` / `dev` — which dependency section the package lives in

A package can be both (`chalk` 4.1.0, range `^4.1.0`, latest 6.0.0 → in-range to 4.1.2 *and* a major behind). Because they overlap, `counts.inRangeUpdate + counts.major` does not equal `counts.total` — never present it as a breakdown that sums.

Partition the packages:

| Group | Selector | Handled by |
| --- | --- | --- |
| **In-range** | `inRangeUpdate: true` | Step 6, no analysis — the declared range already permits it |
| **Majors** | `upgrade: "major"` | Step 4, one analyzer each; step 5 groups coupled families |
| **Unanalyzable** | `upgrade: "unknown"` | Nothing — but they **must** appear in the report's Notes |

Each package also carries `dependents[]` — every workspace that declares it, with that workspace's own range and section. Read it rather than assuming:

- `type` is the **strictest** section across all consumers, so a package that is a prod dependency in any workspace is reported as one. `dev` is true only when every consumer declares it as a devDependency.
- `range` is null when workspaces disagree (e.g. `api` pins `^4.0.14` while `client` pins `^4.1.0`). The per-workspace ranges are in `dependents[]`.
- More than one entry means an upgrade **must touch each of them**. Say so in the plan; a partial upgrade leaves the monorepo inconsistent.

`unknown` means the version couldn't be compared, usually because `current` is null: `node_modules` is missing, or yarn berry is running in PnP mode where there is no `node_modules` tree for npm's resolver to read. If *every* package is `unknown`, say so loudly rather than reporting a clean tree — suggest installing dependencies first, or for yarn PnP, running `yarn install --mode=update-lockfile` and re-running.

Carry `notes[]` through to the final report — that's where the script records fallbacks (yarn using npm's resolver), a missing `node_modules`, and a suspected failed lookup.

If there are no in-range updates and no majors, report that and stop.

### 3. Build the project brief

Every analyzer needs the same context, so assemble it once:

- **Runtime**: `engines.node` in `package.json`, `.nvmrc`, `.node-version`, `node --version`, and the Node versions in any CI workflow
- **TypeScript**: version from `package.json`, plus `module`/`moduleResolution`/`target` from `tsconfig.json`
- **Module format**: `"type"` in `package.json`; bundler if any
- **Framework**: React/Vue/Next/Express/etc. and version
- **Verification scripts**: which of `typecheck`, `test`, `build`, `lint` exist in `package.json` `scripts`
- **Source scope**: the globs analyzers should grep (from `$ARGUMENTS` if given, else the project's source dirs)

### 4. Analyze each major in parallel

Skip this step entirely under `minors-only`.

Launch one `major-upgrade-analyzer` per package with `upgrade: "major"`.

**Parallel (default):** issue all `Agent` calls in a single assistant message. Above ~10 majors, batch them ~8 at a time so results stay manageable.

**Sequential (`sequential` token):** one at a time.

Give each analyzer: the package (name, current, latest, type, range), the project brief from step 3, the scope, and an instruction to **return only its verdict block** — not to edit or install anything.

**Verify each result** before using it. A valid block starts with `### <package>:` and contains a `- **Verdict**:` line reading `safe`, `safe-with-edits`, or `wait`. If a result is empty, malformed, or missing the verdict, treat that analyzer as **failed** and put the package in the wait list with `analyzer failed — <cause>` as its reason. Never drop a launched package silently, and never infer a verdict the analyzer didn't state.

### 5. Resolve coupled upgrades

Do this **before** building the plan. Analyzers judge one package each, so a family locked together by exact peer pins produces N separate `wait` verdicts that all say the same thing: *this one can't move alone, orchestrator — sequence us.* Reporting them as N independent hold-backs is wrong twice over: it triples the apparent cost, and it buries the actual decision.

Collect every analyzer's `Coupled with` line. When two or more packages in this run name each other, they form one **group**.

For each group, re-read the member blocks and derive a group verdict by **discounting the mutual-pin gate** — that gate only says "not alone," and inside the group they aren't alone. What's left is the real question:

- Every member's *other* hard gates pass, and the combined breaking-change surface is empty or tiny → the group can be `safe` or `safe-with-edits`, applied as one atomic change.
- Any member has a non-peer gate failure, or the combined surface is large, or the release is too new to trust → the group is `wait`, and the justification is that reason, **never** "it's coupled."

Present and apply a group as a single unit — one plan entry, one line in the report, one install command per workspace listing every member. A partial application of a mutually-pinned family produces an unsatisfiable install.

### 6. One plan, one approval gate

This is the only gate. Present the whole plan — both passes — before anything is written:

```
Plan (nothing applied yet)

In-range updates — N packages, no decision needed (the declared range already allows these)
  chalk       4.1.0 → 4.1.2
  zod         3.20.0 → 3.25.76

Majors — safe (N)
  rimraf      3.0.2 → 6.1.3 (devDependency in: app)  — no breaking change is used here
Majors — safe with edits (N)
  chalk       4.1.2 → 6.0.0  — ESM-only; 2 files need import changes
Majors — hold back (N)
  react       18.3.1 → 19.2.0 — <one-line blocker>
```

Then `AskUserQuestion` once:

- **Apply in-range + safe majors** (recommended)
- **Apply in-range + safe + safe-with-edits** — *offer only when there are safe-with-edits verdicts*
- **Apply in-range only** — skip all majors
- **Cancel** — change nothing

(Under `majors-only` the in-range half of each label drops away; see below.)

Under `minors-only`, the only meaningful options are apply in-range or cancel. Under `majors-only`, drop the in-range half: offer apply safe / apply safe + safe-with-edits / cancel. Present only the options that apply.

Under `dry-run`, **skip this gate entirely** — the plan above is the deliverable. Print it, then the held-back justifications from step 8, and stop.

Apply only what was approved. Never widen the selection on your own; a `wait` package stays untouched even if you disagree with the analyzer.

### 7. Apply

**In-range first** (skip under `majors-only`, or if the user chose "apply safe majors only"):

Run the detected `updateCommand` (e.g. `npm update`, `pnpm update`, `yarn upgrade`).

On yarn berry `updateCommand` is `null` — there is no safe bulk form, since `yarn up '*'` resolves to latest and crosses majors. Apply `updateCommandTemplate` per package for each entry with `inRangeUpdate: true`, substituting `{name}` and `{range}`.

**Then the approved majors:** use `majorInstallTemplate` with `{name}` and `{latest}` substituted (e.g. `npm install chalk@6.0.0`). Prefer one command listing all approved packages when the manager supports it, so the resolver sees them together.

#### Workspace targeting

In a monorepo, `majorInstallTemplate` alone is **wrong and destructive**. A bare `npm install vitest@5.0.0` run at a workspace root adds `vitest` to the *root* manifest as a new `dependencies` entry and leaves the workspace that actually declares it untouched — a silent downgrade of correctness in two directions at once.

When `workspaces` is true, append `workspaceFlagTemplate` for every workspace in the package's `dependents[]`, substituting `{workspace}`:

| Manager | Shape | Example |
| --- | --- | --- |
| npm | flag, repeatable | `npm install vitest@5.0.0 -w client -w api` |
| pnpm | flag | `pnpm update vitest@5.0.0 --filter client` |
| yarn berry | command **prefix**, one workspace per command | `yarn workspace client up vitest@5.0.0` |
| yarn classic | no workspace targeting — `cd` into the workspace directory | — |

A `workspaceFlagTemplate` beginning with `prefix:` is a command prefix, not a trailing flag: strip the `prefix:` and put the rest in front of the command.

Skip the flag for a dependent whose `workspace` matches the root package's own name — that one really does belong to the root manifest.

Verify afterward: `git diff -- package.json '*/package.json'` should show the change landing in the workspaces you targeted and nowhere else. If a package appeared in the root manifest that wasn't there before, you hit exactly the bug above — say so plainly in the report rather than leaving it for the user to find.

npm rewrites `package.json` formatting (indentation, key spacing) whenever it touches a manifest, so a diff can look far larger than the change. Read the dependency lines, not the line count, and don't report a reformat as a change you made.

For `safe-with-edits`, make the code edits the analyzer specified **before** running verification.

### 8. Verify — report, don't revert

Run whichever of these exist, in this order, stopping at the first failure:

1. `<manager> run typecheck` (or `tsc --noEmit` if the script is absent but TypeScript is present)
2. `<manager> run build`
3. `<manager> run test`

Judge each step by its **exit code**, not by scanning output for the word "passed". In a monorepo, `npm test --workspaces` keeps going after a workspace fails and still prints later successes, so a passing line proves nothing about the run as a whole. Report *which* workspace failed, not just that testing failed.

**Report the outcome; do not revert.** If something fails, show the actual error output, name the packages that were applied in this run, and say plainly that `package.json` and the lockfile are modified and the failure is unresolved. Suggest `git diff package.json` and, if they want out, `git checkout package.json <lockfile>` followed by an install — but let the user run it.

This skill never commits.

### 9. Console report

Print, in this order:

```
## Dependency Update — <manager> <version>

### Applied
- In-range (minor/patch): N packages
  - <name> <from> → <to>
- Majors: N packages (coupled families count as one)
  - <name> <from> → <to> [workspaces: client, api] — <one-line reason it was safe>
  - <name> <from> → <to> [workspaces: client] — safe with edits: <files touched>

### Verification
- typecheck: pass / fail / not configured
- build: pass / fail / not configured
- test: pass / fail / not configured  <in a monorepo, name the failing workspace>
<on failure: the actual error output, which packages were applied in this run,
 and an explicit line that nothing was reverted>

### Held back — N majors
#### <name, or "<family> family (<member>, <member>, <member>)"> <current> → <latest>  (confidence NN)
<the analyzer's "Why wait" text: the specific blocker, what would have to change
first, and the rough cost>

### Notes
- Could not analyze — N packages: <names> (<cause, e.g. "not installed, so the
  current version is unknown">)   [omit the line when N is 0]
- <script notes[]: yarn npm-fallback, missing node_modules, suspected failed lookup>
- <analyzers that failed, as "<name> — <cause>">
- <in a monorepo: which workspaces each applied change landed in, and confirmation
  that the root manifest gained nothing it shouldn't have>
- Working tree is modified and uncommitted. Review with `git diff package.json`.
```

The `from → to` versions come from the step-2 snapshot; that's why it is taken before anything is applied.

Every held-back package gets a real justification. "May contain breaking changes" is not a justification, and neither is "it's coupled to another package" — say what the group as a whole is blocked on — if that's all an analyzer returned, say the analysis was inconclusive and why.

## Usage Examples

```
/update-deps
# Snapshot, parallel major analysis, one approval gate, apply both passes, verify

/update-deps dry-run
# Full analysis, nothing changed, plan printed

/update-deps minors-only
# In-range updates only, still behind the approval gate

/update-deps majors-only
# Skip the in-range pass; analyze and apply majors only

/update-deps sequential
# Analyze majors one at a time

/update-deps dry-run src/api
# Analysis only, with analyzers scoped to src/api call sites
```

## Notes

- Each analyzer returns a verdict block, never a report. You own grouping, approval, application, and the final markdown.
- Analyzers are peers and must not invoke each other.
- The confidence floor (≥ 80 for any `safe` verdict) lives inside the analyzer. Don't re-litigate its filtering.
- `major-upgrade-analyzer`'s description tells Claude not to invoke it directly; `/update-deps` is the entry point.
- Overlaps with `library-modernizer` (used by `/deep-audit`) are intentional and different in kind: that agent *reports* version drift as an audit finding; this skill *applies* upgrades.
