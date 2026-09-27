= Convention Over Configuration

I watched the same agent produce code worthy of a senior hire in one project and unmaintainable garbage in another — on the same afternoon, on the same machine, with the same model. The difference wasn't the prompt. It was the codebase.

Two projects. Same tech stack — TypeScript, React, PostgreSQL. Same size team. Same agent tooling.

Project A has a strict directory layout. Every API endpoint follows the same pattern: a handler file, a schema file, a test file, named identically. The database layer uses a consistent repository pattern. There's an `AGENTS.md` at the root that describes the architecture in two pages. When an engineer points an agent at a ticket — "add a new endpoint for user notifications" — the agent reads the existing endpoints, follows the pattern, and produces a pull request that looks like a human on the team wrote it. The review takes three minutes.

Project B is the other kind. The codebase grew organically over two years. Some endpoints are in `routes/`, some are in `api/`, some are in `handlers/`. Half the database queries use an ORM, the other half use raw SQL. There's no consistent error handling — some functions throw, some return error objects, some return null. The agent looks at this codebase and does its best, but "its best" means picking whichever pattern it saw most recently. The resulting code works, technically, but it doesn't match anything around it. The review takes thirty minutes, most of it spent on "that's not how we do it here."

The difference between these projects isn't talent. It isn't tooling. It's convention.

There's an old principle in software: convention over configuration. Make the default the right thing. Reduce the number of decisions that need to be made. When everyone follows the same patterns, the code explains itself.

This principle was always useful for human teams. For agentic engineering, it's essential.

If this sounds like I'm telling you to do the unglamorous work — writing documentation, enforcing naming conventions, maintaining project structure — I am. And I know how that feels. You didn't become an engineer to write style guides. But this is one of those moments where the craft asks you to care about something that used to feel like overhead, because the stakes have changed. Convention used to be a courtesy to your future self. Now it's the operating system your agents run on.

== Why Agents Love Convention

An agent navigating an unfamiliar codebase does the same thing a new hire does: it looks for patterns. Where do tests live? How are files named? What's the import convention? Where's the config?

If your project follows strong conventions, the agent picks up the patterns quickly and produces code that fits in. If every file is a snowflake — different naming, different structure, different styles — the agent flounders. It doesn't know which pattern to follow, so it invents its own, and the result feels foreign.

There's a deeper reason conventions matter, and it connects to tools. Conventions work because they make the agent's _tools_ more effective. When an agent runs `ls` or `find` or `grep`, consistent naming and structure mean those tools return useful results. A project where tests always live in `__tests__/` means `find . -name "*.test.ts"` always works. Conventions aren't just implicit context — they're what makes the agent's autonomous exploration productive.

Convention is _implicit context_. It's information the agent absorbs from the structure of your code without you having to explain it. When your test files always live next to the source files they test, named `foo.test.ts` beside `foo.ts`, the agent doesn't need to be told where to put a new test. It reads the directory, sees the pattern, and follows it. When your API handlers all export the same shape — a handler function, a schema, a set of middleware — the agent produces a new handler that exports exactly the same shape.

This is why opinionated frameworks have always been productive, and why they're _even more_ productive in the agentic era. Rails, Next.js, Laravel — they impose a structure. That structure isn't just for humans. It's a language the agent speaks fluently.

== The Agent Instruction File

The strongest convention in agentic engineering is the agent instruction file — a document at the root of your project that tells the agent what it needs to know. Not a README for humans. A briefing for agents.

When I wrote the first edition, every tool had its own filename for this. That's largely settled now. `AGENTS.md` has become the cross-tool standard — Codex, Cursor, GitHub Copilot, Gemini CLI and many others read it — and since late 2025 it sits under the Linux Foundation's Agentic AI Foundation alongside MCP. Claude Code reads `CLAUDE.md`; the common pattern is to keep the content in `AGENTS.md` and have `CLAUDE.md` point at it (or simply symlink one to the other), so there's one source of truth. Cursor has moved from a single `.cursorrules` file to a `.cursor/rules/` directory for tool-specific rules. The names still vary at the edges; the principle is identical.

