= Sandboxes

#figure(
  image("../assets/illustrations/ch06-sandbox.jpg", width: 60%),
)

A sandbox is a gift you give your agent: the freedom to be wrong.

When an agent operates in a sandbox, it can try things without consequences. Install a weird dependency. Rewrite a module from scratch. Run a script that might crash. If it works, great — you pull the result out. If it doesn't, you throw the sandbox away. No cleanup, no rollback, no damage.

This isn't just a safety measure. It fundamentally changes how productive an agent can be.

== The Fear Problem

Without a sandbox, every agent action carries risk. The agent hesitates (or rather, you hesitate to let it act). You add more constraints, more approval gates, more guardrails — and soon the agent is barely more useful than a fancy autocomplete.

Sandboxes solve this by making the _cost of failure_ essentially zero. And when failure is cheap, experimentation is free. An agent in a sandbox can try three different approaches to a problem, run them all, and let you pick the winner. That's a workflow that's impossible when every action is irreversible.

== Git Worktrees

We covered worktrees in the Git chapter as an isolation and branching tool. Here they earn a second mention because, viewed through the sandbox lens, they're the lightest disposable environment you can build — a full copy of your repo in a separate directory, on its own branch, in seconds. No containers to build, no VMs to boot. Just git.

The sandbox value is distinct from the version-control value: a worktree makes the _cost of failure_ essentially zero. The agent can try wild approaches, install odd dependencies, rewrite modules from scratch — and if the result is bad, you delete the worktree. No cleanup. This is especially powerful when you're running multiple agents in parallel — each gets its own worktree, its own branch, its own isolated workspace.

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

== Containers

For tasks that go beyond code — installing system packages, running services, testing infrastructure changes — containers are the natural sandbox. Docker gives you a reproducible, isolated environment that you can spin up in seconds and destroy just as fast.

The key is to make your project container-friendly. A good `Dockerfile` and `docker-compose.yml` aren't just for deployment anymore — they're agent infrastructure. When your project can boot in a container with one command, you've given every agent the ability to work in a clean room.

A minimal agent-friendly Dockerfile looks like this:

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Agent can run tests, lint, build — all isolated
CMD ["npm", "test"]
```

The pattern is: fast to build, easy to destroy, contains everything the agent needs to verify its own work. If your container takes fifteen minutes to build, the agent won't iterate quickly enough to be useful. Optimise for rebuild speed — layer your dependencies, use slim base images, cache aggressively.

== Ephemeral Environments

The most sophisticated sandboxes are cloud-based ephemeral environments — short-lived preview deployments that spin up per branch or per task. Services like Railway, Fly.io, or cloud dev environments give you a full running stack that's completely disposable.

This matters for integration testing. An agent can deploy its changes to an ephemeral environment, run end-to-end tests against real infrastructure, verify everything works, and then you decide whether to promote it to staging. The agent never touches your real environments.

The economics are compelling. A preview environment that runs for two hours while the agent works costs pennies. The production incident it prevents costs thousands. The maths always favours more sandboxing, not less.

== The Sandbox Spectrum

There's a spectrum of sandboxing, and the right choice depends on the task:

*Worktrees* — for pure code changes. Fastest to create and destroy. No isolation beyond the filesystem. Good for: refactors, feature branches, test writing. Seconds to set up.

*Containers* — for code plus environment. Isolated filesystem, network, and processes. Good for: dependency changes, system-level work, anything that might pollute your local machine. Minutes to set up.

*Ephemeral cloud environments* — for full-stack verification. Real infrastructure, real databases, real network topology. Good for: integration testing, deployment verification, multi-service changes. Minutes to set up, but costs real money.

*VMs* — for maximum isolation. Separate kernel, separate everything. Good for: security-sensitive work, untrusted agents, infrastructure automation. Minutes to hours to set up.

Start with worktrees. Move up the spectrum when the task demands it. Most day-to-day agentic work never needs more than a worktree.

== The Sandbox Mindset

The deeper lesson isn't about tools — it's about designing your workflow around disposability. If your development environment takes an hour to set up, sandboxes are impractical. If it takes thirty seconds, they're natural.

Invest in fast, reproducible setup. Invest in infrastructure as code. Invest in making your project easy to boot from scratch. These investments pay for themselves every time an agent needs a safe space to work — which, as you get better at agentic engineering, is constantly.

A useful litmus test: can a new developer (or a new agent) go from `git clone` to running tests in under two minutes? If not, you have sandbox debt. Every minute of setup friction is a minute that discourages sandboxing — and unsandboxed agents are agents working without a net.
