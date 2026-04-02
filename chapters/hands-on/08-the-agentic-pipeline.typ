#import "_os-helpers.typ": *
= The Agentic Pipeline

You've been the one typing prompts. In every chapter so far, you started the conversation. You opened the terminal, wrote an instruction, watched the agent work, reviewed the output, and decided what came next. You were the driver. The agent was the engine — powerful, fast, tireless — but it only moved when you turned the key.

This chapter is about removing yourself from the loop.

Not because you're unnecessary. You designed the system. You decided what matters. You set the quality bar. But once those decisions are made, there's no reason you should be the one executing them at 2 a.m. on a Tuesday. The tedious, repetitive work — reading incoming feedback, categorising it, filing issues, writing reports — that's exactly the kind of work agents were made for.

By the end of this chapter, you'll have a pipeline that runs while you sleep. Unstructured input goes in one end. Categorised, prioritised GitHub issues and a summary report come out the other. No frameworks. No platforms. Just shell scripts, the `claude` CLI, and the Unix philosophy: small tools, connected by pipes, doing one thing well.

This is the moment you stop being the worker and start being the architect.


== What You'll Build

By the end of this chapter, you'll have:

+ A shell script that reads unstructured feedback from a JSON file
+ An intake agent that parses messy text into clean, structured JSON
+ A triage agent that categorises each item by type, priority, and suggested labels
+ Automated GitHub issue creation with labels and descriptions
+ A summary report generator that produces weekly Markdown digests
+ A cron job (or GitHub Action) that runs the whole pipeline on a schedule

All of it orchestrated by a single shell script. No Python. No Node.js. No "agent framework." Just pipes.


== What You'll Need

From the previous chapters:
- A terminal with the `claude` CLI installed and authenticated (Chapter 1)
- Git installed and configured
- A GitHub account with a repository you can create issues in

New for this chapter:
- The `gh` CLI — GitHub's official command-line tool (#link("https://cli.github.com")[install it here])
- `jq` — a lightweight JSON processor (#link("https://jqlang.github.io/jq/download/")[install it here])
- About 30 minutes and a willingness to automate yourself out of a job

#quote(block: true)[
  *Why these tools?* The `gh` CLI lets you create issues, pull requests, and releases from the terminal — no browser needed. `jq` lets you slice, filter, and transform JSON on the command line. Together with `claude`, they form a toolkit that can automate almost any development workflow. All three are free, open source, and available on every major platform.
]


== The Boring Work

Before we automate anything, let's feel the pain of doing it manually. This is important — you can't appreciate a pipeline until you've done the work it replaces.

Create a project directory and a sample feedback file:

```
mkdir -p agentic-pipeline
cd agentic-pipeline
```

Now create a file called `feedback.json` with five sample entries — the kind of raw, unstructured input that lands in support inboxes, Slack channels, and feedback forms every day:

```json
[
  {"id": 1, "text": "The app crashes every time I try to upload a photo larger than 5MB. Happens on both iOS and Android. Super frustrating."},
  {"id": 2, "text": "Would be amazing if you could add dark mode. My eyes are burning at night lol"},
  {"id": 3, "text": "Love the new search feature! So much faster than before. Great job team."},
  {"id": 4, "text": "Login page shows a blank screen on Safari 16. I can't access my account at all. This is urgent!!"},
  {"id": 5, "text": "It'd be nice to export data as CSV. Right now I have to copy-paste everything into a spreadsheet manually which is tedious for large datasets."}
]
```

Now do what the pipeline will eventually do — by hand:

+ Read each entry
+ Decide: is it a bug, a feature request, or praise?
+ Assign a priority: high, medium, or low
+ Go to GitHub, click "New Issue," type a title, write a description, pick labels
+ Repeat four more times
+ Write a summary of what you processed

Five entries. Maybe fifteen minutes of work. Not terrible. Now imagine fifty entries. Or five hundred. Every week. _That_ is what pipelines are for.


== Building Block One: The Intake Agent

The first agent has one job: turn messy human text into clean, structured JSON. No opinions. No categorisation. Just parsing.

Create a file called `intake.sh`:

