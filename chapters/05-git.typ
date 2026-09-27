= Git as Agent Infrastructure

#figure(
  image("../assets/illustrations/ch05-git-branches.jpg", width: 80%),
)

You already know Git. You've been committing, branching, and merging for years. But in agentic engineering, Git isn't just version control — it's the backbone of your entire workflow. It's your undo button, your parallel execution framework, your review interface, and your documentation system all at once.

Most engineers use maybe 20% of what Git offers. Agentic engineering demands the other 80%.

== Small Commits, Always

The single most important Git habit for agentic engineering: commit small, commit often.

When an agent makes changes, you want to be able to review each logical step independently. A commit that says "refactored authentication, updated tests, fixed the navbar, and changed the database schema" is impossible to review and impossible to roll back partially. Four separate commits — each doing one thing — give you surgical control.

This matters more with agents than with human developers, because agents move fast. An agent can make twenty file changes in thirty seconds. If those changes are bundled into one commit, and something breaks, you're untangling a mess. If they're in five clean commits, you revert the one that broke things and keep the rest.

Train yourself — and your agents — to commit at natural boundaries:
- After each logical change, not after each session
- Before switching to a different concern
- After tests pass, capturing a known-good state
- Before attempting something risky, creating a save point

== Let Agents Write Your Commit Messages

This is one of the easiest wins in agentic engineering, and it's almost embarrassingly simple: let the agent write the commit message.

Think about it. The agent just made the changes. It knows exactly what it modified, why it modified it, and what the intent was. It has the full diff in context. It will write a more accurate, more descriptive commit message than you would — because you'd be summarising from memory, and the agent is summarising from facts.

A typical human commit message at 11pm: "fix auth bug"

A typical agent commit message: "fix session expiry race condition when WebSocket disconnects during OAuth token refresh — the cleanup goroutine was running before the token exchange completed, leaving orphaned sessions in the database"

The second one is useful six months from now when someone — human or agent — is trying to understand why that code exists. The first one is noise.

Make this a habit. After the agent completes a task, ask it to commit with a descriptive message. Or configure your workflow so it happens automatically. The quality of your git history will improve overnight.

=== Say Who Wrote It

While the agent is writing the message, have it say that it was involved. The common convention is a `Co-Authored-By` trailer at the end of the commit message — most agent tools add one by default, and GitHub shows the co-author on the commit:

```
Fix session expiry race during OAuth token refresh

Co-Authored-By: Claude <noreply@anthropic.com>
```

It costs one line, it makes agent-assisted changes searchable in `git log`, and it keeps you honest with your reviewers. Why that honesty matters is covered in the ethics section of the Guardrails chapter. The short version: the trailer records provenance, not responsibility. Your name is still on the commit.

// v2-verify: confirm the trailer email/name shown matches what current Claude Code emits, or make it generic.

== Branches as Task Boundaries

Every agent task gets its own branch. This is non-negotiable.

The branch serves multiple purposes:
- *Isolation.* The agent's changes don't affect your main branch until you explicitly merge them.
- *Review scope.* When you're done, you review a single PR — the diff between the branch and main. This is a workflow every engineer already knows.
- *Rollback.* If the whole thing is wrong, you delete the branch. Clean. No surgery required.
- *Parallel work.* Multiple agents on multiple branches, working simultaneously, never stepping on each other.

Name your branches descriptively: `agent/refactor-auth-middleware`, `agent/add-user-tests`, `agent/fix-sidebar-rendering`. When you look at your branch list, you should see a manifest of everything your agents are working on.

== Worktrees for Parallel Agents

Branches alone aren't enough for true parallel work. If two agents are on different branches but sharing the same working directory, they'll fight over the filesystem — one checks out a branch while the other is halfway through an edit. Git worktrees solve this. Other chapters lean on them, so here's the full picture.

A worktree is a separate checkout of your repo — a different directory, on a different branch, sharing the same `.git` history. Creating one, along with a new branch, takes seconds:

```bash
git worktree add -b agent/fix-sidebar ../my-project-fix-sidebar
```

Now you have two directories: your main checkout and the worktree. Each agent gets its own worktree, its own branch, its own filesystem. They can both run tests, modify files, and build — simultaneously, without conflicts. Commits made in one are immediately visible to the others, because there's only one repository underneath.

A few commands cover the whole lifecycle:

```bash
git worktree list                          # what's checked out where
git worktree remove ../my-project-fix-sidebar
git worktree prune                         # clean up stale entries
```

When the work is done:
- Good result → merge the branch, remove the worktree
- Bad result → remove the worktree, delete the branch
- Need to iterate → keep the worktree, continue the conversation

