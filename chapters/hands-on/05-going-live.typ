#import "_os-helpers.typ": *
= Going Live

Your app works on localhost. It looks great. The cards animate, the filters snap, the localStorage persists between refreshes. You built this.

Now try sending the URL to a friend.

You can't. `localhost` means "this computer, right here." It's a private address — like a street name that only exists inside your house. To everyone else in the world, your app doesn't exist.

This chapter fixes that. You're going to rent a small server, point a domain at it, and deploy your Travel Bucket List for the world to see — with HTTPS, automatic restarts, and a proper setup. Your AI agent won't just write config files. It will _operate the infrastructure directly_: provisioning the server, SSHing in to configure it, and calling the Cloudflare API to set up DNS. No dashboards. No clicking. Just you, your agent, and a terminal.

This is where the agent stops being a code writer and becomes your ops team.

== What You'll Build

By the end of this chapter, you'll have:

+ Provisioned a real server in a data centre using the Hetzner Cloud CLI
+ Had your agent SSH into the server and configure it from scratch
+ Deployed your Travel Bucket List behind a reverse proxy with automatic HTTPS
+ Used your agent to configure DNS via the Cloudflare API — no dashboard
+ Set up your app as a system service that survives reboots
+ Understood the basics of self-hosting: what it takes to run your own machine on the internet

== What You'll Need

From the previous chapters:
- Your Travel Bucket List app from Chapter 4 (pushed to GitHub)
- A terminal with your AI agent ready
- Git installed and configured

New for this chapter:
- A Hetzner Cloud account (servers start at around EUR 4/month — #link("https://console.hetzner.cloud")[sign up here])
- A Cloudflare account for DNS (free — #link("https://dash.cloudflare.com/sign-up")[sign up here])
- A domain name (optional but recommended — cheap ones start at a few euros per year)
- A willingness to let your agent touch real infrastructure

#quote(block: true)[
  *A note on costs:* A Hetzner CX22 server costs around EUR 4–5 per month — less than a coffee. You can delete it when you're done with the chapter if you want. Cloudflare's DNS is free. If you don't have a domain name, you can still follow along using the server's IP address — you just won't get HTTPS until the DNS step.
]


== Why Self-Host?

There are platforms that will deploy a static site for you in seconds — Vercel, Netlify, Cloudflare Pages. Push your code and it's live. That's genuinely useful, and for many projects it's the right choice.

But you don't learn what deployment _is_ by using a platform that hides everything. You learn it by doing it yourself. A VPS gives you the full picture: a Linux machine, a public IP address, a web server, DNS records, SSL certificates. These are the building blocks that every platform is built on top of.

Self-hosting also means self-reliance. You can run anything on your own server — not just static sites, but databases, APIs, background workers, self-hosted tools like Gitea or Plausible or Nextcloud. Once you know how to manage a VPS, you can host anything. The monthly cost is fixed and predictable. There are no surprise bills, no vendor lock-in, and no terms of service that change overnight.

Your AI agent makes self-hosting dramatically more accessible. The commands and config files that used to require years of sysadmin experience? The agent knows them. You bring the intent — "make this secure," "set up HTTPS," "deploy my app" — and the agent translates that into the right operations on the right machine.

Let's get started.


== Create Your Server

We're going to provision a server using the Hetzner Cloud CLI. First, ask the agent:

- _"Install the Hetzner Cloud CLI (hcloud) and help me authenticate it with my API token."_

You'll need to create an API token in the Hetzner Cloud Console (under Security → API Tokens). Give it read/write permissions. The agent will guide you through this, then configure the CLI with `hcloud context create`.

Now, the fun part. Tell the agent:

- _"Use the hcloud CLI to create an Ubuntu 24.04 server in the Falkenstein data centre. Use the CX22 type. Name it travel-bucket-list. Add my SSH key."_

The agent runs something like:

```
hcloud server create \
  --name travel-bucket-list \
  --type cx22 \
  --image ubuntu-24.04 \
  --location fsn1 \
  --ssh-key your-key-name
```

In about 30 seconds, you have a server. The CLI returns an IP address — that's your machine's address on the internet. Write it down. You'll need it.

#quote(block: true)[
  *What just happened?* You rented a virtual machine in a Hetzner data centre in Falkenstein, Germany. It has 2 CPU cores, 4 GB of RAM, and 40 GB of disk space. It's running Ubuntu Linux. It has a public IP address, which means anyone on the internet can reach it — and you can reach it via SSH. All from a single CLI command.
]


