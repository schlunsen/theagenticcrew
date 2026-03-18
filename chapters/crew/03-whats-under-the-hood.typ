= What's Under the Hood

#figure(
  image("../../assets/illustrations/crew/ch03-under-the-hood.jpg", width: 80%),
  caption: [_Every app is a restaurant — front of house, kitchen, and pantry._],
)

Your friend tells you they're building an app. "It's a Django backend with a React frontend, Postgres for the database, and Redis for caching." You nod. You smile. You have absolutely no idea what any of that means.

This chapter fixes that.

We're not going to turn you into an engineer. We're going to give you the mental model — the map of the territory — so that when you hear these words, you know which part of the machine they're talking about. And more importantly, when you direct an agent to build something, you'll understand what it's actually building.

We're going to use one example throughout: a project management tool, like a simpler version of Trello. A board with columns, cards you can drag around, and people assigned to tasks. Simple enough to understand, complex enough to be real.

== The Restaurant

Every web application is built from a handful of building blocks. Different apps use different specific tools, but the _shape_ is always the same. The easiest way to understand it is to think of a restaurant.

A restaurant has a dining room — the part customers see. It has a kitchen — the part that does the real work. It has a pantry — where ingredients are stored. And it has a prep station — where frequently used ingredients are kept within arm's reach so the chef doesn't have to walk to the pantry every thirty seconds.

A web application has the same four parts. They just have different names.

== React — The Dining Room

*What it is:* React is a _frontend framework_. It's the part of the application that runs in your web browser — everything you see, touch, and interact with.

*In our Trello clone:* The board with its columns. The cards you can drag from "To Do" to "In Progress." The button that says "Add Task." The little avatar showing who's assigned. The dropdown menu when you click the three dots. All of that is React.

*Why it matters:* React doesn't store any data. It doesn't make decisions about business rules. It's the dining room — beautifully laid out, responsive to your every interaction, but it doesn't cook the food. When you drag a card to a new column, React makes the card move _immediately_ on your screen. But behind the scenes, it's sending a message to the kitchen saying "the customer wants to move this card." If the kitchen says no — maybe you don't have permission — React puts the card back.

*What you'll hear people say:* "It's a React app" means the part you interact with is built using this tool. There are alternatives — Vue, Svelte, Angular — but they all do roughly the same job. React is the most common, like how most restaurants have a dining room regardless of which chairs they chose.

== Django — The Kitchen

*What it is:* Django is a _backend framework_. It's the brain of the application — the part that runs on a server, enforces the rules, processes requests, and decides what happens.

*In our Trello clone:* When you click "Add Task" and type "Buy groceries," React sends that request to Django. Django checks: Are you logged in? Do you belong to this project? Is the task title valid? Is the project still active? If everything checks out, Django tells the database to store the new task and sends a confirmation back to React.

*Why it matters:* Django is where the _logic_ lives. The pricing rules. The permission system. The business logic that says "only project admins can delete boards." It's the kitchen — it doesn't care what the dining room looks like, and the dining room doesn't care what brand of oven the kitchen uses. They communicate through a standardised order slip, which we'll get to in a moment.

*What you'll hear people say:* "The backend is returning an error" means Django (the kitchen) is choking on a request. "We need to add that logic on the backend" means the rule needs to live in Django, not React. There are alternatives — Rails (Ruby), Express (JavaScript), Laravel (PHP), FastAPI (Python, like Django) — but the concept is identical. A kitchen is a kitchen.

== Postgres — The Pantry

*What it is:* Postgres (short for PostgreSQL) is a _database_. It's where all the data lives — every user account, every project, every task, every comment, every timestamp.

*In our Trello clone:* When Django stores that new task, it goes into Postgres. Imagine a massive, meticulously organised filing cabinet. There's a drawer labelled "Tasks," and inside it, every task is a row:

#table(
  columns: (auto, auto, auto, auto, auto),
  [*ID*], [*Title*], [*Project*], [*Status*], [*Created*],
  [247], [Fix the nav bar], [Project #3], [Done], [March 12],
  [248], [Buy groceries], [Project #3], [To Do], [March 18],
  [249], [Call the client], [Project #5], [In Progress], [March 18],
)

When you load your board, Django asks Postgres: "Give me all tasks in Project #3, sorted by status." Postgres finds them and hands them back. Django passes them to React. React draws the board. The whole trip takes about 200 milliseconds — less time than a blink.

*Why it matters:* The database is the only part of the system that _remembers_ things. If the server restarts, Django boots back up fresh — but all the data is safe in Postgres, exactly where it was left. Lose the database and you've lost everything. That's why backups matter.

*What you'll hear people say:* "It's in the database" means the information is stored permanently. "We need to query the database" means we need to ask Postgres for specific data. "The database is slow" means Postgres is taking too long to find things — usually because the filing cabinet has gotten enormous and nobody's built an index (think of an index like tabs on the drawers that let you jump straight to the right section).

== Redis — The Prep Station

*What it is:* Redis is an _in-memory cache_. It keeps frequently accessed data in fast, temporary storage so the application doesn't have to hit the database for every single request.

*In our Trello clone:* Some information gets requested constantly. "How many unread notifications does this user have?" "How many tasks are in Project #3?" Instead of making Postgres dig through the filing cabinet every single time someone loads the page, Django stores the answer in Redis.

Redis keeps everything in memory — think of it as a whiteboard mounted on the kitchen wall. Need the notification count? Glance at the whiteboard. Instant. When the count changes (someone assigns you a new task), Django updates the whiteboard. If the whiteboard gets erased — a server restart, for instance — that's fine. Django recalculates the numbers from Postgres and writes them on the whiteboard again.

*Why it matters:* Speed. Postgres is reliable but relatively slow — it stores data on disk, which means physical reading and writing. Redis stores everything in RAM, which is orders of magnitude faster. For data that changes rarely but gets read constantly, this is the difference between a snappy app and one that feels sluggish.

*What you'll hear people say:* "It's cached in Redis" means the data is being served from the whiteboard instead of the filing cabinet. "The cache is stale" means the whiteboard hasn't been updated and is showing old numbers. "Clear the cache" means erase the whiteboard and let it rebuild from the database.

== How They Talk — The Life of a Click

These four pieces aren't one big program. They're four separate programs that communicate by sending messages to each other. Here's what happens when you click "Add Task" and type "Buy groceries":

+ *React (your browser):* You click the button, type the text, hit enter. React sends a message to Django: "New task: Buy groceries, in project \#3, from user \#42."

+ *Django (the backend):* Receives the message. Checks — is user \#42 logged in? Does user \#42 belong to project \#3? Is the title non-empty and under 500 characters? All good. Tells Postgres to store it.

+ *Postgres (the database):* Creates a new row: Task \#248, "Buy groceries," Project \#3, created now, status "To Do." Tells Django: "Done, here's the new task with its ID."

+ *Django tells Redis:* "Bump the task count for project \#3 from 47 to 48." Redis updates its whiteboard.

+ *Django tells React:* "Here's the new task. It's been saved. Task \#248." React adds the card to your board.

All of that happens in about 200 milliseconds. Less time than it takes to blink.

If something goes wrong — say Postgres is down — Django sends an error back to React, and React shows you a friendly message: "Something went wrong, please try again." The kitchen caught fire, but the waiter doesn't dump smoke into the dining room. They deliver the bad news politely.

== The API — The Order Slip

The messages between React and Django follow a specific format. Think of it as a standardised order slip in the restaurant — the waiter writes orders in a format the kitchen can read, and the kitchen sends food back on plates the waiter can carry.

That format is called an *API* — Application Programming Interface. It's a contract. React knows exactly how to ask, Django knows exactly how to answer. If React sends a request that doesn't match the contract — like ordering a dish that's not on the menu — Django sends back an error.

You'll hear people say things like "the API is returning a 500." That number is a status code — a shorthand for what happened:

- *200* — Everything's fine. Here's your food.
- *401* — You're not logged in. Who are you?
- *403* — You're logged in, but you don't have permission.
- *404* — That thing doesn't exist. (This is the one you've seen — "404 Not Found.")
- *500* — Something exploded in the kitchen. It's our fault, not yours.

When your developer friend says "the API is down," they mean the communication channel between the frontend and backend has stopped working. The dining room is fine. The kitchen is fine. But the door between them is jammed.

== Authentication — The Wristband

How does Django know it's _you_ making the request?

When you log in — type your email and password, or click "Sign in with Google" — Django verifies your identity and gives your browser a *token*. Think of it as a wristband at a festival. For the rest of your session, every message React sends to Django includes that wristband. Django glances at it and says, "Yep, that's user \#42, they're allowed to be here."

If the wristband expires (most tokens last a few hours or days), you get bounced back to the login screen. If someone steals your wristband — that's a security breach. That's why "log out on shared computers" isn't just a suggestion.

When your developer says "the auth is broken," they mean this wristband system has a problem. Maybe tokens aren't being issued. Maybe they're expiring too fast. Maybe they're not being checked properly, which is much scarier — it means the bouncer isn't doing their job.

== WebSockets — The Walkie-Talkie

Most web communication works like sending letters. React sends a request, waits, and Django sends a response. It's called request-response, and it's how most of the internet works.

But what about real-time features? When your teammate adds a card to the board, you want to see it _immediately_ — not the next time you refresh the page. That's where *WebSockets* come in.

A WebSocket is like a walkie-talkie. Instead of sending letters back and forth, React and Django open a _persistent connection_ — a line that stays open. The moment something changes on the server, Django broadcasts it to everyone who's listening. Your board updates in real time. You see the cursor moving as your teammate drags a card.

That's how chat apps work. That's why you can see "Sarah is typing..." in real time. It's a WebSocket — an open line between your browser and the server, constantly listening.

== Git — The Undo Button for Everything

#figure(
  image("../../assets/illustrations/crew/ch03-git-branches.jpg", width: 80%),
  caption: [_Every experiment gets its own safe copy._],
)

