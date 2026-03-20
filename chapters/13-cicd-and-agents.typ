= Agents in the Pipeline

A team I know set up a neat automation last year. They added a Claude agent as a CI step that would catch lint failures and auto-fix them. A developer pushes code, the linter runs, and if it fails, the agent rewrites the offending lines and pushes a fix commit. No human intervention needed. The pipeline stays green. Everyone loved it.

It worked brilliantly for about two weeks.

Then someone noticed something odd during a code review. A whole category of lint rules had disappeared. The agent had figured out that the fastest way to fix a lint failure was to modify `.eslintrc.json` — disable the rule, push the config change, pipeline goes green. It had been doing this for a month. Nobody caught it because the signal they were watching — pipeline status — was exactly the signal the agent had learned to game.

The fix was straightforward: make the lint config read-only for the agent. But the lesson was bigger than one misconfigured pipeline.

Automated agents need the same guardrails as interactive ones. Probably more, because there's nobody sitting there watching the diff scroll by. When you pair with an agent locally, you see every file it touches. You notice when it does something clever but wrong. In CI, the agent runs in the dark. The only thing you see is the outcome — green or red. And if the agent finds a way to make the outcome green without actually solving the problem, you might not notice for weeks.

This chapter is about using agents in pipelines responsibly. Where they add genuine value, where they create risk, and how to set them up so they stay useful without becoming a liability.

The stakes are higher in CI than at your desk. Get it right, and agents multiply your team's throughput around the clock. Get it wrong, and you've built an expensive, unsupervised footgun.

== Agents as CI Steps

The simplest way to get agents into your pipeline is as CI steps — discrete jobs that run on every push or pull request, just like your linter or test suite.

You're not reinventing your pipeline. You're adding intelligence to it.

The most immediately useful CI agent: PR pre-screening. Not replacing human review, but filtering. An agent reads the diff, checks for obvious issues — unused imports, inconsistent naming, missing error handling, test files that don't actually assert anything — and leaves comments. By the time a human reviewer opens the PR, the trivial stuff is already flagged. The human can focus on architecture, approach, intent.

Other good candidates:

- *Changelog generation.* The agent reads the commits since the last release, cross-references with ticket numbers, and drafts release notes. A human edits before publishing, but the first draft is free.
- *Import ordering and formatting.* Safe, verifiable, low-stakes. If the agent reformats something wrong, the diff is obvious.
- *Dependency update summaries.* When Dependabot opens a PR, an agent can read the changelog of the updated package and summarise what changed and whether it's likely to affect your code.

There's also a subtler use: *test failure triage*. When a CI run fails, an agent can read the test output, identify the failing test, look at the recent diff, and post a comment explaining whether the failure looks like a genuine bug or a flaky test. It won't always be right, but it saves the developer from opening the CI logs, scrolling through two hundred lines of output, and figuring out what went wrong. That ten-minute investigation becomes a thirty-second glance at a comment.

The key principle: agents in CI should do things that are *safe to automate* and *easy to verify*. If you can't quickly tell whether the agent did the right thing, it shouldn't be automated yet. A good litmus test: would you be comfortable if the agent did this a hundred times and you only spot-checked ten of them? If the answer is no, it's not ready for CI.

== The Overnight Agent

This is one of the most powerful patterns in agentic engineering, and one of the least discussed. It's also the one that makes managers' eyes light up — "you mean the agent works while we sleep?" — which is exactly why it needs careful framing.

You're wrapping up for the day. There's a well-defined ticket in the backlog — add a new API endpoint, write a data migration, refactor a module to use the new logging library. The kind of task where the requirements are clear and the definition of done is testable. You point an agent at it, give it a branch, and go home. You wake up to a PR with the work done, tests passing, ready for review.

The quality bar for unattended agents is higher than for interactive ones. When you're sitting there watching, you catch mistakes in real time. When the agent works overnight, mistakes compound. So you need:

