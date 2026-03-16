= Convention Over Configuration

I watched the same agent produce code worthy of a senior hire in one project and unmaintainable garbage in another — on the same afternoon, on the same machine, with the same model. The difference wasn't the prompt. It was the codebase.

Two projects. Same tech stack — TypeScript, React, PostgreSQL. Same size team. Same agent tooling.

Project A has a strict directory layout. Every API endpoint follows the same pattern: a handler file, a schema file, a test file, named identically. The database layer uses a consistent repository pattern. There's a `CLAUDE.md` at the root that describes the architecture in two pages. When an engineer points an agent at a ticket — "add a new endpoint for user notifications" — the agent reads the existing endpoints, follows the pattern, and produces a pull request that looks like a human on the team wrote it. The review takes three minutes.

Project B is the other kind. The codebase grew organically over two years. Some endpoints are in `routes/`, some are in `api/`, some are in `handlers/`. Half the database queries use an ORM, the other half use raw SQL. There's no consistent error handling — some functions throw, some return error objects, some return null. The agent looks at this codebase and does its best, but "its best" means picking whichever pattern it saw most recently. The resulting code works, technically, but it doesn't match anything around it. The review takes thirty minutes, most of it spent on "that's not how we do it here."

The difference between these projects isn't talent. It isn't tooling. It's convention.

There's an old principle in software: convention over configuration. Make the default the right thing. Reduce the number of decisions that need to be made. When everyone follows the same patterns, the code explains itself.

This principle was always useful for human teams. For agentic engineering, it's essential.

If this sounds like I'm telling you to do the unglamorous work — writing documentation, enforcing naming conventions, maintaining project structure — I am. And I know how that feels. You didn't become an engineer to write style guides. But this is one of those moments where the craft asks you to care about something that used to feel like overhead, because the stakes have changed. Convention used to be a courtesy to your future self. Now it's the operating system your agents run on.

== Why Agents Love Convention

An agent navigating an unfamiliar codebase does the same thing a new hire does: it looks for patterns. Where do tests live? How are files named? What's the import convention? Where's the config?

If your project follows strong conventions, the agent picks up the patterns quickly and produces code that fits in. If every file is a snowflake — different naming, different structure, different styles — the agent flounders. It doesn't know which pattern to follow, so it invents its own, and the result feels foreign.

Convention is _implicit context_. It's information the agent absorbs from the structure of your code without you having to explain it. When your test files always live next to the source files they test, named `foo.test.ts` beside `foo.ts`, the agent doesn't need to be told where to put a new test. It reads the directory, sees the pattern, and follows it. When your API handlers all export the same shape — a handler function, a schema, a set of middleware — the agent produces a new handler that exports exactly the same shape.

This is why opinionated frameworks have always been productive, and why they're _even more_ productive in the agentic era. Rails, Next.js, Laravel — they impose a structure. That structure isn't just for humans. It's a language the agent speaks fluently.

== The CLAUDE.md Deep Dive

A growing convention in agentic engineering is the `CLAUDE.md` file: a document at the root of your project that tells the agent what it needs to know. Not a README for humans. A briefing for agents.

This is one of the highest-leverage things you can do for your agentic workflow, and most teams either skip it or write a few vague lines and call it done. Let's talk about what a good one actually looks like.

A strong `CLAUDE.md` has five sections:

*Project overview.* Two or three sentences. What does this thing do, what's the tech stack, what's the deployment target. An agent that knows it's working on "a B2B SaaS billing platform built with Go and PostgreSQL, deployed to Kubernetes" makes fundamentally different decisions than one that's guessing.

*Build and test commands.* Every command the agent might need, listed explicitly. Not "check the Makefile" — the actual commands. Agents read documentation literally. If your `CLAUDE.md` says `make test`, the agent will run `make test`. If it says "run the tests" without specifying how, the agent will guess, and it might guess wrong.

*Architecture decisions.* The things that aren't obvious from the code. Why you chose a monorepo. Why the auth service is separate. Why you're using event sourcing for the order pipeline but simple CRUD for user management. These are the decisions that shape every piece of new code, and an agent that doesn't know about them will violate them constantly.

*Conventions.* Your style. How you name things. How you handle errors. What your import order looks like. Whether you prefer early returns or nested conditionals. The things that make code feel like it belongs in _this_ project.

