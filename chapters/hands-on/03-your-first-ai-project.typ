#import "_os-helpers.typ": *
= Your First AI-Generated Project

So far you've set up your tools and submitted your first pull request. Now you're going to do something genuinely impressive: take a real open-source project, describe what you want in plain English, and let an AI agent transform it — generating custom illustrations, narration audio, and animated backgrounds using AI models from Hugging Face.

No prior coding experience required. The agent writes the code. You describe the vision.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-ai-studio.typ"]

== What You'll Build

*Web Presenter* is an open-source presentation framework: pure HTML, CSS, and JavaScript, no build step required. It supports slide-by-slide narration (MP3 files), animated Three.js backgrounds, and smooth CSS transitions. You can run it in any browser with a single command.

By the end of this chapter, you'll have:

+ Forked and cloned the project
+ Chosen a topic for your own presentation
+ Had an AI agent generate custom illustrations for each slide
+ Had an AI agent generate spoken narration for each slide
+ Customised the animated background to match your theme
+ Previewed the finished result in your browser

Every piece of AI-generated content — the images, the audio, the animation colours — will come from Hugging Face's free inference API. Hugging Face hosts hundreds of open AI models that anyone can call without a credit card. You'll talk to it through your AI coding agent.

== What You'll Need

From the previous chapters:
- Git installed and configured
- GitHub CLI authenticated
- Claude Code or Gemini CLI ready in your terminal

New for this chapter:
- A Hugging Face account (free)
- A Hugging Face API token
- Python 3 (to run a local server and call the Hugging Face API)
- The `huggingface_hub` Python library (one `pip install` command — covered below)

=== Get a Hugging Face Account and Token

If you don't have one, sign up at #link("https://huggingface.co/join")[huggingface.co/join]. It's free — no credit card required.

Once you're logged in:

+ Click your profile picture (top right) → *Settings*
+ Click *Access Tokens* in the left sidebar
+ Click *New token*
+ Give it a name like `agentic-crew` and select *Read* access
+ Click *Generate a token* and copy it

Keep this token handy — you'll paste it into your terminal in the next step.

=== Check Python

Run:

```
python3 --version
```

#if is-windows [
You should see Python 3.8 or higher. Try `python --version` if `python3` doesn't work. If Python isn't installed:

```
winget install Python.Python.3
```
]

#if is-mac [
You should see Python 3.8 or higher. If Python isn't installed:

```
brew install python
```
]

#if is-linux [
You should see Python 3.8 or higher. If Python isn't installed:

```
sudo apt install python3 python3-pip
```
]

Close and reopen your terminal after installing, then run `python3 --version` again to confirm.

=== Install the Hugging Face Library

The scripts the agent writes will use Hugging Face's official Python library. Install it now:

```
pip install huggingface_hub
```

On some systems you may need `pip3` instead of `pip`. You only need to do this once.

== Set Your Hugging Face Token

Your AI agent will use this token to call Hugging Face's API. Set it as an environment variable so the agent can access it without hard-coding it into any file.

#if is-mac or is-linux [
```
export HF_TOKEN="your-token-here"
```
]

#if is-windows [
```
$env:HF_TOKEN = "your-token-here"
```
]

Replace `your-token-here` with the token you copied. Now verify it was set:

#if is-mac or is-linux [
```
echo $HF_TOKEN
```
]

#if is-windows [
```
echo $env:HF_TOKEN
```
]

#if is-mac or is-linux [
You should see your token printed back. If nothing appears, run the `export` command again — the variable didn't stick.
]

#if is-windows [
You should see your token printed back. If nothing appears, run the `$env:` command again — the variable didn't stick.
]

#quote(block: true)[
  *Keep tokens out of files.* Never paste your API token directly into code or commit it to Git. Environment variables keep it in memory only — no risk of accidentally pushing it to a public repository.
]

