= Sandboxes

A sandbox is a gift you give your agent: the freedom to be wrong.

When an agent operates in a sandbox, it can try things without consequences. Install a weird dependency. Rewrite a module from scratch. Run a script that might crash. If it works, great — you pull the result out. If it doesn't, you throw the sandbox away. No cleanup, no rollback, no damage.

This isn't just a safety measure. It fundamentally changes how productive an agent can be.

== The Fear Problem

Without a sandbox, every agent action carries risk. The agent hesitates (or rather, you hesitate to let it act). You add more constraints, more approval gates, more guardrails — and soon the agent is barely more useful than a fancy autocomplete.

Sandboxes solve this by making the _cost of failure_ essentially zero. And when failure is cheap, experimentation is free. An agent in a sandbox can try three different approaches to a problem, run them all, and let you pick the winner. That's a workflow that's impossible when every action is irreversible.

== Git Worktrees

For code-focused work, git worktrees are the lightest sandbox you can build. A worktree gives you a full copy of your repo in a separate directory, on its own branch, in seconds.

The workflow looks like this:
+ Create a worktree for the task
+ Point the agent at it
+ Let it work — commits, file changes, test runs, whatever it needs
+ Review the result
+ Merge if good, delete the worktree if not

No containers to build, no VMs to boot. Just git. This is especially powerful when you're running multiple agents in parallel — each gets its own worktree, its own branch, its own isolated workspace.

== Containers

For tasks that go beyond code — installing system packages, running services, testing infrastructure changes — containers are the natural sandbox. Docker gives you a reproducible, isolated environment that you can spin up in seconds and destroy just as fast.

The key is to make your project container-friendly. A good `Dockerfile` and `docker-compose.yml` aren't just for deployment anymore — they're agent infrastructure. When your project can boot in a container with one command, you've given every agent the ability to work in a clean room.

== Ephemeral Environments

The most sophisticated sandboxes are cloud-based ephemeral environments — short-lived preview deployments that spin up per branch or per task. Services like Railway, Fly.io, or cloud dev environments give you a full running stack that's completely disposable.

This matters for integration testing. An agent can deploy its changes to an ephemeral environment, run end-to-end tests against real infrastructure, verify everything works, and then you decide whether to promote it to staging. The agent never touches your real environments.

== The Sandbox Mindset

The deeper lesson isn't about tools — it's about designing your workflow around disposability. If your development environment takes an hour to set up, sandboxes are impractical. If it takes thirty seconds, they're natural.

Invest in fast, reproducible setup. Invest in infrastructure as code. Invest in making your project easy to boot from scratch. These investments pay for themselves every time an agent needs a safe space to work — which, as you get better at agentic engineering, is constantly.
