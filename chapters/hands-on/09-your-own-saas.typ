#import "_os-helpers.typ": *
= Your Own SaaS — From Idea to Launch in a Day

Every chapter so far has been an exercise. You set up your workstation. You submitted a pull request. You generated AI content. You pair-programmed a web application. You deployed it to a live server. You pentested it. You wrote tests. You built CI/CD pipelines.

This one is different.

This is the real thing. You are going to build a product — a complete, publicly accessible micro-SaaS application — from scratch, in one chapter. Not a tutorial project. Not a toy. Something with a URL you can text to a friend. Something that solves a real problem, accepts real users, and processes real payments. Something you can put on your portfolio, show in a job interview, or grow into an actual business.

The AI agent is your co-founder for the day.

Every skill from every chapter converges here. You will scaffold a full-stack application (Chapter 4). You will deploy it to production (Chapter 5). You will think about security (Chapter 6). You will write tests (Chapter 7). You will set up a CI/CD pipeline (Chapter 7). You will integrate AI capabilities that make your product intelligent. And you will do all of it by describing what you want and reviewing what the agent builds.

If you have followed this book from the beginning, you are ready. Let's ship something.


== What You'll Build

By the end of this chapter, you'll have:

+ A complete micro-SaaS application with a frontend, backend API, and database
+ User authentication — sign up, log in, manage accounts
+ Payment integration with Stripe — a free tier and a paid tier
+ An AI-powered core feature that uses an LLM API
+ A CI/CD pipeline that tests and deploys on every push
+ A landing page with copy, basic SEO, and social sharing metadata
+ A live URL that anyone on the internet can visit

This is the capstone. Everything before was training. This is the launch.


== What You'll Need

From the previous chapters:
- A terminal with your AI coding agent ready (Claude Code or Gemini CLI)
- Git installed and configured
- A GitHub account
- Node.js installed (v18 or later)
- A server or platform account for deployment (Vercel, Railway, or a VPS from Chapter 5)

New for this chapter:
- A Stripe account in test mode (#link("https://dashboard.stripe.com/register")[sign up here] — no credit card required for test mode)
- An LLM API key (Anthropic, OpenAI, or another provider — you likely have this from Chapter 3)
- A domain name (optional but recommended — you can use the platform's default URL)
- About 4–8 hours of focused time

#quote(block: true)[
  *On time estimates.* "A day" is aspirational, not literal. Your first time through this will take longer than it would the second time. Some readers will finish in an afternoon. Others will spread it over a weekend. The point is not speed — it is that everything you need to ship a SaaS product fits in a single chapter. A year ago, this would have taken a team of three engineers several weeks.
]


== Pick Your Idea

Before you write a line of code, you need to know what you are building. This is where the agent earns its keep as a product partner, not just a code generator.

Open your agent and start a conversation:

- _"I want to build a micro-SaaS product. Something small enough to build in a day, useful enough that real people would pay for it, and AI-powered so it has a genuine advantage over a spreadsheet. Help me brainstorm."_

The agent will generate ideas. Some will be good. Some will be terrible. That is the point — you are the filter. Here are four concrete ideas that work well for this chapter:

=== Idea 1: AI Resume Reviewer

Users paste their resume text. The AI analyses it for clarity, impact, buzzword overuse, and alignment with a target job description. Free tier: one review per day. Paid tier: unlimited reviews with detailed scoring and rewrite suggestions.

=== Idea 2: Meal Plan Generator

Users enter dietary preferences, allergies, and a weekly budget. The AI generates a seven-day meal plan with recipes and a shopping list. Free tier: one plan per week. Paid tier: unlimited plans with nutritional breakdown and grocery store price estimates.

=== Idea 3: Domain Name Generator

Users describe their business or project in a sentence. The AI generates available domain name suggestions, checks availability via a WHOIS API, and ranks them by memorability and brandability. Free tier: five suggestions per query. Paid tier: unlimited suggestions with logo mockups.

=== Idea 4: Email Subject Line Tester

Users paste a draft email subject line. The AI predicts open rates, suggests alternatives, and A/B tests variations against best practices from email marketing data. Free tier: three tests per day. Paid tier: unlimited tests with audience segmentation insights.

Pick one. Or invent your own — the agent will help you scope it. The key constraint is that the core feature must involve an LLM API call. That is what makes it "AI-powered" rather than just another CRUD app.

=== Write the Spec

Once you have picked an idea, ask the agent to help you write a one-page specification:

- _"Let's go with the resume reviewer. Write me a one-page product spec: what it does, who it's for, what the free tier includes, what the paid tier includes, and what the tech stack should be."_

Review the spec carefully. This is your last chance to change direction cheaply. Once scaffolding starts, pivoting costs time. The spec should include:

- *Product name* — something short and memorable
- *One-sentence description* — what it does, for whom
- *Core feature* — the single AI-powered action that delivers value
- *Free tier limits* — what users get without paying
- *Paid tier price and features* — what unlocks with a subscription
- *Tech stack* — frontend framework, backend, database, hosting

#quote(block: true)[
  *Why a spec?* You are about to ask the agent to generate thousands of lines of code. Without a spec, it will make assumptions — and those assumptions will conflict with each other. A spec is not bureaucracy. It is the single source of truth that keeps you and the agent aligned across dozens of prompts. Think of it as the product brief you hand to your co-founder before they start building.
]


