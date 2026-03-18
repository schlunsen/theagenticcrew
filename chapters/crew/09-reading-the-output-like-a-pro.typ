= Reading the Output Like a Pro

#figure(
  image("../../assets/illustrations/crew/ch09-reading-output.jpg", width: 80%),
  caption: [_Trust, but verify._],
)

An agent will never tell you it's wrong. It doesn't know it's wrong. It produces output with the same confidence whether it's perfectly accurate or completely fabricated. Your job — the skill that separates a productive agent user from a dangerous one — is learning to read the output with healthy scepticism.

This isn't about distrust. It's about _calibrated_ trust. A good editor trusts their writers but still checks the facts. A good manager trusts their team but still reviews the deliverables. You're the editor. You're the manager. The agent is a very fast, very confident team member who occasionally makes things up.

== Hallucinations

The technical term is "hallucination" — when an agent produces information that sounds plausible but is factually wrong. It's the most important failure mode to understand because it's the hardest to catch.

A hallucination isn't a random error. It's a _plausible_ error. The agent doesn't say "the revenue was purple." It says "Q2 revenue was \$2.3 million" when the actual number is \$2.1 million. It doesn't cite a source that obviously doesn't exist — it cites one that _sounds_ like it should exist. It doesn't invent a bizarre claim — it states something that fits neatly into the narrative, just happens to be wrong.

This is why hallucinations are dangerous: they pass the sniff test. You read the output, it sounds reasonable, and you move on. The error propagates into your report, your presentation, your decision.

== The Verification Checklist

For any agent output that matters, run through this:

*Numbers:* Where did they come from? Can you trace them back to the source data? If the agent says "sales grew 15%," check the actual data. Don't trust percentages, totals, or statistics without verification.

*Names and dates:* Agents frequently get details slightly wrong. The right person but the wrong date. The right company but the wrong product. The right statistic but from the wrong year. Spot-check specifics.

*Claims and facts:* If the agent states something as fact, ask yourself — is this something I already know to be true, or am I learning it from the agent? If you're learning it from the agent, verify it. A quick web search, a check against your own records, a sanity check with a colleague.

*Sources and citations:* If the agent cites a source, check that the source exists and actually says what the agent claims it says. Agents are notorious for citing real-sounding publications with fabricated content, or citing real publications but misrepresenting what they say.

*Completeness:* Is the output missing anything obvious? Agents tend to produce plausible-looking work that covers 80% of what you asked for. The missing 20% is often the part that would have revealed a problem.

== The Confidence Trap

Agents express everything with the same level of confidence. "The meeting is at 3pm" and "the meeting is at 3pm" look identical whether the agent is reading it from your calendar or guessing based on your usual schedule.

There's no italic font for uncertainty. No "I think" or "I'm not sure." The output arrives as if it's fact, every time.

This means you can't rely on the agent's _tone_ to gauge accuracy. You have to develop your own sense for which types of output are likely to be accurate and which need checking:

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

For medium-stakes tasks (a client report, a data analysis), check the numbers and key claims. Trace at least one or two facts back to their source. Read the whole thing as if someone else wrote it and you're the reviewer.

For high-stakes tasks (a board presentation, a financial projection, a legal document), verify everything. Treat the agent's output as a first draft that needs fact-checking, not a finished product. If you wouldn't publish it without checking when a human wrote it, don't publish it without checking when an agent wrote it.

The goal isn't to never trust the agent. The goal is to trust it _appropriately_ — eagerly for what it does well, cautiously for what it does less well, and never blindly.
