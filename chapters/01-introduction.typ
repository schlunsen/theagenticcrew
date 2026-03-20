= Introduction

It started with a boring project. The kind of thing that sounds reasonable in a planning meeting and turns into a slog the moment you open the editor: a financial application — more or less a CRUD app at its core, but with enough twists to keep you honest. Open banking API integrations. Heavy internationalisation across multiple locales. The sort of work where you spend half your time on plumbing and the other half convincing yourself the plumbing matters.

I'd kicked off the frontend with Lovable, one of the AI-powered app generators, mostly to get a design scaffold up fast. And that's where I first _saw_ it — the agentic workflow in action. Watching Lovable iterate on a design, make changes, rebuild. It was impressive as a demo. But I wasn't blown away. I could see the seams. I could tell how the prompts were structured, where the model was making decisions and where it was following templates. It felt like watching a magic trick after someone's explained the mechanics — still neat, but the mystery was gone.

Then Anthropic released the Claude Agent SDK, and something clicked. Not because the SDK itself was revolutionary — it was a well-designed framework for building agents in Python. What clicked was the _possibility_. I wanted to understand it deeply. So I did something slightly unhinged: I used Claude Code to port the Claude Agent SDK itself from Python to Go.

It was like watching the best movie I'd seen in years.

The planning alone was beautiful. I'd give the agent a module — "read this Python implementation, understand the architecture, and plan the equivalent Go package structure" — and watch it reason through the differences. Python's dynamic typing versus Go's interfaces. Decorators versus middleware patterns. Async context managers versus goroutines. The agent didn't just translate syntax. It _thought_ about the idioms. It planned the refactoring in stages, each one testable, each one building on the last.

I used more than a hundred prompts to complete the port. A hundred sessions of steering, correcting, refining. Some brilliant. Some disastrous. Some where the agent produced Go code so clean it looked like it had been written by someone on the Go team, and some where it mangled the concurrency model so badly I had to throw the whole session away and start over.

But here's the thing I only understood later: most of those hundred prompts were wasted. Not because the agent wasn't capable, but because _I_ wasn't capable yet. I didn't know how to give it the right context. I didn't know how to scope the tasks. I didn't know when to let it run and when to rein it in. Today, with the techniques in this book — the right tooling, the right context infrastructure, the right decomposition — I could do that same port with a fraction of the prompts. Not because the model got smarter. Because I did.

This book grew out of that realisation. It's built on principles I developed and tested in real projects — how to structure your thinking, how to communicate intent to an agent, how to verify output, and how to know when to take the wheel back. I'm by no means sure these are the best approaches — the field is moving too fast for anyone to claim certainty. But I've seen genuine, measurable improvement in my own work, and I believe these ideas can do the same for you. The techniques aren't complicated. They just aren't obvious — and nobody else is teaching them yet.

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

But lately, something feels different. Maybe you've tried AI coding tools and found them impressive but chaotic — like pairing with someone who's incredibly fast but has no concept of scope. Maybe you've watched someone with a fraction of your experience suddenly ship like a ten-year veteran, and it made you feel something you didn't expect. Maybe you're excited but don't know where to start. Maybe you're skeptical and want someone to convince you with substance, not hype.

This book is for you. It assumes you can code. It assumes you've been around. It meets you where you are.

== How to Read This Book

This isn't a reference manual. It's a journey, and it's structured like one.

We start by understanding what's actually changing and why — the shift in how software gets built, not just the tools but the _thinking_. Then we get into what agents actually are, stripped of the marketing language, so you have a mental model that holds up when the tools change next quarter.

From there, we get our hands dirty. You'll learn how to set up guardrails so agents don't wreck your codebase, how Git workflows change when agents are committing code, and why sandboxing isn't optional. We'll dig into testing as the feedback loop that makes agents _reliable_ instead of just fast, conventions as the secret weapon that most people overlook, and how tool integrations extend your agents' reach beyond the filesystem.

Then we go deeper — local versus commercial models, prompt engineering as a real discipline, multi-agent orchestration, and agents in your CI/CD pipeline. We'll look at war stories: real failures, real lessons, real scar tissue. We'll talk about when _not_ to use agents, because knowing when to put down the tool is as important as knowing how to use it. And we'll close with how teams adopt this stuff without imploding.

By the end, you won't just know how to use AI agents. You'll know how to _think_ about them — which is the skill that survives when the current generation of tools is obsolete.

== What This Book Is Not

Let me save you some time.

This is not a prompt cookbook. You won't find "50 ChatGPT prompts for developers" here. Prompting matters, and we cover it, but copy-pasting prompts without understanding the system underneath is a recipe for expensive frustration.

This is not an AI hype manifesto. I'm not here to tell you that agents will replace all programmers by next Tuesday. They won't. The gap between demo and production is as wide as it's ever been, and someone still has to mind that gap.

This is not a doom narrative either. The "AI is coming for your job" framing is lazy and mostly wrong. What's coming is a fundamental change in _how_ the job works, and that's a different conversation entirely.

This is an engineering book. For engineers. Written by someone who spends his days writing code with agents and has the git history to prove it. We're going to be practical, honest, and specific. If that sounds like your kind of thing, turn the page.
