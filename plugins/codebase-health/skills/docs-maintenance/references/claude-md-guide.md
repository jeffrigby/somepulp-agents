# CLAUDE.md Optimization Guide

Reference for creating and maintaining CLAUDE.md files, based on official Claude Code documentation.

## What CLAUDE.md Is

CLAUDE.md is a markdown file that Claude Code reads at the start of every conversation. It provides persistent context — coding standards, architecture decisions, preferred libraries, workflow rules, and build commands.

CLAUDE.md is **context, not enforcement**. Claude reads it and tries to follow it, but there's no guarantee of strict compliance. The more specific and concise the instructions, the more consistently Claude follows them. For actions that must happen every time with zero exceptions, use **hooks** instead (see Hooks vs CLAUDE.md below).

## Critical Constraints

### Size Limit: Target Under 200 Lines

Files over 200 lines consume more context and reduce adherence. If instructions are growing large, split them using:
- `@path` imports to reference other files
- `.claude/rules/` for modular, path-specific rules

**For each line, ask: "Would removing this cause Claude to make mistakes?" If not, cut it.**

### Pruning Is Essential

If Claude already does something correctly without the instruction, delete it or convert it to a hook. Bloated CLAUDE.md files cause Claude to **ignore actual instructions**.

Treat CLAUDE.md like code: review it when things go wrong, prune it regularly, and test changes by observing whether Claude's behavior actually shifts.

## File Hierarchy

CLAUDE.md files can live in several locations, loaded in this order. More specific locations take precedence:

| Scope | Location | Purpose | Shared With |
|-------|----------|---------|-------------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Org-wide instructions managed by IT/DevOps. **Cannot be excluded.** | All users in org |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you (all projects) |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared project instructions | Team via source control |
| **Parent directories** | `CLAUDE.md` in ancestor directories above cwd | Useful for monorepos | Depends on location |
| **Child directories** | `CLAUDE.md` in subdirectories below cwd | Loaded on-demand when Claude reads files there | Depends on location |

### Loading Behavior

- CLAUDE.md files **above** the working directory load in full at launch
- CLAUDE.md files in **subdirectories** load on-demand when Claude reads files in those directories
- Claude walks **up** the directory tree from cwd, stopping before the filesystem root
- User-level rules (`~/.claude/rules/`) load **before** project rules, giving project rules higher priority
- CLAUDE.md **fully survives** `/compact` — after compaction, Claude re-reads it from disk
- The `--add-dir` flag gives access to additional directories, but their CLAUDE.md files are **not** loaded unless `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` is set
- In monorepos, use `claudeMdExcludes` in settings to skip irrelevant CLAUDE.md files. Managed policy files cannot be excluded.

### CLAUDE.local.md (Deprecated)

`CLAUDE.local.md` is deprecated. Use `~/.claude/CLAUDE.md` for personal preferences, or import personal files via `@` syntax:
```markdown
@~/.claude/my-project-overrides.md
```

## @path Imports

CLAUDE.md files can import additional files using `@path/to/import` syntax:

```markdown
See @README.md for project overview and @package.json for available npm commands.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

**Rules:**
- Both relative and absolute paths allowed
- Relative paths resolve relative to the file containing the import
- Imported files can recursively import other files (max depth: 5)
- First time external imports are encountered, Claude shows an approval dialog

## .claude/rules/ Directory

For larger projects, organize instructions into modular, topic-specific files:

```
your-project/
├── .claude/
│   ├── CLAUDE.md           # Main project instructions
│   └── rules/
│       ├── code-style.md   # Code style guidelines
│       ├── testing.md      # Testing conventions
│       └── security.md     # Security requirements
```

### Path-Specific Rules

Rules can be scoped to specific files using YAML frontmatter:

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules

- All API endpoints must include input validation
```

Rules without a `paths` field are loaded unconditionally. Path-scoped rules trigger when Claude reads matching files. Supports symlinks for sharing rules across projects.

## What to Include vs Exclude

