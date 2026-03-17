= Extending the Agent's Reach

Last month I was debugging a production issue — intermittent 502s on a checkout endpoint. The logs were in Datadog. The relevant config was in our Kubernetes cluster. The ticket history was in Linear. The database schema was in PostgreSQL. The code was in my editor.

I had six browser tabs open, copying and pasting between them, trying to assemble enough context to understand the problem. The agent sat in my terminal, ready to help, but it could only see my local files. It was like having a brilliant colleague chained to a desk — eager to help, but blind to everything outside the repo.

Then I set up MCP servers for Datadog, our database, and Linear. The next debugging session was different. I told the agent: "The checkout endpoint is throwing intermittent 502s. Check the Datadog logs for the last hour, look at the relevant database tables, and read the Linear ticket for context." The agent pulled logs, queried the schema, read the ticket history, correlated the timestamps, and identified the issue in four minutes: a connection pool exhaustion caused by a missing timeout on a downstream service call. I didn't copy a single thing. I didn't switch a single tab.

That's what tool integrations do. They expand the agent's world from "files on your disk" to "every system you work with."

== What Is MCP?

The Model Context Protocol — MCP — is an open standard for connecting AI agents to external data sources and tools. Think of it as USB for agents: a standard plug that lets any agent talk to any service, without custom integration code for every combination.

Before MCP, connecting an agent to your database meant writing a bespoke wrapper. Connecting it to Jira meant a different wrapper. Connecting it to Slack, another. Every agent framework had its own plugin system, its own tool definition format, its own way of handling authentication. If you switched frameworks, you rewrote everything.

MCP standardises this. An MCP server is a small program that exposes a set of tools — functions the agent can call — over a consistent protocol. The agent framework connects to any MCP server the same way. Want to give your agent access to PostgreSQL? Run a Postgres MCP server. Want it to read your Notion docs? Run a Notion MCP server. Want it to query your monitoring stack? There's an MCP server for that.

The agent doesn't know or care what's behind the protocol. It sees tools: "query the database," "search Notion pages," "fetch Datadog logs." It calls them the same way it calls any other tool — read a file, run a command. The MCP server handles the translation between the agent's request and the external system's API.

This is a bigger deal than it sounds. It means the ecosystem of agent capabilities grows independently of any single agent framework. Someone builds a Stripe MCP server, and _every_ MCP-compatible agent can now work with Stripe. The network effect is the same one that made USB ubiquitous: one standard, many devices, everyone benefits.

== Why This Matters for Engineering

If you've read the context chapter, you know that an agent is only as good as what it can see. Tool integrations are how you give it eyes beyond the filesystem.

Consider what a typical engineering task actually involves:

- The *code* lives in your repo.
- The *bug report* lives in Jira, Linear, or GitHub Issues.
- The *error logs* live in Datadog, Sentry, or CloudWatch.
- The *database schema* lives in PostgreSQL, MySQL, or MongoDB.
- The *API documentation* lives in Notion, Confluence, or a wiki.
- The *deployment status* lives in your CI/CD platform.
- The *design spec* lives in Figma or a Google Doc.

An agent with access only to your repo is working with maybe 30% of the context it needs. The rest is scattered across six different systems, each with its own interface, its own authentication, its own query language. You spend your day as a human middleware layer — copying error logs from Datadog, pasting them into the agent's context, copying the agent's questions, looking up the answer in Confluence, pasting it back.

Tool integrations eliminate that middleware layer. The agent queries Datadog directly. It reads the Notion doc itself. It checks the deployment status without you switching tabs. You go from being a clipboard to being a captain — giving direction instead of shuttling data.

== The Practical Setup

