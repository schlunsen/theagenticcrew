#import "_os-helpers.typ": *
= Testing as a Safety Net

Your Travel Bucket List is deployed. It's secured. You pentested it in Chapter 6 and understand its attack surface. Everything works.

Now change something.

Add a feature. Tweak the layout. Refactor how destinations are stored. How do you know you didn't break anything? Right now, you don't. You can click around manually, checking each feature by hand, and _hope_ you caught everything. But "hope" is not a strategy — and it definitely isn't something you can teach an AI agent.

Here's the uncomfortable truth: your agent is coding blindfolded. It can write features all day long, but it has no way to verify that what it built actually works — or that it didn't break something that worked five minutes ago. When you ask "add a sort-by-date feature," the agent writes code, says "done," and moves on. Did it work? Did it break the filter? Did it corrupt localStorage? Nobody checked.

Tests fix this. They give the agent eyes. A test suite is a machine-readable specification of what your app is supposed to do. Run the tests and you get a clear signal: green means everything works, red means something's broken. The agent can read that signal, diagnose the failure, and fix it — all without you clicking a single button.

This chapter turns your Travel Bucket List from a "seems to work" app into a "provably works" app.


== What You'll Build

By the end of this chapter, you'll have:

+ Written end-to-end tests that verify every core feature of your Travel Bucket List
+ Installed and configured Playwright as your test runner
+ Experienced test-driven development (TDD) with an AI agent — writing failing tests first, then making them pass
+ Broken your app on purpose and watched the tests catch it
+ Set up a GitHub Actions CI pipeline that runs tests on every push
+ Submitted a pull request and seen the green checkmark (and a red X)

Every test will be written by the agent. Your job is to describe what "correct" looks like.


== What You'll Need

From the previous chapters:
- Your Travel Bucket List app from Chapter 4 (pushed to GitHub)
- A terminal with your AI agent ready (Claude Code or Gemini CLI)
- Git installed and configured
- Node.js and npm installed (you set this up in Chapter 1)
- A browser (Playwright will handle the headless one, but you'll want a real one for manual exploration)

No new accounts or services. Everything runs locally until we set up CI at the end.


== The Blindfolded Agent

Before we write any tests, let's see what happens without them. Open your Travel Bucket List project and start your agent:

```
cd travel-bucket-list
claude
```

Now ask it to add a new feature:

- _"Add a 'sort by date added' button that sorts the destination cards from newest to oldest."_

Watch what happens. The agent reads your code, adds a sort button, wires up the logic, and reports back: "Done. I've added a sort-by-date button that sorts destinations from newest to oldest."

Open the app in your browser. Click the button. Does it work? Maybe. Maybe not. But here's the point — the agent has no idea either. It wrote code that _looks_ correct. It didn't verify that:

- The sort actually reorders the cards
- Existing features (add, edit, delete, filter, mark as visited) still work
- localStorage still saves and loads correctly after sorting
- The sort persists after a page refresh

Now let's make this worse. Ask the agent:

- _"Refactor the destination storage to include a `createdAt` timestamp for each entry."_

This touches the core data model. The agent rewrites the storage logic, updates the add function, and says "done." But did it migrate the existing entries that don't have timestamps? Does the edit function still work? Does the delete function still find entries by the right key?

You'd have to manually test every feature to find out. That's tedious, error-prone, and — crucially — it doesn't scale. The agent can't do it at all.

This is the "before" picture. Remember how it feels.


== Your First Test

Time to give the agent eyes. We'll use Playwright — a browser automation framework that can open your app, click buttons, fill forms, and assert that the right things appear on the page. It's like having a tireless QA tester who checks everything in seconds.

Ask your agent:

- _"Install Playwright as a dev dependency and set it up for end-to-end testing. Configure it to test a static site served from the current directory on port 5500."_

The agent will run something like:

```
npm init -y
npm install -D @playwright/test
npx playwright install chromium
```

It will also create a `playwright.config.js` (or `.ts`) that tells Playwright to spin up a local server before running tests. This matters — your Travel Bucket List is a static site, so Playwright needs a simple HTTP server to serve it.

#quote(block: true)[
  *Why Playwright?* It runs a real browser (Chromium, Firefox, or WebKit) in headless mode — no visible window, but all the rendering and JavaScript execution of a real browser. This means your tests interact with the app exactly like a user would. If the test passes, the feature genuinely works.
]

