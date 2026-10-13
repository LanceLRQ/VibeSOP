# VibeSOP

English | [中文](README.zh.md)

A set of SOPs for governing a software project, packaged as agent skills. They cover where a project's documents live, which of them stay private, what the AI instruction files say, and how its environments are deployed.

VibeSOP is for engineers who already know how to build software. It keeps the project around the code in order. How the code itself gets written is left to the workflow framework you prefer.

## What it is and what it is not

| It is | It is not |
|---|---|
| Procedures an agent follows: detect, ask for your choices, show a plan, write, verify, report | A code generator or a project scaffold |
| Stack-agnostic, for new and existing repositories | A CLI or a fixed tech stack |
| A few plain files in your repository that you can read in a minute | A framework that takes over your workflow |

## Skills

| Skill | Use it when you are |
|---|---|
| [`vibesop-init-project`](skills/vibesop-init-project/SKILL.md) | starting a project, bringing an existing repository under governance, preparing to go public, or checking that nothing private is leaking |
| [`vibesop-init-deployment`](skills/vibesop-init-deployment/SKILL.md) | setting up Docker-based environments for a web project, or a Docker Hub release with a one-line installer |

Each skill stands alone. Install one or both.

## Install

```bash
npx skills add LanceLRQ/VibeSOP
```

The [skills CLI](https://github.com/vercel-labs/skills) asks which skills to install and for which agent. Useful flags: `--skill <name>` for a single skill, `-g` for a global install, `--list` to look before installing.

## Use

Say what you want in your own language, or call a skill by name:

```
Initialize this project.
帮我把这个老项目接入文档治理。
/vibesop-init-project
```

## What `vibesop-init-project` sets up

**One decision comes first: visibility.** It selects one of two layouts, which differ by a single directory level.

| Visibility | Process docs | Git |
|---|---|---|
| open source, or undecided | `docs/_internal/<category>/` | ignored |
| private for good | `docs/<category>/` | committed |

Process docs fall into seven categories: `research`, `discussion`, `specs`, `plans`, `audit`, `reference`, `ui`. Only an index is created up front. A directory appears when its first file is written.

**`AGENTS.md` as a working contract.** It tells an agent where a change goes, which tests it needs and when it is done. `CLAUDE.md` imports it, so every tool reads the same rules. In an existing repository the skill asks before converting anything, and keeps every line you already wrote.

**A governance record.** Visibility, layout, document language and board are written at the top of the index. The next session reads them from there, and so does the deployment skill.

**A check you can run again.** One list of commands verifies a fresh setup and audits an old one: the ignore rules come from the repository's own `.gitignore`, no tracked file should have been private, no public file points at internal docs.

**What stays with you.** `git commit`, `git push` and anything that rewrites history. The skill hands you the commands.

## What `vibesop-init-deployment` sets up

It starts from a service inventory: every process that runs on its own, with its build, port and data directory. From there it asks its questions in small batches and shows a decision table before writing anything.

| Route | You get |
|---|---|
| Private project | Management scripts and one compose file per environment: local dev and production by default, intranet and gray on request. Images go to a private registry, or are built on the server. |
| Open-source project | Public images on Docker Hub, a release pipeline triggered by tags, and a single-file installer your users run with one command. |

Kubernetes, serverless and pure static hosting are outside its scope.

## Language

- Skill bodies are in English, in one copy, so anyone can review them.
- The agent talks to you in the language you write in.
- Files written into your repository use the document language you choose. `vibesop-init-project` ships Chinese and English templates.
- Known gap: the script templates of `vibesop-init-deployment` carry Chinese comments and prompts in this release. For any other document language the skill translates them while generating.

## Companions

VibeSOP does not tell an agent how to write code. `vibesop-init-project` looks at which workflow skills you already have and suggests the ones that fit your project, each with a pinned source. For progress tracking it works with [kanban-hub](https://github.com/lanceLRQ/kanban-hub) when you use it.

## Status

Early release. The acceptance cases are in [`tests/scenarios/`](tests/scenarios/README.md), each in Chinese and English. A report of a run on your client and model is welcome.

## Repository layout

```
skills/
  vibesop-init-project/      SKILL.md, references/, templates/zh, templates/en
  vibesop-init-deployment/   SKILL.md, references/, templates/
tests/
  check.mjs                  structure checks
  make-fixtures.sh           throwaway repositories for the scenarios
  scenarios/                 acceptance cases
```

## Contributing

`node tests/check.mjs` must pass. [`AGENTS.md`](AGENTS.md) holds the conventions of this repository, which is governed by its own SOP.

## License

[MIT](LICENSE)