```bash
#!/bin/bash
# intake.sh — Parse unstructured feedback into structured JSON

cat "$1" | claude --print \
  "You are a data intake processor. Read the following JSON array of
   feedback entries. For each entry, extract:
   - id: the original ID
   - raw_text: the original text
   - summary: a one-sentence summary (max 15 words)
   - mentioned_platforms: any platforms or browsers mentioned
   - sentiment: positive, negative, or neutral

   Return ONLY a valid JSON array. No explanation. No markdown fences."
```

Make it executable and run it:

```bash
chmod +x intake.sh
./intake.sh feedback.json
```

Watch what comes back. The messy, conversational text — "My eyes are burning at night lol" — becomes structured data with a clean summary, detected platforms, and sentiment analysis. The agent didn't guess. It read, understood, and extracted.

#quote(block: true)[
  *Why `--print`?* The `--print` flag tells the `claude` CLI to output the response directly to stdout with no interactive conversation. This is what makes agents composable — when the output goes to stdout, it can be piped into the next command. Interactive mode is for humans. Print mode is for pipelines.
]

Save the output to a file so the next agent can pick it up:

```bash
./intake.sh feedback.json > intake_output.json
```

Open `intake_output.json`. You should see a clean JSON array — every entry parsed, summarised, and annotated. This is the handoff point between the first agent and the second.


== Building Block Two: The Triage Agent

The intake agent parsed the data. Now the triage agent makes decisions about it. This is the agent with _judgment_ — it reads each item and decides what kind of work it represents and how urgent it is.

Create `triage.sh`:

```bash
#!/bin/bash
# triage.sh — Categorise and prioritise parsed feedback

cat "$1" | claude --print \
  "You are a product triage specialist. Read the following JSON array
   of parsed feedback items. For each item, add these fields:
   - category: exactly one of 'bug', 'feature', or 'praise'
   - priority: exactly one of 'high', 'medium', or 'low'
   - labels: an array of GitHub labels (e.g., ['bug', 'ios', 'android', 'upload'])
   - issue_title: a concise GitHub issue title (if category is bug or feature)
   - issue_body: a 2-3 sentence GitHub issue description (if category is bug or feature)

   Priority rules:
   - high: user cannot complete a core task (login, upload, access account)
   - medium: user experience is degraded but workaround exists
   - low: nice-to-have improvement or positive feedback

   Items with category 'praise' do not need issue_title or issue_body.

   Return ONLY a valid JSON array. No explanation. No markdown fences."
```

Make it executable and run it:

```bash
chmod +x triage.sh
./triage.sh intake_output.json > triage_output.json
```

Open `triage_output.json`. The five-megabyte upload crash? Bug, high priority, labels `['bug', 'ios', 'android', 'upload']`. Dark mode request? Feature, low priority. The praise? Categorised as praise, no issue needed. Safari login failure? Bug, high priority — the user literally cannot access their account.

The agent applied the priority rules you gave it. It made judgment calls. And it did it in seconds, not minutes.

#quote(block: true)[
  *This is "multi-agent" orchestration.* Two agents, two system prompts, two jobs. The intake agent doesn't know about priorities. The triage agent doesn't do parsing. Each one is specialised, and the shell script connects them. You've just built what framework vendors charge you a monthly subscription for — with two bash scripts and a pipe.
]


== Wiring the Pipe

Now let's connect the blocks into a single pipeline. Create `pipeline.sh`:

```bash
#!/bin/bash
# pipeline.sh — Full feedback processing pipeline
# Usage: ./pipeline.sh feedback.json

set -euo pipefail

INPUT_FILE="${1:?Usage: ./pipeline.sh <feedback.json>}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="runs/${TIMESTAMP}"

mkdir -p "$OUTPUT_DIR"

echo "=== Agentic Pipeline ==="
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_DIR"
echo ""

# Step 1: Intake
echo "[1/4] Running intake agent..."
./intake.sh "$INPUT_FILE" > "$OUTPUT_DIR/intake.json"
echo "      Parsed $(jq length "$OUTPUT_DIR/intake.json") items"

# Step 2: Triage
echo "[2/4] Running triage agent..."
./triage.sh "$OUTPUT_DIR/intake.json" > "$OUTPUT_DIR/triage.json"
BUGS=$(jq '[.[] | select(.category == "bug")] | length' "$OUTPUT_DIR/triage.json")
FEATURES=$(jq '[.[] | select(.category == "feature")] | length' "$OUTPUT_DIR/triage.json")
PRAISE=$(jq '[.[] | select(.category == "praise")] | length' "$OUTPUT_DIR/triage.json")
echo "      Bugs: $BUGS | Features: $FEATURES | Praise: $PRAISE"

# Step 3: Create GitHub issues (dry run by default)
echo "[3/4] Creating GitHub issues..."
if [ "${DRY_RUN:-true}" = "true" ]; then
  echo "      DRY RUN — set DRY_RUN=false to create real issues"
  jq -r '.[] | select(.category != "praise") | "      [\(.priority)] \(.issue_title)"' \
    "$OUTPUT_DIR/triage.json"
else
  ./create-issues.sh "$OUTPUT_DIR/triage.json" | tee "$OUTPUT_DIR/issues.log"
fi

# Step 4: Generate summary report
echo "[4/4] Generating summary report..."
./summary.sh "$OUTPUT_DIR/triage.json" > "$OUTPUT_DIR/summary.md"
echo "      Report saved to $OUTPUT_DIR/summary.md"

echo ""
echo "=== Pipeline complete ==="
echo "Results in: $OUTPUT_DIR"
```