// v2-verify: check whether Claude Code reads AGENTS.md natively by publication; if so, simplify the CLAUDE.md pointer advice.

This is one of the highest-leverage things you can do for your agentic workflow, and most teams either skip it or write a few vague lines and call it done. Let's talk about what a good one actually looks like.

A strong instruction file has five sections:

*Project overview.* Two or three sentences. What does this thing do, what's the tech stack, what's the deployment target. An agent that knows it's working on "a B2B SaaS billing platform built with Go and PostgreSQL, deployed to Kubernetes" makes fundamentally different decisions than one that's guessing.

*Build and test commands.* Every command the agent might need, listed explicitly. Not "check the Makefile" — the actual commands. Agents read documentation literally. If your instruction file says `make test`, the agent will run `make test`. If it says "run the tests" without specifying how, the agent will guess, and it might guess wrong.

*Architecture decisions.* The things that aren't obvious from the code. Why you chose a monorepo. Why the auth service is separate. Why you're using event sourcing for the order pipeline but simple CRUD for user management. These are the decisions that shape every piece of new code, and an agent that doesn't know about them will violate them constantly.

*Conventions.* Your style. How you name things. How you handle errors. What your import order looks like. Whether you prefer early returns or nested conditionals. The things that make code feel like it belongs in _this_ project.

*Common pitfalls.* Where the bodies are buried. The database migration that must always be run before the seed. The environment variable that isn't in `.env.example` but is required for the payment flow. The test that's flaky on CI but not locally. Every project has these — write them down.

Here's what a real `AGENTS.md` looks like for a medium-sized project:

```markdown
# AGENTS.md — Meridian (billing platform)

TypeScript monorepo (pnpm workspaces). React frontend, Express API,
PostgreSQL with Drizzle ORM. Deployed to Fly.io.

## Commands
- `pnpm install` — install all dependencies
- `pnpm test` — run all tests (vitest)
- `pnpm test:api` — API tests only
- `pnpm test:web` — frontend tests only
- `pnpm lint` — eslint + prettier check
- `pnpm lint:fix` — auto-fix lint issues
- `pnpm db:migrate` — run pending migrations
- `pnpm db:generate` — generate migration from schema changes
- `pnpm dev` — start all services locally

## Architecture
- /packages/api — Express REST API
- /packages/web — React SPA (Vite)
- /packages/shared — shared types and utilities
- /packages/db — Drizzle schema, migrations, seed data

All API routes follow the pattern:
  routes/{resource}/index.ts — route definitions
  routes/{resource}/handlers.ts — request handlers
  routes/{resource}/schemas.ts — Zod validation schemas
  routes/{resource}/__tests__/ — tests for this resource

## Conventions
- All errors go through the AppError class (packages/api/src/errors.ts)
- Never throw raw Error objects in API handlers
- Use Zod schemas for ALL request validation, no manual checks
- Database queries live in packages/db/src/queries/, not in handlers
- Prefer early returns over deeply nested conditionals
- Import order: node builtins, external deps, internal packages, relative

## Pitfalls
- The Stripe webhook handler uses raw body parsing — don't add
  json middleware to that route
- Test database must be created manually: createdb meridian_test
- The `BILLING_SECRET` env var isn't in .env.example (it's in 1Password)
- Flaky test: invoice.concurrent.test.ts — known race condition,
  skip locally if it blocks you

## Deeper docs (read when relevant)
- docs/billing-flows.md — how invoices, credits and refunds interact
- docs/migrations.md — migration rules and rollback procedure
```

And the Claude Code side of it can be a single line:

```markdown
# CLAUDE.md
See @AGENTS.md for project instructions.
```

That's not long. It took maybe thirty minutes to write. But every agent session that reads this file starts with more context than most human developers get in their first week.

