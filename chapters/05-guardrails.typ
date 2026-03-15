= Guardrails

Giving an agent power without boundaries isn't bold engineering — it's negligence. Guardrails are what make autonomous agents _usable_ in real work. They're the difference between an agent that helps you ship and one that takes down your staging environment at 3am.

And yet guardrails are not a solved problem. They're a living thing — something you tune, test, and argue about. Get them wrong in one direction and your agent is dangerous. Get them wrong in the other direction and your agent is useless. The craft is in finding the line.

== The Trust Gradient

Not every task deserves the same level of autonomy. Reading files? Low risk, let it run. Writing code in a feature branch? Medium risk, check the diff. Running database migrations? High risk, require explicit approval.

The agentic engineer develops an intuition for this gradient. You don't configure it once and forget — you adjust it per project, per task, per phase of development. Early exploration gets a long leash. Production deployment gets a short one.

Think of it like a mixing board. Each category of action has its own slider: file reads, file writes, shell commands, network access, git operations. You push each slider to the level of autonomy you're comfortable with. Some sliders stay low forever. Others you nudge up as confidence builds.

The mistake most people make is treating the gradient as binary — either the agent can do something or it can't. The reality is more nuanced. An agent might be allowed to run `npm test` without asking, but `npm install` requires a prompt. Both are shell commands. The risk profile is completely different.

== Permission Scoping

The principle is the same as in security: least privilege. An agent working on your frontend doesn't need SSH access to your database server. An agent writing unit tests doesn't need your AWS credentials.

In practice this means:
- Scoped API keys with expiration times
- Environment-specific credentials (never share prod keys with a dev agent)
- Read-only access as the default, write access as the exception
- Network isolation where possible — if the agent doesn't need internet, don't give it internet

Tools like Claude Code already have built-in permission systems — allow/deny lists for commands, file access controls, approval prompts for destructive operations. Use them. Don't blindly approve everything because clicking "yes" is faster.

A concrete allowlist might start like this:

```
allowed_commands:
  - git status
  - git diff
  - git log
  - npm test
  - npm run lint
  - cat
  - ls
  - find

denied_commands:
  - rm
  - git push
  - npm publish
  - curl
  - wget
  - docker
```

That's a day-one config. It's conservative. The agent can read, test, and explore — but it can't delete, deploy, or reach the network. You'll feel the friction immediately. The agent will ask for permission to run `npm install` when it needs a dependency. It will ask before creating a file. That's the point.

After a week, you've watched it work. You trust its judgement on file creation. You add `touch` and `mkdir` to the allowlist. After a month, you let it run `npm install` without asking — but only in the project directory, not globally. After three months, you let it push to feature branches but never to `main`.

The allowlist _grows_ with your experience. It's a log of trust decisions, and reading an engineer's allowlist tells you exactly how much agentic experience they have.

== Approval Gates

Some actions should always require a human in the loop. Not because the agent can't do them, but because the _consequences_ of getting them wrong are too high.

Good candidates for approval gates:
- Any operation that touches production data
- Deleting files or branches
- Installing new dependencies
- Making network requests to external services
- Any git push
- Modifying CI/CD configuration
- Changing environment variables or secrets

The goal isn't to slow the agent down. The goal is to create natural checkpoints where you, the engineer, can verify that the agent's trajectory still matches your intent. A quick glance at a diff takes five seconds. Recovering from a bad deploy takes hours.

Approval gates also serve a second purpose that's easy to miss: they keep you in the loop. An agent that runs for forty minutes without a single checkpoint is an agent you've lost track of. Even if it does everything correctly, you've lost your mental model of what's happening. Regular approval gates force the agent to surface its work, and they force you to stay engaged.

The best gate is one you almost never reject. If you're rejecting approvals constantly, your agent is misconfigured or miscommunicating — and you should fix the root cause, not keep clicking "no."

== Building Trust Incrementally

You wouldn't give a new hire the production database password on their first day. You'd start them with code reviews on every PR. After a few weeks, you'd let them merge to staging without a second pair of eyes. After a few months, they'd have deploy access. After a year, they'd be the one reviewing _your_ code.

Agents follow the same trajectory, just compressed.

On day one, your agent runs in a tight sandbox. Every shell command gets approved. Every file write gets reviewed. You're watching it like a hawk — not because you distrust the technology, but because you haven't _calibrated_ your expectations yet. You don't know where it's brilliant and where it's brittle.

After a week, patterns emerge. The agent is flawless at writing unit tests. It's solid at refactoring. It occasionally makes questionable choices about dependency management. Now your guardrails reflect that: tests and refactoring run freely, dependency changes get reviewed.

After a month, you've seen a hundred tasks complete successfully. You loosen the leash further. The agent commits to feature branches on its own. It runs the full test suite without asking. It installs dev dependencies when tests require them.

After three months, the agent is like a trusted colleague. You give it a task, check back in an hour, and review the PR. The guardrails are still there — it still can't push to main, still can't touch production, still can't modify CI — but they're invisible for the 95% of work that's routine.

This is the key insight: _guardrails should be barely noticeable for everyday work, and absolutely rigid for exceptional situations._ The agent should flow through its normal tasks without friction, and hit a hard wall the moment it tries something unusual. That wall is where you show up.

