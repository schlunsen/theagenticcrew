#import "_os-helpers.typ": *
= Your First Pull Request

This chapter is a hands-on exercise. By the end of it, you'll have forked a real repository, created a branch, written a review of a book chapter, and submitted a pull request — the standard way open-source contributors propose changes.

This isn't a simulation. Your pull request will show up on GitHub for real people to read.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-pr-flow.typ"]

== What You'll Need

Everything from Chapter 1:
- A terminal (open and ready)
- Git installed and configured
- GitHub CLI authenticated
- A GitHub account

== What's About to Happen

Before the first command, here's the complete journey you're about to take — seven steps, one after another:

+ *Fork* — Create your own copy of the book's repository on GitHub
+ *Clone* — Download that copy to your machine
+ *Branch* — Create a safe, isolated version where you can make changes
+ *Write* — Add your review as a new file
+ *Commit* — Save your changes with a message (Git's version of hitting Save)
+ *Push* — Send your changes back up to your GitHub copy
+ *Pull Request* — Ask the author to merge your changes into the original

This is the open-source workflow. Every contribution to every major project in the world follows these same seven steps. You'll have done all of them by the end of this chapter.

Here are the key words you'll see — read them once now, and they'll make sense as you go:

#table(
  columns: (auto, 1fr),
  [*Term*], [*What it means*],
  [*Repository*], [A project folder that Git is tracking. Often called a "repo."],
  [*Fork*], [Your personal copy of someone else's repository, stored on GitHub.],
  [*Clone*], [Downloading a repository from GitHub to your machine.],
  [*Branch*], [A parallel version of the project where you work without touching the main copy.],
  [*Commit*], [A saved snapshot of your changes, with a message describing what you did.],
  [*Push*], [Sending your commits from your machine up to GitHub.],
  [*Pull Request*], [A formal request to merge your branch into the original project.],
)

You don't need to memorise these. They'll become natural as you use them.

== Fork and Clone the Book

We'll work with _The Agentic Crew_ — the book you're reading right now. The source lives on GitHub as a public repository.

Run this single command:

```
gh repo fork schlunsen/theagenticcrew --clone --remote
```

This does three things in one step:
+ Creates your own copy (a "fork") on GitHub
+ Downloads it to your machine (a "clone")
+ Sets up the connection between your copy and the original

Enter the project directory:

```
cd theagenticcrew
```

Verify your setup:

```
git remote -v
```

You should see two remotes:
- `origin` — your fork (where you push changes)
- `upstream` — the original repository (where you pull updates)

== Explore the Project

Before you change anything, look around. The book is written in Typst, a modern typesetting language. The source files are plain text — you can read them in any editor.

See the project structure:

```
ls
ls chapters/
```

The chapters are in the `chapters/` directory, numbered and named. The one we care about is `01-introduction.typ`.

== Read Chapter 1

Open it in a text editor:

#if is-windows [
```
notepad chapters\01-introduction.typ
```
]

#if is-mac [
```
open -e chapters/01-introduction.typ
```
]

#if is-linux [
```
xdg-open chapters/01-introduction.typ
```
]

Or with VS Code on any platform, if you have it installed:

```
code chapters/01-introduction.typ
```

You'll see Typst markup — headings start with `=`, emphasis uses `_underscores_`, and the rest is prose. It reads like a regular document.

*Take your time.* Read the full chapter. The introduction covers:
- The author's journey discovering agentic workflows
- Why the ground is shifting for software engineers
- Who the book is for and how to read it
- What the book is — and what it isn't

Form your own opinions as you read. That's the whole point of this exercise.

== Create a Branch

In Git, you don't edit the main copy directly. You create a *branch* — a parallel version where you can make changes without affecting anyone else's work.

```
git checkout -b review/chapter-1-YOUR-GITHUB-USERNAME
```

Replace `YOUR-GITHUB-USERNAME` with your actual username. For example:

```
git checkout -b review/chapter-1-johndoe
```

#quote(block: true)[
  *Newer Git versions (2.23+)* offer `git switch -c` as a more explicit alternative to `git checkout -b`. Both do the same thing. You'll see `checkout` used most widely in tutorials and documentation, so that's what we use here.
]

#quote(block: true)[
  *Why branches?* Imagine ten people all editing the same Google Doc at once — chaos. Branches let everyone work independently, then merge their changes one at a time. It's how every serious software project operates.
]

== Write Your Review

Create a `reviews` folder and your review file.

#if is-windows [
```
mkdir reviews
notepad reviews\review-chapter-1-YOUR-GITHUB-USERNAME.md
```
]

#if is-mac or is-linux [
```
mkdir -p reviews
nano reviews/review-chapter-1-YOUR-GITHUB-USERNAME.md
```

This opens a simple terminal text editor. Type (or paste) your review directly. When you're done, press `Ctrl+X` to exit, then `Y` to confirm saving, then `Enter` to keep the filename.

You can also use any editor you like — `code`, `vim`, or anything else that feels natural.
]

Here's a template to start with. Type it out or copy it from this page, then fill in your actual thoughts below each heading:

```markdown
# Review — Chapter 1: Introduction

**Reviewer:** @YOUR-GITHUB-USERNAME
**Date:** YYYY-MM-DD

## First Impressions
What stood out to you when you first read this chapter?

## What Worked Well
What parts resonated? What was clear and engaging?

## What Could Be Improved
Be honest but constructive. Confusing sections?
Missing context? Anything that felt off?

## Who Would Benefit From This Chapter
Based on what you read, who is the ideal reader?

## Rating
Your overall rating out of 5, with a one-line summary.
```