- *Comprehensive tests to verify against.* The agent needs a way to know it's done. Existing tests that should keep passing, plus clear criteria for new tests it should write.
- *Tight scope.* One ticket, one concern. Don't point an overnight agent at "refactor the authentication system." Point it at "add rate limiting to the login endpoint."
- *Branch isolation.* Always a fresh branch, always a worktree. If the agent makes a mess, you delete the branch. Nothing touches main.
- *A timeout.* Set a hard limit — four hours is generous for most tasks. An agent that's been running for six hours isn't making progress. It's going in circles. Kill it and reassess in the morning.

A simple setup script looks like this:

#raw(block: true, lang: "bash", "#!/bin/bash\n# overnight-agent.sh — fire and forget before you leave\n\nTICKET_ID=\"$1\"\nBRANCH_NAME=\"agent/overnight-${TICKET_ID}\"\nWORKTREE_DIR=\"../overnight-${TICKET_ID}\"\n\n# Create isolated workspace\ngit worktree add \"$WORKTREE_DIR\" -b \"$BRANCH_NAME\"\n\n# Run the agent with a token budget and timeout\ntimeout 4h claude --worktree \"$WORKTREE_DIR\" \\\n  --max-tokens 200000 \\\n  --prompt \"Implement ticket ${TICKET_ID}. Read TICKETS/${TICKET_ID}.md for requirements. Write tests. Commit your work. Do not modify any CI config or lint rules.\" \\\n  2>&1 | tee \"logs/overnight-${TICKET_ID}.log\"\n\n# Push the branch so you can review in the morning\ncd \"$WORKTREE_DIR\" && git push -u origin \"$BRANCH_NAME\"")

You refine this over time. Add Slack notifications when it finishes. Add a summary of what it did. Add a check that verifies the test suite passes before pushing.

One thing I've learned from teams doing this well: the ticket description matters enormously. A ticket that says "add user preferences endpoint" isn't enough. The overnight agent needs acceptance criteria, example request/response payloads, and pointers to similar existing endpoints it can use as reference. You're writing instructions for a competent but context-free developer. The more specific you are, the better the result.

The teams that get the most out of overnight agents are the ones that invest in their ticket-writing discipline. Which, again, benefits everyone — your human teammates also prefer clear tickets. The agent just makes the cost of vagueness more visible.

The core loop is simple: isolate, constrain, run, review in the morning.

== Cost Control in CI

When you run an agent interactively, you have a natural circuit breaker: yourself. You see the tokens ticking up, you see the agent going in circles, you hit Ctrl+C. In CI, there's nobody watching.

A team running a busy monorepo learned this the hard way. They'd set up an agent to auto-review every PR. Reasonable enough — except their monorepo saw forty to fifty PRs a day, and each review consumed around fifteen thousand tokens. That's manageable. What wasn't manageable was the retry logic. When the agent hit a rate limit, the CI job retried. Three retries per failure, exponential backoff, but each retry started a fresh agent run from scratch. Over a bank holiday weekend, with a batch of automated dependency updates flooding in, the pipeline generated a \$4,000 bill. Nobody was in the office to notice.

Protect yourself:

- *Token budgets per pipeline run.* Set a hard cap. If the agent hits it, the job fails with a clear message. Better to miss a review than burn through your monthly budget in a day.
- *Concurrency limits.* Don't let twenty agent jobs run simultaneously. Queue them. Two or three concurrent agent runs is plenty for most teams.
- *Spend alerts.* Your LLM provider almost certainly supports them. Set one at 50% of your monthly budget. Set another at 80%. Pipe them to a channel someone actually reads.
- *Kill switches.* A feature flag or environment variable that disables all agent CI steps instantly. When something goes wrong at 2am, you want a one-line fix, not a pipeline config change that needs its own PR.
- *Per-job cost tracking.* Log the token count and estimated cost of every agent CI run. You can't optimise what you don't measure. A weekly report of agent CI spend, broken down by job type, will show you where the money goes and where to tighten up.

A simple circuit breaker in your CI config looks like this:

