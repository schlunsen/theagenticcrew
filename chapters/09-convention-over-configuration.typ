= Convention Over Configuration

There's an old principle in software: convention over configuration. Make the default the right thing. Reduce the number of decisions that need to be made. When everyone follows the same patterns, the code explains itself.

This principle was always useful for human teams. For agentic engineering, it's essential.

== Why Agents Love Convention

An agent navigating an unfamiliar codebase does the same thing a new hire does: it looks for patterns. Where do tests live? How are files named? What's the import convention? Where's the config?

If your project follows strong conventions, the agent picks up the patterns quickly and produces code that fits in. If every file is a snowflake — different naming, different structure, different styles — the agent flounders. It doesn't know which pattern to follow, so it invents its own, and the result feels foreign.

Convention is _implicit context_. It's information the agent absorbs from the structure of your code without you having to explain it.

== Practical Conventions That Help Agents

*Consistent file naming.* If your API routes live in `routes/`, your models in `models/`, and your tests in `__tests__/` — the agent can navigate your project without a map. Name files after what they contain. Keep it boring.

*Formatters and linters.* Tools like Prettier, ESLint, `gofmt`, or Ruff aren't just for code style — they're guardrails that ensure agent-generated code matches your project's standards automatically. Run them on save, run them in CI, make them non-negotiable.

*Standard project layout.* Whether it's the Go standard layout, Rails conventions, or your team's own structure — pick one and stick to it. A `justfile` or `Makefile` at the root that lists the standard commands (`build`, `test`, `lint`, `dev`) gives agents an entry point into any project.

*Small, focused files.* Agents work better with files under a few hundred lines. When a file contains one concern — one component, one module, one set of related functions — the agent can read it, understand it, and modify it without wading through unrelated code.

*Descriptive commit messages.* Agents read git history. A commit that says "fix bug" teaches nothing. A commit that says "fix race condition in session cleanup when WebSocket disconnects during auth" gives the agent context about what was important, what was fragile, and how the team thinks about problems.

== CLAUDE.md and Project Documentation

A growing convention in agentic engineering is the `CLAUDE.md` file (or equivalent): a document at the root of your project that tells the agent what it needs to know. How to build. How to test. What the architecture looks like. What to avoid.

This isn't a README — it's a briefing document. Short, current, and focused on what an agent needs to be productive in this specific codebase. Think of it as the conversation you'd have with a contractor on their first day: "here's the project, here's how we do things, here's where the bodies are buried."

Keep it updated. An outdated `CLAUDE.md` is worse than none at all, because the agent will trust it.

== The Compounding Effect

Every convention you establish, every standard you enforce, every piece of documentation you maintain — it all compounds. Each one makes agents slightly more effective, slightly more autonomous, slightly more likely to produce code that fits your project like a glove.

The engineers who invest in convention early don't just have cleaner codebases. They have codebases that are ready for the agentic future. Their agents produce better results. Their reviews are faster. Their iteration cycles are tighter.

Convention isn't glamorous work. But it's the foundation that everything else in this book builds on.
