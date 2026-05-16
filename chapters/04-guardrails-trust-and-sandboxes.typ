= Guardrails, Trust, and Sandboxes

Giving an agent power without boundaries isn't bold engineering — it's negligence. Guardrails are what make autonomous agents _usable_ in real work. They're the difference between an agent that helps you ship and one that takes down your staging environment at 3am.

And yet guardrails are not a solved problem. They're a living thing — something you tune, test, and argue about. Get them wrong in one direction and your agent is dangerous. Get them wrong in the other direction and your agent is useless. The craft is in finding the line.

== The Trust Gradient

Not every task deserves the same level of autonomy. Reading files? Low risk, let it run. Writing code in a feature branch? Medium risk, check the diff. Running database migrations? High risk, require explicit approval.

Think of it like a mixing board. Each category of action has its own slider: file reads, file writes, shell commands, network access, git operations. You push each slider to the level of autonomy you're comfortable with. Some sliders stay low forever. Others you nudge up as confidence builds.

The mistake most people make is treating the gradient as binary — either the agent can do something or it can't. The reality is more nuanced. An agent might be allowed to run `npm test` without asking, but `npm install` requires a prompt. Both are shell commands. The risk profile is completely different.

And the gradient shifts over time. On day one, your agent runs in a tight sandbox. Every shell command gets approved. Every file write gets reviewed. You don't know yet where it's brilliant and where it's brittle, so you watch everything.

After a week, patterns emerge. The agent is flawless at writing unit tests. It's solid at refactoring. It occasionally makes questionable choices about dependency management. Now your sliders reflect that: tests and refactoring run freely, dependency changes get reviewed.

After a month, you've seen a hundred tasks complete successfully. You loosen the sliders further. The agent commits to feature branches on its own. It runs the full test suite without asking. After three months, it's like a trusted colleague — you give it a task, check back in an hour, and review the PR. The guardrails are still there, but they're invisible for the 95% of work that's routine.

This is the key insight: _guardrails should be barely noticeable for everyday work, and absolutely rigid for exceptional situations._ The agent should flow through its normal tasks without friction, and hit a hard wall the moment it tries something unusual. That wall is where you show up.

The engineers who never adjust the sliders end up abandoning agentic workflows entirely. The engineers who push them too fast get burned. The sweet spot is a steady, evidence-based ratchet.

== Permission Scoping

The principle is the same as in security: least privilege. An agent working on your frontend doesn't need SSH access to your database server. An agent writing unit tests doesn't need your AWS credentials.

But it's worth pausing to notice that guardrails aren't just about _restricting_ what agents can do — they're the flip side of _equipping_ them. Every tool you grant is both a capability and a responsibility. The trust gradient from the previous section is really about calibrating how much autonomous context-gathering and action you allow. Guardrails and tools are the same list, viewed from two directions.

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

The best gate is one you almost never reject. If you're rejecting approvals constantly, your agent is misconfigured or miscommunicating — and you should fix the root cause, not keep clicking "no."

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

== When Your Agent _Is_ the Threat Model

There's a special case worth flagging: agents that are _designed_ to be destructive. In Appendix A, we look at autonomous pentesting — AI agents that probe your application for security vulnerabilities by actively exploiting them. Injection payloads, authentication bypasses, SSRF attacks — the agent does it all, on purpose.

This inverts the usual guardrail calculus. Normally, guardrails protect your system from the agent's mistakes. With a pentesting agent, guardrails protect _everything else_ from the agent's _intentional_ hostility. The trust gradient doesn't loosen over time — it stays locked down permanently. The sandbox isn't a convenience — it's a legal requirement. And human oversight isn't a nice-to-have — it's the difference between a security assessment and an incident.

The principles are the same. The stakes are higher. If your guardrail configuration can handle an agent that's _trying_ to break things, it can handle anything.

== The Cost of Too Many Guardrails