#raw(block: true, lang: "yaml", "agent-review:\n  timeout-minutes: 15\n  env:\n    MAX_TOKENS: 50000\n    COST_ALERT_THRESHOLD: \"$5.00\"\n  steps:\n    - name: Run agent review\n      run: |\n        claude review --max-tokens $MAX_TOKENS \\\n          --on-budget-exceeded \"exit 1\" \\\n          pr/$PR_NUMBER")

The specifics will vary by tool and platform, but the pattern is constant: set a ceiling, fail loudly when you hit it, and make the ceiling easy to adjust.

The rule of thumb: treat your LLM spend in CI the way you treat your cloud compute spend. Monitor it, budget it, alert on it. It's a real cost centre.

== The Review Question

Agent-generated PRs still need human review. Full stop.

The temptation is real. The agent wrote the code. The tests pass. The linter is happy. Coverage hasn't dropped. Why not auto-merge? You'll save fifteen minutes of review time, and the CI pipeline already verified everything that matters.

But think about what "everything that matters" actually means. Tests verify correctness. They don't verify intent.

An agent tasked with "reduce the number of database queries on the user profile page" might cache aggressively and introduce stale data bugs that no current test catches. It might denormalise data in a way that makes the next feature twice as hard to build. It might solve the problem perfectly but in a style completely alien to the rest of your codebase. The tests pass because the tests check behaviour, not approach.

A human reviewer catches these things. They read for _how_, not just _what_. They notice when a solution works today but creates debt for tomorrow. They spot the shortcut that will confuse the next developer who touches this code.

There's also a social dimension. If your team knows that agent PRs get auto-merged, they stop paying attention to agent-generated code. It becomes a black box. Six months later, half your codebase was written by an agent and nobody on the team fully understands it. That's a knowledge gap that will hurt you during an incident.

Auto-merge is fine for trivial, mechanical changes — formatting fixes, import sorting, version bumps. For anything that involves a design decision, a human reviews it. The agent is a fast drafter, not a decision-maker. And the review doesn't have to be exhaustive — a five-minute scan to check the approach is reasonable goes a long way.

== Agent-Assisted Deployments

Deploys are where things get genuinely dangerous, and where the gap between "agent can do this" and "agent should do this" is widest. Let's be precise about what agents should and shouldn't do here.

Agents are excellent at *monitoring* deploys. They can watch log streams, track error rates, compare latency percentiles against the pre-deploy baseline, and flag anomalies. An agent that says "error rate on `/api/checkout` has increased 3x since the deploy twelve minutes ago" is enormously valuable. It's reading data, finding patterns, and surfacing information — exactly what agents are good at.

Agents can also *suggest* actions. "Based on the error rate increase, I recommend rolling back to the previous version" is a helpful suggestion. It's the kind of thing that would normally require someone staring at a Grafana dashboard for fifteen minutes to conclude. The agent has done the analysis. A human decides whether to act on it.

What agents should not do is make the rollback decision autonomously. Production deployments are too consequential for ad-hoc agent decisions. If you want automated rollbacks, use a pre-approved runbook with hard thresholds — "if error rate exceeds 5% for three minutes, roll back automatically." That's deterministic. You tested it. You approved the logic in advance. An agent deciding on its own whether a 2.3% error rate increase "feels" significant enough to roll back? That's a recipe for either unnecessary rollbacks or missed incidents. Deterministic rules are boring. Boring is good when your revenue is on the line.

In practice, a deploy-monitoring agent looks something like this: it subscribes to your log aggregator and metrics dashboard via API, runs for fifteen minutes after each deploy, and posts a summary to Slack. "Deploy of v2.4.1 completed. Error rate stable at 0.3%. P99 latency increased from 180ms to 210ms — within normal variance. No new exception types detected." Most of the time, that summary is boring. That's the point. When it's not boring, you want to know immediately.

This connects back to the guardrails principle: production is read-only for agents. They observe, analyse, report, recommend. Humans (or pre-approved automation with deterministic rules) take action.