== Scaffold the Full Stack

This is where the agent does what agents do best: generate a massive amount of boilerplate in minutes.

Ask your agent:

- _"Based on the spec we just wrote, scaffold the complete project. I want a Next.js app with TypeScript, an API layer using Next.js API routes, a SQLite database using Prisma as the ORM, and a clean folder structure. Set up the project with all necessary dependencies."_

The agent will generate a project structure that looks something like this:

```
my-saas/
├── prisma/
│   └── schema.prisma          # Database schema
├── src/
│   ├── app/
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Landing page
│   │   ├── dashboard/
│   │   │   └── page.tsx        # Authenticated user dashboard
│   │   └── api/
│   │       ├── auth/           # Authentication endpoints
│   │       ├── stripe/         # Payment webhooks
│   │       └── analyze/        # Core AI feature endpoint
│   ├── components/             # Reusable UI components
│   ├── lib/
│   │   ├── db.ts               # Database client
│   │   ├── auth.ts             # Auth utilities
│   │   ├── stripe.ts           # Stripe client
│   │   └── ai.ts               # LLM integration
│   └── types/                  # TypeScript type definitions
├── .env.example                # Environment variable template
├── package.json
└── tsconfig.json
```

#quote(block: true)[
  *Why these choices?* Next.js gives you frontend and backend in one framework — fewer moving parts. SQLite with Prisma means no external database server to manage — the database is a single file. TypeScript catches errors before they reach production. These are pragmatic choices for a solo builder shipping fast. If you prefer a different stack, tell the agent — it will adapt.
]

Review the generated code. You do not need to understand every line, but you should understand the architecture: where the frontend lives, where the API routes are, how the database is structured, and where environment variables are configured.

Ask questions:

- _"Explain the folder structure. Why did you put the API routes here?"_
- _"Walk me through the database schema. What tables did you create and why?"_
- _"What happens when a user hits the /api/analyze endpoint?"_

This is pair programming at the architectural level. The agent made decisions. Your job is to understand them well enough to approve, reject, or redirect.

Run the development server to make sure the scaffold works:

- _"Install dependencies and start the dev server. I want to see it running on localhost."_

You should see a basic page at `http://localhost:3000`. It will not do much yet — but it runs. That is the foundation.


== Add the AI Brain

Now you add the feature that makes your product worth paying for: the AI-powered core action.

Ask your agent:

