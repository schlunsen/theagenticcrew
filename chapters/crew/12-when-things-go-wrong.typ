= When Things Go Wrong

#figure(
  image("../../assets/illustrations/crew/ch12-when-wrong.jpg", width: 80%),
  caption: [_The mistakes are inevitable. The recovery is a skill._],
)

Every person who works with agents long enough has a collection of these stories. The moments where you lean back, stare at the screen, and say something your mother wouldn't approve of. They're humbling. They're educational. And they're inevitable.

This chapter is a collection of things that actually go wrong when you hand real work to an agent. Not hypotheticals. Not worst-case fantasies. The kind of mistakes that cost you an afternoon or your confidence. Each one comes with a lesson that maps back to something from earlier in this book.

Read these before you make the same mistakes. Or read them after, and feel less alone.

== The Email That Wasn't Ready

You asked the agent to draft a follow-up email to a client. The agent produced a perfectly reasonable draft. You skimmed it, thought "looks good," and hit send.

Two hours later, the client called. The email referenced a meeting that hadn't happened yet — the agent had confused the calendar event for next Tuesday with notes from last Tuesday. It also quoted a price that was from an old proposal, not the current one. The email was coherent, professional, and wrong in two places that mattered.

*The lesson:* Never send agent-generated communication without reading it like a human wrote it. The agent doesn't know what's current and what's stale. It doesn't know that the meeting hasn't happened yet. It assembled plausible-sounding content from the context it had, and some of that context was outdated. This is the verification chapter in action — and the reason the trust gradient puts "sending emails" high on the review slider.

== The Confident Statistic

You asked the agent to prepare a competitive analysis. It produced a beautiful report: market sizes, growth rates, competitor revenue figures, market share percentages. Impressive. Detailed. You used three of those numbers in a board presentation.

During the Q&A, a board member pulled up the actual industry report the agent appeared to be citing. Two of the three numbers were wrong. Not wildly wrong — close enough to be plausible, different enough to be embarrassing. The agent hadn't _found_ those numbers. It had _generated_ them — plausible figures that fit the narrative, presented with the same confidence as the one number it got right.

*The lesson:* This is the hallucination problem from Chapter 9, playing out in the highest-stakes setting possible. Numbers from agents must be verified against source data. Always. If the agent cites a report, find the report and check the citation. If the agent produces a percentage, trace it back to the data. The agent doesn't know the difference between a fact it found and a fact it invented.

== The Overzealous Redesign

You asked the agent to change the colour of a button on your website from blue to green. A quick task. Five minutes.

The agent changed the button colour. It also noticed the button's style was "inconsistent with modern design practices" and updated it. Then it updated the other buttons to match. Then the navigation bar. Then the footer. Then it restructured the CSS to use a "more maintainable approach."

The button was green. Everything else was unrecognisable. Eighty-seven files had changed. The agent had done a full redesign you didn't ask for, and rolling it back meant figuring out which of those eighty-seven files contained the one change you actually wanted.

*The lesson:* Constraints. "Change the button colour on the homepage from blue (hex 3b82f6) to green (hex 22c55e). Don't change anything else." That's all it takes. Agents are eager optimisers — they see opportunities for improvement and take them unless you explicitly tell them not to. The chapter on instructions exists for this exact reason. Also: Git branches. If the agent had been working on a branch, you'd delete the branch and start over. Five seconds. No damage.

== The Data That Wasn't Backed Up

You built a small app with an agent. It was working great. Then you asked the agent to "clean up the database" — you meant remove some test data you'd entered while experimenting.

The agent interpreted "clean up" as "reset to a fresh state." It dropped every table and recreated them empty. Six weeks of real customer data — quotes, measurements, contact information — gone.

*The lesson:* Two lessons, actually. First: be terrifyingly specific when the task involves data. "Delete all quotes where the customer name contains 'test' or 'asdf'" is very different from "clean up the database." Second: backups. If you're building something real — something with data that matters — regular database backups are not optional. Ask your agent to set them up. It's one of the first things you should do after the app starts holding real data.

== The Feature Nobody Wanted

You asked the agent to add a dark mode to the quoting app. The agent added it beautifully. Toggle switch in the header, smooth transition, all colours adapted. Looked great.

Morten hated it. "Why is there a switch in my header? I use this on job sites in daylight. Dark mode is useless. And the switch confused my new guy — he thought it was an on/off button for the whole app."

You'd spent two hours on a feature driven by your own preference, not your user's needs. The agent executed perfectly. The problem was the instruction, not the execution.

*The lesson:* An agent will build exactly what you ask for. It won't tell you whether you should be asking. The question "should we build this?" is always yours. Talk to the actual user before you build. Morten would have told you in ten seconds that dark mode was pointless for his workflow — and he might have mentioned three things he actually needs.

== The Recovery Pattern

Every war story above has the same recovery pattern:

+ *Stop.* Don't let the agent keep going. If it's in the wrong direction, more work makes it worse.
+ *Assess.* What actually happened? What changed? What was lost?
+ *Restore.* Git branch? Delete it. Database? Restore from backup. Email? Send a correction.
+ *Learn.* What instruction or guardrail would have prevented this? Add it to your process.
+ *Try again.* With better instructions, better constraints, and better verification.

The mistakes are inevitable. The recovery is a skill. And the prevention — clear instructions, proper constraints, verification, backups — is what this whole book is teaching you.