*Common pitfalls.* Where the bodies are buried. The database migration that must always be run before the seed. The environment variable that isn't in `.env.example` but is required for the payment flow. The test that's flaky on CI but not locally. Every project has these — write them down.

Here's what a real `CLAUDE.md` looks like for a medium-sized project:

```markdown
# Project: Meridian (billing platform)

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
```

That's not long. It took maybe thirty minutes to write. But every agent session that reads this file starts with more context than most human developers get in their first week.

The most important discipline: keep it updated. An outdated `CLAUDE.md` is worse than none at all, because the agent will trust it. When you change a convention, update the file. When you add a new service, add it to the architecture section. When someone discovers a new pitfall, document it. Treat it like code — it lives in version control, it gets reviewed in PRs, it's part of the project.

Some teams go further: they put `CLAUDE.md` files in subdirectories too. A `packages/api/CLAUDE.md` that covers API-specific patterns. A `packages/web/CLAUDE.md` that documents the component library conventions. The deeper the agent goes into the project, the more specific context it gets. It's like an onion of documentation — broad context at the root, specific context as you drill down.

== Conventions as Agent Memory

Conventions are the closest thing agents have to long-term memory. Once you see this, it changes how you think about all of them.

An agent's context window resets every session. It doesn't remember what it did yesterday. It doesn't remember the architectural discussion you had last week. It doesn't remember that the last three times it used `fetch` directly, you asked it to use the API client wrapper instead.

But your project structure persists. Your file naming persists. Your `CLAUDE.md` persists. Your linter rules persist. Your test patterns persist. Everything you encode into the shape of your project is there every time the agent opens its eyes.

This reframes conventions entirely. They're not just about consistency for humans. They're _external memory_ for agents. Every convention you establish is a lesson the agent doesn't have to relearn.

Think about what happens without conventions. Session one: the agent creates a new endpoint and puts the error handling inline. You correct it in review: "We use the AppError class." Session two: the agent creates another endpoint and makes the same mistake, because it doesn't remember session one. Session three: same thing. You're having the same conversation over and over.

Now add one convention — a documented error handling pattern, enforced by a linter rule — and the problem disappears permanently. The agent reads the existing code, sees the pattern, follows it. The linter catches any deviation. The lesson is encoded in the project itself, not in anyone's memory.

This is why the most effective agentic teams obsess over conventions that seem tedious. Consistent import ordering. Strict file naming. Standard function signatures. These aren't aesthetic preferences — they're memory. They're the accumulated wisdom of the team, stored in a format that survives context window resets.

The analogy I keep coming back to: conventions are to agents what institutional knowledge is to organisations. A company where everything lives in one person's head is fragile. A company with strong processes and documentation is resilient. The same applies to codebases. A project where "how we do things" lives only in the senior developer's memory is fragile. A project where it's encoded in the structure, the tooling, and the documentation is resilient — for humans and agents alike.

== Practical Conventions That Help Agents

*Consistent file naming.* If your API routes live in `routes/`, your models in `models/`, and your tests in `__tests__/` — the agent can navigate your project without a map. Name files after what they contain. Keep it boring.

*Formatters and linters.* Tools like Prettier, ESLint, `gofmt`, or Ruff aren't just for code style — they're guardrails that ensure agent-generated code matches your project's standards automatically. Run them on save, run them in CI, make them non-negotiable.

*Standard project layout.* Whether it's the Go standard layout, Rails conventions, or your team's own structure — pick one and stick to it. A `justfile` or `Makefile` at the root that lists the standard commands (`build`, `test`, `lint`, `dev`) gives agents an entry point into any project.

*Small, focused files.* Agents work better with files under a few hundred lines. When a file contains one concern — one component, one module, one set of related functions — the agent can read it, understand it, and modify it without wading through unrelated code.

*Descriptive commit messages.* Agents read git history. A commit that says "fix bug" teaches nothing. A commit that says "fix race condition in session cleanup when WebSocket disconnects during auth" gives the agent context about what was important, what was fragile, and how the team thinks about problems.

*Consistent error handling.* Pick a pattern and enforce it everywhere. Custom error classes with error codes. A central error handler. A standard error response shape. When the agent encounters an error case in new code, it should have zero ambiguity about how to handle it. If your project uses three different error handling approaches in three different files, the agent will produce a fourth.

