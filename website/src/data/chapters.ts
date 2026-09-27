// Chapter metadata for the homepage. Keep in sync with book.typ / book-crew.typ.

export interface Chapter { number: string; title: string; description: string; isNew?: boolean }

export const engineeringChapters: Chapter[] = [
  {
    number: "01",
    title: "Introduction",
    description: "The fundamental loop of software engineering is breaking. What it means to go from writing software to engineering it — with a crew of agents at your side."
  },
  {
    number: "02",
    title: "What Is an Agent?",
    description: "Model, tools, loop, and harness. What makes something truly agentic, how tool calling actually works, how agents fail, and the right mental model for working with them."
  },
  {
    number: "03",
    title: "Context",
    description: "The most important skill in agentic engineering is context engineering. Curating what agents see, compaction, sub-agents for isolation, and why bigger windows didn't remove the tax."
  },
  {
    number: "04",
    title: "Guardrails, Trust, and Sandboxes",
    description: "The trust gradient, real permission configs, hooks the model can't talk its way around, sandboxing, and the ethics of delegation."
  },
  {
    number: "05",
    title: "Git as Agent Infrastructure",
    description: "Small commits, descriptive messages, branch-per-task, worktrees for parallel agents, and reviewing at the volume agents produce."
  },
  {
    number: "06",
    title: "Testing as the Feedback Loop",
    description: "Tests become the agent's eyes. TDD as a superpower, fast test suites as agent infrastructure, and the virtuous cycle of better tests and more autonomous agents."
  },
  {
    number: "07",
    title: "Convention Over Configuration",
    description: "Consistent structure, AGENTS.md instruction files, and skills — conventions your agents can execute, not just read."
  },
  {
    number: "08",
    title: "The Ship's Log",
    description: "Memory for agentic workflows — capturing knowledge across sessions and agents, separating knowledge from execution state, and keeping memory safe."
  },
  {
    number: "09",
    title: "Extending the Agent's Reach",
    description: "MCP, remote servers, and connecting agents to databases, monitoring, and project management — without drowning them in tools."
  },
  {
    number: "10",
    title: "The Agent Attack Surface",
    description: "New in the second edition. Prompt injection, the lethal trifecta, poisoned tools, slopsquatting, and layered defences that limit the blast radius."
  },
  {
    number: "11",
    title: "Articulating Intent",
    description: "From doing to articulating. Plan-first workflows, specs, constraints, task decomposition, voice and visual context, and skills as the modern prompt library."
  },
  {
    number: "12",
    title: "Local, Commercial, and Hybrid Models",
    description: "Capability, cost, privacy, and speed. Open-weight models, subscriptions versus API spend, honest ROI, and matching the model to the task."
  },
  {
    number: "13",
    title: "Multi-Agent Orchestration",
    description: "Sub-agents for context isolation, background agents that return PRs, the handover pattern, and knowing when more agents isn't better."
  },
  {
    number: "14",
    title: "Agents in the Pipeline",
    description: "Agents in CI/CD — review bots, the overnight agent turned product, cost control, and untrusted input when nobody's watching."
  },
  {
    number: "15",
    title: "Building Your Own Agents",
    description: "New in the second edition. From driving a coding agent to shipping your own — owning the loop, the context, human approvals, durable state, and evals."
  },
  {
    number: "16",
    title: "When Agents Get It Wrong",
    description: "War stories from the field — the eager refactorer, the hallucinated library, the poisoned ticket — plus a diagnostic playbook for fixing agent failures."
  },
  {
    number: "17",
    title: "When Not to Use Agents",
    description: "The overhead tax, architecture decisions, security-critical code, hostile input, legacy codebases, and the craft argument."
  },
  {
    number: "18",
    title: "Agentic Teams",
    description: "Measured versus perceived productivity, code review at volume, a path for junior engineers, knowledge distribution, compliance, and hiring."
  },
  {
    number: "19",
    title: "Final Words",
    description: "The craft isn't dying — it's shedding its skin. What changed my mind since the first edition, and why the captain still matters."
  },
];