- _"Implement the core AI feature. When a user submits their resume text to the /api/analyze endpoint, it should send the text to the Anthropic API with a system prompt that instructs the model to review the resume for clarity, impact, and common mistakes. Return a structured JSON response with scores and suggestions."_

The agent will create something like this in your `src/lib/ai.ts`:

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

export async function analyzeResume(resumeText: string) {
  const response = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 2048,
    system: `You are an expert resume reviewer. Analyze the
      resume and return a JSON object with: overall_score (1-10),
      clarity_score (1-10), impact_score (1-10), suggestions
      (array of specific improvements), and summary (2-3
      sentences of overall feedback).`,
    messages: [
      { role: "user", content: resumeText },
    ],
  });
  return JSON.parse(response.content[0].text);
}
```

Three things matter here:

=== Environment Variables

Your API key must never appear in your code. It goes in `.env`:

```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

Add `.env` to `.gitignore` immediately if the agent has not already done so. This is not optional. A leaked API key costs real money — and it happens more often than you think.

- _"Make sure .env is in .gitignore and create a .env.example file with placeholder values."_

=== Error Handling

LLM APIs fail. They time out. They return malformed responses. They hit rate limits. Your product must handle all of these gracefully.

- _"Add error handling to the AI integration. Catch API errors, timeouts, and malformed responses. Return user-friendly error messages instead of crashing."_

The agent should wrap the API call in try/catch, add a timeout, validate the response shape before parsing it, and return appropriate HTTP status codes.

=== Rate Limiting

Your free tier needs limits. Without them, a single user can burn through your entire API budget in an afternoon.

- _"Add rate limiting to the analyze endpoint. Free users get 3 requests per day. Track usage in the database by user ID and reset the count daily."_

This ties usage tracking to user accounts — which means you need authentication next.


== Users, Auth, and Payments

A SaaS product needs users. Users need accounts. Accounts need authentication. And if you want revenue, you need payments.

This is the most complex section of the chapter. The agent will handle the heavy lifting, but you need to understand the moving parts.

=== Authentication

Ask your agent:

- _"Add authentication using NextAuth.js with email/password credentials. Users should be able to sign up, log in, and log out. Store user records in the SQLite database via Prisma."_

The agent will set up:
- A sign-up page with email and password fields
- A login page
- Session management using secure HTTP-only cookies
- A user table in the database with hashed passwords
- Protected routes that redirect unauthenticated users to the login page

#quote(block: true)[
  *On password hashing.* The agent should use bcrypt or argon2 to hash passwords before storing them. If you see passwords stored in plain text anywhere in the generated code, stop immediately and ask the agent to fix it. This is non-negotiable. Remember what you learned in Chapter 6 — a leaked database with plain-text passwords is a catastrophe. With hashed passwords, it is an inconvenience.
]

Test the authentication flow:

+ Visit the sign-up page and create an account
+ Log in with the credentials you just created
+ Verify you can access the dashboard
+ Log out and verify you are redirected to the login page
+ Try to access the dashboard without logging in — you should be blocked

=== Stripe Payments

Now add the ability to charge money. Stripe's test mode lets you process fake payments with fake credit cards — no real money changes hands until you switch to live mode.

- _"Integrate Stripe for subscription payments. Add a pricing page with a free tier and a \$9/month pro tier. When a user clicks 'Upgrade', redirect them to Stripe Checkout. Handle the webhook to update their subscription status in the database."_

The agent will need several pieces:

+ *Stripe products and prices* — created via the Stripe dashboard or API
+ *A checkout session endpoint* — creates a Stripe Checkout session and redirects the user
+ *A webhook endpoint* — receives events from Stripe when a payment succeeds, fails, or a subscription is cancelled
+ *Database fields* — `stripeCustomerId`, `subscriptionStatus`, and `subscriptionTier` on the user model

Set up your environment variables:

```
STRIPE_SECRET_KEY=sk_test_your-test-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-test-key
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret
```

