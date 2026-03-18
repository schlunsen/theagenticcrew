= How to Give Good Instructions

#figure(
  image("../../assets/illustrations/crew/ch05-two-captains.jpg", width: 80%),
  caption: [_The difference between a good instruction and a bad one._],
)

This is the most important chapter in this book.

Everything else — understanding the tech stack, knowing what agents are, setting up guardrails — supports this one skill. Because an agent is only as good as the instructions you give it. Not sometimes. Always.

If you take nothing else from this book, take this: _how you explain the job is more important than the tool doing the job._

== Two Captains

Let me tell you about two people who both wanted the same thing: a simple dashboard showing their team's weekly sales numbers.

Alex opened an agent and typed: "Make me a sales dashboard."

The agent built something. It looked like a dashboard. It had charts. But the data was mocked — fake numbers, not connected to anything real. The charts showed monthly totals, not weekly. There was no way to filter by team member. And it used a JavaScript charting library Alex had never heard of, which didn't match the React app they were supposedly building.

Alex spent an hour trying to explain what was wrong. Each fix introduced a new misunderstanding. After two hours, they gave up and started over.

Maya opened the same agent and typed something different:

"Build a sales dashboard page for our React app. It should:
- Connect to our existing Django API endpoint at `/api/sales/`
- Show a bar chart of sales totals for each of the last 8 weeks
- Each bar should be broken down by team member (stacked bar chart)
- Use the Recharts library, which we already have installed
- Include a dropdown to filter by individual team member, or show all
- The page should match our existing app's styling — blue header, white cards, grey background
- Put it at the route `/dashboard`"

The agent built exactly that. First try. Thirty minutes including a small fix to the date formatting.

Same agent. Same task. Same goal. The difference was entirely in the instructions.

== The Three Parts of a Good Instruction

Every good instruction has three components: *what* you want, *why* it matters, and *how you'll know it worked*.

=== What You Want

Be specific. Not "make a dashboard" but "make a bar chart showing weekly sales totals." Not "fix the layout" but "the sidebar overlaps the main content on screens narrower than 768 pixels — make the sidebar collapse into a hamburger menu."

The more concrete your description, the less the agent has to guess. And when agents guess, they guess confidently. They won't ask "did you mean weekly or monthly?" They'll just pick one and build it.

=== Why It Matters

Context changes everything. "Add a loading spinner" is fine. "Add a loading spinner — our users on slow rural connections are seeing a blank screen for 3-4 seconds and think the app is broken" is better. Now the agent understands the _problem_, not just the feature. It might suggest additional solutions you hadn't considered, like skeleton screens or optimistic loading.

=== How You'll Know It Worked

This is the one most people skip. "Build a login page" gives the agent no way to verify its own work. "Build a login page — I should be able to enter an email and password, click Log In, and be redirected to the dashboard. If I enter a wrong password, I should see an error message that says 'Invalid credentials.' The login button should be disabled while the request is in progress."

Now the agent has _acceptance criteria_. It can check its own work against your expectations. This is the same concept engineers use when writing tests — define what success looks like _before_ you build it.

== Constraints Are Half the Job

Telling an agent what to do is only half the work. Telling it what _not_ to do is equally important.

Agents are eager. They optimise for solving the problem you described, and they'll happily redesign your entire interface to do it. That's not malice — it's an optimiser doing what optimisers do. Your job is to set the boundaries.

Good constraints:

- "Don't change any existing pages — only add the new dashboard page."
- "Use the existing colour scheme. Don't introduce new colours."
- "Don't add new dependencies. Use libraries we already have."
- "Keep the file structure the same. Put the new component in `src/pages/`."
- "Don't modify the API. The dashboard should work with the data the API already returns."

Think of constraints as lane markers on a road. The agent can drive freely within the lanes, but it can't cross the lines. Without lane markers, you get creative solutions that technically work but create chaos. With them, you get solutions that fit naturally into what already exists.

The more experienced you get, the more your instructions are defined by their constraints. You learn which freedoms lead to good outcomes and which lead to an agent rewriting your entire component library because you asked it to fix a button colour.

== The Levels of Instruction

There's a spectrum from vague to precise, and knowing where to land is a skill you develop over time:

*Level 0 — The Wish:* "Make the app better." This gives the agent nothing to work with. It will either do nothing useful or change everything.

*Level 1 — The Goal:* "Add a way for users to export their data." Better — there's a clear objective. But the agent has to decide the format, the interface, the scope. You might get a CSV export. You might get a full API endpoint. You might get a "Download All" button that exports the entire database.

*Level 2 — The Specification:* "Add a button labelled 'Export to CSV' on the settings page. When clicked, it should download a CSV file containing all tasks for the current project, with columns: Task Name, Status, Assignee, Due Date, Created Date. The file should be named `project-name-export-2026-03-18.csv`." This is where you want to be for most tasks. Specific enough that the agent can't misunderstand, flexible enough that it can handle implementation details.

*Level 3 — The Blueprint:* Full implementation spec with exact file paths, function names, and code patterns to follow. Usually unnecessary unless you're working on a large, complex codebase with strict conventions. Your developer might write prompts at this level. You probably won't need to.

For most people reading this book, Level 2 is the sweet spot. Specific about the _what_ and the _outcome_, flexible about the _how_.

== Iteration Is Normal

Nobody writes a perfect instruction on the first try. Not beginners. Not experts. The key difference is that experienced people iterate _faster_ because they've learned what kinds of vagueness cause what kinds of problems.

A healthy workflow looks like this:

+ Give the agent a clear instruction.
+ Review what it produced.
+ Identify what's wrong or missing.
+ Give a _targeted_ follow-up instruction.
+ Repeat until it's right.

The follow-up is where most people struggle. They see something wrong and say "that's not right, fix it." That's Captain Alex again. Instead:

- "The bar chart is showing monthly totals. Change it to weekly — group by ISO week number."
- "The export is missing the Assignee column. Add it between Status and Due Date."
- "The loading spinner is too small. Make it 48 pixels and centre it vertically in the card."

Each follow-up is a miniature instruction with the same structure: what's wrong, what you want instead, how to verify it.

== Practice

This is a skill, which means it improves with practice. Start small. Ask an agent to draft an email and see how specific you need to be about tone and content. Ask it to reorganise a spreadsheet and notice how precisely you need to describe the desired layout. Ask it to plan a trip and watch where it makes assumptions.

Every time the agent produces something that's not what you wanted, ask yourself: "What could I have said differently?" The answer is always the same — be more specific about what you wanted, more explicit about what you didn't want, and more concrete about what success looks like.

The people who get the most out of agents aren't the ones with the most technical knowledge. They're the ones who've learned to communicate with precision. And that's a skill that transfers to every conversation you'll ever have — with agents, with colleagues, and with anyone who needs to understand what you actually want.
