# CLAUDE.md Optimization Guide

This guide covers how to create and maintain CLAUDE.md files based on the official Claude Code documentation.

## What CLAUDE.md Is

CLAUDE.md is a markdown file that Claude Code reads at the start of every conversation. It provides persistent context — coding standards, architecture decisions, preferred libraries, workflow rules, and build commands.

CLAUDE.md is **context, not enforcement**. Claude reads it and tries to follow it, but there's no guarantee of strict compliance. The more specific and concise the instructions, the more consistently Claude follows them.

## Critical Constraints

### Size Limit: Target Under 200 Lines

Files over 200 lines consume more context and reduce adherence. If instructions are growing large, split them using:
- `@path` imports to reference other files
- `.claude/rules/` for modular, path-specific rules

**For each line, ask: "Would removing this cause Claude to make mistakes?" If not, cut it.**

### Pruning Is Essential

If Claude already does something correctly without the instruction, delete it or convert it to a hook. Bloated CLAUDE.md files cause Claude to **ignore actual instructions**.

Treat CLAUDE.md like code: review it when things go wrong, prune it regularly, and test changes by observing whether Claude's behavior actually shifts.

## File Locations

CLAUDE.md files can live in several locations, each with different scope. More specific locations take precedence:

| Scope | Location | Purpose | Shared With |
|-------|----------|---------|-------------|
| **Managed policy** | `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS) | Org-wide instructions managed by IT/DevOps | All users in org |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared project instructions | Team via source control |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Just you (all projects) |
| **Local** | `./CLAUDE.local.md` | Personal project-specific, not in git | Just you (current project) |

### Loading Behavior

- CLAUDE.md files **above** the working directory load in full at launch
- CLAUDE.md files in **subdirectories** load on-demand when Claude reads files in those directories
- CLAUDE.md **fully survives** `/compact` — after compaction, Claude re-reads it from disk
- In monorepos, use `claudeMdExcludes` setting to skip irrelevant CLAUDE.md files from other teams

### CLAUDE.local.md

For personal project-specific preferences that shouldn't be checked into git:
- Automatically loaded at session start
- Automatically added to `.gitignore`
- Good for: sandbox URLs, preferred test data, personal tooling shortcuts

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
- Use the standard error response format
- Include OpenAPI documentation comments
```

Rules without a `paths` field are loaded unconditionally. Path-scoped rules trigger when Claude reads matching files.

### Glob Patterns

| Pattern | Matches |
|---------|---------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` |
| `*.md` | Markdown files in project root |
| `src/components/*.tsx` | React components in a specific directory |
| `src/**/*.{ts,tsx}` | Multiple extensions via brace expansion |

### Symlinks

`.claude/rules/` supports symlinks for sharing rules across projects:

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
ln -s ~/company-standards/security.md .claude/rules/security.md
```

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

### Structure
Use markdown headers and bullets to group related instructions. Organized sections are easier to follow than dense paragraphs.

### Specificity
Write instructions that are concrete enough to verify:

- "Use 2-space indentation" instead of "Format code properly"
- "Run `npm test` before committing" instead of "Test your changes"
- "API handlers live in `src/api/handlers/`" instead of "Keep files organized"

### Emphasis
Add `IMPORTANT` or `YOU MUST` to critical instructions to improve adherence. Use sparingly.

### Consistency
If two rules contradict each other, Claude may pick one arbitrarily. Review periodically to remove outdated or conflicting instructions.

### Check Into Git
CLAUDE.md should be checked into git so the team can contribute. The file compounds in value over time.

## Generating CLAUDE.md

Run `/init` to generate a starter CLAUDE.md automatically. Claude analyzes the codebase and creates a file with build commands, test instructions, and project conventions it discovers. If a CLAUDE.md already exists, `/init` suggests improvements rather than overwriting it.

## Required Sections

Every project CLAUDE.md should include these sections:

### 1. Project Overview

```markdown
## Project Overview

[Project name] is a [type of application] that [primary purpose].

Key technologies:
- [Framework/language]
- [Major dependencies]
- [Infrastructure/deployment]
```

### 2. Build and Test Commands

```markdown
## Commands

### Development
- `npm run dev` - Start development server on port 3000
- `npm run build` - Create production build

### Testing
- `npm test` - Run all tests
- `npm run test:unit` - Run unit tests only
```

Key points:
- Use exact command syntax
- Include what each command does
- Note prerequisites ("requires running server")