There's a failure mode that looks like caution but isn't. You configure your agent with approval gates on everything — every file write, every shell command, every git operation. Fifteen minutes into a task, you've clicked "yes" forty times and you're not reading them any more.

That's the danger. Over-constrained agents produce two outcomes, both bad. Either the engineer gives up and stops using agents, concluding they're "not ready yet." Or — worse — approval fatigue trains them to click "yes" reflexively. Now you have guardrails that _feel_ safe but provide zero actual protection.

The skill is in finding the sweet spot. You want guardrails tight enough to catch genuine mistakes, and loose enough that the agent can _flow_. A good heuristic: if you're approving the same type of action more than five times in a session, it should probably be on the allowlist.

Another heuristic: track how often your approvals actually reject something. If you've approved five hundred actions and rejected three, your guardrails are too aggressive for those action types. If you've approved fifty and rejected ten, they're well-calibrated — those ten rejections are the ones that matter.

The goal is an agent that works like a skilled contractor. It shows up, does the job, and checks in with you at meaningful milestones. Not after every hammer swing.

== The Ethics of Delegation

There's a guardrail that no configuration file can enforce: your own judgment about what _should_ be delegated to an agent.

An agent can write a performance improvement plan for an employee. Should it? An agent can draft a response to a customer complaint. Should it? An agent can generate commit messages that make it look like a human wrote code that an agent actually produced. Should it?

These aren't technical questions. They're ethical ones, and they deserve explicit attention because the default — "the agent can do it, therefore I'll let it" — is not an answer. It's the absence of one.

Three principles that hold up well in practice:

*Transparency about provenance.* If an agent generated the code, the commit should say so. If an agent drafted the document, the reader should know. Not because agent work is inferior — often it isn't — but because hiding the provenance undermines trust. When a colleague reviews a PR and later discovers it was agent-generated with no indication, they feel deceived — even if the code is flawless. A simple `Co-Authored-By` tag or a note in the PR description is enough. Transparency costs nothing and buys trust.

*Accountability doesn't delegate.* The agent doesn't have a performance review. It doesn't get paged at 2am. When you delegate to an agent, you're still the engineer of record. If the agent introduces a bug, you own it. If the agent makes a design decision that creates technical debt, you own that too. This isn't about blame — it's about recognising that delegation doesn't transfer responsibility. You are the pilot. The agent is the autopilot. When the autopilot makes a mistake, the investigation starts with the pilot.

*Human decisions stay human.* Anything that affects people's careers, compensation, access, or wellbeing should involve human judgment, not agent output. An agent can gather data for a code review, but the _assessment_ of a colleague's work should come from a person. An agent can draft options for a technical decision, but the _decision_ — with its tradeoffs, politics, and long-term implications — belongs to the team. The boundary isn't always clear, but the principle is: agents inform, humans decide.

The teams that think about these questions early build healthier relationships with their tools. The ones that don't tend to discover the boundaries the hard way — when someone feels deceived, when accountability is unclear, or when an agent makes a decision that nobody would have approved if they'd been asked.

== Environment-Specific Guardrails

Your development laptop, your staging server, and your production environment are three completely different risk profiles. Your guardrails should reflect that.

*Local development* is where you give agents the most freedom. The agent can install packages, run arbitrary commands, modify any file, and execute tests — because the worst case is that you `git reset` and start over. Your local machine is a playground. Let the agent play.

Even here, there are limits. The agent shouldn't have access to production credentials. It shouldn't be able to push to `main`. It shouldn't be able to publish packages. But within the bounds of "local development on a feature branch," let it move fast.

*Staging* tightens the screws. The agent can deploy to staging — but with approval. It can read staging logs and query staging databases — but not modify data. It can run integration tests against staging services — but not reconfigure those services. Staging is where you verify that the agent's work survives contact with a real environment, and the guardrails reflect the higher stakes.