Notice what it _doesn't_ do. It doesn't paste the billing flow documentation in. It points at it. That's deliberate. The instruction file is loaded into context on every session — every turn pays for every line. A two-hundred-line instruction file full of edge cases is a tax on every task, including the ninety percent of tasks that never touch those edge cases. Keep the root file short: the things that apply everywhere. Link to deeper documents and let the agent read them when the task calls for it. This is progressive disclosure — the same principle from the Context chapter — applied to your own documentation.

The most important discipline: keep it updated. An outdated instruction file is worse than none at all, because the agent will trust it. When you change a convention, update the file. When you add a new service, add it to the architecture section. When someone discovers a new pitfall, document it. Treat it like code — it lives in version control, it gets reviewed in PRs, it's part of the project.

Most teams also put instruction files in subdirectories. A `packages/api/AGENTS.md` that covers API-specific patterns. A `packages/web/AGENTS.md` that documents the component library conventions. The deeper the agent goes into the project, the more specific context it gets. It's like an onion of documentation — broad context at the root, specific context as you drill down — and it's progressive disclosure again: the API rules only load when the agent is working in the API.

== Skills: Conventions You Can Execute

An instruction file tells the agent what's true about your project. But a lot of team knowledge isn't a fact — it's a _procedure_. How we cut a release. How we add a database migration. How we write a post-mortem. These used to live in a wiki page nobody read, or in one senior engineer's head.

Skills are the answer the industry converged on. A skill is a folder containing a `SKILL.md` file — a short piece of frontmatter with a name and a description, followed by instructions — plus any scripts or reference files the procedure needs. Anthropic introduced them in late 2025 and published the format as an open standard, and other tools have since adopted it.

The clever part is how they load. At the start of a session, the agent sees only each skill's name and description — a line or two. The full instructions load only when a task actually needs them. You can have thirty skills in a repo and pay almost nothing for the twenty-nine you're not using. It's progressive disclosure, built into the format.

A small one might look like this:

```markdown
---
name: add-migration
description: Use when adding or changing a database table or
  column in Meridian. Covers schema change, migration, and tests.
---

# Adding a database migration

1. Edit the schema in packages/db/src/schema/.
2. Run `pnpm db:generate` and review the generated SQL.
   Never hand-edit a generated migration.
3. If the change drops or renames a column, stop and ask —
   these need a two-step deploy (see docs/migrations.md).
4. Run `pnpm db:migrate` against the test database.
5. Add or update repository tests in packages/db/src/queries/.
6. Run `pnpm test:api` before declaring the task done.
```

That's team know-how, packaged. It lives in the repo, it's versioned, it gets reviewed in PRs like any other code. When the migration process changes, you change the skill, and every engineer's agent picks up the new procedure on the next session. Skills are what a prompt library should have been all along.

Two neighbours are worth knowing:

- *Custom slash commands* — a saved prompt the _human_ triggers on purpose, like `/review` or `/release-notes`. In Claude Code they're markdown files in `.claude/commands/`. Use them for things you do deliberately; use skills for things the agent should recognise it needs.
- *Hooks* — scripts that run on agent lifecycle events, which we met in the Guardrails chapter. An instruction file says "run the linter before finishing"; a hook _runs the linter_. A hook is a convention the model can't forget.

The progression is worth internalising. A convention the agent keeps getting wrong goes into the instruction file. A procedure that needs more than a line becomes a skill. A rule that must never be broken becomes a hook.

== Conventions as Agent Memory

Conventions are the closest thing agents have to long-term memory. Once you see this, it changes how you think about all of them.

Your project structure persists across sessions. Your file naming persists. Your `AGENTS.md` persists. Your linter rules persist. Everything you encode into the shape of your project is there every time the agent opens its eyes. Conventions aren't just about consistency for humans — they're _external memory_ for agents. Every convention you establish is a lesson the agent doesn't have to relearn.