== The Agent SSHes In

Here's where this chapter diverges from a typical tutorial. You're not going to SSH into the server and type commands. The _agent_ is going to SSH in and configure the machine for you.

Tell the agent:

- _"SSH into my new server at [IP address] as root and run `uname -a` to verify we're connected."_

The agent connects. You see the output: `Linux travel-bucket-list 6.x.x ... Ubuntu ...`. Your agent is now inside a real Linux machine in a data centre. Everything it does from here happens on that remote server.

Now ask:

- _"While you're on the server, update all packages and show me the system info — how much RAM, disk space, and what CPU we're working with."_

The agent runs `apt update && apt upgrade -y`, then `free -h`, `df -h`, and `lscpu`. You can see exactly what you're renting.

#quote(block: true)[
  *Infrastructure-as-conversation.* Your AI agent just connected to a remote computer via SSH and ran commands on it. This is the same thing a system administrator does — but instead of remembering arcane commands and flags, you described what you wanted in plain English. The agent translated your intent into operations. This pattern will repeat throughout the chapter: you say _what_, the agent figures out _how_.
]


== Harden the Server

A fresh server on the internet is like an unlocked house on a busy street. Bots will start probing it within minutes. Let's fix that. Ask the agent:

- _"SSH into the server and do basic security setup: create a user called deploy with sudo access, copy my SSH key to that user, disable root SSH login, and set up UFW to allow only SSH, HTTP, and HTTPS."_

The agent SSHes in as root and runs a series of commands: creating the user, setting up the SSH authorised key, editing `sshd_config`, enabling the firewall. It knows to allow port 22 _before_ enabling UFW — because if you enable the firewall and forget to allow SSH, you've locked yourself out.

#quote(block: true)[
  *War story: The locked-out admin.* This happens to everyone at least once. You enable the firewall, forget to allow SSH, and suddenly you can't connect to your own server. Hetzner's web-based console (VNC) is your escape hatch — you can log in through the browser and fix the firewall rules. Your agent knows this risk and handles the ordering correctly. But if you're doing it manually, always remember: allow SSH _first_, enable the firewall _second_.
]

After this step, verify the new setup works:

- _"SSH into the server as the deploy user and verify we have sudo access."_

From now on, you'll always connect as `deploy`, not `root`. This is a basic security practice — the root account has unlimited power, and you don't want to use it for everyday work.


== Deploy the App

Now let's get the Travel Bucket List running on the server. Tell the agent:

- _"SSH into the server as the deploy user. Install Node.js using nvm, clone my travel-bucket-list repo from GitHub, and start the app."_

The agent handles the whole sequence: installing nvm, installing Node, cloning the repo, and starting the app. It reports back that the app is listening on port 3000.

Test it by visiting `http://[your-server-ip]:3000` in your browser. There it is — your app, running on a real server, reachable from anywhere in the world.

Take a moment. You built this app in Chapter 4. Now it's on the internet. That's real.

But we're not done. This setup is fragile in two ways: if the SSH session closes, the app dies. And if the server reboots, the app doesn't come back. Let's fix both problems.


== Set Up the Web Server

Right now, visitors need to type a port number (`:3000`) to reach your app. That's not how real websites work. We need a _reverse proxy_ — a web server that listens on the standard ports (80 for HTTP, 443 for HTTPS) and forwards requests to your Node.js app.

We're going to use Caddy. It has a superpower: automatic HTTPS. Caddy provisions SSL certificates from Let's Encrypt without any configuration from you. Ask the agent:

- _"SSH into the server and install Caddy. Then write a Caddyfile that reverse-proxies port 3000. For now, use the server's IP address since we haven't set up DNS yet."_

The agent installs Caddy and creates `/etc/caddy/Caddyfile`. Once Caddy is running, you can visit `http://[your-server-ip]` — no port number needed.

