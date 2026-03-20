= Building Something Without Code

#figure(
  image("../../assets/illustrations/crew/ch11-building-real.jpg", width: 80%),
  caption: [_The principles transfer to everything._],
)

The window quoting app proved you can build software. But agents aren't just for building software. The same principles — clear instructions, good context, verification, iteration — apply to any complex task where you're directing an agent to produce real output.

This chapter is a second walkthrough. Shorter. No code. And the kind of task that most non-technical people encounter every week: turning raw data into a polished, automated report.

== The Scenario

You manage a small team. Every Monday morning, you spend 90 minutes pulling numbers from three spreadsheets — sales, support tickets, and project milestones — and assembling them into a weekly status report for your manager. The report is a Word document with charts, a summary paragraph, and a table of action items. It's tedious, it's manual, and you've been doing it the same way for two years.

You're going to automate the whole thing with an agent. Not the _thinking_ — you still decide what matters. But the assembly, the formatting, the chart generation, and the boilerplate. By the end, your Monday morning report takes fifteen minutes instead of ninety.

== Step 1: Define the Output

Before you touch the agent, describe what the finished report looks like. You've been making it for two years — you know this better than anyone.

"The weekly status report is a 2-page document with:

- A header with the team name, week number, and date range
- A summary paragraph (3-4 sentences) highlighting the biggest wins and any blockers
- A bar chart showing this week's sales vs. last week's and vs. target
- A line chart showing open support tickets over the past 8 weeks
- A table of active project milestones with columns: project name, milestone, due date, status (on track / at risk / delayed), and owner
- An action items section: bullet points of what needs to happen this week
- A footer with my name and the date generated"

That's your specification. You just did the hardest part.

== Step 2: Prepare the Raw Materials

Remember the workbench. Don't describe your data — show it. Export each spreadsheet to CSV or copy the relevant rows. Give the agent:

- This week's sales numbers and last week's (two columns of data, not a description)
- The support ticket counts for the past 8 weeks (a simple list of numbers)
- The current milestone table (copy-paste from your project tracker)
- An example of a previous report you liked (the gold standard)

The example is the most important piece. It shows the agent the tone, the formatting, the level of detail. It answers a hundred questions you'd otherwise have to specify.

== Step 3: Generate the Report

Now prompt the agent:

"Using the attached data and the example report format, generate this week's status report for the week of March 17–21. Sales data is in the first attachment — compare this week to last week and to the target of \$45,000. Support ticket data is in the second attachment — create a trend line for the past 8 weeks. Milestones are in the third attachment. Write a summary paragraph that highlights: we exceeded the sales target for the third consecutive week, but the Horizon project milestone is now 5 days overdue. Tone should match the example — professional but not stiff. Generate the charts as images I can paste into a document."

Notice what you're doing: providing data (Level 2 context), providing an example (showing, not describing), specifying the narrative angle (the summary isn't neutral — you're directing the story), and constraining the tone.

== Step 4: Verify and Iterate

The agent produces a draft. Now you verify:

- *Check the numbers.* Does the sales chart match your spreadsheet? Is the target line at \$45,000? Are the support ticket counts correct?
- *Check the narrative.* Does the summary paragraph say what you want it to say? Is it accurate? Does it capture the nuance — the Horizon delay isn't a crisis, but it needs attention?
- *Check the tone.* Does it sound like _your_ report? Your manager knows your writing style. If this suddenly reads like a press release, it'll feel off.

First pass might need corrections: "The chart shows last week's sales as \$38,000 but the spreadsheet says \$38,500. Fix the chart. Also, change 'exceeded expectations' to 'exceeded target' — we use 'target' in our team, not 'expectations.'"

Second pass is usually close to done. Adjust a sentence, tweak a label, add the one action item you forgot to mention. Ten minutes of iteration, not ninety minutes of assembly.

== Step 5: Build the Template

Here's where the real leverage happens. Once you have one good report, tell the agent:

"Save this as a reusable template. Every Monday, I'll provide: (1) this week's sales CSV, (2) updated support ticket numbers, (3) updated milestone table, and (4) two or three bullet points about what to highlight in the summary. You generate the full report using the same format, charts, and tone."

Now your Monday process is:
+ Export three spreadsheets (5 minutes)
+ Write three bullet points about what matters this week (5 minutes)
+ Give everything to the agent and review the output (5 minutes)

Fifteen minutes. The other seventy-five minutes of your Monday morning are now free.

== Why This Matters

This walkthrough uses no code. No APIs, no databases, no deployment. But it uses every principle from this book:

- *Clear instructions* with specific constraints (Ch. 5)
- *Raw materials* instead of descriptions — Level 2 context (Ch. 6)
- *Verification* of numbers, narrative, and tone (Ch. 6)
- *Iteration* — first draft, corrections, second pass (Ch. 5)
- *The trust gradient* — you check everything the first few weeks, then loosen as the template proves reliable (Ch. 7)

The window quoting app showed that you can build software. This shows something equally important: you can transform any tedious, repetitive, knowledge-heavy task into an agent-assisted workflow. The thinking stays with you. The assembly gets automated.

That's the real promise of agents — not just for engineers building apps, but for anyone who spends too much of their Monday morning on work that a machine could assemble while they focus on the parts that actually need a human brain.