Three things catch people out. First, a worktree contains only what Git tracks. Your `.env`, your `node_modules`, your build caches — none of it comes along, so the agent's first job in a fresh worktree is often installing dependencies and copying (safe, non-production) config. Script this. Second, Git won't let two worktrees check out the same branch — which is exactly the protection you want. Third, parallel agents still share your machine: two dev servers on the same port, or two test suites against the same local database, will collide in ways Git can't prevent.

This is the cheapest sandbox you can build. No containers, no VMs, no cloud resources. Just Git.

=== Increasingly, the Tool Does It for You

When I first wrote this chapter, you created worktrees by hand. Many agent tools now do it for you: you start a session or spin up a sub-agent with worktree isolation, and the tool creates the branch and directory, points the agent at it, and cleans up afterwards. Know what's underneath anyway — when something breaks, you'll be debugging a worktree whether you created it or not.

Cloud agents take the same idea one step further. You hand a task to a background agent — assign it an issue, or send it from a chat window — and it clones your repo into a remote sandbox, works on a branch there, and returns a pull request. There's no worktree on your machine at all. But the shape is identical: an isolated copy, a dedicated branch, and a diff you review before anything touches `main`. Branch-per-task turned out to be the right abstraction, which is why every tool converged on it.

== Reviewing Agent Work Through Diffs

Your primary interface for reviewing agent work isn't reading code — it's reading diffs.

This is a subtle but important shift. When you write code yourself, you review it as you write. When an agent writes code, you review it after the fact. And the most efficient way to do that is through the diff against your base branch.

Develop your diff-reading skills:
- *Start with the test changes.* If the agent wrote or modified tests, read those first. They tell you what the agent thinks the code should do. If the tests match your intent, the implementation is probably fine.
- *Look for scope creep.* Did the agent change files you didn't expect? Unrelated formatting changes? Extra dependencies? These are red flags.
- *Check the boundaries.* Function signatures, API contracts, database schemas — changes to interfaces have outsized impact. Review these carefully.
- *Trust but verify.* If the diff is large, don't read every line. Spot-check the critical paths, make sure the tests are meaningful, and run the suite yourself.

The goal isn't to read every line the agent wrote — that defeats the purpose. The goal is to verify that the agent's changes match your intent and don't introduce problems. Diffs make this fast.

== Reviewing at Higher Volume

Once agents are working in parallel — locally, in the cloud, overnight — the bottleneck moves. Writing code stops being the slow part. _Reviewing_ it becomes the slow part.

The answer isn't to review less carefully. It's to make each review cheaper:

- *Small PRs, always.* The same discipline as small commits, one level up. One concern per PR. A 150-line PR gets a real review; a 1,500-line PR gets a rubber stamp. If an agent's task produced something huge, that's a scoping problem — split it.
- *Stack them.* When a change genuinely needs to be large, break it into a stack of dependent PRs — the migration, then the data layer, then the API, then the UI — each reviewable on its own and merged in order. Agents are good at producing stacks if you ask for one up front.
- *Let the machines take the first pass.* CI, linters, type checkers and an AI review bot should all have had their say before a human looks. Your attention goes on intent, design and risk — the things only you can judge.
- *Cap work in progress.* If you can't review it this week, don't start it today. An unreviewed agent PR isn't progress; it's inventory, and it goes stale as `main` moves under it.

The Agentic Teams chapter comes back to what this does to a team's review culture.

== Git History as Documentation

Here's the insight most engineers miss: agents read your git history. When an agent is trying to understand why code exists, how a feature evolved, or what approach was tried before, it looks at `git log` and `git blame`.

This means your commit history is documentation. Not the kind you write in a wiki — the kind that's embedded in the code itself, permanently, with perfect provenance.

Good commit messages compound over time. Six months from now, when an agent is working on your codebase, it will read those messages to understand context. The difference between a history of "fix bug" and "fix race condition in session cleanup" is the difference between an agent that understands your codebase and one that's guessing.

And if your agent has access to run `git log` and `git blame` — which it should — this documentation isn't something you need to copy-paste into prompts. The agent reads it directly from the repository. Your job is to make the history worth reading, not to read it for the agent.

This also applies to PR descriptions, branch names, and merge commit messages. Every piece of text you attach to your Git history is context for future agents. Write accordingly.

== The Git Workflow for Agentic Engineering

Putting it all together, here's the workflow:

+ Create a branch for the task — or let your tool create one
+ Give the agent its own worktree (or a cloud sandbox)
+ Let it work — committing at natural boundaries
+ Agent writes descriptive, attributed commit messages
+ Open a small PR and review the diff against main
+ Merge if good, discard if not

It uses Git features that have existed for years — branches, worktrees, diffs — combined in a way that's purpose-built for agentic engineering. The best part: you already know all of this. You've been using Git for years. Agentic engineering doesn't require new tools — it requires using your existing tools more deliberately.