Setting up MCP servers is simpler than it sounds. Most agent frameworks that support MCP — Claude Code, Cline, Continue, and others — let you configure servers in a JSON file. Here's what a typical configuration looks like:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_..."
      }
    }
  }
}
```

That's it. Two servers. Your agent can now query your database and interact with GitHub — read issues, check PR status, search code. The servers start automatically when the agent session begins. No code to write. No plugins to install beyond the MCP server packages.

The ecosystem is growing fast. As of early 2026, there are community-maintained MCP servers for:

- *Databases:* PostgreSQL, MySQL, SQLite, MongoDB, Redis
- *Project management:* GitHub, GitLab, Linear, Jira, Notion
- *Monitoring:* Datadog, Sentry, Grafana
- *Communication:* Slack, Discord
- *Cloud:* AWS, GCP, Kubernetes
- *Documentation:* Confluence, Notion, Google Docs
- *APIs:* Generic REST, GraphQL, OpenAPI-based servers

You don't need all of these. Start with the two or three systems you context-switch to most often. For most engineers, that's a database and a project management tool. Add more as the workflow demands it.

== Building Your Own MCP Server

The existing servers cover common tools. But every team has internal systems — a custom admin panel, a proprietary API, an internal deployment tool, a bespoke data pipeline. This is where building your own MCP server pays off.

An MCP server is a small program that implements the MCP protocol and exposes tools. The protocol handles the communication; you write the tools. Here's what a minimal custom server looks like in TypeScript:

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from
  "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "internal-deploy",
  version: "1.0.0",
});

server.tool(
  "get-deploy-status",
  "Get the current deployment status for a service",
  { service: z.string().describe("Service name, e.g. 'checkout-api'") },
  async ({ service }) => {
    const status = await fetchDeployStatus(service);
    return {
      content: [{
        type: "text",
        text: JSON.stringify(status, null, 2)
      }]
    };
  }
);

server.tool(
  "list-recent-deploys",
  "List recent deployments across all services",
  { hours: z.number().default(24).describe("How many hours back") },
  async ({ hours }) => {
    const deploys = await fetchRecentDeploys(hours);
    return {
      content: [{
        type: "text",
        text: deploys.map(d =>
          `${d.service} → ${d.version} (${d.status}) at ${d.timestamp}`
        ).join("\n")
      }]
    };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

That's a working MCP server. It exposes two tools: one to check a specific service's deploy status, another to list recent deployments. The agent can now ask "what's the deploy status of checkout-api?" and get a real answer from your internal systems.

The pattern is always the same: define a tool with a name, a description, a schema for inputs, and a function that does the work. The description matters more than you'd think — it's what the agent reads to decide _when_ to call your tool. A vague description like "does deploy stuff" will confuse the agent about when to use it. A precise description like "Get the current deployment status for a service, including version, health, and last deploy timestamp" gives the agent exactly the information it needs to call the right tool at the right time.

Most custom MCP servers are under 200 lines of code. If you can write an API client, you can write an MCP server. The investment is small and the payoff is immediate: your agent now speaks your infrastructure's language.

== How Tool Calling Actually Works

We've been talking about tools as if the agent just "calls" them — like a function call in your code. But what actually happens under the hood is worth understanding, because it explains a lot of agent behaviour that otherwise seems mysterious.

When you send a message to an agent, the LLM doesn't execute code. It generates text. Tool calling is a structured form of that text generation. Here's the cycle:

+ *You send a prompt.* "What tables exist in the database?"
+ *The model sees available tools.* Along with your message, the model receives a list of every tool it can use — their names, descriptions, and input schemas. This is part of the system prompt or tool configuration, injected by the agent framework before the model sees your message.
+ *The model decides to call a tool.* Instead of generating a text response, the model outputs a structured tool call: the tool name and the arguments, formatted as JSON. It's not "running" anything — it's _requesting_ that the framework run something.
+ *The framework executes the tool.* The agent framework takes that structured output, validates the arguments against the schema, and actually calls the function — queries the database, reads the file, hits the API.
+ *The result goes back to the model.* The tool's output is injected into the conversation as a new message, and the model generates its next response based on that result.
+ *Repeat.* The model might call another tool, or it might finally respond to you with text. Complex tasks can involve ten, twenty, or more tool calls in sequence, each one informed by the results of the last.

This is the fundamental loop of agentic behaviour. The model _thinks_ about what to do, _acts_ by requesting a tool call, _observes_ the result, and _thinks_ again. It's a reasoning loop with real-world side effects.

Understanding this loop explains several things that trip up new agent users:

*Why agents sometimes call the wrong tool.* The model picks tools based on descriptions and the current conversation context. If two tools have similar descriptions, the model might pick the wrong one. If the description is vague, the model guesses. The tool selection is a _language_ task — the model is pattern-matching your request against tool descriptions, not executing a lookup table.

*Why agents sometimes pass wrong arguments.* The model generates arguments as structured text. If the schema isn't clear about what a parameter means, the model fills in its best guess. A parameter called `id` with no description could be a user ID, an order ID, or a database row ID. The model will guess based on conversation context, and it will sometimes guess wrong.

*Why agents sometimes call tools unnecessarily.* The model doesn't have a cost function for tool calls. It doesn't know that querying the database takes 200ms or that checking Datadog costs API credits. If a tool _might_ be relevant, the model might call it — even when the answer is already in context. This is why curating the tool list matters.

*Why agents get better with better descriptions.* This is the single most important thing to internalise. The model's _only_ information about a tool is its name, description, and parameter schema. Better descriptions lead to better tool selection. Better parameter descriptions lead to better arguments. This isn't a minor optimisation — it's the difference between an agent that works and one that flails.

== Designing Good Tools

If you're building MCP servers — or even just configuring which tools your agent can access — tool design matters enormously. A well-designed tool makes the agent smarter. A poorly designed one makes it confused.

Here are the principles I've learned the hard way:

*Name tools as verbs, not nouns.* `get-deploy-status` is better than `deploy-status`. `search-logs` is better than `logs`. `create-ticket` is better than `ticket`. The verb tells the model what the tool _does_, which helps it decide _when_ to use it.

*Write descriptions for the model, not for humans.* You might write a README that says "Queries the PostgreSQL database." For a tool description, be specific: "Execute a read-only SQL query against the production PostgreSQL database. Returns results as JSON rows. Use this when you need to check data, verify schema, or investigate data-related issues. Do not use for write operations — this connection is read-only and writes will fail." The more context you give the model about _when_ and _how_ to use the tool, the better it performs.

*Describe every parameter.* Don't just define `{ query: z.string() }`. Define `{ query: z.string().describe("A valid PostgreSQL SELECT query. Do not include INSERT, UPDATE, DELETE, or DDL statements — they will be rejected by the read-only connection.") }`. The description is the model's documentation. If you wouldn't hand an intern a function with no docstring and expect correct usage, don't do it to the model.

*Return useful error messages.* When a tool call fails, the error message goes back to the model as the tool result. A good error message lets the model self-correct. "Query failed: column 'user_id' does not exist. Did you mean 'id'? Available columns in the users table: id, email, name, created_at" is infinitely better than "SQL error." The model will read that error, understand the mistake, and retry with the correct column name. A vague error leads to repeated failures or hallucinated fixes.

*Keep tools focused.* A tool that does one thing well is better than a tool that does five things based on a `mode` parameter. `search-logs`, `get-log-entry`, and `count-log-events` are better than `logs-tool` with a `mode` field that accepts "search", "get", or "count". Focused tools have clearer descriptions, simpler schemas, and fewer failure modes. The model can reason about them independently.

*Limit output size.* If a tool can return megabytes of data, it will — and that data goes into the model's context window, crowding out everything else. Add pagination, truncation, or summarisation to your tools. Return the first 50 rows, not all 50,000. Return log snippets, not entire log files. The model works better with focused, relevant data than with a firehose.

*Include examples in descriptions when the input format isn't obvious.* If your tool expects a date in ISO 8601 format, say so: "Start date in ISO 8601 format, e.g. '2026-01-15T00:00:00Z'." If it expects a specific ID format, show one: "Service ID, e.g. 'svc-checkout-prod'." Examples eliminate an entire class of formatting errors.

These aren't arbitrary style preferences. Each principle directly affects the model's ability to use the tool correctly. I've watched the same agent go from a 40% success rate to a 95% success rate on a task, just by rewriting tool descriptions and adding parameter documentation. The tools didn't change. The model didn't change. The _interface_ between them got better.

This is the part of agentic development that feels most like API design — because that's exactly what it is. Your tools are an API for the model. Design them like you'd design any good API: clear naming, comprehensive documentation, helpful errors, and a principle of least surprise.

== MCP Resources: Giving Agents Context, Not Just Tools

Tools let agents _do_ things. But MCP also has a concept called *resources* — structured data that agents can _read_. The distinction matters.

A tool is an action: "query the database," "create a ticket," "check deploy status." A resource is reference material: "the database schema," "the API documentation," "the current project roadmap."

Resources are loaded into the agent's context at the start of a session or on demand. They're the MCP equivalent of opening a reference document before starting work. You wouldn't ask a new team member to start coding without showing them the architecture diagram. Resources are how you show it to the agent.

A practical example: you build an MCP server that exposes your database schema as a resource. Every agent session starts with the schema in context. When the agent needs to write a query, it doesn't guess at table names — it already knows them. When it needs to add a column, it knows what's already there. The resource is passive context that makes every tool call better.

The combination of tools and resources is powerful. Resources give the agent the _map_. Tools give it the _hands_. Together, they let the agent navigate your infrastructure the way you do — with both knowledge and capability.

== Trust and Guardrails for Connected Agents

Here's where the guardrails chapter comes back with a vengeance.

An agent with access to your filesystem can delete files. An agent with access to your database can delete _data_. An agent with access to your deployment pipeline can push to production. The stakes escalate with every integration you add.

The guardrails principles are the same — least privilege, approval gates, read-only defaults — but the implementation needs to be specific to each integration.

*Databases: read-only by default.* Your database MCP server should connect with a read-only user. The agent can query tables, inspect schemas, and understand data shapes. It cannot insert, update, or delete. If you need write access for specific tasks — running a migration in a dev database, inserting test fixtures — use a separate server with a separate connection string, and only enable it when the task requires it.

A minimal safe setup:

```json
{
  "mcpServers": {
    "db-readonly": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://readonly_user:pass@localhost/mydb"
      }
    }
  }
}
```

*Project management: read and comment, not create.* Let the agent read tickets, search issues, and add comments. Don't let it create tickets, close issues, or reassign work — those are human decisions with human consequences. The engineer who discovers their agent auto-closed twenty tickets because they were "resolved by the code changes" will not have a good morning.

*Monitoring: read-only, always.* The agent reads logs, queries metrics, and searches traces. It never modifies alerts, dashboards, or configurations. Monitoring systems are the _source of truth_ during incidents. An agent that can modify that truth is an agent that can hide problems.

*Communication tools: proceed with extreme caution.* Giving an agent access to Slack means it can send messages as you. Think carefully about whether "the agent posted in \#engineering" is something you're comfortable with. If so, scope it to specific channels. If not, let the agent _draft_ messages that you review before sending.

The general principle: every new integration is a new attack surface. Add them deliberately, scope them tightly, and start read-only. Expand permissions only when you've seen enough successful read-only sessions to trust the workflow.

== What Changes When Agents Can See Everything

Something subtle happens when you give an agent access to your full working environment — not just code, but logs, tickets, docs, databases, monitoring. The agent stops being a code generator and starts being an _engineering partner_.

The debugging workflow changes. Instead of "here's an error, fix it," you can say "users are reporting slow checkout. Investigate." The agent checks the logs, queries the database for slow queries, reads the recent deploy history, looks at the error rate in monitoring, and comes back with a diagnosis. It's doing what you would do — just faster, and without the tab-switching tax.

The planning workflow changes. "I need to add a notifications feature. Check the existing data model, look at how we built the email system (there's a Linear ticket about it), and propose an approach." The agent reads the schema, finds the ticket, reads the related code, and produces a plan that accounts for your existing architecture. It's not guessing — it's _informed_.

The incident response workflow changes. "We're seeing elevated error rates. Check Datadog for the last thirty minutes, look at the most recent deploy, and tell me what changed." The agent correlates logs, diffs, and deploy timestamps, and narrows the problem to a specific commit in under a minute.

The mobile development workflow changes — and this one still catches me off guard. With an Xcode MCP server, the agent can build your iOS app, spin up the simulator, navigate through screens, and take screenshots to verify its own work. You tell it "add a settings screen with a dark mode toggle," and you watch it write the SwiftUI, build the project, launch the simulator, tap through to the new screen, take a screenshot, notice the toggle alignment is off, fix it, rebuild, and screenshot again. The whole cycle — code, build, run, visually verify, iterate — happens without you touching Xcode. It's like pair programming with someone who can also _be_ the QA tester at the same time.

Building iPhone apps used to mean constant context-switching between your editor, Interface Builder, the simulator, the console, and the device. Now the agent handles the build-run-verify loop while you focus on what the app should _do_. I've watched it iterate through three rounds of UI refinement in the time it would have taken me to find the right SwiftUI modifier. The simulator spinning up on its own, the agent tapping through your app, screenshots appearing in the conversation — it makes mobile development feel like something new. Not easier, exactly. _More fluid._ The gap between "I want this" and "I can see this working" collapses from minutes to seconds.

None of this is magic. It's what you already do, manually, every day. Tool integrations just remove the friction. The agent does the same investigation you would — it just does it without the ten minutes of tab-switching, logging in, constructing queries, and copying output.

== The Integration Creep Problem

There's a failure mode here, and it's worth naming: integration creep.

You start with a database connection. Then you add Datadog. Then Notion. Then Slack. Then Jira. Then your internal admin panel. Then Stripe. Then your analytics platform. Before long, your agent has access to _everything_, and two problems emerge.

First, *context overload*. The agent now has so many tools available that it spends tokens deciding which one to use. For a simple code change, it might try to check Datadog logs, query the database, and read Jira tickets — none of which are relevant. More tools means more opportunities for the agent to take unnecessary detours.

Second, *security surface*. Each integration is a set of credentials the agent can use. Each one is a system the agent can interact with, intentionally or accidentally. The more integrations you add, the harder it is to reason about what the agent can do. You lose the ability to hold the full picture in your head — which is ironic, given that the whole point of agents is to handle complexity you can't.

The fix is the same as with context management: curate deliberately. Don't connect everything because you can. Connect the systems that are _relevant to the work you're doing now_. Use per-project configurations — your billing service project connects to Stripe and the billing database; your frontend project connects to Figma and the CDN. Not every project needs every integration.

A useful heuristic: if you wouldn't have a browser tab open to that system during a typical work session on this project, the agent doesn't need access to it either.

== The Ecosystem Is Young

I want to be honest about where things stand. MCP is real, it works, and it's the closest thing we have to a standard for agent-tool integration. But the ecosystem is still maturing.

Some MCP servers are rock-solid — the official database servers, the GitHub server, the filesystem server. Others are community-maintained side projects that may break on edge cases or fall behind on API changes. Before connecting your agent to a critical system through a third-party MCP server, read the source. It's usually a few hundred lines. Understand what it does, what permissions it requests, and what data it sends where.

The protocol itself is still evolving. New capabilities — streaming responses, OAuth flows, multi-step tool interactions — are being added. The servers you set up today might need updating in six months. That's fine. The pattern doesn't change, even when the specifics do.

And some integrations that _should_ exist don't yet. If your team uses a niche internal tool, you'll probably need to build the MCP server yourself. The good news is that it's not hard — a few hours at most for a basic read-only server. The better news is that once you build it, everyone on your team benefits, and every future agent session has access to that system.

This is the same early-adopter curve we've seen with every developer tool ecosystem. The people who invest now — building servers, contributing to the standard, figuring out the patterns — will have a significant advantage when the ecosystem matures. And it will mature. The problem MCP solves is too real and too universal for it not to.

== Start Here

If you're going to set up one integration today, make it your database. The ability to say "check the schema for the users table" or "what indexes exist on the orders table" eliminates an entire category of context-switching. A read-only database connection is low-risk, high-reward, and takes five minutes to configure.

If you're going to set up two, add your project management tool — GitHub Issues, Linear, Jira, whatever your team uses. The ability to say "read ticket PROJ-1234 and implement it" or "what tickets are assigned to me this sprint" turns the agent from a code generator into a task executor.

If you're going to set up three, add your monitoring stack. The ability to investigate production issues without leaving your terminal is a workflow transformation that, once experienced, you'll never want to give up.

Beyond that, let the work guide you. When you find yourself copying data from a system into the agent's context more than twice, that's a signal: build or install the MCP server. The friction you feel is the friction the integration removes.

The agents are already capable. The question is whether they can see enough of your world to be useful. Tool integrations are the answer.