The engineers who never loosen guardrails end up abandoning agentic workflows entirely. The agents feel sluggish and frustrating, so they go back to doing everything manually. The engineers who loosen guardrails _too fast_ get burned by an agent that does something unexpected. The sweet spot is a steady, evidence-based ratchet.

== When Guardrails Fail

They will. An agent will misunderstand a constraint, find a creative workaround to a limitation, or encounter an edge case your guardrails didn't anticipate. This is normal.

Here's a real scenario. An engineer had `rm` and `rm -rf` on the deny list — sensible enough. The agent needed to undo some changes to a set of files. It couldn't delete them. So it ran `git checkout -- .` which _was_ on the allowlist, because checking out files from git sounds harmless. The result? Every uncommitted change in the working directory — including the engineer's own in-progress work on other files — was wiped clean. The agent solved its narrow problem and created a much larger one.

The lesson isn't that `git checkout` should be denied. It's that guardrails are _defense in depth_, not a single wall. You need multiple layers:

- *The allowlist* catches the obvious dangerous commands.
- *The sandbox* (a worktree, a container) limits the blast radius.
- *The commit history* lets you recover when something slips through.
- *Your own review* catches the things that no automated rule would flag.

No single layer is sufficient. An agent that's blocked from running `rm` will find another way to delete data if that's what it thinks the task requires. It's not being malicious — it's being _resourceful_. The same creativity that makes agents useful is the thing that makes single-layer guardrails insufficient.

The response isn't to remove autonomy — it's to improve the guardrails and add layers. Every failure is a signal. Treat it like a bug: understand what happened, add a check, and move on. Over time, your guardrail configuration becomes a reflection of hard-won experience, not unlike how a `.gitignore` grows with a project.

The best agentic engineers don't fear agent mistakes. They build systems where mistakes are caught early, contained quickly, and learned from automatically.

== The Cost of Too Many Guardrails

There's a failure mode that nobody talks about because it doesn't look like a failure. It looks like caution.

You configure your agent with approval gates on everything. Every file write: approval. Every shell command: approval. Every git operation: approval. The agent asks, you approve, the agent asks, you approve. Fifteen minutes into a task, you've clicked "yes" forty times and you're exhausted.

At this point, you're not using an agentic workflow. You're using a very slow, very annoying autocomplete. The agent does the typing and you do the thinking — which is exactly the same division of labour you had _before_ agents, except now there's a confirmation dialog in the way.

Over-constrained agents produce two outcomes, both bad. Either the engineer gives up and stops using agents, concluding they're "not ready yet." Or — worse — the engineer starts approving everything without reading it, because the approval fatigue has trained them to click "yes" reflexively. Now you have guardrails that _feel_ safe but provide zero actual protection.

The skill is in finding the sweet spot. You want guardrails tight enough to catch genuine mistakes, and loose enough that the agent can _flow_. A good heuristic: if you're approving the same type of action more than five times in a session, it should probably be on the allowlist.

Another heuristic: track how often your approvals actually reject something. If you've approved five hundred actions and rejected three, your guardrails are too aggressive for those action types. If you've approved fifty and rejected ten, they're well-calibrated — those ten rejections are the ones that matter.

The goal is an agent that works like a skilled contractor. It shows up, does the job, and checks in with you at meaningful milestones. Not after every hammer swing.

== Environment-Specific Guardrails

Your development laptop, your staging server, and your production environment are three completely different risk profiles. Your guardrails should reflect that.

*Local development* is where you give agents the most freedom. The agent can install packages, run arbitrary commands, modify any file, and execute tests — because the worst case is that you `git reset` and start over. Your local machine is a playground. Let the agent play.

Even here, there are limits. The agent shouldn't have access to production credentials. It shouldn't be able to push to `main`. It shouldn't be able to publish packages. But within the bounds of "local development on a feature branch," let it move fast.

*Staging* tightens the screws. The agent can deploy to staging — but with approval. It can read staging logs and query staging databases — but not modify data. It can run integration tests against staging services — but not reconfigure those services. Staging is where you verify that the agent's work survives contact with a real environment, and the guardrails reflect the higher stakes.

*Production* is a different animal entirely. The most honest advice: your production agent should be read-only, if it exists at all. Let it query logs. Let it read metrics. Let it investigate incidents by pulling data. But the moment it needs to _change_ something in production — a config value, a database record, a running service — that's a human decision, full stop.

Some teams allow agents to execute pre-approved runbooks in production: restart a service, scale up replicas, roll back to a known-good deploy. These are tightly scoped, well-tested operations with clear rollback paths. That's reasonable. But "let the agent figure out how to fix the production incident" is not a guardrail configuration — it's a prayer.

The pattern is simple: the closer you are to real users and real data, the tighter the guardrails get. Your local agent is a collaborator. Your staging agent is a supervised worker. Your production agent is a read-only observer.

Set this up once, and it becomes invisible. The agent adjusts its behaviour based on the environment it's operating in. It moves fast locally, checks in on staging, and goes hands-off in production. That's not friction — that's engineering.