#quote(block: true)[
  *Getting your Stripe keys.* Log in to #link("https://dashboard.stripe.com")[dashboard.stripe.com]. Make sure the "Test mode" toggle in the top right is enabled. Go to Developers > API keys. Copy the publishable key and secret key. For the webhook secret, you will set up the webhook endpoint in the Stripe dashboard later — or use the Stripe CLI for local testing.
]

Test the payment flow with Stripe's test card:

+ Log in as a free-tier user
+ Click "Upgrade to Pro"
+ On the Stripe Checkout page, use card number `4242 4242 4242 4242`, any future expiration date, and any CVC
+ Complete the checkout
+ Verify you are redirected back to your app with a pro subscription
+ Verify the rate limit has been lifted — you should now have unlimited access

For local webhook testing, use the Stripe CLI:

```
stripe listen --forward-to localhost:3000/api/stripe/webhook
```

This forwards Stripe's webhook events to your local development server so you can test the full flow without deploying.

=== Connect Auth to Usage

Now tie everything together:

- _"Update the rate limiting logic. Check the user's subscription tier before applying limits. Free users get 3 requests per day. Pro users get unlimited requests. Show the user their remaining usage on the dashboard."_

This is where the three systems — auth, payments, and the AI feature — connect into a cohesive product. The user signs up (auth), uses the free tier (rate limiting), hits the limit (usage tracking), upgrades (Stripe), and unlocks full access (tier check).


== Test It

You built something complex. Now make sure it works. This callbacks to the testing mindset from Chapter 7.

Ask your agent:

- _"Write a test suite for the core flows: user registration, login, the AI analysis endpoint, rate limiting for free users, and the Stripe webhook handler. Use Vitest as the test framework."_

The agent should create tests that cover:

+ *User registration* — can a new user sign up with valid credentials?
+ *Authentication* — does login return a valid session? Does an invalid password fail?
+ *AI endpoint* — does the analysis endpoint return a properly structured response? (Mock the LLM API for testing.)
+ *Rate limiting* — does the fourth request from a free user get blocked?
+ *Stripe webhook* — does a `checkout.session.completed` event update the user's subscription tier?

Run the tests:

```
npm test
```

Fix anything that fails. Ask the agent:

- _"Test X is failing with this error: [paste error]. Fix it."_

You do not need 100% coverage. You need confidence that the critical paths work: users can sign up, the AI feature returns results, free users hit limits, and payments upgrade accounts. If those four things work, you have a product.

#quote(block: true)[
  *On mocking the LLM API.* Your tests should not make real API calls — they would be slow, expensive, and flaky. The agent should mock the Anthropic SDK to return a fixed response. This tests your code's logic without depending on an external service. If the agent does not mock the API by default, ask explicitly: _"Mock the Anthropic API in the tests so we don't make real calls."_
]


== Ship It

Your application works locally. Time to put it on the internet.

=== Set Up the GitHub Repository

If you have not already, initialise a git repository and push to GitHub:

- _"Initialise a git repo, create a .gitignore that excludes node_modules, .env, and the SQLite database file, and push to a new GitHub repository."_

Review what gets committed. Make sure `.env` is not in the repository. Make sure the database file is not in the repository. Make sure `node_modules` is not in the repository. This is the security hygiene from Chapter 6 in action.

=== Create the CI/CD Pipeline

Ask your agent:

- _"Create a GitHub Actions workflow that runs on every push to main. It should install dependencies, run the test suite, and if tests pass, deploy to production."_

The agent will create `.github/workflows/deploy.yml`:

```yaml
name: Test and Deploy

on:
  push:
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
      - run: npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Add your deployment steps here"
```

This is the CI/CD pipeline from Chapter 7. Tests run automatically. If they pass, the code deploys. If they fail, the deploy is blocked. You do not ship broken code.

=== Deploy to Production

Choose your deployment platform. For a Next.js app, the simplest options are:

*Option A: Vercel* (easiest for Next.js)
- _"Deploy this Next.js app to Vercel. Walk me through connecting the GitHub repo and setting environment variables."_