Now let's write the first test. Tell your agent:

- _"Write an end-to-end test: when I add a destination called 'Tokyo', it should appear as a card on the page."_

The agent will create a test file — something like `tests/bucket-list.spec.js` — with a test that:

+ Opens the app in a headless browser
+ Finds the input field and types "Tokyo"
+ Clicks the add button
+ Asserts that a card containing "Tokyo" appears on the page

Run the tests:

```
npx playwright test
```

You should see output like:

```
  1 passed (2.1s)
```

One test. One green line. But that single green line changes everything. You now have a _machine-verifiable fact_: adding a destination makes it appear on the page. The agent can check this in two seconds, every single time it makes a change. No clicking required.


== Build the Suite

One test is a start. A suite is a safety net. Let's describe every important behavior your app should have and let the agent write a test for each.

Give the agent a list of behaviors in plain English:

- _"Write end-to-end tests for each of these behaviors:"_

+ When I add "Tokyo" as a destination, a card with "Tokyo" appears on the page
+ When I add "Tokyo" and refresh the page, "Tokyo" is still there (localStorage persistence)
+ When I edit "Tokyo" to "Kyoto", the card updates to show "Kyoto"
+ When I delete "Tokyo", the card disappears
+ When I mark "Tokyo" as visited, it visually changes (e.g., a checkmark or different style)
+ When I have destinations "Tokyo", "Paris", and "Berlin", I can filter to show only visited or unvisited
+ When I add three destinations, all three appear as cards

The agent will write a test for each behavior. Some will be straightforward. Others might require the agent to understand your app's specific UI — which input fields exist, what the buttons are labelled, how cards are structured.

#quote(block: true)[
  *Tests as documentation.* Notice that each test reads like a sentence: "When I do X, Y should happen." This is intentional. Your test suite becomes a living specification of what your app does. Six months from now, you (or anyone else) can read the tests and understand every feature without touching the source code.
]

Run the full suite:

```
npx playwright test
```

You might see some failures. That's normal and actually useful — it means either the test is wrong (the agent misunderstood your UI) or the feature has a bug you didn't know about. Ask the agent to investigate each failure:

- _"The 'edit destination' test is failing. Look at the test code and the app code, figure out why, and fix it."_

This is the feedback loop. Tests fail, you diagnose, you fix, tests pass. Every passing test is one more thing you never have to manually check again.


== Red-Green-Refactor with an Agent

Now let's experience test-driven development — writing the test _before_ the feature exists. This is where agents really shine.

Tell your agent:

- _"Write a failing test for this behavior: when I click a 'Sort A-Z' button, the destination cards are reordered alphabetically."_

The agent writes the test. Run it:

```
npx playwright test
```

It fails. Red. The button doesn't exist yet, the sort logic doesn't exist, nothing works. That's the point — the test is a precise, executable description of what you want.

Now tell the agent:

- _"Make the failing 'Sort A-Z' test pass. Don't modify the test — only change the application code."_

The agent reads the failing test, understands exactly what's expected (a button labelled "Sort A-Z" that reorders cards alphabetically), and implements the feature. It adds the button, writes the sort logic, and wires it up.

Run the tests again:

```
npx playwright test
```

Green. Every test passes — the new sort feature works, _and_ nothing else broke.

This is the TDD cycle with an agent:

+ *Red* — you describe a behavior, the agent writes a failing test
+ *Green* — you tell the agent to make it pass, the agent implements the feature
+ *Refactor* — you ask the agent to clean up the code, the tests ensure nothing breaks

The test isn't just checking the agent's work. It's _guiding_ the agent's work. Instead of vaguely saying "add sorting," you gave it a concrete, verifiable target. The agent knows exactly when it's done — when the test goes green.

#quote(block: true)[
  *Why constrain the agent with tests?* Without tests, "add sorting" is ambiguous. Sort what? By what criteria? In what direction? Where does the button go? The agent makes guesses. With a test, every question has an answer encoded in the assertions. The test is the spec.
]