Make it executable:

```bash
chmod +x pipeline.sh
```

Notice the structure. Each step reads from the previous step's output file. Each step writes to the run's output directory with a timestamp. Every run is preserved — you can diff Tuesday's results against Wednesday's.

The `set -euo pipefail` at the top is critical. It means: stop immediately if any command fails (`-e`), treat unset variables as errors (`-u`), and catch failures in piped commands (`-o pipefail`). Without this, a broken agent response could silently corrupt the rest of the pipeline.

And notice `DRY_RUN=true` as the default. Never auto-fire without a safety switch.


== Connecting to GitHub

Time to make the pipeline actually _do_ something. Create `create-issues.sh`:

```bash
#!/bin/bash
# create-issues.sh — Create GitHub issues from triaged feedback
# Requires: gh CLI authenticated, jq

REPO="${GITHUB_REPO:?Set GITHUB_REPO=owner/repo}"
INPUT_FILE="$1"

# Only process bugs and features (not praise)
jq -c '.[] | select(.category != "praise")' "$INPUT_FILE" | while read -r item; do
  TITLE=$(echo "$item" | jq -r '.issue_title')
  BODY=$(echo "$item" | jq -r '.issue_body')
  LABELS=$(echo "$item" | jq -r '.labels | join(",")')
  PRIORITY=$(echo "$item" | jq -r '.priority')

  # Add priority label
  LABELS="${LABELS},priority:${PRIORITY}"

  echo "Creating issue: $TITLE"
  gh issue create \
    --repo "$REPO" \
    --title "$TITLE" \
    --body "$BODY" \
    --label "$LABELS" 2>&1

  # Rate limiting — be kind to the GitHub API
  sleep 1
done
```

Make it executable:

```bash
chmod +x create-issues.sh
```

Before going live, do a dry run — which is the pipeline's default behaviour:

```bash
./pipeline.sh feedback.json
```

You'll see the pipeline print each step, show the categorisation counts, and list the issues it _would_ create. Check that the titles make sense. Check that priorities look right. Only when you're satisfied, run it for real:

```bash
DRY_RUN=false GITHUB_REPO=your-username/your-repo ./pipeline.sh feedback.json
```

Open your GitHub repository. You should see new issues with labels, priorities, and descriptions — all created automatically from the raw feedback file. No browser. No manual data entry. No copy-paste.

#quote(block: true)[
  *Create the labels first.* GitHub won't auto-create labels that don't exist. Before your first live run, create the labels your pipeline uses: `bug`, `feature`, `priority:high`, `priority:medium`, `priority:low`, and any platform labels like `ios`, `android`, `safari`. You can do this with `gh label create "priority:high" --color "B60205"` or just ask your agent to set them up.
]


== The Summary Report

The final agent in the pipeline takes everything that was processed and writes a human-readable summary. Create `summary.sh`:

```bash
#!/bin/bash
# summary.sh — Generate a Markdown summary report from triaged feedback

cat "$1" | claude --print \
  "You are a technical writer generating a weekly feedback summary.
   Read the following JSON array of triaged feedback items and produce
   a Markdown report with these sections:

   ## Feedback Summary — [today's date]

   ### Overview
   Total items processed, breakdown by category (bug/feature/praise),
   breakdown by priority.

   ### Critical Items
   List any high-priority bugs with a one-line description.

   ### Feature Requests
   Bullet list of requested features, ordered by priority.

   ### Positive Feedback
   Brief summary of praise items — what's working well.

   ### Trends
   Any patterns you notice (e.g., multiple platform-specific bugs,
   recurring feature themes).

   Keep it concise. This report will be read by a team lead in
   under two minutes."
```

Make it executable and test it:

```bash
chmod +x summary.sh
./summary.sh triage_output.json
```

The output is a clean Markdown report. Two high-priority bugs. One feature request at medium priority, one at low. One piece of praise. A trends section that might note "two of three bugs are platform-specific rendering issues."

To automatically commit the summary to your repository, add this to `pipeline.sh` — or keep it separate. The point is that it _can_ be automated. Whether it _should_ be is your call.

```bash
# Optional: commit the summary to the repo
cp "$OUTPUT_DIR/summary.md" reports/summary-${TIMESTAMP}.md
git add "reports/summary-${TIMESTAMP}.md"
git commit -m "Add feedback summary for ${TIMESTAMP}"
```


== Set It and Forget It

A pipeline you run manually is a tool. A pipeline that runs on a schedule is a system. Let's make it a system.

=== Option A: cron

The simplest scheduler on Unix. Open your crontab:

```bash
crontab -e
```

Add a line that runs the pipeline every Monday at 8 a.m.:

```
0 8 * * 1 cd /path/to/agentic-pipeline && DRY_RUN=false GITHUB_REPO=owner/repo ./pipeline.sh feedback.json >> /tmp/pipeline.log 2>&1
```

The format is `minute hour day-of-month month day-of-week`. `0 8 * * 1` means minute 0, hour 8, any day of month, any month, Monday (1).

#quote(block: true)[
  *cron tip:* Always redirect output to a log file (`>> /tmp/pipeline.log 2>&1`) so you can debug failures. cron runs in a minimal environment — it won't have your shell aliases, PATH additions, or environment variables. Use absolute paths for everything, and consider adding `source ~/.bashrc` at the top of your pipeline script if you need your usual environment.
]

=== Option B: GitHub Actions