#if is-mac [
This setting lasts for your current terminal session. To make it permanent, add the `export` line to your shell config file (`~/.zshrc`).
]

#if is-linux [
This setting lasts for your current terminal session. To make it permanent, add the `export` line to your shell config file (`~/.bashrc`).
]

#if is-windows [
This setting lasts for your current terminal session. To make it permanent, add it via System Properties → Environment Variables.
]

== Fork and Clone the Project

This single command creates your own copy of the project on GitHub and downloads it to your machine:

```
gh repo fork schlunsen/web-presenter --clone --remote
```

Step into the project directory:

```
cd web-presenter
```

Verify your connections to GitHub:

```
git remote -v
```

You should see two entries:
- `origin` — your fork (where you push your changes)
- `upstream` — the original project (where you can pull updates)

Each remote is listed twice — once for fetching, once for pushing. Four lines total is correct. If you only see `origin`, something went wrong — open your AI assistant and describe what you see; it will help.

== Explore the Project

Have the agent explain what you're working with. Open your AI assistant from inside the project directory.

If you installed Claude Code, run:
```
claude
```

If you installed Gemini CLI, run:
```
gemini
```

Either works for everything in this chapter. Once it's open, ask:

- _"Read index.html, presentation-script.js, and presentation-styles.css. Explain how this presentation framework works — how slides are structured, how audio narration is loaded, and how the animated background works."_

The agent will read the files and give you a plain-language summary. You'll understand the project in two minutes rather than thirty. It's only reading at this point — nothing is being changed yet.

Once you have a feel for it, ask about the existing assets:

- _"List all the files in presentation-audio/ and presentation-images/. What's already there?"_

You'll see the existing narration clips and images — placeholders you're about to replace with your own.

== Choose Your Topic

Pick something you know or care about. The presentation has ten slides, so you want a topic with enough substance for ten short points. Some ideas:

- A technology you use at work
- A hobby or skill you want to explain to a friend
- A project you're building
- An argument you want to make about something

For the rest of this chapter, we'll use the placeholder *[YOUR TOPIC]* — replace it with whatever you choose.

Write down ten short bullet points — your slide topics. One sentence each. You'll paste these into the agent prompts that follow.

#quote(block: true)[
  *Make your bullet points visual.* Each one will become an AI-generated image, so specific and concrete works better than abstract. "A warehouse filled with rows of server racks" will generate a better illustration than "technology infrastructure." "A child reading under a tree at sunset" is better than "education."
]

== Generate the Illustrations

In this step you'll ask the agent to write a Python script. You won't write it yourself — the agent will. Your job is to provide your ten bullet points and then ask the agent to run the script. Everything else is automatic.

Open your AI assistant (if it's not already open) and give it this prompt. *Do not copy it word-for-word* — replace `[YOUR TOPIC]` with your actual topic and `[paste your bullet points]` with your ten sentences:

- _"Write a Python script using the huggingface_hub library. Use InferenceClient with the token from the HF_TOKEN environment variable. Call client.text_to_image() with the model black-forest-labs/FLUX.1-schnell to generate one image per slide, and save each result to presentation-images/ as slide-01.jpg, slide-02.jpg, and so on. Here are the ten slide topics: [paste your bullet points]. Make the prompts vivid and consistent in style."_

The agent will write the script. Review it — you don't need to understand every line, but check that it reads the token from the environment (`os.environ` or similar) rather than having a value hard-coded in the code.

When you're happy with it, ask the agent to run it:

- _"Run the script."_

Generation takes roughly 10–20 seconds per image. The agent will report progress as each one completes. When it's done, the `presentation-images/` folder will contain ten new files.

#quote(block: true)[
  *What if an image looks wrong?* Ask the agent to regenerate just that one: _"The illustration for slide 3 doesn't look right — it should show [description]. Regenerate just that one with a better prompt."_ Image generation is iterative. A second or third attempt usually lands closer to what you had in mind.
]

== Generate the Narration

