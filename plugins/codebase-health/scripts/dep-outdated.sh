#!/usr/bin/env bash
# dep-outdated.sh - Detect the JS package manager and emit a normalized
# outdated-dependency report.
# Part of codebase-health plugin for Claude Code.
#
# Emits a single JSON object on stdout so a skill can inject it verbatim.
# All human-facing chatter goes to stderr.

set -euo pipefail

if [[ -t 2 ]]; then
    RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[0;34m'; NC=$'\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

trap 'echo "${YELLOW}Interrupted${NC}" >&2; exit 130' INT TERM

DIR="$(pwd)"
FORMAT="json"
DETECT_ONLY=false

show_help() {
    cat <<EOF
${GREEN}dep-outdated.sh${NC} - Detect the JS package manager and report outdated dependencies

${YELLOW}USAGE:${NC}
    dep-outdated.sh [OPTIONS]

${YELLOW}OPTIONS:${NC}
    -d, --dir DIR       Project directory (default: current directory)
    -f, --format FMT    Output format: 'json' (default) or 'text'
        --detect        Print package-manager detection only, then exit
    -h, --help          Show this help message

${YELLOW}EXAMPLES:${NC}
    ${GREEN}# Normalized outdated report as JSON${NC}
    dep-outdated.sh

    ${GREEN}# Just find out which package manager and update command to use${NC}
    dep-outdated.sh --detect

    ${GREEN}# Human-readable table${NC}
    dep-outdated.sh --format text

${YELLOW}SUPPORTED MANAGERS:${NC}
    npm, pnpm, yarn (classic and berry)

${YELLOW}DETECTION ORDER:${NC}
    1. \`packageManager\` field in package.json (Corepack)
    2. Lockfile: pnpm-lock.yaml -> pnpm, yarn.lock -> yarn, package-lock.json -> npm
    3. Default: npm

${YELLOW}OUTDATED SOURCE:${NC}
    npm  -> \`npm outdated --json\`
    pnpm -> \`pnpm outdated --format json\` (falls back to npm)
    yarn -> \`npm outdated --json\` (read-only; yarn classic emits NDJSON and
            yarn berry has no native \`outdated\`, so npm's resolver is used
            against the installed node_modules tree). Reported in
            \`outdatedSource\` as "npm-fallback".

${YELLOW}OUTPUT SHAPE (json):${NC}
    {
      "manager": "pnpm",
      "managerVersion": "9.1.0",
      "updateCommand": "pnpm update",
      "updateCommandTemplate": "pnpm update {name}",
      "majorInstallTemplate": "pnpm update {name}@{latest}",
      "lockfile": "pnpm-lock.yaml",
      "workspaces": false,
      "workspaceGlobs": [],
      "outdatedSource": "pnpm",
      "counts": {
        "total": 12, "inRangeUpdate": 7, "major": 5,
        "minorOrPatch": 0, "unknown": 0
      },
      "packages": [
        {
          "name": "react",
          "range": "^18.3.1",
          "current": "18.3.1",
          "wanted": "18.3.1",
          "latest": "19.2.0",
          "type": "dependencies",
          "dev": false,
          "direct": true,
          "dependents": [
            { "workspace": "client", "range": "^18.3.1", "type": "dependencies" }
          ],
          "upgrade": "major",
          "inRangeUpdate": false,
          "deprecated": false
        }
      ],
      "notes": []
    }

${YELLOW}THE TWO AXES:${NC}
    \`upgrade\` is the gap from the installed version to \`latest\`:
      "major"  major differs, or major is 0 and the minor differs
               (0.x minors are breaking under semver)
      "minor" / "patch" / "unknown"
    \`inRangeUpdate\` is true when \`wanted\` differs from \`current\` - the
    declared range already permits the move, so it needs no decision.

    These overlap on purpose. chalk 4.1.0 with range ^4.1.0 and latest 6.0.0 is
    both \`inRangeUpdate: true\` (-> 4.1.2) and \`upgrade: "major"\` (-> 6.0.0).
    \`counts.inRangeUpdate\` and \`counts.major\` therefore do not sum to
    \`counts.total\`.

${YELLOW}WORKSPACES:${NC}
    In a workspace root, \`npm outdated\` reports the union across every
    workspace and names the owner in \`dependent\`. The script reads every
    workspace manifest and resolves each finding back to the package that
    declared it, so \`dependents[]\` carries the real range and section per
    workspace. Reading only the root manifest would report a workspace
    devDependency as a prod dependency.

    \`type\` is the strictest section across all consumers (a package that is a
    prod dependency anywhere is reported as one); \`dev\` is true only when
    every consumer declares it as a devDependency. \`range\` is null when
    workspaces disagree - read \`dependents[]\` for the per-workspace ranges.
    More than one entry in \`dependents\` means an upgrade must touch each.

${YELLOW}NOTES:${NC}
    - Requires node (used for JSON normalization) and the detected manager.
    - \`updateCommand\` is null on yarn berry, which has no safe bulk in-range
      form; use \`updateCommandTemplate\` per package there.
    - Never modifies files. Read-only.
    - Exit code is 0 even when dependencies are outdated.
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo "${RED}Error: -d/--dir requires a directory path${NC}" >&2; exit 1
            fi
            DIR="$2"; shift 2 ;;
        -f|--format)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo "${RED}Error: -f/--format requires 'json' or 'text'${NC}" >&2; exit 1
            fi
            FORMAT="$2"
            if [[ "$FORMAT" != "json" && "$FORMAT" != "text" ]]; then
                echo "${RED}Error: Format must be 'json' or 'text'${NC}" >&2; exit 1
            fi
            shift 2 ;;
        --detect)
            DETECT_ONLY=true; shift ;;
        -h|--help)
            show_help; exit 0 ;;
        -*)
            echo "${RED}Error: Unknown option: $1${NC}" >&2
            echo "Use -h or --help for usage information" >&2; exit 1 ;;
        *)
            echo "${RED}Error: Unexpected argument: $1${NC}" >&2; exit 1 ;;
    esac
done

if [[ ! -d "$DIR" ]]; then
    echo "${RED}Error: Directory does not exist: $DIR${NC}" >&2
    exit 1
fi

if [[ ! -f "$DIR/package.json" ]]; then
    echo "${RED}Error: No package.json in $DIR${NC}" >&2
    echo "This script handles JavaScript/TypeScript projects only." >&2
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "${RED}Error: node is required for JSON normalization but was not found${NC}" >&2
    exit 1
fi

NOTES=()

# ---------------------------------------------------------------- detection --
PM=""

# 1. Corepack `packageManager` field wins.
PM_FIELD="$(node -e 'try{const p=require(process.argv[1]+"/package.json");process.stdout.write(String(p.packageManager||""))}catch(e){}' "$DIR" 2>/dev/null || true)"
if [[ -n "$PM_FIELD" ]]; then
    case "$PM_FIELD" in
        pnpm@*) PM="pnpm" ;;
        yarn@*) PM="yarn" ;;
        npm@*)  PM="npm" ;;
    esac
fi

# 2. Lockfile.
LOCKFILE=""
if [[ -f "$DIR/pnpm-lock.yaml" ]]; then
    LOCKFILE="pnpm-lock.yaml"; [[ -z "$PM" ]] && PM="pnpm"
elif [[ -f "$DIR/yarn.lock" ]]; then
    LOCKFILE="yarn.lock"; [[ -z "$PM" ]] && PM="yarn"
elif [[ -f "$DIR/package-lock.json" ]]; then
    LOCKFILE="package-lock.json"; [[ -z "$PM" ]] && PM="npm"
elif [[ -f "$DIR/npm-shrinkwrap.json" ]]; then
    LOCKFILE="npm-shrinkwrap.json"; [[ -z "$PM" ]] && PM="npm"
fi

# 3. Default.
if [[ -z "$PM" ]]; then
    PM="npm"
    NOTES+=("No lockfile or packageManager field found; defaulting to npm.")
fi

if ! command -v "$PM" &> /dev/null; then
    echo "${RED}Error: detected package manager '$PM' is not installed${NC}" >&2
    echo "Install it, or run with a directory whose lockfile matches an available manager." >&2
    exit 1
fi

PM_VERSION="$("$PM" --version 2>/dev/null | tr -d '\r\n' || echo "unknown")"

YARN_MAJOR=""
if [[ "$PM" == "yarn" ]]; then
    YARN_MAJOR="${PM_VERSION%%.*}"
fi

# Commands for step 1 (in-range minor/patch) and step 2 (explicit major).
# `updateCommand` upgrades every in-range dep at once; when a manager has no
# safe bulk form it is null and `updateCommandTemplate` must be used per package.
case "$PM" in
    npm)
        UPDATE_CMD="npm update"
        UPDATE_TMPL="npm update {name}"
        MAJOR_TMPL="npm install {name}@{latest}"
        WS_FLAG_TMPL="-w {workspace}"
        ;;
    pnpm)
        UPDATE_CMD="pnpm update"
        UPDATE_TMPL="pnpm update {name}"
        # `pnpm update <pkg>@<ver>` bumps in place and keeps the package in its
        # existing section; `pnpm add` can move a devDependency to dependencies.
        MAJOR_TMPL="pnpm update {name}@{latest}"
        WS_FLAG_TMPL="--filter {workspace}"
        ;;
    yarn)
        if [[ "$YARN_MAJOR" == "1" ]]; then
            UPDATE_CMD="yarn upgrade"
            UPDATE_TMPL="yarn upgrade {name}"
            MAJOR_TMPL="yarn upgrade {name}@{latest}"
            WS_FLAG_TMPL=""
        else
            # `yarn up '*'` resolves to latest and would cross majors, so there
            # is no safe bulk in-range command on Berry: go package by package
            # with the declared range.
            UPDATE_CMD=""
            UPDATE_TMPL="yarn up '{name}@{range}'"
            MAJOR_TMPL="yarn up {name}@{latest}"
            # Berry targets a workspace with a command prefix, not a flag.
            WS_FLAG_TMPL="prefix:yarn workspace {workspace}"
            NOTES+=("yarn berry has no safe bulk in-range update (\`yarn up '*'\` jumps majors); apply in-range updates per package with updateCommandTemplate.")
        fi ;;
esac

# Workspace detection.
WORKSPACE_GLOBS="$(node -e '
try {
  const fs = require("fs");
  const dir = process.argv[1];
  const p = JSON.parse(fs.readFileSync(dir + "/package.json", "utf8"));
  let globs = [];
  if (Array.isArray(p.workspaces)) globs = p.workspaces;
  else if (p.workspaces && Array.isArray(p.workspaces.packages)) globs = p.workspaces.packages;
  if (fs.existsSync(dir + "/pnpm-workspace.yaml")) {
    const txt = fs.readFileSync(dir + "/pnpm-workspace.yaml", "utf8");
    for (const line of txt.split("\n")) {
      const m = line.match(/^\s*-\s*["\x27]?([^"\x27#]+?)["\x27]?\s*$/);
      if (m) globs.push(m[1].trim());
    }
  }
  process.stdout.write(JSON.stringify([...new Set(globs)]));
} catch (e) { process.stdout.write("[]"); }
' "$DIR" 2>/dev/null || echo '[]')"

HAS_WORKSPACES=false
[[ "$WORKSPACE_GLOBS" != "[]" ]] && HAS_WORKSPACES=true

if [[ "$DETECT_ONLY" == "true" ]]; then
    MANAGER="$PM" MANAGER_VERSION="$PM_VERSION" UPDATE_COMMAND="$UPDATE_CMD" \
    UPDATE_TEMPLATE="$UPDATE_TMPL" MAJOR_TEMPLATE="$MAJOR_TMPL" \
    WS_FLAG_TEMPLATE="${WS_FLAG_TMPL:-}" LOCKFILE_NAME="$LOCKFILE" WS_GLOBS="$WORKSPACE_GLOBS" HAS_WS="$HAS_WORKSPACES" \
    node -e '
      process.stdout.write(JSON.stringify({
        manager: process.env.MANAGER,
        managerVersion: process.env.MANAGER_VERSION,
        updateCommand: process.env.UPDATE_COMMAND || null,
        updateCommandTemplate: process.env.UPDATE_TEMPLATE,
        majorInstallTemplate: process.env.MAJOR_TEMPLATE,
        workspaceFlagTemplate: process.env.WS_FLAG_TEMPLATE || null,
        lockfile: process.env.LOCKFILE_NAME || null,
        workspaces: process.env.HAS_WS === "true",
        workspaceGlobs: JSON.parse(process.env.WS_GLOBS)
      }, null, 2) + "\n");
    '
    exit 0
fi

# ----------------------------------------------------------------- outdated --
RAW=""
SOURCE=""

run_npm_outdated() {
    (cd "$DIR" && npm outdated --json 2>/dev/null) || true
}

case "$PM" in
    npm)
        SOURCE="npm"
        RAW="$(run_npm_outdated)"
        ;;
    pnpm)
        SOURCE="pnpm"
        RAW="$( (cd "$DIR" && pnpm outdated --format json 2>/dev/null) || true )"
        if [[ -z "$RAW" ]] || ! R="$RAW" node -e 'JSON.parse(process.env.R||"")' 2>/dev/null; then
            NOTES+=("pnpm outdated --format json produced no usable JSON; fell back to npm outdated.")
            SOURCE="npm-fallback"
            RAW="$(run_npm_outdated)"
        fi
        ;;
    yarn)
        SOURCE="npm-fallback"
        if [[ "$YARN_MAJOR" == "1" ]]; then
            NOTES+=("yarn classic emits NDJSON from \`yarn outdated\`; used \`npm outdated --json\` against the installed node_modules tree instead.")
        else
            NOTES+=("yarn berry has no native \`outdated\` command; used \`npm outdated --json\` against the installed node_modules tree instead.")
        fi
        RAW="$(run_npm_outdated)"
        ;;
esac

if [[ -z "$RAW" ]]; then
    # `npm outdated` / `pnpm outdated` print a literal `{}` when nothing is
    # outdated, so empty stdout means the command itself failed.
    NOTES+=("The outdated command produced no output; it may have failed (registry unreachable, or dependencies not installed). Treating the result as empty.")
    RAW="{}"
fi

if [[ ! -d "$DIR/node_modules" ]]; then
    NOTES+=("node_modules is missing; \`current\` versions may be null. Install dependencies first for accurate results.")
fi

NOTES_JSON="$(NOTES_RAW="$(printf '%s\n' "${NOTES[@]+"${NOTES[@]}"}")" node -e '
  const raw = process.env.NOTES_RAW || "";
  process.stdout.write(JSON.stringify(raw.split("\n").filter(Boolean)));
')"

# EDITING THE NODE BLOCK BELOW: it is a single-quoted shell string, so a literal
# apostrophe anywhere inside it (including in a comment) terminates the string
# and breaks the script at runtime. Use \x27 in JS string literals, and avoid
# apostrophes in comments. `bash -n` does NOT catch this -- it passes on a script
# that then fails inside the command substitution, so always run the script once
# after editing here.
RESULT="$(
  OUTDATED_RAW="$RAW" PKG_DIR="$DIR" MANAGER="$PM" MANAGER_VERSION="$PM_VERSION" \
  UPDATE_COMMAND="$UPDATE_CMD" UPDATE_TEMPLATE="$UPDATE_TMPL" MAJOR_TEMPLATE="$MAJOR_TMPL" \
  WS_FLAG_TEMPLATE="${WS_FLAG_TMPL:-}" LOCKFILE_NAME="$LOCKFILE" WS_GLOBS="$WORKSPACE_GLOBS" \
  HAS_WS="$HAS_WORKSPACES" OUTDATED_SOURCE="$SOURCE" NOTES_JSON="$NOTES_JSON" \
  node -e '
const fs = require("fs");
const dir = process.env.PKG_DIR;
const notes = JSON.parse(process.env.NOTES_JSON || "[]");

let raw = {};
try { raw = JSON.parse(process.env.OUTDATED_RAW || "{}"); }
catch (e) { notes.push("Could not parse the package manager\x27s outdated output as JSON; reporting zero packages."); }

const DEP_FIELDS = ["dependencies", "devDependencies", "optionalDependencies", "peerDependencies"];

// In a workspace root, `npm outdated` reports the union across every workspace
// and names the owner in `dependent`. Reading only the root manifest would
// mislabel a workspace devDependency as a prod dependency, so collect every
// manifest and resolve each finding against the workspace that declared it.
const readJson = (f) => { try { return JSON.parse(fs.readFileSync(f, "utf8")); } catch (e) { return null; } };
const rootPkg = readJson(dir + "/package.json") || {};

const expandGlob = (glob) => {
  if (!glob.includes("*")) return [glob];
  const slash = glob.lastIndexOf("/");
  const parent = slash === -1 ? "" : glob.slice(0, slash);
  const leaf = slash === -1 ? glob : glob.slice(slash + 1);
  if (leaf !== "*") return [];  // only simple single-level globs
  const base = parent ? dir + "/" + parent : dir;
  try {
    return fs.readdirSync(base, { withFileTypes: true })
      .filter((e) => e.isDirectory() && !e.name.startsWith("."))
      .map((e) => (parent ? parent + "/" : "") + e.name);
  } catch (e) { return []; }
};

// npm names the owner in `dependent`, but for the ROOT package it uses the
// directory basename rather than the package name -- these differ often enough
// that matching on only one silently drops the match and mislabels the section.
// Match on either, for every manifest.
const basename = (pth) => pth.replace(/\/+$/, "").split("/").pop();
const aliasesOf = (name, relDir) =>
  [...new Set([name, relDir ? basename(relDir) : basename(dir)].filter(Boolean))];

const manifests = [{
  label: rootPkg.name || basename(dir),
  aliases: aliasesOf(rootPkg.name, null),
  pkg: rootPkg,
  root: true
}];
for (const glob of JSON.parse(process.env.WS_GLOBS || "[]")) {
  for (const rel of expandGlob(glob)) {
    const wp = readJson(dir + "/" + rel + "/package.json");
    if (wp) manifests.push({ label: wp.name || basename(rel), aliases: aliasesOf(wp.name, rel), dir: rel, pkg: wp });
  }
}

// name -> [{ workspace, dir, range, type }]
const declaredBy = {};
for (const m of manifests) {
  for (const field of DEP_FIELDS) {
    for (const [name, range] of Object.entries(m.pkg[field] || {})) {
      (declaredBy[name] ||= []).push({
        workspace: m.label, aliases: m.aliases, dir: m.dir || null,
        root: m.root === true, range, type: field
      });
    }
  }
}

const parse = (v) => {
  if (!v || typeof v !== "string") return null;
  const m = v.trim().replace(/^[v=]/, "").match(/^(\d+)\.(\d+)\.(\d+)/);
  return m ? { major: +m[1], minor: +m[2], patch: +m[3] } : null;
};

// Size of the gap from the installed version to `latest`. Semver: a major bump
// is breaking, and so is a minor bump while the major is 0.
const gapToLatest = (current, latest) => {
  const c = parse(current), l = parse(latest);
  if (!c || !l) return "unknown";
  if (l.major !== c.major) return "major";
  if (c.major === 0 && l.minor !== c.minor) return "major";
  if (l.minor !== c.minor) return "minor";
  if (l.patch !== c.patch) return "patch";
  return "current";
};

const packages = [];
for (const [name, entryRaw] of Object.entries(raw)) {
  // npm >= 9 emits an array when several workspaces depend on one package.
  const entries = (Array.isArray(entryRaw) ? entryRaw : [entryRaw])
    .filter((e) => e && typeof e === "object");
  if (!entries.length) continue;

  const first = entries[0];
  const current = first.current || null;
  const latest = first.latest || null;
  const wanted = first.wanted || null;

  // Resolve every consumer: npm gives `dependent` (the workspace name), pnpm
  // gives `dependencyType` for the single root package.
  const declared = declaredBy[name] || [];
  let dependents = [];
  for (const e of entries) {
    const match = e.dependent
      ? declared.find((d) => d.aliases && d.aliases.includes(e.dependent))
      : null;
    dependents.push({
      // Report the canonical package name, not whatever alias npm happened to use.
      workspace: (match && match.workspace) || e.dependent || (declared[0] && declared[0].workspace) || null,
      root: match ? match.root : null,
      range: match ? match.range : null,
      type: (match && match.type) || e.type || e.dependencyType || null
    });
  }
  // Nothing matched by `dependent` (single-package repo, or pnpm): fall back to
  // whatever the manifests declared.
  if (dependents.every((d) => !d.type) && declared.length) {
    dependents = declared.map((d) => ({ workspace: d.workspace, root: d.root, range: d.range, type: d.type }));
  }
  for (const d of dependents) if (!d.type) d.type = "dependencies";

  const types = [...new Set(dependents.map((d) => d.type))];
  const ranges = [...new Set(dependents.map((d) => d.range).filter(Boolean))];
  // A package that is a prod dependency anywhere is held to the prod bar.
  const type = types.find((t) => t !== "devDependencies") || types[0] || "dependencies";

  const upgrade = gapToLatest(current, latest);
  // `wanted` is what the declared range already permits, so moving there is a
  // no-decision update. A package can be both in-range updatable AND a major
  // behind (e.g. 4.1.0 -> wanted 4.1.2 -> latest 6.0.0); these are independent.
  const inRangeUpdate = Boolean(current && wanted && wanted !== current);
  if (upgrade === "current" && !inRangeUpdate) continue;

  packages.push({
    name,
    range: ranges.length === 1 ? ranges[0] : null,
    current,
    wanted,
    latest,
    type,
    dev: dependents.every((d) => d.type === "devDependencies"),
    direct: declared.length > 0,
    // Every workspace that declares this package, each with its own range and
    // section. More than one entry means an upgrade must touch each of them.
    dependents,
    upgrade,
    inRangeUpdate,
    deprecated: entries.some((e) => e.isDeprecated === true)
  });
}

packages.sort((a, b) => {
  const rank = (p) => (p.upgrade === "major" ? 0 : p.upgrade === "unknown" ? 1 : 2);
  return rank(a) - rank(b) || a.name.localeCompare(b.name);
});

const counts = {
  total: packages.length,
  // Overlapping on purpose: inRangeUpdate and major describe different axes.
  inRangeUpdate: packages.filter((p) => p.inRangeUpdate).length,
  major: packages.filter((p) => p.upgrade === "major").length,
  minorOrPatch: packages.filter((p) => p.upgrade === "minor" || p.upgrade === "patch").length,
  unknown: packages.filter((p) => p.upgrade === "unknown").length
};

process.stdout.write(JSON.stringify({
  manager: process.env.MANAGER,
  managerVersion: process.env.MANAGER_VERSION,
  updateCommand: process.env.UPDATE_COMMAND || null,
  updateCommandTemplate: process.env.UPDATE_TEMPLATE,
  majorInstallTemplate: process.env.MAJOR_TEMPLATE,
  workspaceFlagTemplate: process.env.WS_FLAG_TEMPLATE || null,
  lockfile: process.env.LOCKFILE_NAME || null,
  workspaces: process.env.HAS_WS === "true",
  workspaceGlobs: JSON.parse(process.env.WS_GLOBS),
  outdatedSource: process.env.OUTDATED_SOURCE,
  counts,
  packages,
  notes
}, null, 2) + "\n");
'
)"

if [[ "$FORMAT" == "json" ]]; then
    printf '%s\n' "$RESULT"
    exit 0
fi

# ------------------------------------------------------------------- text ----
printf '%s' "$RESULT" | RESULT_IS_STDIN=1 node -e '
let buf = "";
process.stdin.on("data", (d) => (buf += d));
process.stdin.on("end", () => {
  const r = JSON.parse(buf);
  const pad = (s, n) => String(s == null ? "-" : s).padEnd(n);
  console.log(`Package manager: ${r.manager} ${r.managerVersion}` + (r.lockfile ? ` (${r.lockfile})` : ""));
  console.log(`Update command:  ${r.updateCommand || "(none - use per-package: " + r.updateCommandTemplate + ")"}`);
  console.log(`Outdated source: ${r.outdatedSource}`);
  if (r.workspaces) console.log(`Workspaces:      yes -> ${r.workspaceGlobs.join(", ")}`);
  console.log("");
  if (!r.packages.length) { console.log("All dependencies are up to date."); }
  else {
    const ws = (p) => {
      const names = [...new Set((p.dependents || []).map((d) => d.workspace).filter(Boolean))];
      return names.length ? names.join(",") : "-";
    };
    const showWs = r.workspaces;
    console.log(`${pad("PACKAGE", 34)}${pad("CURRENT", 12)}${pad("WANTED", 12)}${pad("LATEST", 12)}${pad("GAP", 9)}${pad("IN-RANGE", 10)}${pad("TYPE", 20)}${showWs ? "WORKSPACE" : ""}`);
    for (const p of r.packages) {
      console.log(`${pad(p.name, 34)}${pad(p.current, 12)}${pad(p.wanted, 12)}${pad(p.latest, 12)}${pad(p.upgrade, 9)}${pad(p.inRangeUpdate ? "yes" : "no", 10)}${pad(p.type, 20)}${showWs ? ws(p) : ""}`);
    }
    console.log("");
    console.log(`Total: ${r.counts.total}  in-range updates: ${r.counts.inRangeUpdate}  major behind: ${r.counts.major}  minor/patch behind: ${r.counts.minorOrPatch}  unknown: ${r.counts.unknown}`);
  }
  if (r.notes.length) { console.log(""); console.log("Notes:"); for (const n of r.notes) console.log(`  - ${n}`); }
});
'
