= What Is an Agent, Really?

#figure(
  image("../../assets/illustrations/crew/ch04-agent-loop.jpg", width: 80%),
  caption: [_Observe, plan, act, check — repeat._],
)

You've been using agents for years. You just didn't know it.

When your email app moves a newsletter to your Promotions tab, that's an agent — a tiny one, with a narrow job. When your phone suggests "You usually leave for work at 8:15, traffic is heavy, leave now" — that's an agent. When Spotify builds you a playlist based on what you've been listening to — agent.

These are small agents. Single-task. Narrow. They observe something (your email, your location, your listening history), they decide something (this is a promotion, traffic is bad, you'd like this song), and they act (move the email, send a notification, queue the song).

The agents this book is about are the same idea, but much, much bigger. They don't just categorise your email — they can read your entire codebase, plan a series of changes, write the code, run the tests, and iterate on failures. They're not doing one clever thing. They're doing _many_ things, in sequence, adapting as they go.

== The Loop

Every agent, from the simplest email filter to the most sophisticated code-writing tool, runs the same basic loop:

+ *Observe.* Take in information. Read the files. See the error message. Look at the current state of things.
+ *Plan.* Decide what to do. "The test is failing because this function returns the wrong value. I need to change line 47."
+ *Act.* Do the thing. Write the code. Move the file. Send the message.
+ *Check.* Did it work? Run the test. Read the output. See if the error is gone.
+ *Repeat.* If it worked, move to the next task. If it didn't, go back to step 1 with new information.

That's it. Observe, plan, act, check, repeat. The loop is the same whether the agent is sorting your inbox or building a web application. What differs is the _scope_ — how much the agent can see, how many tools it has, and how much autonomy you've given it.

A simple agent runs this loop once. A powerful agent runs it dozens of times, adjusting its approach each time, building on what it learned from previous attempts.

== Tools Define Capability

An agent without tools is just a chatbot. It can _think_ and _respond_, but it can't _do_ anything. The tools you give an agent define what it's capable of.

An agent with access to your filesystem can read and write code. An agent with a web browser can research documentation. An agent with a terminal can run commands, execute tests, and start servers. An agent with access to your Git repository can create branches, make commits, and open pull requests.

Think of it like a new employee. A smart person with no access to any systems is just someone sitting at an empty desk. Give them a login to the project management tool and they can track work. Give them access to the code repository and they can make changes. Give them deployment credentials and they can ship to production.

The tools are the access. The agent is the person. You decide what access to grant based on what you trust them to do — which is exactly what the Trust Gradient chapter is about.

== What an Agent Is Not

An agent is not a person. It doesn't have goals, desires, or feelings. It's not "trying" to help you in any meaningful sense. It's running a very sophisticated pattern-matching process — predicting the most likely useful next action given everything it can see.

This distinction matters because it changes how you work with it. You don't motivate an agent. You don't need to be polite (though it doesn't hurt). What you need to be is _clear_. An agent responds to clarity the way a person responds to motivation. The better you describe what you want, the better the output. Every time.

An agent is also not infallible. It will confidently produce wrong answers. It will hallucinate libraries that don't exist. It will solve the wrong problem with beautiful precision. It will work tirelessly in the wrong direction unless you check its course.

That's your job. Not writing the code — _steering_.

== The Spectrum

Not all agents are equal. There's a spectrum from simple to sophisticated:

*Autocomplete* — The simplest form. You start typing and the tool predicts what comes next. GitHub Copilot does this for code. Your phone keyboard does it for text. Low autonomy, low risk, constantly supervised.

*Chat assistants* — You ask a question, you get an answer. ChatGPT, Claude, Gemini. More capable, but still reactive — they do what you ask, one exchange at a time. No tools, no memory between sessions (usually), no ability to act on the world.

*Tool-equipped agents* — The same intelligence, but with hands. They can read files, run commands, search the web, interact with APIs. This is where things get powerful — and where the rest of this book lives. Claude Code, Cursor, Windsurf — these are agents with access to your project, your terminal, your tools.

*Autonomous agents* — Agents that run unsupervised for extended periods. You give them a goal, they figure out the steps, execute them, handle errors, and come back with results. The most powerful and the most dangerous. Most of the guardrails in this book exist because of this category.

Where you are on this spectrum depends on your comfort level, your use case, and how much you trust the output. Most people reading this book will work primarily with tool-equipped agents — powerful enough to build real things, supervised enough to catch mistakes.

== Why This Matters for You

You don't need to understand how the language model works internally. You don't need to know about transformers, attention heads, or token prediction. That's the engine. You need to know how to drive.

What you _do_ need to understand:

- Agents work in a loop: observe, plan, act, check.
- Tools define what they can do. More tools means more capability, but also more risk.
- They're confidently wrong as often as they're confidently right. Verification is not optional.
- Clarity is your superpower. The better you communicate, the better the output.

If you've ever managed people, you already have the core skill. You're about to learn how to apply it to a very fast, very literal, very tireless team member who never needs coffee but also never asks clarifying questions.
