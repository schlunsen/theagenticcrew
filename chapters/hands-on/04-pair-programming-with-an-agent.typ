#import "_os-helpers.typ": *
= Pair Programming with an Agent

In the last three chapters you set up your tools, submitted a pull request, and generated AI content. Now you're going to build something from scratch — a complete web application — by describing what you want to an AI coding agent.

You won't write the code yourself. You'll describe what you want, review what the agent builds, and iterate until it's right. This is pair programming with an AI: you bring the vision, the agent brings the implementation.

== What You'll Build

A *Travel Bucket List* — a personal web app where you can add destinations you want to visit, browse them as visual cards, edit the details, mark places as visited, and remove entries you've changed your mind about. The data lives in your browser's local storage, so nothing is sent to a server and nothing disappears when you close the tab.

By the end of this chapter, you'll have:

+ Created a project from scratch using only natural-language prompts
+ Built a working app with Create, Read, Update, and Delete operations
+ Used localStorage for persistence — no database, no server
+ Styled it into something you'd actually want to look at
+ Pushed it to GitHub

Every line of HTML, CSS, and JavaScript will be written by the agent. Your job is to describe, review, and refine.

== What You'll Need

From the previous chapters:
- A terminal (open and ready)
- Git installed and configured
- GitHub CLI authenticated
- Claude Code or Gemini CLI ready in your terminal

No new tools for this chapter. Everything runs in a browser — no build step, no dependencies.

== Create the Project

Start by creating an empty project folder and initialising Git:

```
mkdir travel-bucket-list && cd travel-bucket-list
git init
```

Now open your AI assistant from inside the project directory:

```
claude
```

Or:

```
gemini
```

You're ready to start building.

== Describe the App

Give the agent a clear picture of what you want. Don't worry about technical details — describe it like you're explaining to a friend what the app should look like and do.

Try this as your opening prompt:

- _"Build me a Travel Bucket List app in a single index.html file with embedded CSS and JavaScript. It should let me add destinations I want to visit, show them as visual cards in a grid, edit any destination, mark it as visited, and delete it. Store everything in localStorage so the data persists between page refreshes. Make it look beautiful — I want to actually enjoy using this."_

The agent will generate an `index.html` file. This single file contains everything — the structure (HTML), the styling (CSS), and the behaviour (JavaScript). No frameworks, no build tools, no complexity.

#quote(block: true)[
  *Why a single file?* For a small personal app, one file is the simplest thing that works. You can open it in any browser, email it to a friend, or host it anywhere. The agent could split it into separate files later if the project grows — but right now, simplicity wins.
]

== Review What the Agent Built

Before opening the browser, ask the agent to explain what it created:

- _"Walk me through the code. How are destinations stored? How does adding a new one work? How does the delete button know which card to remove?"_

You don't need to understand every line, but you should understand the shape of it:

- *HTML* defines the form and the card container
- *CSS* makes it look good — the grid layout, the card styling, the colours
- *JavaScript* handles the logic — saving to localStorage, rendering cards, handling button clicks

This is the most important habit in agent-assisted development: *always review before you run*. The agent is fast, but it's not infallible. A quick explanation catches misunderstandings early.

== Open It in Your Browser

#if is-mac [
```
open index.html
```
]

#if is-linux [
```
xdg-open index.html
```
]

#if is-windows [
```
start index.html
```
]

You should see your app — a form at the top and an empty card area below. Try adding your first destination:

+ Type a destination name (e.g., "Kyoto, Japan")
+ Add a short reason ("Cherry blossoms in spring")
+ Pick a priority
+ Click *Add*

A card should appear. Add two or three more. Refresh the page — they should still be there, because they're saved in localStorage.

== The CRUD Cycle

Your app now supports all four operations. Here's what each one means in practice:

#table(
  columns: (auto, 1fr, 1fr),
  [*Operation*], [*What it means*], [*In your app*],
  [*Create*], [Add a new entry], [Fill out the form and click Add],
  [*Read*], [View existing entries], [The card grid shows all destinations],
  [*Update*], [Edit an existing entry], [Click Edit on a card, change the details, save],
  [*Delete*], [Remove an entry], [Click Delete on a card — it's gone],
)

These four operations are the foundation of almost every application you've ever used — email, social media, note-taking apps, online shops. The data model changes, but the pattern is always the same: create, read, update, delete.

== Iterate and Improve

The first version is a starting point. Now make it yours. This is where pair programming shines — you describe what you want to change, the agent makes it happen, you review, repeat.

Here are prompts to try. Pick the ones that appeal to you:

=== Make it more visual

- _"Add an image URL field to each destination. When a card has an image, show it as the card's background. When it doesn't, use a nice gradient based on the priority level."_

- _"Add a colour-coded badge to each card — green for 'must go', amber for 'would love', grey for 'someday'."_

=== Add filtering and search

- _"Add a search bar that filters the cards as I type — matching on destination name or reason."_

- _"Add filter buttons at the top: All, Must Go, Would Love, Someday, Visited. Clicking one shows only matching cards."_

=== Make the visited toggle satisfying

- _"When I mark a destination as visited, animate the card — maybe a subtle confetti burst or a stamp overlay that says 'BEEN THERE'. Make it feel like an achievement."_

=== Add a stats bar

- _"Add a summary bar at the top showing: total destinations, how many visited, how many remaining. Update it live as I add, remove, or mark destinations."_

=== Improve the form

- _"Add a country dropdown (or auto-suggest) to the form, and group cards by country in the grid."_

- _"Make the form collapsible so I can hide it when I'm just browsing."_

#quote(block: true)[
  *Go off-script.* These prompts are suggestions, not assignments. If you want a dark mode toggle, a map view, or a "random destination" button — ask for it. The agent will figure out how to build it. The point is to practise the back-and-forth: describe, review, refine.
]