*Option B: Railway* (good for full-stack with database)
- _"Deploy this app to Railway. Set up the environment variables and make sure the SQLite database persists."_

*Option C: VPS* (if you have one from Chapter 5)
- _"Deploy this app to my VPS at [your-ip]. Set up a reverse proxy with Nginx, configure SSL with Let's Encrypt, and create a systemd service."_

Whichever platform you choose, you need to configure environment variables in production:

```
ANTHROPIC_API_KEY=sk-ant-your-production-key
STRIPE_SECRET_KEY=sk_test_your-test-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-test-key
STRIPE_WEBHOOK_SECRET=whsec_your-production-webhook-secret
NEXTAUTH_SECRET=a-long-random-string
NEXTAUTH_URL=https://your-domain.com
```

#quote(block: true)[
  *Stay in Stripe test mode.* For this chapter, keep Stripe in test mode even in production. This means real users can "pay" with test cards but no real money moves. When you are ready to accept real payments, switching to live mode is a single toggle in the Stripe dashboard — plus replacing the test API keys with live ones. Do not rush this. Get the product right first.
]

Once deployed, visit your production URL. Test the full flow again — sign up, log in, use the AI feature, hit the rate limit, "upgrade" with the test card. Everything that worked locally should work in production.


== The Landing Page and Launch Checklist

Your product works. But nobody will use it if they cannot find it or understand what it does in five seconds.

=== The Landing Page

Ask your agent:

- _"Create a landing page for the root URL. It should have a hero section with a clear headline and subheadline, a brief explanation of what the product does, a demo or screenshot section, pricing cards for the free and pro tiers, and a call-to-action button that links to the sign-up page."_

Good landing pages follow a formula:

+ *Headline* — what the product does, in one sentence ("Get your resume reviewed by AI in 30 seconds")
+ *Subheadline* — who it is for and why they should care ("Stop guessing if your resume is good enough. Get specific, actionable feedback instantly.")
+ *Social proof or demo* — a screenshot, a sample result, or a testimonial
+ *Pricing* — clear, simple, no surprises
+ *Call to action* — one button, one action ("Try it free")

Ask the agent for SEO basics:

- _"Add meta tags for SEO: title, description, Open Graph tags for social sharing, and a favicon. Write the OG description so that when someone shares the link on Twitter or LinkedIn, it looks professional."_

=== The Launch Checklist

Before you call it "launched," run through this checklist with your agent:

- _"Go through this launch checklist with me and help me address each item."_

#table(
  columns: (auto, 1fr),
  [*Item*], [*Details*],
  [HTTPS], [Is the site served over HTTPS? (Most platforms handle this automatically.)],
  [Environment variables], [Are all secrets set in production? Is `.env` excluded from the repo?],
  [Error tracking], [Add a basic error boundary in the frontend. Consider a free Sentry account for production error alerts.],
  [Monitoring], [Can you tell if the site goes down? Vercel and Railway have built-in monitoring. For a VPS, set up a free uptime check with UptimeRobot.],
  [Rate limiting], [Is the AI endpoint rate-limited? Can a single user bankrupt your API budget?],
  [Database backups], [If using SQLite on a VPS, set up a cron job to copy the database file daily. If using a managed database, backups are likely automatic.],
  [README], [Does the repository have a README that explains what the project is and how to run it locally?],
  [LICENSE], [Pick a license. MIT is fine for most projects. If unsure, ask the agent to explain the options.],
  [Stripe webhooks], [Is the production webhook endpoint configured in the Stripe dashboard?],
  [404 page], [Does visiting a nonexistent URL show a friendly error page instead of a stack trace?],
)


== Show Your Work

You built a product. Now make it presentable.

=== Clean Up the Repository

Ask your agent:

- _"Review the codebase for any cleanup needed: remove console.log statements, delete commented-out code, make sure all files have consistent formatting, and ensure no secrets are committed anywhere in the git history."_