export const crewChapters: Chapter[] = [
  {
    number: "01",
    title: "Welcome to the Crew",
    description: "The horizon is wider than you think. Why this book exists — and why it's for you."
  },
  {
    number: "02",
    title: "The Ground Is Shifting",
    description: "The line between technical and non-technical is dissolving. What's changing, and why it matters for your role."
  },
  {
    number: "03",
    title: "What's Under the Hood",
    description: "Every app is a restaurant — front of house, kitchen, and pantry. A plain-language tour of how software actually works."
  },
  {
    number: "04",
    title: "What Is an Agent, Really?",
    description: "Observe, plan, act, check — repeat. The mental model that makes everything else click."
  },
  {
    number: "05",
    title: "How to Give Good Instructions",
    description: "The difference between a good instruction and a bad one. The two-captains story that changes how you think about prompts."
  },
  {
    number: "06",
    title: "Context In, Verification Out",
    description: "An agent can only work with what's on the bench. How to set up the right inputs and check the outputs."
  },
  {
    number: "07",
    title: "The Trust Gradient",
    description: "Start tight. Loosen with evidence. How much autonomy to give, and when to pull the reins."
  },
  {
    number: "08",
    title: "Extending the Crew's Reach",
    description: "Connecting the agent to the world beyond its window — tools, databases, and integrations."
  },
  {
    number: "09",
    title: "Building Something Real",
    description: "From idea to working prototype in a weekend. Your first hands-on walkthrough."
  },
  {
    number: "10",
    title: "The Padlock",
    description: "The sealed envelope — how the internet keeps secrets. Security explained without jargon."
  },
  {
    number: "11",
    title: "Building Something Without Code",
    description: "The principles transfer to everything. A second walkthrough that proves you don't need to be a programmer."
  },
  {
    number: "12",
    title: "When Things Go Wrong",
    description: "The mistakes are inevitable. The recovery is a skill. Real war stories and how to handle them."
  },
  {
    number: "13",
    title: "When to Do It Yourself",
    description: "Sometimes the right tool is your own hands. Knowing when agents aren't the answer."
  },
  {
    number: "14",
    title: "Being the Human in the Loop",
    description: "You are the quality control. What it means to review, verify, and direct — not just delegate."
  },
  {
    number: "15",
    title: "Talking to Your Tech Team",
    description: "You speak two languages now. How to bridge the gap between technical and non-technical colleagues."
  },
  {
    number: "16",
    title: "Keeping Your Finger on the Pulse",
    description: "Ten minutes, three times a week. How to stay current without drowning in the firehose."
  },
  {
    number: "17",
    title: "Getting Started: Your First Agent",
    description: "Which tool do you actually open on Monday morning? A practical guide to your first steps."
  },
  {
    number: "18",
    title: "Final Words",
    description: "Now go build something. You were always technical enough."
  },
];

export const newInSecondEdition = new Set(["The Agent Attack Surface", "Building Your Own Agents"]);

// Parts of the voyage — ranges are 1-based chapter numbers (inclusive).
export const parts = [
  { numeral: "I", title: "Setting Sail", subtitle: "What changed, and what an agent really is", from: 1, to: 2 },
  { numeral: "II", title: "Rigging the Ship", subtitle: "The durable foundations: context, guardrails, git, tests, conventions, memory", from: 3, to: 8 },
  { numeral: "III", title: "Beyond the Harbour", subtitle: "Reach, risk, intent, and the models underneath", from: 9, to: 12 },
  { numeral: "IV", title: "Running a Fleet", subtitle: "Many agents, pipelines, and building your own", from: 13, to: 15 },
  { numeral: "V", title: "Hard-Won Lessons", subtitle: "Failure, restraint, teams, and what lasts", from: 16, to: 19 },
];