== Breaking Things on Purpose

Let's prove that the safety net actually catches you when you fall.

Ask your agent:

- _"In the app's JavaScript, comment out the line that saves destinations to localStorage. Don't change anything else."_

The agent comments out the save call. Your app still _looks_ like it works — you can add destinations and they appear as cards. But refresh the page and they're gone. The data isn't persisting.

This is exactly the kind of subtle bug that slips through manual testing. You add a destination, it shows up, everything looks fine. You move on. A week later, a user complains that their data disappeared.

Run the tests:

```
npx playwright test
```

Red. The "add and refresh" persistence test fails. The test added "Tokyo," refreshed the page, and "Tokyo" was gone. The test caught what your eyes missed.

Now here's the powerful part. Ask your agent:

- _"The tests are failing. Diagnose the issue and fix it."_

The agent reads the test failure output, sees which test failed and why, examines the code, finds the commented-out save call, and restores it. Run the tests again — green.

You didn't tell the agent _what_ was broken. You said "tests are failing, fix it." The test output was the communication channel. The red test told the agent exactly where to look and what the expected behavior should be. Tests aren't just a safety net for you — they're a language the agent understands.


== Automate It: GitHub Actions

Running tests locally is good. Running them automatically on every push is better. Let's set up a CI pipeline so that GitHub runs your tests every time you push code or open a pull request.

Ask your agent:

- _"Create a GitHub Actions workflow that installs dependencies, installs Playwright browsers, and runs the test suite on every push and pull request."_

The agent will create a file at `.github/workflows/test.yml` that looks something like this:

```yaml
name: Tests
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test
```

Commit everything and push:

```
git add -A
git commit -m "Add test suite and CI pipeline"
git push
```

Visit your repository on GitHub and click the "Actions" tab. You should see your workflow running. When it finishes — green checkmark. Your tests pass in CI.

Now let's see the red X. Create a branch, introduce a bug, and open a pull request:

- _"Create a new branch called 'break-something', remove the localStorage save call again, commit it, push it, and open a pull request."_

The agent creates the branch, breaks the code, pushes, and opens the PR. Go to GitHub. The PR shows a red X next to the failing checks. Click it and you can see exactly which test failed and why.

This is the workflow that professional teams use every day. No code merges to main unless the tests pass. The CI pipeline is the gatekeeper, and the tests are its rules.

#quote(block: true)[
  *The red X is a feature, not a failure.* When a PR shows failing tests, that's the system working exactly as designed. It caught a problem before it reached production. The alternative — merging broken code and finding out from angry users — is far worse.
]

Close the broken PR without merging. Switch back to main:

```
git checkout main
```


== The Checkpoint

You've built the safety net. Now use it.

Pick a feature you want to add to your Travel Bucket List. Some ideas:

- A "random destination" button that highlights a random card
- A character count or word limit on destination descriptions
- A "visited on" date field that records when you visited a place
- An export button that downloads your destinations as a JSON file

Whatever you pick, do it with TDD:

+ Write a failing test that describes the behavior (red)
+ Tell the agent to make it pass (green)
+ Ask the agent to clean up the code (refactor)
+ Run the full suite to make sure nothing else broke
+ Commit and push — watch CI go green

No step-by-step instructions this time. You have the tools and the workflow. The agent is your pair programmer, and the tests are your shared language.


== What Just Happened

You turned a fragile, manually-verified app into one that checks itself. Let's look at what you brought versus what the agents brought:

#table(
  columns: (1fr, 1fr),
  [*You brought*], [*The agents brought*],
  [The decision to invest in tests], [Test code for every core behavior],
  [Plain-English descriptions of correct behavior], [Playwright configuration and browser automation],
  [The TDD discipline: test first, then implement], [Feature implementation guided by failing tests],
  [The instinct to break things and verify the net catches them], [Diagnosis and fixes driven by test output],
  [The choice to automate with CI], [A complete GitHub Actions workflow],
)

The core loop:

+ *Describe* what correct behavior looks like ("when I add Tokyo and refresh, Tokyo is still there")
+ *Review* the test the agent writes (does it actually check what you described?)
+ *Iterate* until all tests pass and the code is clean
+ *Automate* so the checks run without you