If secrets were accidentally committed at any point, the agent can help you remove them from git history — but the safest approach is to rotate the compromised keys immediately.

=== Write a Proper README

- _"Write a comprehensive README for this project. Include: what it is, a screenshot or demo link, how to set it up locally, what environment variables are needed (without revealing actual values), how to run tests, how to deploy, and the tech stack."_

A good README is the difference between a project that impresses and one that confuses. It is the first thing a hiring manager, a potential collaborator, or a future-you will see.

=== Open Source (Optional)

If you want to share your work:

- _"Help me prepare this project for open source. Add a LICENSE file, a CONTRIBUTING.md with guidelines, and make sure no proprietary API keys or business logic would be exposed."_

Open-sourcing a SaaS project is a strong portfolio move. It shows you can build a complete product. It shows you think about code quality. And it invites others to learn from — or contribute to — what you have built.

=== Add to Your Portfolio

Whether open source or not, this project is portfolio-ready. You can describe it as:

- "Built a full-stack AI-powered SaaS application with user authentication, Stripe payment integration, and CI/CD deployment"
- Deployed at [your-url.com]
- Source code at [github.com/you/your-project]

That sentence, backed by a live URL and a clean repository, carries more weight than most technical interviews.


== What Just Happened

Take a breath. Look at what you have.

You started this book not knowing what a terminal was. Or maybe you knew that, but you had never committed code, or deployed a server, or written a test. Wherever you started, look at where you are now.

You just shipped a SaaS product. A real one. Let's trace which skills from which chapters you used:

#table(
  columns: (auto, 1fr),
  [*Chapter*], [*Skill used in this capstone*],
  [Chapter 1], [Terminal, shell, environment setup — the foundation everything runs on],
  [Chapter 2], [Git workflow — committing, pushing, managing a repository],
  [Chapter 3], [AI-generated content — you used the same pattern of directing AI output],
  [Chapter 4], [Pair programming — you described features and the agent built them],
  [Chapter 5], [Deployment — you put a working application on a live server],
  [Chapter 6], [Security awareness — password hashing, environment variables, input validation],
  [Chapter 7], [Testing and CI/CD — automated tests, GitHub Actions pipeline],
  [Chapter 8], [Everything above, combined — this is the integration chapter],
)

Every chapter was a building block. None of them was wasted. The reader who skipped Chapter 6 would have committed API keys to GitHub. The reader who skipped Chapter 7 would have deployed untested code. The reader who skipped Chapter 5 would not know how to get the app on the internet.

And here is the thing worth sitting with: the agent wrote the code. All of it. You did not write a single function, route, or database migration by hand.

But you made every decision.

You picked the idea. You scoped the product. You defined the spec. You chose the tech stack. You decided what the free tier includes. You set the price. You reviewed the authentication flow. You tested the payment integration. You chose where to deploy. You wrote the launch checklist.

The agent was the builder. You were the architect. And the building is standing.

#quote(block: true)[
  *This is what "agentic" means.* Not that the AI does everything. Not that you do everything. That you work together — each contributing what you are best at. You bring judgment, taste, and decisions. The agent brings speed, breadth, and tireless execution. Neither is sufficient alone. Together, you shipped in a day what would have taken weeks.
]


== Troubleshooting

*The Next.js app will not start:*
Check that Node.js v18+ is installed: `node --version`. Run `npm install` again if dependencies are missing. Check for TypeScript errors: `npx tsc --noEmit`. If the port is in use, try `npx next dev -p 3001`.

*Prisma errors or database issues:*
Run `npx prisma generate` to regenerate the client after schema changes. Run `npx prisma db push` to sync the schema to the database. If the database is corrupted, delete the SQLite file and re-run `npx prisma db push` — you will lose data, but in development that is fine.

*The AI endpoint returns errors:*
Check your API key is set correctly in `.env`. Check you have credits on your LLM provider account. Test the API call in isolation: ask the agent to write a simple script that calls the API and prints the response. If the API works in isolation but not in the app, the issue is in your route handler.