#quote(block: true)[
  *Why Caddy over nginx?* Nginx is the industry standard, and your agent can write nginx configs too — ask it if you're curious. But for this chapter, the goal is deployment confidence, not web server mastery. Caddy's automatic HTTPS and minimal config means you get a working production setup in minutes. You can always switch later.
]


== Point Your Domain with the Cloudflare API

This is where Cloudflare comes in — not for hosting, but for DNS. DNS is the system that translates a human-readable domain name (like `bucketlist.example.com`) into your server's IP address. Cloudflare provides a fast, free DNS service with an excellent API.

If you have a domain managed by Cloudflare (or want to transfer one there), tell the agent:

- _"Use the Cloudflare API to create an A record for `bucketlist.example.com` pointing to [server IP address]. My Cloudflare API token is in the environment variable CLOUDFLARE_API_TOKEN."_

The agent constructs the API call:

+ Queries the Cloudflare API to find your DNS zone
+ Creates an A record pointing your domain to the server's IP
+ Verifies the record was created successfully

All via HTTP requests to the Cloudflare API. You never open the Cloudflare dashboard. The agent explains each step:

#quote(block: true)[
  *What's an A record?* It's the most basic DNS entry — it maps a domain name directly to an IP address. When someone types `bucketlist.example.com` into their browser, their computer asks DNS "what's the IP for this domain?" and the A record answers with your server's address. The agent is creating this record through the Cloudflare API — the same API that the web dashboard uses behind the scenes.
]

Now update your Caddyfile to use the domain. Ask the agent:

- _"SSH into the server and update the Caddyfile to use my domain `bucketlist.example.com` instead of the IP address. Restart Caddy."_

The agent updates `/etc/caddy/Caddyfile` to:

```
bucketlist.example.com {
    reverse_proxy localhost:3000
}
```

When Caddy sees a real domain name, it automatically provisions an SSL certificate from Let's Encrypt. Within seconds, your site is live at `https://bucketlist.example.com` — green lock and all.

#quote(block: true)[
  *DNS propagation.* After creating the A record, it can take a few minutes for DNS changes to spread across the internet. If your domain doesn't resolve immediately, don't panic. Ask the agent: _"Check if the DNS record for bucketlist.example.com has propagated using dig."_ It usually takes under five minutes with Cloudflare.
]

If you don't have a domain, that's fine. Your app is still accessible at `http://[server-ip]`. You can add a domain later — the agent can walk you through buying one and setting up Cloudflare DNS whenever you're ready.


== Make It Survive Reboots

The last piece: a systemd service file so your app starts automatically and restarts if it crashes. Ask the agent:

- _"SSH into the server and create a systemd service for my Node.js app. It should start on boot, restart on crash, and run as the deploy user. Enable and start it."_

The agent creates `/etc/systemd/system/travel-bucket-list.service`, enables it with `systemctl enable`, and starts it. Now your app is managed by the operating system itself.

You can check on it any time:

- _"SSH in and check the status of the travel-bucket-list service."_
- _"SSH in and show me the last 50 lines of application logs."_

The agent runs `systemctl status travel-bucket-list` and `journalctl -u travel-bucket-list -n 50`. You're monitoring a production server from your terminal, with the agent translating your questions into the right commands.


== Test the Full Stack

Let's prove everything works end to end. Ask the agent:

- _"SSH into the server and reboot it."_

Wait 30 seconds, then visit your URL. Your app should be there — HTTPS, green lock, fully operational. The operating system started Caddy and your Node.js app automatically on boot.

This is a real deployment. Not a toy. Not a demo. A real server in a real data centre, running your code, with encrypted connections, automatic certificate renewal, and crash recovery. You could point a business at this.


== What Just Happened

You took an app from `localhost` to the real internet. Let's look at what you brought versus what the agent brought:

#table(
  columns: (1fr, 1fr),
  [*You brought*], [*The agent brought*],
  [The decision to ship it], [Server provisioning via the hcloud CLI],
  [Account credentials and API tokens], [SSH sessions and Linux system administration],
  [A domain name], [DNS configuration via the Cloudflare API],
  [High-level instructions ("make it secure")], [Firewall rules, user management, SSH hardening],
  [Bug reports ("I'm getting a 502")], [Log analysis, diagnosis, and fixes],
  [The final check ("does the URL work?")], [systemd services, Caddy configs, SSL certificates],
)

