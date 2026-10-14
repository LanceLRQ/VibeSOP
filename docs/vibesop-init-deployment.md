# vibesop-init-deployment: deployment environments

English | [中文](vibesop-init-deployment.zh.md)

`vibesop-init-deployment` generates Docker-based environments and management scripts for web projects. The procedure itself is [`skills/vibesop-init-deployment/SKILL.md`](../skills/vibesop-init-deployment/SKILL.md); this page is for users.

## Scope

In scope: web projects and web services that need Docker environments built or tidied up, in any language, framework and service count. A project that already has a deployment structure gets its gaps filled: current state and differences are listed, and the user decides what changes; nothing is torn down.

Out of scope: Kubernetes, serverless, and pure static hosting (Vercel, OSS static sites) — the skill says so explicitly when it meets one. Document layout and AI instruction files belong to `vibesop-init-project`.

## Service inventory

Everything starts from a service inventory: every process that runs on its own (backend, frontend, admin console, small tools), with its build method, listening port, data directory and whether it holds state. The inventory is put to the user as a table for confirmation — if the inventory is wrong, everything after it is wrong. Detected values serve as recommended defaults only; each is still asked.

## Environments

| Environment | Default | Role |
|---|---|---|
| Local dev | on | source mounted with hot reload; data lands in a local ignored directory |
| Production | on | runs images; application and database lifecycles are separate |
| Intranet | optional | LAN test or staging machine with its own data, same structure as production |
| Gray | optional | runs beside production on the same machine; traffic splitting validates the new version |

When gray is chosen, the skill must confirm whether it shares the production database or uses its own; when shared, no migration guidance that would break the old version is generated. Build-time variables (`NEXT_PUBLIC_*`, `VITE_*` and the like) and background jobs (scheduled tasks, queue consumers) are the key risks in gray and are confirmed one by one.

## Release route

The first question decides the direction:

| Route | You get |
|---|---|
| Private project (default) | One compose file per environment with `dev.sh` / `prod.sh` management scripts; images go to a private registry (e.g. Alibaba Cloud ACR) or are built on the server |
| Open-source project | Public images on Docker Hub, a release pipeline triggered by tags, and a single-file installer users run with one command |

A repository whose governance record says open source gets the open-source route recommended; either way, the local dev environment is generated.

## Other key decisions

- Deploy account: root, a sudo user, or a regular user in the docker group — all three are supported. Together with the user the container runs as, it decides whether data directories need `chown` and whether command examples carry `sudo`.
- Reverse proxy: with exactly one externally exposed HTTP service, no Nginx is built in and the reason is stated; with two or more, the user is asked and the trade-offs explained.
- Image registry: Alibaba Cloud ACR (guided step by step when not set up yet), cloning and building on the server, or carrying images with `docker save/load`.

## Verification and delivery

After generation, each item is verified: every script passes `bash -n`; every compose file passes `docker compose config -q`; data directories and secret files match ignore rules; `*.example` files are not caught by an ignore rule; no template placeholder remains in the output; `git status` shows nothing staged.

Delivery lists the generated files, a command quick reference per environment, and what the user must do personally: fill in `.env`, configure registry credentials, `chown` the data directories on the server, and set up the reverse proxy and domain.

## Red lines

- A value that was never asked is not written to disk
- Passwords, keys and tokens go only into ignored files; what enters git is `*.example` templates only
- No `docker push`, no logging in to a server, nothing live is touched, no git commit or push; generation is where it stops
- Git is used read-only; every change stays in the working tree for the user to review

## Common mistakes

These happened on real projects; the rules of the skill are shaped around them:

| Mistake | Consequence |
|---|---|
| Dumping all questions at once | The user must decide without context |
| Using a detected port as is | Clashes with other projects on the server; ports are always asked |
| Adding an Nginx to a single-service project | One more component to maintain |
| Pushing only `latest` | No way to roll back; the version tag and `latest` are pushed together |
| Building on ARM, running on x86 | `exec format error`; `--platform` is passed explicitly at build time |
| Background jobs running in both gray and production | Messages consumed twice, scheduled tasks run twice; gray disables background jobs by default |