Before we go further into infrastructure, you need to know about Git. Not because you'll use it directly every day — but because it's the single most important reason you can let agents work on your code without losing sleep.

Imagine you're writing a long document in Google Docs. You know that little "Version history" feature? Where you can see every change anyone ever made, and restore any previous version? Git is that — but much, much more powerful. It's how virtually every piece of software in the world is built.

=== The Core Concepts

*Repository (repo):* A project folder that remembers everything. Every file, every change, every version — all the way back to day one. Your Trello clone lives in a repo.

*Commit:* A snapshot. Like saving your game. "Here's what everything looked like at 3pm on Tuesday." Each commit has a short message describing what changed: "Added price calculator" or "Fixed the glass transparency." You can go back to any snapshot, any time.

*Branch:* A parallel universe. You say, "I want to try adding a 3D preview, but I'm not sure it'll work." You create a branch — a copy of your project where you can experiment freely. If it works, you merge it back into the main project. If it doesn't, you delete the branch. The original is untouched.

Think of it as drafting on tracing paper over your blueprint. Experiment all you want. The blueprint underneath doesn't change until you decide to make it permanent.

*Merge:* Taking the tracing paper and pressing it onto the blueprint. The experiment worked, so you fold those changes into the main project.

*Pull Request (PR):* Before you merge, you can ask someone to review your tracing paper. "Hey, look at what I changed — does this seem right?" That review step is a pull request. It's where teammates — or you, reviewing an agent's work — look at the changes before they become official.

*GitHub:* The place where repos live online. Think of it as Google Drive for code. Your repo is stored there, backed up, and shareable. It's also where pull requests and code reviews happen.

=== Why Git Matters for Working with Agents

Here's why this is so important. When you tell an agent to "add a 3D preview using Three.js," the agent might change fifteen files. Maybe it works beautifully. Maybe it breaks everything. Without Git, you'd be stuck — Ctrl+Z doesn't work across fifteen files.

