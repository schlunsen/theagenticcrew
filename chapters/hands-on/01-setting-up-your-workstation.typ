#import "_os-helpers.typ": *
= Setting Up Your Workstation

Before you can contribute to a project, fix a bug, or even read source code properly, you need a working environment. This chapter gets your machine ready — from scratch, on whatever OS you're running.

By the end of this chapter, you'll have a terminal, a package manager, Git, the GitHub CLI, and optionally an AI assistant — all ready to go.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-workshop.typ"]

== Open Your Terminal

The terminal is your command line — the place where you'll run everything in this book.

#if is-windows [
PowerShell comes pre-installed on Windows 10 and 11.

+ Press `Win + X`
+ Select *Terminal* (or *Windows PowerShell*)

Verify it's working:

```
$PSVersionTable.PSVersion
```

You should see version *5.1* or higher.
]

#if is-mac [
Terminal is built in. Open it from Spotlight:

+ Press `Cmd + Space`
+ Type *Terminal* and press Enter

Or find it in *Applications → Utilities → Terminal*.

Verify you're running a modern shell:

```
echo $SHELL
```

You should see `/bin/zsh` (the default since macOS Catalina) or `/bin/bash`. Either works for this guide.
]

#if is-linux [
How you open the terminal depends on your desktop environment, but these shortcuts work on most distributions:

- *Ubuntu / GNOME:* `Ctrl + Alt + T`
- *KDE Plasma:* right-click the desktop → *Open Terminal*
- *Any distro:* search for "Terminal" in your app launcher

Verify the shell:

```
echo $SHELL
```

You should see `/bin/bash` or `/bin/zsh`.
]

#quote(block: true)[
  *Why the terminal?* AI coding agents live in the terminal. You can't pair-program with an agent if you don't have a place for it to work. Think of this as setting up your workshop before you start building.
]

== Install a Package Manager

A package manager lets you install software by typing one command instead of downloading installers and clicking through wizards. Each platform has its own.

#if is-windows [
=== WinGet

WinGet ships with Windows 10 (version 1809+) and Windows 11.

Check if you have it:

```
winget --version
```

If you get an error, install it from the Microsoft Store — search for *App Installer* — then close and reopen your terminal.
]

#if is-mac [
=== Homebrew

Homebrew is the standard package manager for macOS. Install it with:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This downloads and runs the official Homebrew installer. Follow the prompts — it will ask for your password and install a few things. When it finishes, verify:

```
brew --version
```

On Apple Silicon Macs (M1/M2/M3), Homebrew installs to `/opt/homebrew`. If `brew` isn't found after install, look for a "Next steps" section printed at the end of the installer output — it will show two commands to run. Copy and run those, then open a new terminal window.
]

#if is-linux [
=== apt / dnf

Linux distributions ship with a package manager. The most common:

#quote(block: true)[
  *What is `sudo`?* On Linux, `sudo` runs a command as an administrator — like "Run as Administrator" on Windows. You'll be asked for your user password. Nothing is shown as you type; that's normal.
]

*Ubuntu, Debian, and derivatives:*
```
sudo apt update
```

*Fedora, RHEL, and derivatives:*
```
sudo dnf check-update
```

*Arch Linux:*
```
sudo pacman -Sy
```

No install needed — these come with your OS. The examples in this guide use `apt`; swap for your distro's equivalent.
]

== Install Git

Git is version control. It tracks every change to every file in a project, and it's how teams collaborate without overwriting each other's work. Every project in this book uses Git.

#if is-windows [
```
winget install Git.Git
```

*Close and reopen your terminal* after installation.
]

#if is-mac [
Git is bundled with the Xcode Command Line Tools, which you likely already have. Try:

```
git --version
```

If you see a version number, you're done. If macOS prompts you to install the developer tools, click *Install* and wait for it to finish.

To get a newer version via Homebrew:

```
brew install git
```
]

#if is-linux [
*Ubuntu / Debian:*
```
sudo apt install git
```

*Fedora:*
```
sudo dnf install git
```

*Arch:*
```
sudo pacman -S git
```
]

---

Verify:

```
git --version
```

You should see a version number like `git version 2.47.1`.

Now set your identity so Git knows who's making changes:

```
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Use the same email as your GitHub account.

== See Git in Action

Git is installed — but you haven't used it yet. Let's do a quick 60-second test so Git isn't a mystery when Chapter 2 arrives.

Create a practice folder and step into it:

#if is-windows [
```
mkdir test-repo
cd test-repo
```
]

#if is-mac [
```
mkdir test-repo && cd test-repo
```
]

#if is-linux [
```
mkdir test-repo && cd test-repo
```
]

Tell Git to start tracking this folder:

```
git init
```

Check the status:

```
git status
```

You should see something like: `On branch main — nothing to commit`. That's Git telling you it's watching this folder and there's nothing new to record yet.

In Chapter 2 you'll use `git status` constantly — it's how you check what's changed. Now you've seen what it looks like when everything is clean.

Head back to your home folder when you're done:

```
cd ..
```

#quote(block: true)[
  *What just happened?* `git init` created a hidden `.git` folder inside `test-repo`. That folder is where Git stores its entire history. Every project that uses Git has one. You never need to touch it directly.
]

== Install the GitHub CLI

The GitHub CLI (`gh`) lets you fork repositories, create pull requests, and manage issues — all without leaving the terminal.

#if is-windows [
```
winget install GitHub.cli
```

Close and reopen your terminal.
]

#if is-mac [
```
brew install gh
```
]

#if is-linux [
*Ubuntu / Debian* — `gh` isn't in the default package repositories, so you need to add GitHub's official one first. These commands do that, then install `gh`:

```
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

