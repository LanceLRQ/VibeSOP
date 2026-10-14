# Tech selection guide

English | [中文](tech-selection.zh.md)

When to use this: the repository has been initialized, there is no code yet, and the next step is unclear. This page gives the method and the mainstream candidates as of 2026-10; verify versions before committing to anything — selection content ages far faster than governance rules.

## The route

Requirements → stack selection → scaffolding → back to `vibesop-init-deployment`.

Requirements come first, as a hard rule: until the platform is settled, no candidates appear. For a mini-program, no web framework makes the list however mainstream it is; for a CLI tool, ORMs and UI libraries are out of place.

## Five questions to settle first

| Question | Why it changes the candidates |
|---|---|
| What does it run on: web, mini-program, mobile app, desktop, server API, CLI | the first filter |
| Who uses it, and how heavily | a content site, an internal tool and a product with paying users weigh maturity differently |
| What does the team already know | a stack the team knows beats a marginally better one |
| Domestic only, or global | payment, compliance and network reach change the list |
| Does this project take a frontier route | the default is no; only after an explicit yes may frontier options appear among the candidates |

## Mainstream candidates by scenario (as of 2026-10)

Defaults favor the mainstream: mature ecosystem, wide deployment, easy hiring and documentation. Items marked frontier are on their way to mainstream but not fully landed; weigh the team's appetite before taking them.

### Web frontend

| Candidate | Fits | Notes |
|---|---|---|
| React + Next.js | the default | largest ecosystem, App Router stable |
| Vue 3 + Nuxt | team knows Vue | strong in China; Nuxt 4 is out |
| Svelte 5 + SvelteKit | minimal runtime | smaller ecosystem, second-tier mainstream |

Tailwind CSS is the default for styling; TypeScript across the board.

### Mini-programs (China)

| Candidate | Fits | Notes |
|---|---|---|
| WeChat native | WeChat is the only target | no cross-platform compromise |
| Taro 4 | team knows React | compiles to WeChat/Alipay/Douyin mini-programs and H5 |
| uni-app / uni-app x | team knows Vue | widest platform coverage; uni-app x compiles to native code and is still young |

When a HarmonyOS NEXT target is in play, check the framework's current adapter status first — this area is still moving fast in 2026; do not promise that end from old material.

### Mobile apps

| Candidate | Fits | Notes |
|---|---|---|
| Expo (React Native) | team has a web/JS background | the standard way to run React Native in 2026, New Architecture on by default |
| Flutter | UI-heavy, consistent across platforms | Impeller renderer default on both iOS and Android |
| Native Kotlin / Swift | heavy platform requirements | two codebases, high cost; only when the platform demands it |

### Desktop

| Candidate | Fits | Notes |
|---|---|---|
| Electron | the default | most mature ecosystem, at the cost of installer size |
| Tauri 2 | size and memory matter | Rust core, frontend of your choice |

### Server side

| Candidate | Fits | Notes |
|---|---|---|
| TypeScript: NestJS / Fastify / Hono | same language as the frontend | NestJS for structure at scale; Hono for light and edge deployments. Auth with better-auth; database layer with Drizzle or Prisma |
| Python: FastAPI | API services | async, type hints, generated docs |
| Python: Django | admin UI and a full ORM wanted | boring in the good way |
| Go: standard-library routing + Gin | high concurrency, simple deployment | single binary |
| Java: Spring Boot 3 | enterprise settings | the de-facto standard |

Authentication in TypeScript, in short: better-auth is the 2026 default for new projects; Auth.js (NextAuth) is the mature option tied closest to Next.js; Lucia is no longer maintained and serves as a learning reference.

Databases: PostgreSQL is the default answer; MySQL remains widespread in the Chinese ecosystem; SQLite (including libSQL) fits embedded and local-first cases; MongoDB only when the data is genuinely document-shaped.

## The frontier route

Mainstream-first is the default tier, not a ceiling. After an explicit user choice the frontier route is open, under three rules.

Two risk layers come first:

| Layer | Examples | Cost of going frontier |
|---|---|---|
| Toolchain | linter, formatter, bundler, a faster compiler | low: pinned in dev dependencies and config; the way back is a config change, no business code touched |
| Runtime / dependencies | framework, ORM, auth library | high: baked into business code; the way back is a real migration |

Admission — one of these must hold before a frontier candidate appears: the project is greenfield, with nothing to migrate; or the candidate sits in the toolchain layer, where the way back is cheap; or the user explicitly accepts the migration cost and the candidate carries a clear fallback. Each frontier candidate states three things: the problem it solves over the mainstream pick, the way back, and its verification status — who verified what, at what scale.

One class of evidence needs the right reading: combination lists verified in CI — installed, type-checked, tested and built across combinations — prove that frontier pieces work together, not that they endure in production. A birth certificate is not a health report.

The frontier route does not apply to running projects: a project that already works keeps its stack, and no migration, rewrite or upgrade is proposed unless the user explicitly asks. The frontier route is an option for new projects, not a reason to renovate old ones.

## Recording the decision

A selection outcome is a process document, not a conversation that evaporates:

1. Write it as a selection decision under `specs/` (or a comparison under `research/` when the study is long) and register it in the docs index.
2. Record four things: the requirement points, the candidates with their trade-offs, the chosen stack with its version, and the date.
3. Once the user picks, the stack counts as a user statement and may be written into `AGENTS.md`; after scaffolding produces a manifest, later sessions detect it as a fact.

`vibesop-init-project` states the outline of this route in the final report of a new-project run; this page is the full version.