Without conventions, you have the same conversation over and over. Session one: the agent puts error handling inline. You correct it: "We use the AppError class." Session two: same mistake. Session three: same again. Add one convention — a documented error handling pattern, enforced by a linter rule — and the problem disappears permanently. The lesson is encoded in the project itself, not in anyone's memory.

This is why the most effective agentic teams obsess over conventions that seem tedious. Consistent import ordering. Strict file naming. Standard function signatures. These aren't aesthetic preferences — they're memory. The accumulated wisdom of the team, stored in a format that survives context window resets. We'll explore how to build on this with active memory systems in the next chapter.

== Practical Conventions That Help Agents

*Consistent file naming.* If your API routes live in `routes/`, your models in `models/`, and your tests in `__tests__/` — the agent can navigate your project without a map. Name files after what they contain. Keep it boring.

*Formatters and linters.* Tools like Prettier, ESLint, `gofmt`, or Ruff aren't just for code style — they're guardrails that ensure agent-generated code matches your project's standards automatically. Run them on save, run them in CI, make them non-negotiable.

*Standard project layout.* Whether it's the Go standard layout, Rails conventions, or your team's own structure — pick one and stick to it. A `justfile` or `Makefile` at the root that lists the standard commands (`build`, `test`, `lint`, `dev`) gives agents an entry point into any project.

*Small, focused files.* Agents work better with files under a few hundred lines. One concern per file — one component, one module, one set of related functions. The agent can read it, understand it, and modify it without wading through unrelated code.

*Consistent error handling.* Pick a pattern and enforce it everywhere. Custom error classes with error codes. A central error handler. A standard error response shape. If your project uses three different error handling approaches in three different files, the agent will produce a fourth.

*Standard API response formats.* Every endpoint returns the same shape: `{ data, error, meta }` or whatever you choose. Status codes follow the same rules everywhere. Pagination works the same way on every list endpoint.

*Directory structure that tells a story.* An agent should be able to `ls` the top level of your project and understand the architecture:

```
src/
  routes/         # HTTP handlers — one file per resource
  services/       # Business logic — one file per domain concept
  repositories/   # Database access — one file per table/entity
  middleware/      # Express/Koa middleware
  utils/          # Pure utility functions
  types/          # Shared TypeScript types
  errors/         # Custom error classes
tests/
  fixtures/       # Test data factories
  helpers/        # Test utilities
migrations/       # Database migrations (numbered)
scripts/          # One-off and maintenance scripts
```

Every directory name is a noun. Every file within contains exactly what the directory name promises. An agent reading this structure immediately knows: "I need to add a new database query, that goes in `repositories/`. I need a new endpoint, that starts in `routes/`."

== The Convention Tax

Let's be honest about the cost. Writing a good `AGENTS.md` takes an afternoon. Setting up linters and formatters takes a day. Refactoring an inconsistent codebase to follow a single pattern takes a week. It feels like overhead.

If you're a solo developer building a throwaway prototype, it probably isn't worth it. But the moment a second pair of eyes touches your codebase — human _or_ agent — conventions start paying for themselves. The first time you establish a convention, it costs you an hour. Every subsequent time an agent follows that convention instead of asking you how to handle it, you save five minutes. After twelve sessions, it's paid for itself. After a hundred, you've saved _hours_.

The teams that invest in conventions early look slower at first. Three months in, their agents produce code that requires minimal review. Six months in, they're shipping twice as fast as the team that skipped the convention work. Convention is technical _wealth_ — and like financial wealth, the earlier you start investing, the more dramatic the compounding.

== Why It All Fits Together

Conventions interact. A consistent file naming convention _plus_ a standard directory structure _plus_ an instruction file that describes the architecture — together, these give the agent a mental model of the entire project. Remove any one of those three, and the agent's effectiveness drops disproportionately. Half-hearted conventions are almost as bad as no conventions.

Your codebase is the environment your agents live in. Make it legible. Make it predictable. Make it boring. The agents will thank you by writing code that looks like it belongs.