There's a deeper lesson here. In Chapter 4, you told the agent _what to build_. In this chapter, you told the agent _what "correct" means_. That's a different skill — and a more powerful one. An agent that knows what correct looks like can verify its own work, catch its own mistakes, and fix its own bugs. You went from giving instructions to setting standards.


== Troubleshooting

*Playwright install fails or times out:*
Playwright needs to download browser binaries. If you're behind a corporate proxy or firewall, this can fail. Try: `npx playwright install --with-deps chromium` (installing just Chromium instead of all browsers). On Linux, the `--with-deps` flag installs system dependencies Playwright needs.

*Tests fail with "page.locator(...) not found":*
The agent wrote a test that looks for a specific CSS selector or text that doesn't match your app's actual HTML. Ask the agent: _"The test can't find the element. Look at the actual HTML structure of the app and update the test selectors to match."_ This is the most common issue and usually a one-line fix.

*Tests pass locally but fail in CI:*
Usually a timing issue. Headless browsers in CI run on slower machines, so elements take longer to appear. Ask the agent to add explicit waits: `await page.waitForSelector('.card')` instead of immediately asserting. Playwright's auto-waiting handles most cases, but complex interactions sometimes need help.

*The local server doesn't start for tests:*
Check your `playwright.config.js` — the `webServer` section needs the right command to serve your static files. Common options: `npx serve .` or `python3 -m http.server 5500`. Make sure the port matches what the config expects.

*"Browser was not installed" error:*
Run `npx playwright install chromium` again. This downloads the browser binary that Playwright controls. If you switch Node.js versions (via nvm or similar), you may need to reinstall.

*GitHub Actions workflow fails with permission errors:*
Make sure your workflow file is at exactly `.github/workflows/test.yml` (not `.github/workflow/` — note the plural). The `actions/checkout@v4` step should be the first step in the job.

*Tests are flaky — passing sometimes, failing others:*
Flaky tests are almost always timing issues. The app hasn't finished rendering when the test checks for an element. Ask the agent: _"This test is flaky. Add proper waits and make it deterministic."_ Playwright's `expect(locator).toBeVisible()` auto-retries, which helps.

*localStorage tests fail after other tests:*
Tests might be interfering with each other through shared localStorage state. Ask the agent to add a `beforeEach` hook that clears localStorage before every test: `await page.evaluate(() => localStorage.clear())`.


== Quick Reference

#table(
  columns: (1fr, 2fr),
  [*Task*], [*Command or prompt*],
  [Install Playwright], [`npm install -D @playwright/test && npx playwright install chromium`],
  [Run all tests], [`npx playwright test`],
  [Run tests with visible browser], [`npx playwright test --headed`],
  [Run a single test file], [`npx playwright test tests/bucket-list.spec.js`],
  [Run tests matching a name], [`npx playwright test -g "sort"` (matches test names containing "sort")],
  [See the test report], [`npx playwright show-report`],
  [Debug a failing test], [`npx playwright test --debug`],
  [Write a new test], [_"Write a failing test for: when I click X, Y should happen."_],
  [Make a test pass], [_"Make the failing test pass. Only change application code."_],
  [Diagnose failures], [_"The tests are failing. Diagnose and fix the issue."_],
  [Set up CI], [_"Create a GitHub Actions workflow that runs Playwright tests on push and PR."_],
)


== Cleaning Up

Your test suite and CI pipeline are additions, not temporary artifacts — you'll want to keep them. But if you created the `break-something` branch for the CI demo, clean it up:

```
git branch -d break-something
```

If you pushed it to GitHub:

```
git push origin --delete break-something
```

The test infrastructure (Playwright, the config file, the test files, the GitHub Actions workflow) should stay. They're the foundation for every change you make from here on out. Every future chapter builds on the assumption that you can verify your work automatically.

#quote(block: true)[
  *What comes next?* You've now built, deployed, secured, and tested an application — all with AI agents doing the heavy lifting. The safety net is in place. From here, you can move faster because you can move with confidence. Every new feature starts with a test. Every change is verified before it ships. The agent isn't coding blindfolded anymore — it can see exactly what's working and what's not. That's the difference between writing code and engineering software.
]
