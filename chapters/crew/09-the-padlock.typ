= The Padlock

#figure(
  image("../../assets/illustrations/crew/ch09-the-padlock.jpg", width: 80%),
  caption: [_The sealed envelope — how the internet keeps secrets._],
)

You've seen it thousands of times. The little padlock icon in your browser's address bar, right next to the URL. You know it means "secure." But what does that actually mean? And what happens when it's missing?

This chapter is about the invisible security layer that makes the modern internet work. You don't need to understand the mathematics — but understanding the _concept_ will make you a better judge of what's safe, what's risky, and what to do when something looks wrong.

== Postcards and Envelopes

The simplest way to understand encryption is to think about mail.

When the early web was built, every message between your browser and a website was sent as a postcard. Anyone handling that postcard along the way — your internet provider, the coffee shop's Wi-Fi router, any network between you and the server — could read it. Your login credentials, your credit card number, your private messages: all written in plain text on the back of a postcard, visible to anyone who bothered to look.

That was HTTP — Hypertext Transfer Protocol. The "how" of web communication, with zero privacy.

HTTPS added the envelope. The S stands for "Secure," and what it means is simple: the conversation between your browser and the server is encrypted. Scrambled in a way that only the two endpoints can read. Everyone in between still carries the envelope, but they can't open it. They can see _where_ it's going (the address on the front), but not _what's inside_.

Today, over 95% of web traffic uses HTTPS. It's the default. When you see that padlock, it means the envelope is sealed.

== What the Padlock Means — and Doesn't Mean

Here's the crucial distinction that trips people up:

*The padlock means the connection is encrypted.* It means nobody between you and the server can read or tamper with the data in transit. That's it.

*The padlock does _not_ mean the website is trustworthy.* A phishing site can have a padlock. A scam shop can have a padlock. A malware distribution page can have a padlock. The padlock tells you the _pipe_ is secure — it says nothing about what's on the other end of it.

Think of it this way: a sealed envelope guarantees nobody read your letter in transit. It doesn't guarantee the person you're writing to is honest.

This matters because people have been trained to "look for the padlock" as a sign of safety. That was reasonable advice in 2005, when getting a certificate required proving your identity to a certificate authority and paying hundreds of dollars. Today, anyone can get a certificate in seconds, for free. The padlock is table stakes, not a trust signal.

== Certificates: ID Cards for Websites

So how does your browser know it's really talking to your bank and not an impostor? This is where _certificates_ come in.

An SSL/TLS certificate is like an ID card for a website. It contains:

+ The domain name the certificate was issued for (e.g., "mybank.com")
+ The identity of the organisation that issued it (the _certificate authority_)
+ An expiry date
+ A cryptographic signature proving the certificate is genuine

When you visit a website, your browser checks the certificate before the padlock appears. It asks three questions:

+ *Is this certificate for the right domain?* If you're visiting mybank.com but the certificate says mybank-secure-login.com, something is wrong.
+ *Was it issued by a certificate authority my browser trusts?* Your browser comes with a built-in list of trusted authorities — organisations vetted and approved to issue certificates.
+ *Has it expired?* Certificates have expiry dates, typically 90 days to one year. An expired certificate triggers a warning.

If any of these checks fail, your browser shows you that scary full-page warning: "Your connection is not private." That warning isn't being dramatic — it's telling you the ID card doesn't check out.

== Let's Encrypt: Free Locks for Everyone

For most of the web's history, SSL certificates cost money. Sometimes a lot of money — hundreds of dollars per year for a single domain. Small businesses, personal websites, and open-source projects often went without. The internet was a mix of padlocked doors and wide-open ones.

In 2015, a nonprofit called Let's Encrypt changed everything.

Let's Encrypt issues SSL certificates for free. Completely free. And not just free — automated. Instead of a manual process involving paperwork and payments, Let's Encrypt uses a protocol called ACME that lets servers prove they control a domain and receive a certificate in seconds, with no human involved.

The impact was enormous. Before Let's Encrypt, roughly 40% of web traffic was encrypted. Today, it's over 95%. They've issued billions of certificates. The entire security posture of the internet shifted because someone removed the cost barrier.

There's a catch, though: Let's Encrypt certificates expire every 90 days. This is intentional — short lifetimes limit the damage if a certificate is compromised. But it means you need automation to renew them. If your certificate expires and nobody notices, your visitors get that scary browser warning, and many will simply leave.

This is where the tooling matters.

== Caddy: The Server That Just Handles It

If you've ever heard a developer say "I'll set up the SSL certificate," you might imagine a complex, multi-step process. For years, it was. You had to generate a certificate request, submit it to a certificate authority, receive the certificate, install it on your server, configure the server to use it, and set up a renewal process.

Caddy made all of that disappear.

Caddy is a web server — the same category of software as Apache or Nginx, which you may have heard of. But Caddy's party trick is automatic HTTPS. You tell Caddy what domain to serve, and it handles everything else: requests the certificate from Let's Encrypt, installs it, configures the encryption, and automatically renews it before it expires. No configuration files. No cron jobs. No forgetting and waking up to a broken site.