*Standard API response formats.* Every endpoint returns the same shape: `{ data, error, meta }` or whatever you choose. Status codes follow the same rules everywhere. Pagination works the same way on every list endpoint. This is the kind of consistency that agents excel at maintaining — but only if the convention is clear from the existing code.

*Logging conventions.* Structured logging with consistent fields. Every log entry includes a request ID, a timestamp, and a severity level. Every error log includes the error code and a stack trace. When the agent adds logging to new code — and it should — the logs should look identical to every other log in the system.

*Directory structure that tells a story.* An agent should be able to `ls` the top level of your project and understand the architecture. Here's what a well-structured project looks like from an agent's perspective:

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

Every directory name is a noun. Every file within contains exactly what the directory name promises. There's nowhere to be confused about where new code should go. An agent reading this structure immediately knows: "I need to add a new database query, that goes in `repositories/`. I need a new endpoint, that starts in `routes/`."

Compare that to a project where database queries are scattered across handler files, business logic lives in utility functions, and there are three different directories that all seem to contain "helpers." The agent will put code in _a_ place, but it probably won't be the _right_ place.

== The Convention Tax

Let's be honest about the cost. Establishing conventions takes time, and it feels like overhead — especially at the start.

Writing a `CLAUDE.md` takes an afternoon. Setting up linters and formatters takes a day. Refactoring an inconsistent codebase to follow a single pattern takes a week, maybe more. Enforcing conventions in code review means slowing down PRs that "work fine" but don't follow the standard.

There's a real temptation to skip all of this. The code works. The tests pass. Why spend time on naming conventions when there are features to ship?

The honest answer: if you're a solo developer building a throwaway prototype, the convention tax probably isn't worth it. Move fast, ship it, throw it away.

But the moment a second pair of eyes touches your codebase — human _or_ agent — conventions start paying for themselves. And the returns compound.

The first time you establish a convention, it costs you an hour. Every subsequent time an agent follows that convention instead of asking you how to handle it, you save five minutes. Do the arithmetic: after twelve agent sessions, the convention has paid for itself. After a hundred sessions, you've saved _hours_.

This compounds across the team. Five engineers, each running multiple agent sessions per day, all benefiting from the same conventions. The initial investment of one engineer's afternoon saves the team hundreds of hours over the course of a year.

The teams that invest in conventions early look slower at first. They spend time on "boring" things — linter configs, project structure, documentation. But three months in, their agents are producing code that requires minimal review. Six months in, they're shipping twice as fast as the team that skipped the convention work. A year in, the gap is embarrassing.

This is the same dynamic as technical debt, just inverted. Convention is technical _wealth_ — and like financial wealth, the earlier you start investing, the more dramatic the compounding.

The biggest mistake I see is teams that wait until their codebase is a mess before trying to establish conventions. That's the most expensive time to do it. The cheapest time is at the start of a project — but the second cheapest time is today.

== The Compounding Effect

Every convention you establish, every standard you enforce, every piece of documentation you maintain — it all compounds. Each one makes agents slightly more effective, slightly more autonomous, slightly more likely to produce code that fits your project like a glove.

But the compounding isn't just additive. Conventions interact. A consistent file naming convention _plus_ a standard directory structure _plus_ a `CLAUDE.md` that describes the architecture — together, these give the agent a mental model of the entire project. It knows where to find things, what to name them, and how they fit together. Remove any one of those three, and the agent's effectiveness drops disproportionately.

This is why half-hearted conventions are almost as bad as no conventions. A project with consistent file naming but chaotic directory structure sends mixed signals. The agent sees order in one dimension and chaos in another, and it doesn't know which signal to trust.

The engineers who invest in convention early don't just have cleaner codebases. They have codebases that are ready for the agentic future. Their agents produce better results. Their reviews are faster. Their iteration cycles are tighter.

Convention isn't glamorous work. It's the least exciting chapter in this book. But it's the one that makes every other chapter work. The sandboxes, the testing strategies, the multi-agent orchestration — all of it works better when the underlying codebase is consistent, documented, and conventional.

Your codebase is the environment your agents live in. Make it legible. Make it predictable. Make it boring. The agents will thank you by writing code that looks like it belongs.
