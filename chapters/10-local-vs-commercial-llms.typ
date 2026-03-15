= Local LLMs vs. Commercial LLMs

Where does the model run? It sounds like an infrastructure question, but it's really a question about trust, cost, and capability — and every agentic engineer has to answer it for themselves.

== The Case for Commercial LLMs

Commercial models — Claude, GPT, Gemini — are where the frontier is. They have the largest context windows, the best reasoning, and the most consistent tool use. For serious agentic engineering work, they're hard to beat.

The trade-off is straightforward: your code leaves your machine. Every file you feed into context, every prompt you write, every error log you share — it travels over the wire to someone else's infrastructure. For personal projects and many companies, this is fine. For defence contractors, healthcare, or anyone bound by strict data residency rules, it's a non-starter.

Cost is the other factor. When you're running agents that iterate in loops — reading, writing, testing, retrying — token usage adds up. A single complex task can burn through thousands of calls. At scale, this becomes a real line item.

== The Case for Local LLMs

Running a model locally — Llama, Mistral, Qwen, or any of the open-weight models via Ollama, llama.cpp, or vLLM — gives you something commercial APIs can't: complete privacy and zero marginal cost per token.

Your code never leaves your machine. You can feed it proprietary source, internal documents, production logs — anything — without thinking twice about data policies. And once the model is downloaded, every inference is free. Run it a thousand times, run it all night, nobody sends you a bill.

The trade-off is capability. Local models are smaller, less capable, and have shorter context windows. A 70B parameter model running on a beefy MacBook is impressive, but it's not going to match a frontier commercial model on complex multi-file reasoning tasks. You'll find it handles focused, well-scoped tasks well — writing a single function, explaining a piece of code, generating tests for a known interface — but struggles when it needs to hold a large system in its head.

== The Practical Answer: Use Both

Most experienced agentic engineers land on a hybrid approach. Local models for the high-volume, low-stakes work: quick code generation, boilerplate, commit messages, documentation drafts, and anything touching sensitive data. Commercial models for the hard stuff: complex debugging, multi-file refactoring, architectural reasoning, and tasks where you need the best judgement available.

The key insight is that this isn't a religious choice — it's an engineering one. You match the model to the task the same way you'd choose between SQLite and Postgres. The agentic engineer who can fluently move between local and commercial models, picking the right tool for the job, will consistently outperform someone locked into either camp.

And the landscape is shifting fast. The gap between local and commercial models shrinks with every release. The setup that's right today might look different in six months. Stay flexible.