For the crew member, this matters because Caddy is the kind of tool that eliminates an entire category of problems. When your developer says "the SSL cert expired," you can ask: "Why aren't we using Caddy?" or "Why isn't renewal automated?" These are reasonable questions. In 2026, expired certificates should be a solved problem.

== Cloudflare: The Bouncer at the Door

Cloudflare is harder to explain in one sentence because it does _many_ things. But the simplest way to understand it: Cloudflare sits between your visitors and your server, like a bouncer at a restaurant door.

When someone types your website address, their request doesn't go directly to your server. It goes to Cloudflare first. Cloudflare inspects the request, decides if it's legitimate, and then passes it along to your actual server. The response comes back through Cloudflare too.

Why would you want a middleman? Several reasons:

*SSL termination.* Cloudflare handles the encryption between the visitor and itself, using its own certificates. This means your actual server doesn't need to manage certificates at all — Cloudflare deals with the padlock. For many small sites, this is the easiest path to HTTPS.

*DDoS protection.* A DDoS attack is when someone floods your server with millions of fake requests until it collapses under the load. Cloudflare absorbs the flood. It has data centres all over the world with enormous bandwidth — far more than your server could handle alone. The attack hits Cloudflare's wall and your server never even notices.

*CDN (Content Delivery Network).* Cloudflare caches your website's static files — images, CSS, JavaScript — on servers around the world. When someone in Tokyo visits your site hosted in London, they get the cached version from a nearby Cloudflare server instead of waiting for the data to cross the globe. Faster page loads. Less strain on your server.

*DNS management.* Cloudflare manages your domain's DNS records — the system that translates "mysite.com" into the actual server address. Their DNS is one of the fastest in the world.

You'll recognise Cloudflare by the orange cloud icon in DNS dashboards, or by the occasional "Checking your browser..." interstitial page that appears before some websites load. That's Cloudflare's bot-detection in action, making sure you're a real person before letting you through.

Half the internet sits behind Cloudflare. If you manage a website or domain of any kind, you'll almost certainly encounter their dashboard at some point.

== Encryption in Everyday Life

SSL and HTTPS are the most visible form of encryption, but the same underlying ideas show up everywhere:

*WhatsApp and Signal* use end-to-end encryption. This means the messages are encrypted on your phone and can only be decrypted by the recipient's phone. Not even WhatsApp's servers can read them — they're carrying sealed envelopes they can't open. This is a step beyond HTTPS, where the server _can_ read the data.

*Password managers* like 1Password or Bitwarden encrypt your vault with a key derived from your master password. The company running the service cannot access your passwords — they don't have the key. If you forget your master password, they genuinely cannot help you recover it. That's not a limitation; it's the security model working as designed.

*File encryption* tools like VeraCrypt let you create encrypted containers on your hard drive — digital safes that require a password to open. Full-disk encryption (FileVault on Mac, BitLocker on Windows) encrypts your entire drive, so if your laptop is stolen, the thief gets a useless block of scrambled data.

*Digital signatures* prove that a document or piece of software hasn't been tampered with. When you download an app and your operating system says "this app is from a verified developer," it's checking a digital signature — a cryptographic proof that the app is genuinely from who it claims to be.

== API Keys and Secrets

This one ties directly back to working with agents.

When your agent connects to external services — a database, an email provider, a payment processor — it authenticates using _API keys_ or _secrets_. These are essentially passwords that grant programmatic access to a service. An API key for your email provider can send emails as you. An API key for your payment processor can issue refunds.

The cardinal rule: *never put secrets in public places.*

This sounds obvious, but it happens constantly. Developers accidentally commit API keys to public GitHub repositories. People paste keys into shared documents. Agents, if not properly configured, might include keys in their output or logs.

Secrets belong in environment variables or secret management tools — never in code, never in chat logs, never in documents. When you're working with agents that have access to sensitive services, ask your developer: "Where are the API keys stored? Who can access them? What happens if one is compromised?"

If a key _is_ compromised — posted publicly, sent in a message, found in a log — the response is immediate: revoke it and generate a new one. Most services make this a one-click operation. The old key becomes useless instantly.

This is the security equivalent of changing the locks when you lose your house keys. Don't waste time wondering if someone found them. Just change them.

== The Minimum You Should Remember

If this chapter feels like a lot, here's the short version:

+ *HTTPS (the padlock) means the connection is encrypted* — but it doesn't mean the site is trustworthy.
+ *Certificates are ID cards for websites.* They expire, and when they do, browsers warn your visitors. Automation (Let's Encrypt, Caddy) solves this.
+ *Cloudflare is the bouncer* — it handles SSL, blocks attacks, and speeds up your site. Half the internet uses it.
+ *Encryption protects data in transit and at rest.* Your messages, passwords, and files can all be encrypted.
+ *API keys are passwords for machines.* Treat them with at least as much care as your own passwords — more, because they often have broader access.

You don't need to configure any of this yourself. But knowing what these pieces do means you can ask the right questions, spot problems early, and make informed decisions about the tools your team uses. That's not engineering. That's good seamanship.