Next: spoken audio for each slide. Hugging Face hosts text-to-speech models that convert text into an audio file. The audio will sound clear and intelligible — not quite human, but natural enough for a presentation.

Give the agent this prompt, replacing the placeholders with your actual narration text:

- _"Write a Python script using the huggingface_hub library. Use InferenceClient with the token from the HF_TOKEN environment variable. Call client.text_to_speech() with the model facebook/mms-tts-eng to generate narration for each slide. Save each result to presentation-audio/ as slide-01.wav through slide-10.wav. Here are the narration texts for each slide: [paste your one-sentence descriptions]."_

The agent will write the script. Run it the same way:

- _"Run the narration script."_

Audio generation is faster than image generation — expect a few seconds per clip. When it finishes, `presentation-audio/` will have ten `.wav` files ready to play.

#quote(block: true)[
  *Want a more natural voice?* Ask the agent to try `suno/bark-small` instead — same library, different model, slower but more expressive. Just ask: _"Rewrite the narration script to use the model suno/bark-small and run it again."_
]

== Update the Presentation

`index.html` is the main file your presentation reads from — it contains all the slide content, image paths, and audio file names. Now the agent will update it with your new content.

- _"Update index.html to replace the existing slides with my ten slides about [YOUR TOPIC]. Each slide should use the matching .jpg illustration from presentation-images/ and the matching .wav narration from presentation-audio/. Use the existing slide layouts — title layout for slide 1, two-column or centered for the rest. Keep the HTML structure exactly as it is; just update the content and asset references."_

The agent will make the edits. When it's done, ask it to check its own work:

- _"Read index.html back and confirm all ten slides are present, each with the correct image and audio file."_

This self-check catches missed references before you open the browser.

== Customise the Animated Background

The Three.js background draws a network of nodes and connecting lines. By default it uses cool blues and greys. Ask the agent to match it to your topic's mood:

- _"Update presentation-bg.js to change the network animation colours to [describe your palette — e.g. 'warm amber and dark brown' or 'deep green and soft white' or 'electric blue on black']. Also update the CSS colour variables in presentation-styles.css to match."_

The agent will edit both files. If the result doesn't feel right, describe what you want more precisely:

- _"The background is too bright. Make the nodes smaller and reduce the line opacity to 30%."_

Iterate as many times as you need. Each change takes a few seconds.

== Preview in Your Browser

Before opening your browser, confirm three things:

+ The `presentation-images/` folder contains 10 `.jpg` files (slide-01.jpg through slide-10.jpg)
+ The `presentation-audio/` folder contains 10 `.wav` files (slide-01.wav through slide-10.wav)
+ The terminal you used to run the generation scripts is still active in the `web-presenter` directory

If any files are missing, ask the agent: _"Check the presentation-images/ and presentation-audio/ folders. What files are there, and are any missing?"_

Web Presenter needs a local HTTP server — it uses `fetch()` to load audio files, which browsers block for plain `file://` paths. Ask the agent to start one:

- _"Start a local HTTP server in this directory on port 8000."_

It will run:

```
python3 -m http.server 8000
```

You should see output like:

```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

That means the server is ready. *Leave this terminal window open* — closing it stops the server. Now open your browser and go to:

```
http://localhost:8000
```

You should see your presentation. Press the spacebar or right arrow key to advance to the next slide. Each slide will show its illustration, play the narration, and advance automatically when the audio finishes. You can also press right arrow to skip ahead manually.

Press `M` to toggle background music, `A` to toggle narration, and `Esc` to stop playback.

When you're done, go back to the terminal and press *Ctrl+C* to stop the server.

== Commit and Push

Once you're happy with your presentation, save your work to GitHub:

- _"Create a branch called presentation/[YOUR TOPIC], add all the changed files, commit with a message describing what I built, and push to my fork."_

The agent will handle every Git step. When it's done, verify on GitHub:

+ Go to `https://github.com/YOUR_USERNAME/web-presenter`
+ Open the branch dropdown and look for your branch (`presentation/[YOUR TOPIC]`)
+ Click it — you should see your new images, audio files, and updated `index.html`