You can paste the entire block at once — the terminal will run each line in sequence. You'll be asked for your password on the first `sudo`.

*Fedora:*
```
sudo dnf install gh
```

*All Linux distributions* — or install directly from #link("https://github.com/cli/cli/releases")[github.com/cli/cli/releases] by downloading the binary for your architecture.
]

---

Verify:

```
gh --version
```

== Create a GitHub Account

If you don't have one, sign up at #link("https://github.com/signup")[github.com/signup]. It's free. You'll need it for everything from Chapter 2 onward.

== Authenticate

Now connect your terminal to your GitHub account:

```
gh auth login
```

When prompted, choose:
- *GitHub.com*
- *HTTPS*
- *Login with a web browser*

It will give you a one-time code and open your browser. Paste the code, authorize, and you're connected.

Verify it worked:

```
gh auth status
```

You should see `Logged in to github.com`.

== (Optional) Install an AI Coding Assistant

This book is about working with AI agents. While you don't strictly need one for the exercises, having an AI assistant in your terminal makes the experience real.

Both Claude Code and Gemini CLI require Node.js. Install it first.

=== Install Node.js

#if is-windows [
```
winget install OpenJS.NodeJS.LTS
```
]

#if is-mac [
```
brew install node
```
]

#if is-linux [
*Ubuntu / Debian:*
```
sudo apt install nodejs npm
```

*Fedora:*
```
sudo dnf install nodejs npm
```
]

Close and reopen your terminal, then verify:

```
node --version
npm --version
```

=== Option A: Claude Code

Claude Code is Anthropic's AI coding agent. It runs in your terminal and can read, write, and reason about code.

Install it using the official installer (the recommended method):

#if is-mac [
```
curl -fsSL https://claude.ai/install.sh | bash
```
]

#if is-linux [
```
curl -fsSL https://claude.ai/install.sh | bash
```
]

#if is-windows [
```
winget install Anthropic.Claude
```
]

Alternatively, if you prefer npm:
```
npm install -g @anthropic-ai/claude-code
```

Launch it:

```
claude
```

You'll be prompted to authenticate with your Anthropic account on first run.

=== Option B: Gemini CLI

Gemini CLI is Google's AI coding agent. Similar concept, different model.

```
npm install -g @google/gemini-cli
gemini
```

You'll need a Google API key. Set it in your current session:

#if is-windows [
```
$env:GEMINI_API_KEY = "your-key-here"
```
]

#if is-mac [
```
export GEMINI_API_KEY="your-key-here"
```
]

#if is-linux [
```
export GEMINI_API_KEY="your-key-here"
```
]

#if is-mac [
To make it permanent so it's set every time you open a terminal, add the `export` line to your shell config file. This file runs automatically when your terminal starts:

Open `~/.zshrc` with:
```
open -e ~/.zshrc
```

Add `export GEMINI_API_KEY="your-key-here"` on a new line at the bottom, save, and close. Then run `source ~/.zshrc` to apply the change in your current session.
]

#if is-linux [
To make it permanent so it's set every time you open a terminal, add the `export` line to your shell config file. This file runs automatically when your terminal starts:

Open `~/.bashrc` with:
```
nano ~/.bashrc
```

Add `export GEMINI_API_KEY="your-key-here"` on a new line at the bottom, save, and close. Then run `source ~/.bashrc` to apply the change in your current session.
]

If you're not sure where to get a Google API key, go to #link("https://aistudio.google.com")[aistudio.google.com], sign in, and create a key under *Get API key*. It's free to start.

=== Which one?

Either works for this book. Claude Code tends to excel at code reasoning and multi-file edits. Gemini CLI has strong integration with Google's ecosystem. Try both if you want — they're free to start with. The exercises will show prompts that work with either tool.

== Verify Everything

Run this quick checklist:

```
git --version
gh --version
gh auth status
```

If all three commands work, you're ready. Your workstation is set up, your identity is configured, and you have a direct line to GitHub.

== The Prompt-First Way

Once Claude Code or Gemini CLI is installed, you don't have to remember every command — you can just describe what you want in plain English. Here's how you'd ask an AI agent to verify your entire setup for you.

Open your AI assistant in the terminal:

```
claude
```

Then try prompts like these:

- _"Check whether Git is installed and properly configured with a name and email."_
- _"Is the GitHub CLI installed and authenticated? Show me the status."_
- _"Run a quick checklist: git, gh, and gh auth status — tell me what's working and what isn't."_

The agent will run the commands, interpret the output, and tell you in plain language what's ready and what still needs attention. If something is missing or broken, ask it:

- _"Git isn't configured with my email — how do I fix that?"_
- _"Walk me through authenticating the GitHub CLI step by step."_
- _"I'm on macOS and Homebrew isn't in my PATH — how do I fix that?"_

#quote(block: true)[
  *Commands vs. prompts.* Both approaches get you to the same place. Commands are fast and precise once you know them. Prompts are forgiving — they meet you where you are. As you build experience, you'll find yourself switching between the two naturally.
]

In the next chapter, we'll put it all to use: you'll fork a real repository, read a real chapter of a real book, write an honest review, and submit your first pull request.
