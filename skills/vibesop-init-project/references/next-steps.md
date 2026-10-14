# Next steps for a new project

Read when the entry is New project and step 1 found no manifest, when writing the Next part of the report for such a run, and when the user asks what comes next or how to choose a stack.

## The route

A repository that has governance but no code needs one route, stated in one line each:

1. Requirements — what is being built, for whom, on which platform.
2. Stack selection — two or three candidates matched to the requirements; the user picks one.
3. Scaffolding — the chosen stack is set up by its own tooling or by a workflow skill; the user runs the commands.
4. Back for `vibesop-init-deployment` once the project has services to run.

## Requirements before stack

The platform comes first. A mini-program requirement never gets a web framework among its candidates; a CLI tool never gets an ORM. These questions follow the batching rules of step 3:

| Question | Why it changes the candidates |
|---|---|
| What does it run on: web, mini-program, mobile app, desktop, server API, CLI | the first filter |
| Who uses it, and how heavy is the use | a content site, an internal tool and a product with paying users weigh maturity differently |
| What does the team already know | a stack the team knows beats a marginally better one |
| Domestic only, or global | payment, compliance and network reach change the list |

## How to recommend

- Mainstream by default: widely deployed, mature ecosystem, easy to hire for and to read about. A frontier choice — a 1.0 that shipped last month, a new toolchain — is named as frontier, never offered as the default.
- Two or three candidates, each with the reason it fits, its cost, and the version the recommendation is based on. State the date: the table below is as of 2026-10, and the user verifies versions before committing.
- Never a single candidate: a selection without an alternative is not a selection.

## Risk tiers

Every candidate carries a tier. Mainstream is the default and needs no ceremony. The frontier tier — a tool clearly becoming the standard but not fully landed — enters only by explicit user choice:

- One question precedes any frontier candidate: does this project take a frontier route? The default is no, and the answer belongs to the user.
- A frontier candidate is reasonable when the project is greenfield, or when the choice sits in the toolchain layer (linter, formatter, bundler, a faster compiler), where the way back is a config change. Runtime-layer choices — framework, ORM, auth — need the user's explicit yes and a stated fallback.
- Each frontier candidate states three things: the problem it solves over the mainstream pick, the way back, and its verification status — who verified what, at what scale.
- Combination lists verified in CI (installed, type-checked, tested and built across combinations) are evidence that frontier pieces work together, not that they survive production for years. Greenfield-proof is not three-years-proof.

## When this route does not apply

A project that already runs keeps its stack. Never propose a migration, a rewrite or a frontier upgrade unless the user asked for one; for such a project the answer to "what next" is features and fixes on the stack it has. Selection questions apply to a greenfield project, or to the single part the user explicitly wants to change.

## Mainstream candidates by scenario (as of 2026-10)

| Scenario | Candidates | Notes |
|---|---|---|
| Web frontend | React + Next.js; Vue 3 + Nuxt | Svelte 5 + SvelteKit when the team prefers it; Tailwind CSS for styling either way; TypeScript throughout |
| Mini-program (China) | WeChat native; Taro 4 when the team knows React; uni-app when it knows Vue | Taro and uni-app also compile to H5 and app platforms; uni-app x compiles to native code and is still young. HarmonyOS NEXT coverage changes fast — check it per platform before promising that end |
| Mobile app | Expo (React Native); Flutter | Expo suits teams with a web background and is the standard way to run React Native in 2026; Flutter suits UI-heavy apps; native Kotlin and Swift only when the platform demands it |
| Desktop | Electron; Tauri 2 | Electron for ecosystem maturity; Tauri 2 for small binaries and low memory |
| Server API, TypeScript | NestJS; Fastify; Hono | NestJS for structure at scale, Hono for light and edge deployments. Sign-in: better-auth. Database layer: Drizzle or Prisma |
| Server API, Python | FastAPI; Django | Django when the admin UI and its ORM are wanted |
| Server API, Go | standard-library routing; Gin | single binary, simple deployment |
| Server API, Java | Spring Boot 3 | the enterprise default |
| Database | PostgreSQL; MySQL where the surrounding ecosystem expects it; SQLite for embedded and local-first | MongoDB only for document-shaped data |

For authentication in TypeScript: better-auth is the 2026 default for new projects; Auth.js (NextAuth) is the mature option tied to Next.js; Lucia is no longer maintained and serves as a learning reference only.

## Where the outcome goes

- The decision becomes a process document: a selection decision under `specs/`, or a comparison under `research/`, registered in the index.
- Record the requirement points, the candidates with their trade-offs, the chosen stack with its version, the risk tier when it is frontier, and the date.
- After the user picks, the chosen stack counts as something the user stated and may be written into `AGENTS.md` as such. Once scaffolding produces a manifest, later runs detect it as a fact.
- The user runs the scaffold and install commands. This skill does not generate the project.