If your feedback file lives in a repository (maybe it's populated by a webhook or a form submission), GitHub Actions can trigger the pipeline:

```yaml
# .github/workflows/feedback-pipeline.yml
name: Feedback Pipeline

on:
  schedule:
    - cron: '0 8 * * 1'  # Every Monday at 8 AM UTC
  workflow_dispatch:        # Manual trigger button

jobs:
  process-feedback:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install tools
        run: |
          # Install claude CLI
          npm install -g @anthropic-ai/claude-code
          # jq is pre-installed on GitHub runners
          # gh is pre-installed on GitHub runners

      - name: Run pipeline
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPO: ${{ github.repository }}
          DRY_RUN: 'false'
        run: |
          chmod +x *.sh
          ./pipeline.sh feedback.json

      - name: Commit summary report
        run: |
          git config user.name "Feedback Pipeline Bot"
          git config user.email "bot@example.com"
          git add reports/
          git commit -m "Add weekly feedback summary" || echo "No changes to commit"
          git push
```

The `workflow_dispatch` trigger adds a "Run workflow" button in the GitHub Actions UI — useful for testing before you trust the schedule.

Either way, the result is the same: feedback goes in, issues and reports come out, and you're not involved. You check the summary on Monday morning, glance at the created issues, and get on with your actual work.


== What Just Happened

You built an automated pipeline from nothing but shell scripts and AI agents. Let's look at who did what:

#table(
  columns: (1fr, 1fr),
  [*You brought*], [*The agents brought*],
  [The decision about what feedback matters], [Parsing messy human text into structured data],
  [Priority rules and category definitions], [Consistent judgment applied to every single item],
  [The choice of where issues should go], [Formatted issue titles, descriptions, and labels],
  [Quality review of the first few runs], [A weekly summary report with trends and stats],
  [System design — which agents, in what order], [Execution at 8 a.m. Monday, whether you're awake or not],
)

The pattern that runs through this entire book crystallises here:

+ *You define the rules* — what counts as high priority, what categories exist, what format issues should take
+ *Agents execute the rules* — consistently, tirelessly, at scale
+ *You review the output* — especially early on, until you trust the system
+ *Then you step back* — and the pipeline runs itself

This is _leverage_. Not the buzzword kind. The real kind. You spent thirty minutes building a system that saves you hours every week. And the system doesn't get tired, doesn't forget the priority rules, and doesn't accidentally skip the fifth feedback item because it was lunchtime.

You're no longer doing the work. You're designing the system that does the work.


== Troubleshooting

*The agent returns invalid JSON:*
This is the most common failure. LLMs sometimes wrap JSON in markdown code fences or add explanatory text. Add explicit instructions to the system prompt: "Return ONLY valid JSON. No markdown fences. No explanation." If it still happens, pipe the output through `jq .` as a validation step — `jq` will exit with an error code if the JSON is malformed, and `set -e` will stop the pipeline.

*`jq` says "parse error":*
Usually means the agent's output wasn't pure JSON. Check the raw output file. If it starts with a markdown code fence or contains text before/after the JSON array, the system prompt needs tightening. You can also add a cleanup step: `sed -n '/^\[/,/^\]/p'` to extract just the JSON array.

*`gh issue create` fails with "label not found":*
GitHub requires labels to exist before you can apply them. Create them once: `gh label create "priority:high" --color "B60205" --repo owner/repo`. Or add a setup script that creates all required labels.

*cron job doesn't run:*
Check that the cron daemon is running (`crontab -l` to verify your entry exists). Use absolute paths — cron doesn't use your shell's PATH. Test by setting the schedule to a minute from now and watching the log file.

*Rate limiting from GitHub:*
The `sleep 1` in `create-issues.sh` helps, but if you're processing hundreds of items, you may hit GitHub's API rate limit (5,000 requests per hour for authenticated users). For large batches, increase the sleep interval or batch the work across multiple pipeline runs.

*The pipeline worked last week but fails this week:*
LLM outputs are non-deterministic. The same prompt can produce slightly different JSON structures between runs. Add validation after each agent step: check that required fields exist, check that category values are from the allowed set, check that the JSON array length matches the input. Defensive scripting makes pipelines robust.

*Environment variables missing in cron:*
cron runs with a minimal environment. Your `ANTHROPIC_API_KEY` and `GITHUB_REPO` variables won't be available unless you set them explicitly in the crontab or source a config file at the top of your pipeline script.


== Quick Reference

#table(
  columns: (1fr, 2fr),
  [*Task*], [*Command*],
  [Run intake agent], [`./intake.sh feedback.json > intake_output.json`],
  [Run triage agent], [`./triage.sh intake_output.json > triage_output.json`],
  [Run full pipeline (dry run)], [`./pipeline.sh feedback.json`],
  [Run full pipeline (live)], [`DRY_RUN=false GITHUB_REPO=owner/repo ./pipeline.sh feedback.json`],
  [Create a GitHub label], [`gh label create "priority:high" --color "B60205" --repo owner/repo`],
  [Generate summary only], [`./summary.sh triage_output.json`],
  [Validate JSON output], [`jq . output.json > /dev/null && echo "Valid" \|\| echo "Invalid"`],
  [Edit crontab], [`crontab -e`],
  [View cron logs], [`tail -f /tmp/pipeline.log`],
  [Trigger GitHub Action manually], [Go to Actions tab → "Feedback Pipeline" → "Run workflow"],
  [Check `gh` auth status], [`gh auth status`],
  [Check `jq` is installed], [`jq --version`],
)


== Cleaning Up

If you want to remove the practice pipeline:

```
rm -rf agentic-pipeline
```

If you created test issues in a GitHub repository, you can close them in bulk:

```bash
gh issue list --repo owner/repo --label "priority:low" --json number \
  | jq -r '.[].number' \
  | xargs -I {} gh issue close {} --repo owner/repo
```

Or keep them. They're good evidence of what your pipeline can do.

#quote(block: true)[
  *What comes next?* You've built a pipeline that handles one workflow — feedback processing. But the pattern is universal. Swap out the system prompts and you have a pipeline that triages security alerts, processes support tickets, categorises pull requests, or generates changelog entries. The architecture is the same: intake, triage, action, report. Once you see it, you see it everywhere. The next time you catch yourself doing the same task for the third time, stop. Write the pipeline instead. Let the agents do the work. You've got better things to think about.
]
