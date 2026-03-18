= What the Agent Can See

#figure(
  image("../../assets/illustrations/crew/ch06-workbench.jpg", width: 80%),
  caption: [_An agent can only work with what's on the bench._],
)

The single most important thing about working with agents isn't how you prompt them. It's what you put in front of them before you ask the question.

An agent is only as good as what it can see. Give it a vague description and a blank slate, and it will hallucinate confidently. Give it the right files, the right constraints, the right view of the problem — and it will do things that feel like magic. The difference isn't the model. It's you.

== The Workbench

Think of the agent's view as a physical workbench. It has limited space. You can't dump your entire life onto it and expect good results. Instead, you lay out the pieces that matter for _this_ task: the relevant documents, the specific error message, the screenshot, the example of what you want.

Good workbench management:

- Working on a quoting tool? Put the current version in front of the agent, plus an example of what a finished quote should look like.
- Trying to fix a bug? Don't describe the bug — paste the actual error message. Show the screenshot. Include the steps that triggered it.
- Designing a new feature? Provide a sketch, a competitor's example, or a detailed description of the user flow.

Bad workbench management:

- Pasting your entire project and saying "something's broken."
- Describing a problem from memory instead of sharing the actual error.
- Giving the agent information about ten different tasks and asking it to figure out which one you mean.

The workbench principle applies to everything — not just code. If you're asking an agent to draft a report, give it the raw data, the audience, the format you want, and an example of a good report. If you're asking it to plan an event, give it the constraints (budget, date, venue size) rather than just "plan a team event."

== Raw Materials vs. Descriptions

There's a crucial difference between _describing_ something and _showing_ it.

*Description:* "The sales numbers are in a spreadsheet. The totals seem wrong for Q2."

*Raw material:* Paste the actual spreadsheet data. Or better — give the agent access to the file. Now it can see the formulas, find the error, and fix it. You described the symptom. The raw material shows the cause.

This is the single biggest upgrade most people can make: stop describing, start showing. Paste the error message. Attach the screenshot. Upload the document. Give the agent the same information you'd give a colleague sitting next to you.

Every time you paraphrase, you lose signal. You compress the actual problem through the narrow pipe of your interpretation, and the agent has to decompress it — badly — on the other side. It's like describing a painting over the phone and asking someone to reproduce it.

== Context Quality Levels

There's a useful way to think about how good your context is:

*Level 0 — Vague description:* "The report looks wrong." The agent guesses what report, guesses what's wrong, and guesses how to fix it. Three guesses deep, the odds of getting it right are low.

*Level 1 — Specific description:* "The Q2 revenue in the quarterly report shows \$2.3M but it should be \$2.1M. I think the formula is including refunded transactions." Much better. The agent knows the symptom and your theory about the cause.

*Level 2 — Raw data:* You paste the relevant section of the spreadsheet, the formula, and the list of transactions. Now the agent can verify your theory or discover the real cause. Maybe the formula is fine but two transactions were duplicated. You wouldn't have caught that by describing the problem.

*Level 3 — Access:* The agent can open the spreadsheet itself, run the formulas, check the data source, and investigate independently. You provide the _intent_ ("find out why Q2 revenue is overstated") and the agent does the detective work.

Most people live at Level 0 or 1. The goal is to get to Level 2 as your default, and Level 3 when the tools support it.

== Less Is More (Sometimes)

This isn't about giving the agent _everything_. It's about giving it _the right things_.

Too little context and the agent guesses. Too much context and the agent gets buried. Imagine handing someone a stack of a thousand pages and saying "the answer is in there somewhere." Good luck.

For each task, ask yourself:
- What does the agent need to see to understand this task?
- What will confuse it if I include it?
- Is the information I'm providing current, or am I feeding it stale data?

A focused workbench beats a cluttered one. Three relevant files are better than thirty irrelevant ones. The specific error message is better than the entire log file.

== The Compound Effect

Every time you give an agent good context, the output is better. Better output means less time spent correcting. Less correcting means more time for the next task. Over a week, the difference between someone who dumps vague descriptions and someone who provides clean, focused context is enormous — not because they're smarter, but because they've learned to set the agent up for success.

This skill compounds. And it's the exact same skill that makes you better at delegating to humans, writing clearer emails, and filing better bug reports. The agent just gives you faster feedback on whether your communication was clear enough.
