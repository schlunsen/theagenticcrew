= Git as Agent Infrastructure

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

== Branches as Task Boundaries

Every agent task gets its own branch. This is non-negotiable.

The branch serves multiple purposes:
- *Isolation.* The agent's changes don't affect your main branch until you explicitly merge them.
- *Review scope.* When you're done, you review a single PR — the diff between the branch and main. This is a workflow every engineer already knows.
- *Rollback.* If the whole thing is wrong, you delete the branch. Clean. No surgery required.
- *Parallel work.* Multiple agents on multiple branches, working simultaneously, never stepping on each other.

Name your branches descriptively: `agent/refactor-auth-middleware`, `agent/add-user-tests`, `agent/fix-sidebar-rendering`. When you look at your branch list, you should see a manifest of everything your agents are working on.

== Worktrees for Parallel Agents

Branches alone aren't enough for true parallel work. If two agents are on different branches but sharing the same working directory, they'll fight over the filesystem. Git worktrees solve this.

A worktree is a separate checkout of your repo — a different directory, on a different branch, sharing the same `.git` history. Creating one takes seconds:

```bash
git worktree add ../my-project-feature feature-branch
```

Now you have two directories: your main checkout and the worktree. Each agent gets its own worktree, its own branch, its own filesystem. They can both run tests, modify files, and build — simultaneously, without conflicts.

When the work is done:
- Good result → merge the branch, remove the worktree
- Bad result → remove the worktree, delete the branch
- Need to iterate → keep the worktree, continue the conversation

This is the cheapest sandbox you can build. No containers, no VMs, no cloud resources. Just Git.

== Reviewing Agent Work Through Diffs

Your primary interface for reviewing agent work isn't reading code — it's reading diffs.

This is a subtle but important shift. When you write code yourself, you review it as you write. When an agent writes code, you review it after the fact. And the most efficient way to do that is through the diff against your base branch.

Develop your diff-reading skills:
- *Start with the test changes.* If the agent wrote or modified tests, read those first. They tell you what the agent thinks the code should do. If the tests match your intent, the implementation is probably fine.
- *Look for scope creep.* Did the agent change files you didn't expect? Unrelated formatting changes? Extra dependencies? These are red flags.
- *Check the boundaries.* Function signatures, API contracts, database schemas — changes to interfaces have outsized impact. Review these carefully.
- *Trust but verify.* If the diff is large, don't read every line. Spot-check the critical paths, make sure the tests are meaningful, and run the suite yourself.

The goal isn't to read every line the agent wrote — that defeats the purpose. The goal is to verify that the agent's changes match your intent and don't introduce problems. Diffs make this fast.

== Git History as Documentation

Here's the insight most engineers miss: agents read your git history. When an agent is trying to understand why code exists, how a feature evolved, or what approach was tried before, it looks at `git log` and `git blame`.

This means your commit history is documentation. Not the kind you write in a wiki — the kind that's embedded in the code itself, permanently, with perfect provenance.

Good commit messages compound over time. Six months from now, when an agent is working on your codebase, it will read those messages to understand context. The difference between a history of "fix bug" and "fix race condition in session cleanup" is the difference between an agent that understands your codebase and one that's guessing.

This also applies to PR descriptions, branch names, and merge commit messages. Every piece of text you attach to your Git history is context for future agents. Write accordingly.

== The Git Workflow for Agentic Engineering

Putting it all together, here's the workflow:

+ Create a branch for the task
+ Optionally create a worktree for isolation
+ Point the agent at the worktree
+ Let it work — committing at natural boundaries
+ Agent writes descriptive commit messages
+ Review the diff against main
+ Merge if good, discard if not

This workflow is fast, safe, and scales to multiple parallel agents. It uses Git features that have existed for years — branches, worktrees, diffs — but combines them in a way that's purpose-built for agentic engineering.

The best part: you already know all of this. You've been using Git for years. Agentic engineering doesn't require new tools — it requires using your existing tools more deliberately.