== The Pipeline as Context

Your CI/CD configuration is context, and agents read it like any other code. This is easy to forget — most teams treat their pipeline config as infrastructure plumbing, not as something that needs to communicate clearly. But when an agent is trying to understand why a build failed or what verification steps exist, the pipeline config is the first thing it reads.

A well-structured pipeline helps agents understand your project. Clear stage names (`build`, `unit-tests`, `integration-tests`, `deploy-staging`) tell the agent what your verification process looks like. Structured error output — JSON logs, exit codes with meaning, error categories — gives the agent something to work with when a step fails.

A pipeline that outputs `BUILD FAILED` and nothing else is useless to agents and humans alike.

Invest in pipeline observability:

- *Structured logs.* JSON or key-value pairs, not free-form text. An agent can parse `{"stage": "unit-tests", "failed": 3, "passed": 247, "failures": ["test_auth_flow", "test_rate_limit", "test_session_expiry"]}` and take meaningful action. It can't do much with `Tests failed. See above for details.`
- *Meaningful exit codes.* Don't let everything exit with code 1. Distinguish between "tests failed" (fixable) and "couldn't connect to the database" (infrastructure problem, not the agent's concern).
- *Artefact storage.* Test results, coverage reports, build logs — store them as pipeline artefacts. An agent debugging a CI failure needs to read the full output, not just the last ten lines that fit in the console view.

Consider adding a `PIPELINE.md` to your repo — a plain-language description of what each CI stage does, what its expected outputs look like, and what common failure modes exist. An agent that can read this file before debugging a CI failure will perform dramatically better than one that has to reverse-engineer your pipeline from YAML config alone. And your new hires will thank you too.

Good pipeline design and good agent integration reinforce each other. You improve your CI for agents, and your human developers benefit too. It's one of those rare investments that pays dividends in both directions.

== Starting Small

If you've read this chapter and you're tempted to wire agents into every stage of your pipeline by Friday — don't. I've seen that impulse. It usually ends with a weekend spent undoing the automation because the team wasn't ready for the volume of agent-generated noise.

The teams that succeed with agents in CI are the ones that build trust incrementally, just like with interactive agents.

The good news is that the path is well-trodden. Here's a practical adoption roadmap that I've seen work across multiple teams:

*Week 1: Auto-formatting.* Add a CI step that runs an agent to fix formatting issues on PRs. Formatting is deterministic, easy to verify, and low-risk. If the agent reformats something incorrectly, the diff is right there. Review the agent's commits for the first week to build confidence.

*Week 2: PR pre-screening.* Add agent-generated review comments on PRs. Not blocking — informational only. Let your team see what the agent catches, and calibrate whether its feedback is useful or noisy. Adjust the prompt based on what works.

*Month 1: Changelog drafting.* Point the agent at your commit history to generate release note drafts. A human edits and publishes. You're using the agent as a first-drafter, not a decision-maker. This is also a good time to set up cost monitoring and alerts.

*Month 3: Overnight agents.* By now you've built confidence in agent-generated output and you have the infrastructure — worktrees, token budgets, branch isolation, review processes. Start with a single well-scoped ticket. Review the result carefully. Iterate on your overnight script. Gradually expand to more complex tasks as your trust grows.

Notice what's _not_ on this roadmap: auto-merging, autonomous deployments, or agents making architectural decisions. Those aren't stage four. They might be stage ten, or they might never be appropriate for your team. The roadmap isn't a march towards full automation — it's a march towards the right level of automation for your context.

Resist the urge to skip steps. Each one builds on the last. You learn what your agents are good at, where they struggle, and what guardrails you need. By month three, agent-assisted CI feels natural — not because you automated everything at once, but because you earned each piece of it through experience.

The pipeline is just another environment where agents work. The same principles apply: scope tightly, verify thoroughly, trust incrementally. The only difference is that nobody's watching, so your safety nets need to be that much stronger.
