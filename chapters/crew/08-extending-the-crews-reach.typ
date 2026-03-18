= Extending the Crew's Reach

#figure(
  image("../../assets/illustrations/crew/ch08-extending-reach.jpg", width: 80%),
  caption: [_Connecting the agent to the world beyond its window._],
)

An agent that can only read and write text is useful. An agent that can connect to your tools — your calendar, your spreadsheets, your project management app, your email — is transformative.

This chapter is about giving your agent _hands_. Not the technical plumbing (your developer can handle that) but the concept of what becomes possible when an agent can reach beyond the conversation window and interact with the systems you already use.

== The Empty Desk vs. The Connected Workstation

Remember the new employee metaphor? A smart person with no access to any systems is just someone sitting at an empty desk. Give them access to your calendar and they can schedule meetings. Give them access to your CRM and they can update client records. Give them access to your document storage and they can research answers to your questions.

Agents work the same way. Each connection you add — each _integration_ — expands what the agent can do:

- *Connected to your file system:* The agent can read your documents, analyse spreadsheets, organise folders.
- *Connected to the web:* The agent can research competitors, check documentation, look up current information.
- *Connected to your email:* The agent can draft replies, summarise threads, flag urgent messages.
- *Connected to your project management tool:* The agent can create tasks, update statuses, generate reports.
- *Connected to your database:* The agent can query data, generate reports, and find patterns you'd miss in a spreadsheet.

Each of these is a tool in the agent's hands. More tools means more capability — but also more responsibility, which is why the trust gradient exists.

== No-Code Plumbing

You don't need to be a developer to connect things together. A growing ecosystem of tools exists to wire up systems without writing code:

*Zapier, Make (formerly Integromat), n8n* — These are automation platforms. They let you create "if this, then that" workflows: "When a new row appears in my spreadsheet, create a task in my project management tool." "When I receive an email from a specific client, summarise it and post the summary to Slack."

These aren't agents — they're pipelines. But they can work _with_ agents. An agent drafts a quote, and a Zapier workflow sends it to the client and logs it in the CRM. The agent does the thinking. The pipeline does the plumbing.

*Apple Shortcuts, Power Automate* — Lighter versions for personal workflows. "Every morning, have an agent summarise my unread emails and put the summary in my Notes app." These are small, but they compound.

*MCP (Model Context Protocol)* — This is a newer standard that lets agents connect directly to external tools in a standardised way. It's technical under the hood, but the result is simple: instead of you copying data _into_ the agent, the agent can go _get_ data from your tools. Your developer will set it up. You'll enjoy the results.

== The Multiplier Effect

Each tool integration doesn't just add — it multiplies. An agent that can read your sales data _and_ access your email _and_ check your calendar can do things none of those connections could do alone:

"Check my sales data for Q2, find the three biggest accounts that haven't been contacted in over 30 days, draft follow-up emails for each, and suggest meeting times based on my calendar availability next week."

That's one prompt. Four tools. A task that would have taken you ninety minutes, done in five.

This is the compound effect of tool integration. Each new connection opens up combinations that weren't possible before. The people who get the most from agents are rarely the ones with the most powerful model — they're the ones with the most connected workspace.

== The Privacy Question

Every tool you connect to an agent is a door you're opening. Before you connect something, ask:

- *What data will the agent be able to see?* Connecting your email means the agent can read _all_ your email, not just the thread you're working on.
- *What can the agent do with it?* Read-only access is very different from read-write access. Can the agent just view your calendar, or can it create and delete events?
- *Where does the data go?* When the agent reads your spreadsheet, that data is sent to the AI provider's servers. Is that acceptable for this data? Would it be acceptable for your client's data?
- *What would happen if this went wrong?* An agent with delete access to your file system can accidentally delete files. An agent with send access to your email can accidentally send an email. Think about the worst case.

This isn't a reason to avoid tool integration. It's a reason to be intentional about it. Connect what you need. Grant the minimum access required. And apply the trust gradient: start read-only, upgrade to read-write after you've built confidence.