### 3. Key File Locations

```markdown
## Project Structure

Key files:
- `src/app/layout.tsx` - Root layout with providers
- `src/lib/db.ts` - Database connection singleton
- `src/services/auth.ts` - Authentication logic
```

### 4. Architecture Overview

```markdown
## Architecture

### Data Flow
1. API routes in `src/app/api/` handle requests
2. Routes call services in `src/services/`
3. Services use Prisma client from `src/lib/db.ts`

### Key Patterns
- All database access goes through service layer
- Components fetch data using React Query
```

### 5. Coding Conventions

```markdown
## Conventions

### Naming
- Components: PascalCase (`UserProfile.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- Constants: SCREAMING_SNAKE_CASE

### Patterns
- Use `async/await` over `.then()` chains
- Prefer named exports over default exports
```

### 6. Common Pitfalls

```markdown
## Common Pitfalls

### Do NOT
- Import from `@/lib/db` in client components (server-only)
- Use `any` type - always define proper types
- Skip error boundaries in page components

### Watch Out For
- The `user` table uses soft deletes (`deleted_at` column)
- Environment variables need `NEXT_PUBLIC_` prefix for client access
```

### 7. Tool and Dependency Notes

```markdown
## Dependencies

### Required Environment
- Node.js 20+
- PostgreSQL 15+

### Environment Variables
- `DATABASE_URL` - PostgreSQL connection string
- `STRIPE_SECRET_KEY` - Stripe API key (test mode ok for dev)
```

## AI-Friendly Writing Patterns

### Use Imperative Language

**Good:** "Run `npm test` before committing"
**Bad:** "You might want to run tests"

### Be Specific About Paths

**Good:** "Edit `src/components/Button/Button.tsx`"
**Bad:** "Edit the Button component"

### Include Concrete Examples

**Good:**
```markdown
Create API routes following this pattern:
```typescript
export async function GET() {
  const users = await userService.getAll();
  return Response.json(users);
}
```
```

**Bad:** "API routes should follow RESTful conventions"

### State Constraints Explicitly

**Good:** "Maximum 5 items in the cart. Validation in `src/lib/cart.ts:45`"
**Bad:** "There are some cart limits"

### List Anti-Patterns

Always include what NOT to do. Agents learn from boundaries.

## Troubleshooting

### Claude Isn't Following CLAUDE.md

1. Run `/memory` to verify files are loaded
2. Check the file is in a location that gets loaded
3. Make instructions more specific
4. Look for conflicting instructions across files
5. Use the `InstructionsLoaded` hook to debug which files load

### CLAUDE.md Is Too Large

- Move detailed content into `@path` imported files
- Split instructions into `.claude/rules/` files
- Ruthlessly prune instructions Claude follows without being told

### Instructions Lost After /compact

CLAUDE.md fully survives compaction. If an instruction disappeared, it was given only in conversation, not written to CLAUDE.md.

## Maintenance Checklist

When updating CLAUDE.md, verify:

- [ ] Under 200 lines (or split with @imports / rules)
- [ ] All commands still work
- [ ] File paths are accurate
- [ ] Examples compile/run
- [ ] Version numbers are current
- [ ] Removed features are removed from docs
- [ ] New features are documented
- [ ] Conventions match current code
- [ ] Pitfalls are still relevant
- [ ] No conflicting instructions
- [ ] No instructions Claude follows without being told (prune these)

## Advanced: Monorepo Configuration

### claudeMdExcludes Setting

Skip irrelevant CLAUDE.md files in monorepos by adding to `.claude/settings.local.json`:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

Patterns match against absolute file paths using glob syntax. Managed policy CLAUDE.md files cannot be excluded.

## Template for New Projects

```markdown
# CLAUDE.md

## Project Overview

[Brief description of what this project does]

Key technologies:
- [List main technologies]

## Commands

### Development
- `[command]` - [description]

### Testing
- `[command]` - [description]

## Project Structure

Key files:
- `[path]` - [purpose]

## Architecture

[How components connect and data flows]

## Conventions

### Naming
- [Convention]: [Pattern]

### Patterns
- [Pattern description]

## Common Pitfalls

### Do NOT
- [Anti-pattern]

### Watch Out For
- [Gotcha]

## Dependencies

### Required
- [Dependency] [version]

### Environment Variables
- `[VAR_NAME]` - [purpose]
```