| Include | Exclude |
|---------|---------|
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners | Detailed API documentation (link to docs instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to the project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

## Writing Effective Instructions

### Specificity
Write instructions that are concrete enough to verify:
- "Use 2-space indentation" — not "Format code properly"
- "Run `npm test` before committing" — not "Test your changes"
- "API handlers live in `src/api/handlers/`" — not "Keep files organized"

### Structure
Use markdown headers and bullets to group related instructions. Organized sections are easier to follow than dense paragraphs.

### Emphasis
Add `IMPORTANT` or `YOU MUST` to critical instructions to improve adherence. Use sparingly — overuse dilutes impact.

### Consistency
If two rules contradict each other, Claude may pick one arbitrarily. Review periodically to remove outdated or conflicting instructions across CLAUDE.md files and `.claude/rules/`.

### Check Into Git
CLAUDE.md should be checked into git so the team can contribute. The file compounds in value over time.

## Hooks vs CLAUDE.md

Unlike CLAUDE.md instructions which are **advisory**, hooks are **deterministic** and guarantee execution. Use the right mechanism:

| Use CLAUDE.md for | Use hooks for |
|-------------------|---------------|
| Coding conventions and style preferences | Linting after every edit |
| Architecture guidance | Blocking writes to protected directories |
| Common gotchas and anti-patterns | Mandatory pre-commit checks |
| Build/test commands | Enforcing tool restrictions |
| Project context and rationale | Actions that must happen every time with zero exceptions |

**Key rule:** If Claude keeps failing to follow a CLAUDE.md instruction despite it being clearly written, consider converting it to a hook instead.

## Recommended Sections

Not every project needs all of these. Include only sections relevant to your project, and only content that Claude couldn't figure out by reading the code:

1. **Project Overview** — What it does, key technologies
2. **Commands** — Exact build/test/run commands with descriptions
3. **Project Structure** — Key directories and files (only non-obvious ones)
4. **Architecture** — How components connect, data flow patterns
5. **Conventions** — Naming patterns, style preferences that differ from defaults
6. **Common Pitfalls** — Things Claude often gets wrong in this codebase
7. **Dependencies** — Required environment, environment variables

Keep each section concise. If a section would exceed ~30 lines, consider moving details to `.claude/rules/` or a referenced file via `@path` import.

## Anti-Patterns

From the official documentation, these are the most common failure modes:

### 1. The Over-Specified CLAUDE.md
If your CLAUDE.md is too long, Claude ignores half of it because important rules get lost in the noise.
**Fix:** Ruthlessly prune. If Claude already does something correctly without the instruction, delete it.

### 2. Too Many Post-Task Rules
Having many "always do X after Y" rules in CLAUDE.md leads to inconsistent compliance (e.g., "15+ critical rules" where Claude "forgets" post-feature documentation tasks).
**Fix:** Convert must-execute post-task actions to hooks, which are deterministic.

### 3. Contradicting Instructions
If two CLAUDE.md files or rules give conflicting guidance, Claude picks one arbitrarily.
**Fix:** Review all CLAUDE.md files and `.claude/rules/` periodically for conflicts.

### 4. Vague Instructions
"Format code nicely" gets ignored; "Use 2-space indentation" gets followed.
**Fix:** Make every instruction specific enough that compliance is objectively verifiable.

### 5. Frequently-Changing Information
Information that changes often will become stale and cause contradictions.
**Fix:** Keep volatile data out of CLAUDE.md. Link to authoritative sources instead.

### 6. Inlined Documentation
Pasting API docs, full schemas, or long examples bloats the file.
**Fix:** Use `@path` imports or link to external docs.

### 7. Using CLAUDE.md for Hook-Worthy Rules
If something must happen 100% of the time (like running a linter after edits), CLAUDE.md is the wrong tool.
**Fix:** Use hooks for guaranteed execution.

## Generating and Debugging CLAUDE.md

- Run `/init` to generate a starter CLAUDE.md from the codebase. If one exists, `/init` suggests improvements.
- Run `/memory` to verify which CLAUDE.md files are actually being loaded.
- Run `/status` to see which settings sources are active.

## Troubleshooting

### Claude Isn't Following CLAUDE.md
1. Run `/memory` to verify files are loaded
2. Run `/status` to see active settings sources
3. Check the file is in a location that gets loaded (see hierarchy)
4. Make instructions more specific
5. Look for conflicting instructions across files
6. If over 200 lines, prune — the rule may be getting lost in noise

### CLAUDE.md Is Too Large
- Move detailed content into `@path` imported files
- Split instructions into `.claude/rules/` files
- Ruthlessly prune instructions Claude follows without being told
- Convert must-execute rules to hooks

### Instructions Lost After /compact
CLAUDE.md fully survives compaction. If an instruction disappeared, it was given only in conversation, not written to CLAUDE.md.

## Monorepo Configuration

### claudeMdExcludes Setting

Skip irrelevant CLAUDE.md files by adding to `.claude/settings.local.json`:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match against absolute file paths using glob syntax. Managed policy CLAUDE.md files cannot be excluded.

## Maintenance Checklist

When updating CLAUDE.md, verify:

- [ ] Under 200 lines (or split with @imports / rules)
- [ ] All commands still work
- [ ] File paths are accurate
- [ ] No instructions Claude follows without being told (prune these)
- [ ] No conflicting instructions across files
- [ ] Conventions match current code
- [ ] Removed features removed from docs
- [ ] New features documented
- [ ] Must-execute rules use hooks, not CLAUDE.md
- [ ] Critical rules use `IMPORTANT` sparingly