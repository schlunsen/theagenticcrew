= Context In, Verification Out

#figure(
  image("../../assets/illustrations/crew/ch06-workbench.jpg", width: 80%),
  caption: [_An agent can only work with what's on the bench._],
)

Working with an agent is a loop with two sides. On one side: what you put in front of the agent before you ask the question. On the other: how you read what comes back. Most people focus on the prompt — the words in the middle. But the real skill is managing both ends. Give it the right context, and the output is sharp. Read the output with the right eye, and you catch the things the agent can't.

This chapter is about both halves of that loop.

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

== Now Read What Comes Back

Good context gets you better output. But better output is not the same as _correct_ output. An agent will never tell you it's wrong. It doesn't know it's wrong. It produces output with the same confidence whether it's perfectly accurate or completely fabricated.

Your job — the skill that separates a productive agent user from a dangerous one — is learning to read the output with healthy scepticism. This isn't about distrust. It's about _calibrated_ trust. A good editor trusts their writers but still checks the facts. You're the editor.

== Hallucinations

The technical term is "hallucination" — when an agent produces information that sounds plausible but is factually wrong. It's the most important failure mode to understand because it's the hardest to catch.

A hallucination isn't a random error. It's a _plausible_ error. The agent doesn't say "the revenue was purple." It says "Q2 revenue was \$2.3 million" when the actual number is \$2.1 million. It doesn't cite a source that obviously doesn't exist — it cites one that _sounds_ like it should exist.

This is why hallucinations are dangerous: they pass the sniff test. You read the output, it sounds reasonable, and you move on. The error propagates into your report, your presentation, your decision.

== The Verification Checklist

For any agent output that matters, run through this:

*Numbers:* Where did they come from? Can you trace them back to the source data? If the agent says "sales grew 15%," check the actual data. Don't trust percentages, totals, or statistics without verification.

*Names and dates:* Agents frequently get details slightly wrong. The right person but the wrong date. The right company but the wrong product. Spot-check specifics.

*Claims and facts:* If the agent states something as fact, ask yourself — is this something I already know to be true, or am I learning it from the agent? If you're learning it from the agent, verify it.

*Sources and citations:* If the agent cites a source, check that the source exists and actually says what the agent claims. Agents are notorious for citing real-sounding publications with fabricated content.

*Completeness:* Is the output missing anything obvious? Agents tend to produce plausible-looking work that covers 80% of what you asked for. The missing 20% is often the part that would have revealed a problem.

== The Confidence Trap

Agents express everything with the same level of confidence. "The meeting is at 3pm" looks identical whether the agent is reading it from your calendar or guessing based on your usual schedule.

There's no italic font for uncertainty. No "I think" or "I'm not sure." You have to develop your own sense for which types of output are likely to be accurate:

*High confidence (usually reliable):*
- Formatting and restructuring existing data you provided
- Following explicit instructions ("sort this list alphabetically")
- Performing calculations on data you gave it
- Summarising a document you provided

*Lower confidence (always verify):*
- Factual claims about the world (dates, statistics, current events)
- Anything involving recent events (the model's training has a cutoff date)
- Specific numbers it didn't calculate from data you provided
- Legal, medical, or financial advice
- Claims about what's in a document it hasn't actually read

== Building the Habit

Verification shouldn't feel like a burden. It should feel like proofreading — a natural, quick pass over the output before you use it.

For low-stakes tasks (drafting an internal message, organising notes), a quick skim is enough. Did it capture the key points? Does the tone feel right? Good enough.

For medium-stakes tasks (a client report, a data analysis), check the numbers and key claims. Trace at least one or two facts back to their source.

For high-stakes tasks (a board presentation, a financial projection, a legal document), verify everything. Treat the agent's output as a first draft that needs fact-checking, not a finished product.

== The Compound Effect

Every time you give an agent good context, the output is better. Better output means less time spent correcting. Every time you verify efficiently, you build intuition for where agents are reliable and where they're brittle.

These two skills compound together. Over a week, the difference between someone who dumps vague descriptions and blindly accepts output versus someone who provides clean context and verifies smartly is enormous — not because they're smarter, but because they've learned to manage both ends of the loop.

And it's the exact same skill that makes you better at delegating to humans, writing clearer emails, and filing better bug reports. The agent just gives you faster feedback on whether your communication was clear enough.