== When Something Goes Wrong

It will. The agent might generate code with a bug, or build something that doesn't quite match what you described. That's normal — and it's a skill to practise, not a failure.

*If a button doesn't work:*
- _"The Delete button isn't removing the card. Check the event listener — is it attached correctly? Fix it and explain what was wrong."_

*If the layout looks broken:*
- _"The cards are overlapping on mobile. Make the grid responsive — single column on small screens, two columns on medium, three on large."_

*If the data disappears:*
- _"My destinations vanish when I refresh. Check whether the save-to-localStorage function is actually being called after each change."_

*If the agent changed something you didn't ask for:*
- _"You changed the card layout but I only asked you to add the image field. Revert the layout changes and only add the image feature."_

The pattern is always the same: describe the problem, ask the agent to diagnose it, review the fix. This is debugging by conversation — and it's exactly how professional developers work with AI agents.

== Understand What Was Built

Before you commit, take a moment to understand the key concepts the agent used. Ask:

- _"Explain how localStorage works in this app. Where is data saved, and what happens if I clear my browser data?"_

- _"What is the DOM? How does the JavaScript update what I see on screen when I add a new card?"_

- _"Walk me through what happens, step by step, from the moment I click the Add button to the moment the new card appears."_

You don't need to memorise the answers. But understanding the flow — form input → JavaScript function → localStorage → DOM update — gives you vocabulary for the next time you build something.

#table(
  columns: (1fr, 1fr),
  [*Concept*], [*What it means*],
  [*HTML*], [The structure — what elements exist on the page],
  [*CSS*], [The style — how those elements look],
  [*JavaScript*], [The behaviour — what happens when you interact],
  [*localStorage*], [Browser storage that persists between visits],
  [*DOM*], [The live representation of the page that JavaScript can change],
  [*Event listener*], [Code that runs when something happens (click, submit, keypress)],
  [*CRUD*], [Create, Read, Update, Delete — the four basic data operations],
)

== Commit and Push

Once you're happy with your app, save it to GitHub. Ask the agent:

- _"Initialise a Git repository if one doesn't exist, create a branch called feature/travel-bucket-list, add all files, commit with a message describing what we built, and push to a new GitHub repository called travel-bucket-list."_

Or do it step by step:

```
git add index.html
git commit -m "Build travel bucket list app with CRUD and localStorage"
```

Create a repository on GitHub and push:

```
gh repo create travel-bucket-list --public --source=. --remote=origin --push
```

Verify it's there:

```
gh repo view --web
```

Your app is now on GitHub. Anyone with the link can clone it and open `index.html` in their browser.

== What Just Happened

You built a complete web application without writing a single line of code yourself. You described what you wanted, reviewed what the agent produced, and iterated until it was right.

#table(
  columns: (1fr, 1fr),
  [*You brought*], [*The agent brought*],
  [A clear idea — "travel bucket list"], [The HTML, CSS, and JavaScript],
  [Opinions on how it should look], [Card layouts, grids, and colour schemes],
  [Bug reports when something broke], [Diagnosis and fixes],
  [The decision to ship it], [Git commands and GitHub setup],
)

This is the core loop of agent-assisted development:

+ *Describe* what you want
+ *Review* what the agent builds
+ *Iterate* until it's right
+ *Understand* enough to stay in control

You don't need to know how to write JavaScript to build a JavaScript app. You need to know what you want, how to check whether you got it, and how to ask for changes. That's a different skill — and it's the one this book is teaching.

== Troubleshooting

*The page is blank when I open index.html:*
Open your browser's developer tools (F12 or right-click → Inspect) and check the Console tab. Red errors tell you what went wrong. Copy the error message and paste it to the agent: _"I'm getting this error in the console: [paste error]. Fix it."_

*Cards appear but disappear on refresh:*
The localStorage save function isn't being called. Ask: _"Check that every function which modifies the destinations array also calls the save function afterwards."_

*The form submits but nothing appears:*
The card rendering function might have a bug. Ask: _"Add a console.log at the start of the render function so I can see if it's being called. Then check the browser console."_

#if is-windows [
*index.html opens in Notepad instead of a browser:*
Right-click the file → *Open with* → choose your browser. Or type the full path in your browser's address bar.
]

*The styling looks different in different browsers:*
Ask the agent: _"Add a CSS reset at the top of the styles to normalise differences between browsers."_

*I want to start over:*
That's fine — and easy. Ask: _"Delete index.html and let's start fresh. This time I want [new description]."_ One of the advantages of agent-assisted development is that starting over costs minutes, not hours.

*localStorage is full or behaving strangely:*
Open developer tools → Application tab → Local Storage. You can see and delete entries manually. Or ask the agent: _"Add a 'Clear all data' button that wipes localStorage and resets the app."_

== Quick Reference

#table(
  columns: (1fr, 2fr),
  [*Task*], [*Prompt or command*],
  [Start the project], [`mkdir travel-bucket-list && cd travel-bucket-list && git init`],
  [Build the app], [_"Build a Travel Bucket List app in a single index.html..."_],
  [Open in browser], [#if is-mac [`open index.html`] #if is-linux [`xdg-open index.html`] #if is-windows [`start index.html`]],
  [Review the code], [_"Walk me through how the app works"_],
  [Add a feature], [_"Add [feature description] to the app"_],
  [Fix a bug], [_"[describe the problem] — diagnose and fix it"_],
  [Understand a concept], [_"Explain how [concept] works in this app"_],
  [Push to GitHub], [`gh repo create travel-bucket-list --public --source=. --remote=origin --push`],
  [View on GitHub], [`gh repo view --web`],
)