Your presentation is now saved on GitHub and shareable with anyone via that URL.

== What Just Happened

You generated ten AI illustrations, narrated them, customised animated 3D graphics, and updated a web project — all by describing what you wanted in plain English. The agent handled the mechanics. This is what agentic programming looks like.

#table(
  columns: (1fr, 1fr),
  [*You brought*], [*The agent brought*],
  [A topic you care about], [API calls to Hugging Face],
  [Ten sentences of content], [A working Python script],
  [A colour palette description], [Updated JavaScript and CSS],
  [Judgment on what looks right], [The mechanics of making it so],
)

The skill isn't coding. It's knowing what to ask for, how to check the result, and how to iterate when it's not quite right. That's what the next chapters will build on.

== Troubleshooting

*Image generation returns an error about the model being too busy:*
The free inference API has rate limits. Wait 30 seconds and try again, or ask the agent to add a delay: _"Add a 10-second sleep between each image generation call."_

*Audio files are silent or not playing:*
The TTS model returns WAV files, not MP3s. If index.html references `.mp3` extensions, ask the agent: _"Check whether the audio src attributes in index.html use .wav extensions. Update any that don't match the files in presentation-audio/."_ Also confirm file sizes — any `.wav` file under 5KB is probably an error response that needs regenerating.

*Slides show broken image icons:*
The image path in the HTML doesn't match the actual filename. Ask: _"Check all image src attributes in index.html against the actual files in presentation-images/. Fix any mismatches."_

#if is-windows [
*The server command fails:*
Try `python -m http.server 8000` instead of `python3`. Or ask the agent: _"Start a local server using npx serve instead."_
]

*My HF_TOKEN isn't found by the script:*
#if is-mac or is-linux [
The variable was set in a different terminal session. Set it again in the current session (`export HF_TOKEN="..."`), then run the script again.
]
#if is-windows [
The variable was set in a different terminal session. Set it again in the current session (`$env:HF_TOKEN = "..."`), then run the script again.
]

*Nothing loads or the page is blank:*
Make sure the server is running in the `web-presenter` directory, not a parent folder. Open your browser's developer tools (F12) and check the Console tab — missing files are listed there. Tell the agent what you see and it will fix them.

*The Three.js animation has stopped working after editing:*
Ask the agent: _"The background animation has stopped working. Read presentation-bg.js and check for any syntax errors or missing function calls."_

*The wrong branch shows on GitHub after pushing:*
Make sure the branch name has no spaces — use hyphens instead. Ask the agent: _"What branch did we push? Show me the output of git branch -a."_

If you hit an error not listed here, describe it to your AI agent — it's seen most errors before and will usually know what to do.

== Quick Reference

#table(
  columns: (1fr, 2fr),
  [*Task*], [*Prompt or command*],
  [Verify HF token is set], [#if is-mac or is-linux [`echo $HF_TOKEN`] #if is-windows [`echo $env:HF_TOKEN`]],
  [Explore the project], [_"Read index.html and explain how slides work"_],
  [Install HF library], [`pip install huggingface_hub`],
  [Generate images], [_"Use InferenceClient.text_to_image() with FLUX.1-schnell..."_],
  [Generate narration], [_"Use InferenceClient.text_to_speech() with facebook/mms-tts-eng..."_],
  [Update slide content], [_"Update index.html with my ten slides..."_],
  [Change background], [_"Update the animation colours to..."_],
  [Check generated files], [_"List the files in presentation-images/ and presentation-audio/"_],
  [Start local server], [`python3 -m http.server 8000`],
  [View presentation], [`http://localhost:8000`],
  [Stop the server], [`Ctrl+C` in the server terminal],
)
