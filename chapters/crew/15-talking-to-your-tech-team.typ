= Talking to Your Tech Team

#figure(
  image("../../assets/illustrations/crew/ch15-talking-tech-team.jpg", width: 80%),
  caption: [_You speak two languages now._],
)

You've just spent the better part of this book learning how software works, what agents are, and how to direct them. You now have something most non-technical people don't: a shared vocabulary with your developers.

This chapter is about using it. Not to pretend you're an engineer — but to close the gap between "I don't understand what you're building" and "I understand enough to help you build the right thing."

== The Vocabulary

Here's a reference for the terms you've learned, framed as they come up in real conversations:

When your developer says *"the API is returning a 500"* — the kitchen (Django) is broken. Something exploded on the server side. The dining room (React) is fine. The problem is behind the scenes.

When they say *"we need to write a migration"* — the database (Postgres) structure needs to change to support a new feature. Like adding a new drawer to the filing cabinet.

When they say *"it's cached in Redis"* — the data is being served from the fast whiteboard instead of the big filing cabinet. If the data seems stale, the whiteboard might need updating.

When they say *"I'll put it on a branch"* — they're working in a parallel universe (Git branch) so the main app isn't affected. The experiment is safe.

When they say *"the PR needs review"* — there's a pull request ready. Someone has proposed changes and wants a second pair of eyes before merging.

When they say *"CI is failing"* — the automated checklist caught a problem. The change broke a test or violated a rule. It needs fixing before it can ship.

When they say *"DNS isn't propagated"* — the internet's phone book hasn't updated everywhere yet. Some people can see the change, others can't. Wait.

When they say *"we should add a WebSocket for that"* — instead of the page checking for updates by refreshing, they want to add a live connection so updates appear instantly.

When they say *"the context window"* — the agent's workbench. How much information it can hold at once.

When they say *"it hallucinated"* — the agent made something up. Confidently. It looks real but isn't.

== Questions Worth Asking

The most valuable thing you can do in a technical conversation isn't understanding every detail. It's asking the right questions. Here are some that will earn you respect:

*"What does the user actually see when that happens?"* — This grounds any technical discussion in reality. Developers sometimes get lost in implementation details. This question brings them back to the experience.

*"What's the risk if this goes wrong?"* — This is the trust gradient applied to conversation. It separates the things worth worrying about from the things that sound scary but aren't.

*"Can we try it on a branch first?"* — You know what a branch is now. Suggesting this shows you understand that experiments can be safe.

*"Is this something an agent could handle?"* — Not to replace your developer — but to suggest that maybe the tedious migration script or the repetitive styling task could be delegated. Developers sometimes forget to use their own tools.

*"What would make this easier to test?"* — This shows you understand that verification matters. It's one of the most engineering-fluent questions a non-engineer can ask.

*"What does the data model look like?"* — You know what a database is now. You know about tables and rows. Asking about the data model shows you're thinking about structure, not just features.

== Being Useful in Planning

The biggest contribution you can make to a technical team isn't writing code or reviewing pull requests. It's _defining the problem correctly_.

Engineers are optimised for building solutions. They're often less good at questioning whether it's the right solution. That's where you come in — especially if you're closer to the users:

*"We're building a notification system"* — you can ask: "Have we talked to users about whether they want notifications? What kind? How often? The last three apps I used have a 'notification fatigue' problem."

*"We're adding a dark mode"* — you can ask: "Who asked for this? Our users are window installers on bright job sites. Maybe we should do a high-contrast light mode instead."

*"The agent will handle customer onboarding"* — you can ask: "What happens when the agent gets it wrong? Is there a handoff to a human? How will the customer know they're talking to an agent?"

These aren't technical questions. They're _product_ questions. And they're often more valuable than any technical decision being made in the same meeting.

== The Bridge

You're a bridge. You speak two languages now — not fluently in the technical one, but well enough to translate between the people building the product and the people using it.

That bridge didn't exist before you read this book. The developers spoke in APIs and migrations and CI pipelines. The users spoke in frustrations and wishes and "it would be nice if." The gap between those two conversations is where products fail.

You're standing in that gap now. Not as an engineer. Not as a user. As someone who understands enough of both sides to make sure they're building the same thing.

That's not a small role. That's the role that determines whether the ship reaches the right island.