With Git, you tell the agent: work on a branch. Now all its changes are contained in that parallel universe. You test it. If the 3D preview looks great — merge. If the agent went haywire and rewrote your entire pricing logic for no reason — delete the branch. Five seconds. No damage done.

The flow looks like this:

```
main (your stable app)
  |
  |-- branch: "add-3d-preview"
  |     |-- Agent makes changes (commit: "Add Three.js scene")
  |     |-- Agent fixes a bug  (commit: "Fix camera angle")
  |     |-- You review it -- looks good!
  |     +-- Merge back into main
  |
  |-- main now has the 3D preview
  |
  |-- branch: "pdf-generation"
  |     |-- Agent tries something (commit: "Add PDF export")
  |     |-- It's a mess -- the PDFs are blank
  |     +-- Delete branch. Main is untouched.
  |
  +-- main is still safe. Try again.
```

Every experiment is safe. Every mistake is reversible. That branch diagram is your safety net, drawn out. Engineers live in this flow every single day. Now you understand why.

*Git means you can always go back. That means you can be bold.*

== DNS — The Internet's Phone Book

#figure(
  image("../../assets/illustrations/crew/ch03-dns-phonebook.jpg", width: 80%),
  caption: [_The internet's phone book connects names to numbers._],
)

You type `trello.com` into your browser. But computers don't understand names — they understand numbers. Somewhere, there's a giant lookup system that translates `trello.com` into `104.192.141.1` — the actual address of the server where Trello lives.

That system is *DNS* — the Domain Name System. It works exactly like the contacts on your phone. You tap "Mom," your phone knows that means +45 12 34 56 78. You never think about the number. But without it, the call doesn't connect.

When your developer friend says "the DNS isn't propagated yet," they mean: we changed the phone number, but not everyone's phone book has updated yet. DNS changes can take minutes to hours to spread across the internet. That's why after launching a new site, some people can see it and others can't — their phone book is still showing the old address.

Every website you've ever visited started with a DNS lookup. You just never noticed, because it takes about 20 milliseconds.

== VPS — The Apartment Where Your App Lives

Your Django backend, your Postgres database, your Redis cache — they need a computer to run on. Not your laptop. A computer that's on 24 hours a day, 7 days a week, connected to the internet, sitting in a building with backup power and serious air conditioning.

A *VPS* — Virtual Private Server — is renting a slice of one of those computers. You don't get the whole machine. You get a walled-off section of it, with your own operating system, your own storage, your own memory. Like renting an apartment instead of buying a house — the building is shared, but your apartment is yours.

Common names you'll hear: *DigitalOcean*, *Hetzner*, *Linode*, *AWS*, *Google Cloud*. The first three are like renting a straightforward apartment — here's your server, here's the key, good luck. AWS and Google Cloud are more like entire cities — thousands of services, overwhelming if you just need somewhere to run your app, but powerful if you need to scale to millions of users.

When someone says "the server is down," they mean this computer — the VPS — has stopped responding. When they say "we need to scale up," they mean the apartment is too small and they need a bigger one, or several.

React is a bit different from the others: it gets downloaded to _your_ browser and runs on _your_ computer. Django, Postgres, and Redis all live on the server. React is the only part that travels to the customer.

== Migrations — Reshaping the Database

What happens when you want to add a "due date" field to tasks? You can't just scribble a new column onto the filing cabinet. Postgres needs a formal instruction: "Add a new column called `due_date` to the tasks drawer."

That instruction is called a *migration*. Django generates it automatically when you change your data model, and it reshapes the database without losing any existing data. Every row in the Tasks drawer gets a new, empty "due date" slot, and from now on, new tasks can include a due date.

Migrations can also remove columns, rename them, or change their type. They're applied in order, like a changelog — migration 001, 002, 003. You can see the entire history of how your database evolved from a single table to a hundred.

When your developer says "we need to write a migration for that," they mean the database structure needs to change to support a new feature. It sounds scary, but it's routine — most apps run dozens or hundreds of migrations over their lifetime.

== CI — The Automated Checklist