*Production* is a different animal entirely. The most honest advice: your production agent should be read-only, if it exists at all. Let it query logs. Let it read metrics. Let it investigate incidents by pulling data. But the moment it needs to _change_ something in production — a config value, a database record, a running service — that's a human decision, full stop.

Some teams allow agents to execute pre-approved runbooks in production: restart a service, scale up replicas, roll back to a known-good deploy. These are tightly scoped, well-tested operations with clear rollback paths. That's reasonable. But "let the agent figure out how to fix the production incident" is not a guardrail configuration — it's a prayer.

The pattern is simple: the closer you are to real users and real data, the tighter the guardrails get. Your local agent is a collaborator. Your staging agent is a supervised worker. Your production agent is a read-only observer.

Set this up once, and it becomes invisible. The agent adjusts its behaviour based on the environment it's operating in. It moves fast locally, checks in on staging, and goes hands-off in production. Once your team agrees on these boundaries, they rarely need revisiting — and when they do, it's because something went wrong in production, which is exactly when you want to be rethinking guardrails anyway.

== Sandboxes: The Freedom to Be Wrong

#figure(
  image("../assets/illustrations/ch06-sandbox.jpg", width: 60%),
)

A sandbox is a gift you give your agent: the freedom to be wrong.

When an agent operates in a sandbox, it can try things without consequences. Install a weird dependency. Rewrite a module from scratch. Run a script that might crash. If it works, great — you pull the result out. If it doesn't, you throw the sandbox away. No cleanup, no rollback, no damage.

This isn't just a safety measure. It fundamentally changes how productive an agent can be. Without a sandbox, every agent action carries risk. You add more constraints, more approval gates — and soon the agent is barely more useful than a fancy autocomplete. Sandboxes solve this by making the cost of failure essentially zero. And when failure is cheap, experimentation is free.

=== The Sandbox Spectrum

There's a spectrum of sandboxing, and the right choice depends on the task:

*Git worktrees* — for pure code changes. A worktree is a separate checkout of your repo in a different directory, on its own branch, sharing the same `.git` history. Creating one takes seconds. The agent works in its own branch, its own directory. If the result is good, you merge it. If not, you delete the worktree and move on. No containers, no VMs, no cloud resources. Just Git.

I keep a shell alias for this because I use it so often:

```bash
# In .bashrc / .zshrc
agent-sandbox() {
  local name="${1:?Usage: agent-sandbox <name>}"
  local branch="agent/$name"
  local dir="../$(basename $PWD)-$name"
  git worktree add "$dir" -b "$branch"
  echo "Sandbox ready: $dir (branch: $branch)"
}
```

*Containers* — for code plus environment. Isolated filesystem, network, and processes. Good for: dependency changes, system-level work, anything that might pollute your local machine. The key is to make your project container-friendly — a good `Dockerfile` and `docker-compose.yml` aren't just for deployment anymore, they're agent infrastructure. Optimise for rebuild speed: layer your dependencies, use slim base images, cache aggressively.

*Ephemeral cloud environments* — for full-stack verification. Services like Railway, Fly.io, or cloud dev environments give you a full running stack that's completely disposable. A preview environment that runs for two hours while the agent works costs pennies. The production incident it prevents costs thousands.

*VMs* — for maximum isolation. Separate kernel, separate everything. Good for: security-sensitive work, untrusted agents, infrastructure automation.

Start with worktrees. Move up the spectrum when the task demands it. Most day-to-day agentic work never needs more than a worktree.

=== The Sandbox Mindset

The deeper lesson isn't about tools — it's about designing your workflow around disposability. If your development environment takes an hour to set up, sandboxes are impractical. If it takes thirty seconds, they're natural.

A useful litmus test: can a new developer (or a new agent) go from `git clone` to running tests in under two minutes? If not, you have sandbox debt. Every minute of setup friction is a minute that discourages sandboxing — and unsandboxed agents are agents working without a net.
