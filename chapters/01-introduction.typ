= Introduction

Last year I watched a junior developer on my team — two years of experience, still nervous in code reviews — ship a complete API endpoint in forty-five minutes. Data model, validation, error handling, tests, documentation. The code was clean. The tests were thorough. The PR passed review on the first try.

It would have taken me an hour to do the same work. And I've been doing this for twenty years.

She didn't type most of it. She described what she needed, pointed an agent at the codebase, and steered it to the finish line. Her skill wasn't in writing the code — it was in knowing what to ask for, recognising when the output was good, and catching the one edge case the agent missed. She was _engineering_. Just not the way I learned to engineer.

I went home that evening and sat with an uncomfortable question: if the gap between twenty years of experience and two years of experience just got a lot narrower, what exactly am I bringing to the table?

The answer, I eventually realized, is everything that isn't typing. But getting to that answer took months, a lot of mistakes, and this book.

== The Ground Is Shifting

For twenty years, being a software engineer meant one thing: you open an editor, you write code, you ship it. The tools changed — from Vim to VS Code, from SVN to Git, from bare metal to Kubernetes — but the fundamental loop stayed the same. You, a keyboard, and a problem.

That loop is breaking. And it's breaking fast.

AI agents don't just autocomplete your code. They read your entire codebase, reason about architecture, make changes across dozens of files, run your tests, and iterate on failures — all without you touching the keyboard. They're not replacing the editor. They're replacing the _workflow_. The engineer who used to spend 80% of their time typing is now spending 80% of their time thinking, reviewing, and steering.

Some engineers are thriving in this shift. They're shipping more, with higher quality, and they'll tell you they're enjoying their work more than they have in years. Others are frustrated, skeptical, or quietly terrified that the craft they spent a decade mastering is evaporating underneath them.

Both reactions are rational. The truth is somewhere in the uncomfortable middle.

== Why This Book

Because nobody handed us a playbook.

The tools showed up fast — Copilot, then Claude, then agents that can autonomously run tasks end-to-end — and we're all figuring it out in real time. I looked for the book that would tell me how to actually work with these things. Not the marketing pitch. Not the academic paper. Not the Twitter thread from someone who tried it for twenty minutes. I wanted the honest engineering guide — written by someone who ships production code and has watched agents do brilliant things and catastrophically stupid things in equal measure.

That book didn't exist. So I wrote it.

I wrote it because I was lost too. I was the senior engineer who couldn't figure out why the agent kept rewriting my entire component library when I asked it to fix a button color. I was the guy who burned 500,000 tokens on a task that should have taken ten minutes, because I didn't know how to set boundaries. I made every mistake in this book before I learned to avoid them.

This is the guide I wish someone had given me.

== Who This Is For

You're a software engineer. You've shipped real things. You know what a production incident feels like at 2am. You're not afraid of the terminal.

But lately, something feels different. Maybe you've tried AI coding tools and found them impressive but chaotic — like pairing with someone who's incredibly fast but has no concept of scope. Maybe you've watched a developer with two years of experience ship a full feature in an afternoon using agent assistance, and it made you feel something you didn't expect. Maybe you're excited but don't know where to start. Maybe you're skeptical and want someone to convince you with substance, not hype.

This book is for you. It assumes you can code. It assumes you've been around. It meets you where you are.

== How to Read This Book

This isn't a reference manual. It's a journey, and it's structured like one.

We start by understanding what's actually changing and why — the shift in how software gets built, not just the tools but the _thinking_. Then we get into what agents actually are, stripped of the marketing language, so you have a mental model that holds up when the tools change next quarter.

From there, we get our hands dirty. You'll learn how agents work in the terminal, how to set up guardrails so they don't wreck your codebase, how Git workflows change when agents are committing code, and why sandboxing isn't optional. We'll dig into testing as the feedback loop that makes agents _reliable_ instead of just fast, and conventions as the secret weapon that most people overlook.

Then we go deeper — local versus commercial models, prompt engineering as a real discipline, and multi-agent orchestration. We'll look at war stories: real failures, real lessons, real scar tissue. We'll talk about when _not_ to use agents, because knowing when to put down the tool is as important as knowing how to use it. And we'll close with how teams adopt this stuff without imploding.

By the end, you won't just know how to use AI agents. You'll know how to _think_ about them — which is the skill that survives when the current generation of tools is obsolete.

== What This Book Is Not

Let me save you some time.

This is not a prompt cookbook. You won't find "50 ChatGPT prompts for developers" here. Prompting matters, and we cover it, but copy-pasting prompts without understanding the system underneath is a recipe for expensive frustration.

This is not an AI hype manifesto. I'm not here to tell you that agents will replace all programmers by next Tuesday. They won't. The gap between demo and production is as wide as it's ever been, and someone still has to mind that gap.

This is not a doom narrative either. The "AI is coming for your job" framing is lazy and mostly wrong. What's coming is a fundamental change in _how_ the job works, and that's a different conversation entirely.

This is an engineering book. For engineers. Written by someone who spends his days writing code with agents and has the git history to prove it. We're going to be practical, honest, and specific. If that sounds like your kind of thing, turn the page.
