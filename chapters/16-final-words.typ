= Final Words

My oldest son is five. He can't read yet, not really — he sounds out words on cereal boxes and street signs, proud of every syllable. But he knows what my computer does. He's seen me talk to it, seen text appear on the screen in response, seen me nod or shake my head and talk again. One evening he climbed onto my lap, watched an agent refactor a module in real time — files opening and closing, tests running, green checkmarks appearing — and said, "Is the computer fixing itself?"

I didn't have a good answer. I still don't, not entirely. But that question stuck with me through every chapter of this book. Because what I realized, sitting there with him, is that I wasn't writing a book about tools. I was writing a book about what it means to be an engineer at the exact moment the definition of engineering is being rewritten — and about what we carry forward into whatever comes next.

This chapter is not a summary. You don't need me to recap fifteen chapters you just read. This is the stuff I want to say to you directly, one engineer to another, before we part ways.

== What I Believe

I believe the craft is not dying. It is being _compressed_. A decade of boilerplate and plumbing and ceremony is collapsing into intent and judgement. What remains when you strip away the typing is the thing that was always the actual job: knowing what to build and knowing when it's right.

I believe agents are amplifiers, not replacements. Give an agent to a mediocre engineer and you get mediocre software at terrifying speed. Give one to a great engineer and you get something that, frankly, makes the last twenty years of software development look like we were building highways with shovels.

I believe the engineers who thrive will be the ones who master the _boring_ things — context, guardrails, testing, conventions, clear thinking — while everyone else chases the shiny new model announcement. Tools change every quarter. Judgement compounds over a career.

I believe we are not being replaced. We are being promoted. From typists to captains. From coders to _engineers_, in the fullest sense of the word. The question is whether you accept the promotion.

I believe this shift is _good_. Not easy. Not painless. But good. Because the part of our work that's being automated was never the part we loved. Nobody became an engineer because they dreamed of writing boilerplate JSON parsers. We became engineers because we wanted to build things that matter. Now we can.

== What I Got Wrong

I'll be honest with you: I changed my mind at least three times while writing this book.

When I started the chapter on sandboxes, I thought container isolation was overkill for most workflows. By the time I finished it, after an agent had rm -rf'd a directory I cared about on a Tuesday afternoon, I believed sandboxing was non-negotiable. That experience made it into the chapter. The conviction behind it is scar tissue.

I originally wrote the multi-agent chapter with the assumption that orchestrating five or six agents simultaneously was the natural end state — a factory floor of autonomous workers. I've pulled back from that. The coordination overhead is real, the failure modes multiply, and I've found that two or three well-directed agents outperform six unsupervised ones almost every time. The chapter reflects where I landed, but I may land somewhere different in six months.

I was also, for a while, too dismissive of local models. I wrote an early draft that basically said "just use the commercial APIs." Then I spent a weekend running a fine-tuned local model on a codebase with proprietary constraints and realized there's a whole world of use cases where local is not just viable but _necessary_. The chapter on local versus commercial models exists because I was wrong and had to correct myself.

Parts of this book are probably already wrong in ways I can't see yet. The landscape moves that fast. But the specific tools were never the point. If I've helped you build a mental model — a way of thinking about autonomy, trust, and structure — then the book did its job, even when every code example in it is outdated.

== The Crew Metaphor, One Last Time

I grew up in Denmark, near the water. If you've sailed in Scandinavian waters, you know the light in late summer — low and golden, the kind of light that makes the sea look like hammered copper. I remember a crossing once, a small boat, four of us. The wind shifted hard and suddenly we were all moving without speaking. One person on the jib, one on the mainsheet, one trimming, one at the helm. No commands. Just trust built over dozens of previous sails.

That's what agentic engineering feels like on a good day. You at the helm, agents trimming and adjusting, the work flowing because you've put in the hours to build shared context — through conventions, through guardrails, through test suites that catch mistakes before they matter. You don't need to shout instructions. The system _knows_.

And then there are the bad days. The days the wind dies and an agent hallucinates an API that doesn't exist, or rewrites a module you didn't ask it to touch, or passes all the tests because it deleted the ones that were failing. Those days, you're bailing water and swearing. That's sailing too.

But I should be honest about something, because this book doesn't work if I'm not.

The metaphor of a _crew_ implies loyalty. Continuity. Shipmates you've sailed with before, who know your habits, who anticipate the next command. That's a beautiful image. It's also not how I actually work.

Most days, what I actually do is spin up an agent, give it a job, take the output, and throw it overboard. Then I spin up another one. They don't remember the last session. They don't know what I asked the previous agent to do. Each one arrives fresh, does its work, and disappears. It's less a loyal crew and more like hiring dockworkers at every port — you brief them, you watch them work, you pay them off, and at the next port you do it again.

And that's fine. That's how most real crews worked throughout maritime history. The ship was the continuity. The captain was the continuity. The charts, the logbook, the rigging — those persisted between voyages. The crew was often assembled for a single crossing and dissolved at the destination. What made it work was not that the sailors knew the captain. It was that the captain knew the _ship_ — and had systems good enough that any competent sailor could step aboard and be useful.

That's what your codebase is. That's what your conventions, your test suites, your CLAUDE.md files, your guardrails are. They're the ship. Every new agent you spin up is a fresh crew member stepping aboard a well-rigged vessel. They don't need to know your history. They need to know the ship. And if you've built the ship well, they'll be productive in minutes.

So yes — throw them overboard. Spin up new ones. That's not a failure of the metaphor. That's the metaphor working exactly as intended. The crew is disposable. The ship is not.

You're the captain. You were always the captain. The crew just arrived — and they'll keep arriving, fresh and ready, every time you need them.

== Thank You

Thank you for reading this book. I mean that. You traded your time and attention for my words, and I don't take that lightly. I hope I earned it.

Thank you to the community — the engineers in forums, in Discord servers, in open source repos — who are sharing their experiments, their failures, their hard-won insights. This book was shaped by hundreds of conversations I didn't have alone.

And thank you, I suppose, to the agents themselves — who helped me write code, debug problems, and occasionally generate prose so bad it reminded me why human judgement still matters. You're a good crew. You're getting better. And I suspect that by the time my son is old enough to read this book, you'll be something none of us quite predicted.

== Go Build Something

Here's what I want you to do.

Tonight — not tomorrow, not next week, _tonight_ — open your terminal. Pick a bug you've been avoiding. That one you keep moving to the bottom of the backlog, the one that's annoying but not urgent, the one that lives in a part of the codebase you'd rather not touch. Point an agent at it. Give it context. Set a guardrail. Watch what happens.

Maybe it fixes the bug in four minutes and you feel the ground shift under your feet, the way it shifted under mine that evening with the migration script. Maybe it makes a mess and you learn something about how to give better instructions. Either way, you'll know more than you did before.

Then go bigger. Set up worktree isolation and run two agents in parallel. Write a CLAUDE.md file for a project you care about. Build a test suite that's good enough to be your safety net when agents are committing code. Refactor that module everyone is afraid of — but this time, with a crew.

Then go bigger still. Introduce agentic workflows to your team. Share what you've learned — the wins _and_ the disasters. Write up your own war stories. Contribute to the collective knowledge of a discipline that's still being invented.

Because that's what this is: a discipline being invented, right now, by the people willing to do the work. Not by the people writing blog posts about the future. Not by the people waiting for the perfect tool. By the people who open a terminal today and build something real with what they have.

The engineers who will define this era are not waiting for permission. They are not waiting for certainty. They are shipping, breaking things, learning, and shipping again — with a crew at their side that gets a little better every day.

I hope you'll be one of them.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _March 2026_
]