The core loop stayed the same as Chapter 4:

+ *Describe* what you want ("deploy my app," "secure the server," "set up DNS")
+ *Review* what the agent does (watch the commands, check the output)
+ *Iterate* when something goes wrong (paste the error, let the agent diagnose)
+ *Understand* enough to stay in control (know what DNS does, what a reverse proxy is, why HTTPS matters)

But the agent's role expanded. In Chapter 4, it wrote code. In this chapter, it _operated infrastructure_ — provisioning servers, SSHing into remote machines, calling APIs, managing system services. The agent went from pair programmer to DevOps engineer. Same workflow, entirely different domain.

That's the real lesson: the agentic workflow isn't limited to writing code. It applies anywhere you need to translate intent into precise technical operations. Deployment. Configuration. Monitoring. Debugging. The agent meets you where the problem is.

Open your phone. Type the URL. Show someone.


== Troubleshooting

*I can't SSH into the server:*
Check three things: (1) Is the server running? Ask the agent to check via `hcloud server list`. (2) Is your SSH key correct? Run `ssh -v root@[ip]` to see verbose connection info. (3) Did you accidentally lock port 22 with UFW? If so, use Hetzner's web console (VNC) to log in and fix it.

*The site shows "502 Bad Gateway":*
Caddy is running but can't reach your app. Ask the agent: _"SSH in and check if the Node.js app is running on port 3000. Then check the Caddy logs."_ Common causes: the app crashed, it's listening on the wrong port, or the Caddyfile uses `localhost` instead of `127.0.0.1` (IPv6 mismatch).

*DNS isn't resolving:*
Ask the agent: _"Use dig to check if the A record for my domain exists and what IP it points to."_ If it returns nothing, the record wasn't created — have the agent call the Cloudflare API again. If it returns the wrong IP, update the record.

*HTTPS isn't working:*
Caddy needs two things to provision a certificate: port 443 open in the firewall, and the domain resolving to the server's IP. Ask the agent: _"SSH in and check that UFW allows port 443, and verify with dig that my domain points here."_ Also check `journalctl -u caddy` for certificate errors.

*The app dies when I close the terminal:*
You forgot the systemd step. Ask the agent to create the service file and enable it. Once systemd manages the app, it runs independently of your SSH session.

*The app works on the IP but not the domain:*
DNS is probably still propagating. Wait a few minutes and try again. Or the Caddyfile still references the IP instead of the domain — ask the agent to check and update it.

*"Permission denied" errors on the server:*
You're probably running commands as the wrong user, or files are owned by root. Ask the agent: _"SSH in and check who owns the app files, and fix the permissions so the deploy user can run everything."_


== Quick Reference

#table(
  columns: (1fr, 2fr),
  [*Task*], [*Prompt or command*],
  [Create a server], [`hcloud server create --name travel-bucket-list --type cx22 --image ubuntu-24.04 --location fsn1`],
  [Agent SSHes in], [_"SSH into my server at [IP] as [user] and [describe what you need]"_],
  [Harden the server], [_"Create a deploy user, disable root login, set up UFW for SSH/HTTP/HTTPS"_],
  [Deploy the app], [_"Install Node.js, clone my repo, and start the app"_],
  [Set up Caddy], [_"Install Caddy and configure it as a reverse proxy for my app"_],
  [Configure DNS], [_"Use the Cloudflare API to create an A record pointing my domain to [IP]"_],
  [Create a systemd service], [_"Create a systemd service for my app that starts on boot and restarts on crash"_],
  [Check status], [_"Show me the status of my app and the last 50 lines of logs"_],
  [Reboot and verify], [_"Reboot the server"_ — then visit your URL],
  [Delete the server], [`hcloud server delete travel-bucket-list`],
)


== Cleaning Up

If you want to keep your server running, great — it costs about EUR 4–5 per month and you now have a platform to host anything you want.

If you'd rather tear it down, ask the agent:

- _"Delete my Hetzner server called travel-bucket-list using hcloud. Also remove the DNS A record for my domain via the Cloudflare API."_

The agent runs `hcloud server delete travel-bucket-list` and calls the Cloudflare API to clean up the DNS record. Two commands, and it's as if the server never existed. Your code is still safe on GitHub — you can redeploy any time.