Don't overthink it. A genuine paragraph for each section is worth more than a polished essay.

== The Prompt-First Way

The command-by-command approach above is the full manual workflow. Once Claude Code or Gemini CLI is installed, you can describe the entire task in plain English and let the agent handle most of it.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-two-paths.typ"]

Open your AI assistant from inside the cloned project directory:

```
claude
```

Or:

```
gemini
```

=== Let the agent read the chapter

Instead of opening the file yourself, ask the agent to read it and give you a summary:

- _"Read chapters/01-introduction.typ and summarise what it covers."_
- _"What's the main argument of chapters/01-introduction.typ? Who does the author think this book is for?"_

This is useful when you want a fast orientation before reading the whole thing yourself.

=== Draft your review together

Once you've read the chapter (yourself or with the agent's help), use the agent as a thinking partner:

- _"Read chapters/01-introduction.typ and give me your honest take — what works well and what's missing for a book introduction?"_
- _"I think the introduction spends too long on the author's backstory. Do you agree? What would you cut?"_
- _"Help me fill out this review template for chapter 1."_ (paste the template into the prompt)

The agent will give you a draft to react to. Agree, disagree, edit — the review should end up in your voice, not the agent's.

=== Let the agent do the Git work

Here's where the prompt-first approach really shines. After you've written your review, you can hand the Git steps to the agent:

- _"Create a branch called review/chapter-1-YOUR-GITHUB-USERNAME, add my review file to it, commit it with a sensible message, push it to my fork, and open a pull request."_

The agent will run each command, show you what it's doing, and flag any problems. You stay in the loop without having to remember the exact syntax.

Or go even further — describe the whole task upfront before you start:

- _"I want to submit a review of chapters/01-introduction.typ as a pull request to this repo. Walk me through it step by step, or just do it for me if I say go."_

The agent will outline the plan, wait for your approval, and execute.

=== When to use commands vs. prompts

#table(
  columns: (1fr, 1fr),
  [*Use commands when...*], [*Use prompts when...*],
  [You know exactly what to do], [You're not sure what step comes next],
  [Speed matters], [You want to understand what's happening],
  [You're scripting or automating], [You're exploring or experimenting],
  [The command is short and memorable], [The task involves multiple steps],
)

#quote(block: true)[
  *A note on honesty.* Whether you write your review manually or draft it with an AI assistant, the opinions should be yours. Use the agent to sharpen your thinking and handle the mechanical steps — not to replace your judgment. The best reviews have a human voice. An agent can help you find the words for what you already feel, but it can't feel it for you.
]

== Stage and Commit

Once your review is written and saved, tell Git to track it:

```
git add reviews/
```

Check what's staged:

```
git status
```

You should see your review file listed under "Changes to be committed."

Now commit — this creates a snapshot with your changes and a message explaining what you did:

```
git commit -m "Add Chapter 1 review by YOUR-GITHUB-USERNAME"
```

== Push to Your Fork

Send your branch to GitHub:

```
git push origin review/chapter-1-YOUR-GITHUB-USERNAME
```

Your changes now exist both on your machine and on GitHub.

== Create the Pull Request

This is the moment. A pull request says: "Hey, I made some changes on my fork — would you like to merge them into the original project?"

```
gh pr create --title "Chapter 1 Review: YOUR-GITHUB-USERNAME" --body "Honest review of Chapter 1 (Introduction) of The Agentic Crew. Covers first impressions, strengths, areas for improvement, and target audience fit."
```

The CLI will output a URL. Open it in your browser — that's your pull request, live on GitHub.

You can also view it anytime:

```
gh pr view --web
```

== What Happens Next

Once you submit your PR:

+ *The author reads it* — honest feedback on a book-in-progress is genuinely valuable
+ *They may comment* — asking follow-up questions or thanking you for a specific insight
+ *It gets merged* — your review becomes a permanent part of the project's history

That's the open-source workflow: fork, branch, change, push, PR. Every contribution to every major project in the world follows this pattern. You just did it for real.

== Troubleshooting

*`git push` asks for a password:*
Run `gh auth setup-git` to configure Git to use your GitHub CLI credentials. Works the same on all platforms.

#if is-windows [
*`mkdir reviews` fails because the folder already exists:*
That's fine — just skip the `mkdir` step and open the file directly with `notepad reviews\chapter-1-review-YOUR-GITHUB-USERNAME.md`. Windows will create the file if it doesn't exist.

*`mkdir reviews` gives an error on older PowerShell:*
Use `New-Item -ItemType Directory -Force -Path reviews` instead.
]

#if is-linux [
*`nano` isn't installed on your distro:*
Use `vi reviews/...` (available everywhere) or install nano: `sudo apt install nano`.
]

#if is-mac [
*`open -e` doesn't open a text editor:*
TextEdit is the default. For plain text, try `open -a TextEdit chapters/01-introduction.typ` or just use `code` if you have VS Code.
]

*You made a typo in your branch name:*
Create a new branch from main: `git checkout main && git checkout -b review/chapter-1-corrected-name`, then copy your review file over.

*The PR targets the wrong branch:*
You can specify the base: `gh pr create --base main --title "..."`.

== Quick Reference

#table(
  columns: (1fr, 2fr),
  [*Task*], [*Command*],
  [See your branches], [`git branch`],
  [See what changed], [`git status`],
  [View the diff], [`git diff`],
  [Pull latest from upstream], [`git fetch upstream && git merge upstream/main`],
  [View your PR], [`gh pr view --web`],
)
