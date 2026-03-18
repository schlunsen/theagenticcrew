= The Trust Gradient

#figure(
  image("../../assets/illustrations/crew/ch07-trust-gradient.jpg", width: 80%),
  caption: [_Start tight. Loosen with evidence._],
)

Would you let a new intern send emails to your clients on their first day? Probably not. Would you let them draft emails for you to review? Sure. Would you let them send routine replies after they've been around for a month and you've seen their work? Likely.

That escalation — from "I'll do it myself" to "do it, but I'll check" to "go ahead, I trust you" — is exactly how you should think about working with agents. It's called the trust gradient, and getting it right is the difference between an agent that helps you and one that creates a mess you spend the afternoon cleaning up.

== The Mixing Board

Think of your trust level as a mixing board — the kind with sliding controls. Each type of task has its own slider:

- *Reading files and data* — Low risk. The agent is just looking. Slide it up.
- *Writing and editing documents* — Medium risk. The agent might change something you care about. Keep it at "review before saving."
- *Sending messages or emails* — Higher risk. Once it's sent, it's sent. Keep it at "draft for my approval."
- *Making purchases or financial decisions* — High risk. Keep it at "suggest, don't act."
- *Deleting or overwriting data* — High risk. Keep it at "ask me first."

You don't set all the sliders the same way, and you don't set them once and forget them. They move over time as you build confidence in specific areas.

== The Ratchet

Day one with an agent, everything gets reviewed. Every output gets checked. You don't know yet where it's brilliant and where it's brittle, so you watch everything. This is normal. This is smart.

After a few days, patterns emerge. The agent is excellent at drafting reports. It's solid at data analysis. It occasionally makes questionable choices about tone in customer-facing emails. Now your sliders reflect that: reports and analysis run with minimal review, customer emails get a careful read before sending.

After a few weeks, you've seen dozens of tasks complete successfully. You trust the agent more in the areas where it's proven itself. The guardrails are still there, but they're invisible for the 90% of work that's routine. They only kick in for unusual situations.

This is the ratchet: slow, evidence-based tightening and loosening. The people who never loosen the guardrails end up abandoning agents because it's "too much work to check everything." The people who loosen too fast get the email that shouldn't have been sent, or the data that shouldn't have been deleted.

== Guardrails in Practice

For software projects — the kind you might build with an agent — guardrails have a very concrete form, and you already learned about it: Git branches.

When an agent works on a branch, all its changes are isolated. You can review them in a pull request before they touch the main project. That's a guardrail. The agent has freedom to experiment, but the results go through your approval before they become real.

For non-code tasks, guardrails look different:

- *Drafts, not sends.* The agent writes the email. You send it.
- *Suggestions, not decisions.* The agent recommends the budget allocation. You approve it.
- *Summaries with sources.* The agent summarises the report _and shows you where each claim came from_. You verify.
- *Staged rollouts.* Try the agent's output on a small, low-stakes task before trusting it with the big one.

The principle is always the same: keep the human in the loop for anything that can't be easily undone.

== The Two Mistakes

There are exactly two ways to get the trust gradient wrong:

*Too tight:* You review every single output, re-check every fact, rewrite every sentence. The agent becomes a slow, expensive way to produce a rough draft you were going to rewrite anyway. You burn out on supervision and conclude that "agents aren't worth it." They are — you just never let the ratchet move.

*Too loose:* You let the agent run unsupervised because the first few results were good. The agent sends an email with a factual error. It publishes a report with a hallucinated statistic. It deletes a file that wasn't backed up. You conclude that "agents can't be trusted." They can — you just skipped the part where you verify before promoting to autonomy.

The sweet spot is neither. It's a gradual, evidence-based shift — checking everything early, loosening as confidence builds, but keeping hard boundaries on the things that truly matter.

== Your Role

This might be the most empowering idea in the book: the trust gradient means _you_ are always in control. Not the agent. Not the technology. You.

You decide what the agent can see. You decide what it can do. You decide when to review and when to trust. You can tighten the guardrails at any time. You can delete a branch. You can reject a draft. You can say "actually, I'll handle this one myself."

An agent is a tool with a trust dial. You hold the dial. That's not a limitation — it's the design.