A developer finishes a change. Maybe they fixed a bug. Maybe they added a new feature. Now what? They can't just paste it onto the live server and hope for the best. (They _can_. Engineers have a saying: never deploy on Friday.)

*CI* — Continuous Integration — is an automated checklist that runs every time someone proposes a change. Think of it as a factory quality check before the product leaves the building:

+ *Does the code even run without errors?* Sometimes a change breaks something obvious — a typo, a missing file, an incompatible version.

+ *Do all the tests pass?* The app has hundreds of automated tests — little scripts that verify things like "log in as a user, create a task, mark it done, verify it shows in the Done column." If any of those scenarios break, CI catches it.

+ *Does it match the team's style rules?* Consistent formatting, naming conventions, no leftover debugging code.

+ *Does it introduce security problems?* Known vulnerabilities in dependencies, exposed credentials, unsafe patterns.

If anything fails, the change gets rejected with a red mark and a message explaining what broke. The developer fixes it and tries again.

If everything passes — green checkmark. Now a teammate reviews the change in a pull request, and if they approve it, CI can automatically *deploy* it — push the new version to the VPS. The next time someone loads the app, they get the updated version.

The whole thing takes minutes, runs without any human touching it, and catches problems that humans miss. It's the reason apps update constantly without you noticing — behind the scenes, changes are flowing through this pipeline dozens of times a day.

Common tools you'll hear about: *GitHub Actions*, *GitLab CI*, *Jenkins*. They all do roughly the same thing — run the checklist, report the result.

== Keeping Your Finger on the Pulse

You don't need to write code to stay current with what's happening in the software world. The best non-technical people I've worked with have one thing in common: they know what's out there. They read about a new tool on Hacker News three weeks before the engineering team brings it up. They spot a trending open-source project on GitHub that solves exactly the problem the team has been complaining about. They're not experts in these tools — but they know they exist, and that's half the battle.

Three places worth visiting a few times a week:

*Hacker News* (news.ycombinator.com) — A link aggregator run by Y Combinator, the startup incubator behind Airbnb, Dropbox, and Stripe. Engineers post and discuss articles about technology, tools, and industry shifts. The comment sections are gold — you'll see real engineers arguing about whether a new tool is actually good or just hype. Skim the top five stories a few times a week and you'll be ahead of most people in any meeting.

*GitHub Trending* (github.com/trending) — A daily and weekly list of open-source projects gaining traction. You won't understand all the code — you don't need to. Read the project descriptions. "A faster alternative to Elasticsearch." "Self-hosted Notion clone." "AI agent framework for Python." You start seeing patterns: what problems people are solving, what's gaining momentum, what your team might adopt next quarter.

*Reddit* (r/programming, r/webdev, r/selfhosted, r/artificial) — Community discussions, more casual than Hacker News, often more practical. People share what they're building, what broke, what they learned. Great for the "how do real people actually feel about this?" perspective. When a new AI tool drops, Reddit will tell you within 24 hours whether it's genuinely useful or just marketing.

The habit is simple. Ten minutes with your morning coffee, three times a week. Skim the front page. Read one article that catches your eye. Within a month, you'll start recognising names — frameworks, libraries, companies. Within three months, you'll overhear your developer friend talking about something and think, "Oh, I read about that last week."

That moment — when you stop being the person who nods along in meetings and start being the person who asks the question that changes the direction of the conversation — that's when this chapter has done its job.

== Now You Know

That's it. Four building blocks. A dining room (React), a kitchen (Django), a pantry (Postgres), and a prep station (Redis). Plus the infrastructure that holds it all together: Git for version control, DNS for finding the app, a VPS for running it, and CI for making sure nothing breaks when changes roll out.

Almost every web application you use daily — your bank, your streaming service, your project management tools — is some variation of this pattern. The specific names change. The shape doesn't.

Now when your developer friend says "the API is returning a 500" or "we need to add a Redis cache for that" or "I'm writing a migration," you'll know which part of the restaurant is having a bad day. And when you sit down with an agent and say "build me a quoting tool" — you'll understand what it's actually building.

That understanding is your boarding pass for the rest of this book.