*Stripe checkout redirects fail:*
Make sure your publishable key is exposed to the frontend (prefix it with `NEXT_PUBLIC_` in Next.js). Make sure the checkout session's `success_url` and `cancel_url` point to valid pages. Check the Stripe dashboard's "Events" tab — it shows every webhook event and whether it was delivered successfully.

*Stripe webhooks are not received locally:*
You need the Stripe CLI: `brew install stripe/stripe-cli/stripe` on macOS, or download from #link("https://stripe.com/docs/stripe-cli")[stripe.com/docs/stripe-cli]. Run `stripe listen --forward-to localhost:3000/api/stripe/webhook` and use the webhook signing secret it prints. This secret is different from the one in the Stripe dashboard.

*Authentication is not persisting:*
Check that `NEXTAUTH_SECRET` is set in `.env`. It must be a long random string — generate one with `openssl rand -base64 32`. If cookies are not being set, check that your browser is not blocking third-party cookies and that the `NEXTAUTH_URL` matches the URL you are visiting.

*Deployment works but the AI feature does not:*
Environment variables set locally in `.env` do not automatically transfer to production. You must set them in your deployment platform's dashboard (Vercel: Settings > Environment Variables; Railway: Variables tab). The most common issue is a missing `ANTHROPIC_API_KEY` in production.

*The database resets on every deploy:*
If using SQLite with a platform like Vercel, the database file is ephemeral — it gets wiped on each deployment because the filesystem is not persistent. For production, either use a persistent volume (Railway, VPS) or switch to a managed database like Supabase or PlanetScale. Ask your agent: _"Migrate from SQLite to Supabase for production persistence."_

*Tests pass locally but fail in CI:*
Check that CI has the same Node.js version. Check that test environment variables are set in the GitHub Actions workflow (use GitHub Secrets for API keys). Make sure the test database is created fresh in CI — do not rely on a local SQLite file.

*CORS errors in the browser:*
If your frontend and API are on different domains, you need CORS headers. In Next.js API routes, this is usually handled automatically. If you see CORS errors, ask the agent: _"Add CORS headers to the API routes."_


== Quick Reference

#table(
  columns: (1fr, 2fr),
  [*Task*], [*Command or prompt*],
  [Scaffold project], [_"Scaffold a Next.js app with TypeScript, Prisma, and SQLite"_],
  [Install dependencies], [`npm install`],
  [Start dev server], [`npm run dev`],
  [Generate Prisma client], [`npx prisma generate`],
  [Push database schema], [`npx prisma db push`],
  [View database], [`npx prisma studio`],
  [Run tests], [`npm test`],
  [Build for production], [`npm run build`],
  [Deploy to Vercel], [`npx vercel --prod`],
  [Stripe local testing], [`stripe listen --forward-to localhost:3000/api/stripe/webhook`],
  [Test card number], [`4242 4242 4242 4242` (any future date, any CVC)],
  [Generate auth secret], [`openssl rand -base64 32`],
  [Check TypeScript errors], [`npx tsc --noEmit`],
  [Format code], [`npx prettier --write .`],
  [Add AI integration], [_"Add an Anthropic API call to the /api/analyze endpoint"_],
  [Add authentication], [_"Add NextAuth.js with email/password and Prisma adapter"_],
  [Add Stripe], [_"Integrate Stripe Checkout with a free and pro tier"_],
  [Create CI/CD pipeline], [_"Create a GitHub Actions workflow for testing and deployment"_],
  [Write README], [_"Write a comprehensive README for this project"_],
)

#quote(block: true)[
  *You shipped it.* That URL is yours. That product is yours. The agent wrote the code, but every decision — from the idea to the architecture to the pricing to the launch — was yours. You are not "someone who uses AI tools." You are someone who builds and ships products. The tools are just how you do it. Now go build the next one.
]
