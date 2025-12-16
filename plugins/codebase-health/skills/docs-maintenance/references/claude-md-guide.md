# CLAUDE.md Optimization Guide

This guide covers how to create and maintain CLAUDE.md files that maximize AI coding agent effectiveness.

## Purpose of CLAUDE.md

CLAUDE.md is a special file that AI coding agents (like Claude Code) read to understand how to work with a codebase. Unlike README (for humans) or code comments (for developers), CLAUDE.md is specifically designed to give AI agents the context they need to be effective.

## Required Sections

Every CLAUDE.md should include these sections:

### 1. Project Overview

**Purpose:** Help the agent understand what the project does and its scope.

**Template:**
```markdown
## Project Overview

[Project name] is a [type of application] that [primary purpose].

Key technologies:
- [Framework/language]
- [Major dependencies]
- [Infrastructure/deployment]
```

**Good Example:**
```markdown
## Project Overview

This is a Next.js e-commerce platform that handles product catalog, shopping cart, and checkout flows.

Key technologies:
- Next.js 14 with App Router
- PostgreSQL with Prisma ORM
- Stripe for payments
- Redis for session management
```

**Bad Example:**
```markdown
## Overview

This is our main project. It does a lot of things.
```

### 2. Build and Test Commands

**Purpose:** Give agents exact commands to build, test, and run the project.

**Template:**
```markdown
## Commands

### Development
- `npm run dev` - Start development server on port 3000
- `npm run build` - Create production build
- `npm run lint` - Run ESLint

### Testing
- `npm test` - Run all tests
- `npm run test:unit` - Run unit tests only
- `npm run test:e2e` - Run end-to-end tests (requires running server)

### Database
- `npm run db:migrate` - Run pending migrations
- `npm run db:seed` - Seed development data
```

**Key Points:**
- Use exact command syntax
- Include what each command does
- Note any prerequisites (e.g., "requires running server")
- Include less obvious commands agents might need

### 3. Key File Locations

**Purpose:** Help agents navigate the codebase efficiently.

**Template:**
```markdown
## Project Structure

```
src/
├── app/           # Next.js App Router pages
├── components/    # Reusable React components
├── lib/           # Shared utilities and helpers
├── services/      # Business logic and API clients
└── types/         # TypeScript type definitions
```

Key files:
- `src/app/layout.tsx` - Root layout with providers
- `src/lib/db.ts` - Database connection singleton
- `src/services/auth.ts` - Authentication logic
```

### 4. Architecture Overview

**Purpose:** Explain how components connect and data flows.

**Template:**
```markdown
## Architecture

### Data Flow
1. API routes in `src/app/api/` handle requests
2. Routes call services in `src/services/`
3. Services use Prisma client from `src/lib/db.ts`
4. Responses are typed with schemas from `src/types/`

### Key Patterns
- All database access goes through service layer
- Components fetch data using React Query
- Form validation uses Zod schemas
```

### 5. Coding Conventions

**Purpose:** Ensure agents write code that matches project style.

**Template:**
```markdown
## Conventions

### Naming
- Components: PascalCase (`UserProfile.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- Constants: SCREAMING_SNAKE_CASE
- Database tables: snake_case

### File Organization
- One component per file
- Co-locate tests with source (`Button.tsx`, `Button.test.tsx`)
- Index files only for public API exports

### Patterns
- Use `async/await` over `.then()` chains
- Prefer named exports over default exports
- Use TypeScript strict mode types (no `any`)
```

### 6. Common Pitfalls

**Purpose:** Prevent agents from making common mistakes.

**Template:**
```markdown
## Common Pitfalls

### Do NOT
- Import from `@/lib/db` in client components (server-only)
- Use `any` type - always define proper types
- Modify state directly in reducers
- Skip error boundaries in page components

### Watch Out For
- The `user` table uses soft deletes (`deleted_at` column)
- API routes require auth middleware - check `src/middleware.ts`
- Environment variables need `NEXT_PUBLIC_` prefix for client access
```

### 7. Tool and Dependency Notes

**Purpose:** Document special requirements and gotchas.

**Template:**
```markdown
## Dependencies

### Required Environment
- Node.js 20+
- PostgreSQL 15+
- Redis 7+

### Environment Variables
Copy `.env.example` to `.env.local` and configure:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `STRIPE_SECRET_KEY` - Stripe API key (test mode ok for dev)

### Known Issues
- `sharp` package requires manual install on M1 Macs
- Run `npm run postinstall` after adding new Prisma models
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
// src/app/api/users/route.ts
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

**Good:**
```markdown
### Never Do This
- Don't use dynamic code execution functions
- Don't store passwords in plain text
- Don't commit `.env` files
```

## Section Order Recommendation

1. Project Overview (what is this?)
2. Commands (how do I run it?)
3. Project Structure (where is everything?)
4. Architecture (how does it work?)
5. Conventions (how should I write code?)
6. Common Pitfalls (what should I avoid?)
7. Dependencies (what do I need?)

## Maintenance Checklist

When updating CLAUDE.md, verify:

- [ ] All commands still work
- [ ] File paths are accurate
- [ ] Examples compile/run
- [ ] Version numbers are current
- [ ] Removed features are removed from docs
- [ ] New features are documented
- [ ] Conventions match current code
- [ ] Pitfalls are still relevant

## Anti-Patterns to Avoid

### Vague References
```markdown
# Bad
See the main config file for settings.

# Good
See `config/app.config.ts` for application settings.
```

### Outdated Information
Regularly check:
- Command syntax hasn't changed
- Dependencies are current versions
- Deprecated features are removed
- New patterns are documented

### Assumed Context
```markdown
# Bad
Use the standard auth pattern.

# Good
Use the auth pattern from `src/lib/auth.ts`:
1. Import `withAuth` wrapper
2. Wrap API route handler
3. Access `req.user` for authenticated user
```

### Missing Negative Guidance
Always include what NOT to do, not just what to do. Agents learn from boundaries.

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

```
[directory tree]
```

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
