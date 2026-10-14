# VibeSOP

English | [中文](README.zh.md)

VibeSOP is a set of project-governance SOPs packaged as agent skills. They cover four areas outside the code itself: how project documents are organized, how public and private content are separated, what the AI instruction files contain, and how the environments are deployed. They are stack-agnostic and apply to new and existing repositories; everything written into a repository is plain text, open to direct review.

VibeSOP is for engineers with software development experience. Its scope is the project governance around the code; how the code itself is written stays with the workflow framework you prefer.

## Use cases

| Scenario | Skill |
|---|---|
| Starting a project, with governance and document layout in place from the first commit | `vibesop-init-project` |
| Bringing an existing repository under governance: document layout, AI instruction files, no re-explaining the context each session | `vibesop-init-project` |
| Preparing a repository to go public: isolating private content, adding a LICENSE, checking for leaks | `vibesop-init-project` |
| Auditing a governed repository to confirm no private content is tracked | `vibesop-init-project` |
| Setting up Docker environments for a web project, or adding gray and intranet ones | `vibesop-init-deployment` |
| Consolidating scattered deployment files into one layout with scripts | `vibesop-init-deployment` |
| Publishing images for an open-source project, with a one-line installer | `vibesop-init-deployment` |

## Install

Prerequisites: Node.js (for npx) and a client that supports agent skills.

```bash
npx skills add LanceLRQ/VibeSOP
```

The [skills CLI](https://github.com/vercel-labs/skills) asks which skills to install and for which client. The default is the current project, committed and shared with the team; `-g` installs to the user directory, available to every project. Skills take effect in a newly started session.

| Flag | Effect |
|---|---|
| `--skill <name>` | install only the named skill; repeatable, `--skill '*'` takes all |
| `-g` | global install |
| `-a <client>` | target client, e.g. `-a claude-code`, `-a zcode`, `-a codex` |
| `--list` | list the skills in the repository without installing |
| `-y` | skip confirmation prompts |

Verify with `npx skills list`, remove with `npx skills remove`. The two skills stand alone and can be installed separately.

### Installation via your AI client

Send the following text to your AI client as is, and it will carry out the installation:

```text
Install the two VibeSOP governance skills for me:
1. Work out which AI client this machine uses (claude-code, zcode, codex, ...), then run
   npx skills add LanceLRQ/VibeSOP --skill vibesop-init-project --skill vibesop-init-deployment -g -a <client> -y
2. Run npx skills list -g, confirm both skills are installed, and tell me where they landed.
Install only; do not run the skills themselves.
```

## Use

Describe what you need in your own language, or call a skill by name:

```
Initialize this project.
帮我把这个老项目接入文档治理。
/vibesop-init-project
```

Calling by name is the reliable way: some clients show the model only skill names, and natural triggering can fail — see [client compatibility and known issues](docs/compatibility.md). These skills make repository-level decisions, so run them on the strongest model your client offers.

## The two skills

### `vibesop-init-project`: project governance

Sets up a document layout, an `AGENTS.md` working contract, a governance record, and a list of check commands that can be run repeatedly. Four entries are supported: new project, existing project, open-source prep, check. Visibility is the decision taken first: process docs live under the ignored `docs/_internal/` or the committed `docs/`, and the two layouts differ by a single directory level.

Details: [`docs/vibesop-init-project.md`](docs/vibesop-init-project.md) · procedure: [`skills/vibesop-init-project/SKILL.md`](skills/vibesop-init-project/SKILL.md)

### `vibesop-init-deployment`: deployment environments

For web projects with service processes. Starting from a service inventory, it confirms the environments and the image registry in batches, then generates Docker compose environments for local dev, production, and gray or intranet on request, with management scripts. Open-source projects can take the Docker Hub publishing route with a one-line installer.

Details: [`docs/vibesop-init-deployment.md`](docs/vibesop-init-deployment.md) · procedure: [`skills/vibesop-init-deployment/SKILL.md`](skills/vibesop-init-deployment/SKILL.md)

## Philosophy

Both skills follow one working method: detect first, ask next, show a plan, write after an explicit yes, verify with commands, report what actually happened. Facts the repository shows are not asked of the user; only choices are. Questions come in batches of at most four, each with a default and a one-line reason. Nothing is written before the plan table is confirmed.

The agent is bound by these red lines:

- `git commit`, `git push` and history rewrites are executed by the user; the skill only prepares the commands
- A value that was never asked is not written to disk; there is no silent decision
- Passwords, keys and tokens go only into ignored files; what enters git is `*.example` templates only
- The deployment skill stops at generating files: no `docker push`, no logging in to a server, nothing live is touched

How code is written is out of scope. For matters like library choices and scaffolding it points to the workflow skills you already have, each with its source repository named; the full list is in [companion tools](docs/companions.md).

## Boundaries and out-of-scope cases

| Scenario | Reason |
|---|---|
| Writing code, choosing libraries, scaffolding | Only the work around the code is governed; code writing stays with the workflow framework |
| Kubernetes, serverless, pure static hosting | The deployment skill covers Docker compose deployments only and says so explicitly when it meets one |
| Unattended runs, or inside CI | Every decision waits for the user's confirmation; it is not an automation script |
| Expecting it to commit and push | Git operations are deliberately the user's; the skill only prepares the commands |

## Related documentation

| Document | Contents |
|---|---|
| [Client compatibility and known issues](docs/compatibility.md) | Acceptance results per client; the non-triggering open-source-prep entry, its cause and workaround |
| [Companion tools](docs/companions.md) | Recommended third-party skills and workflow frameworks, with sources and install commands |
| [Tech selection guide](docs/tech-selection.md) | The route from requirements to a stack, mainstream candidates per scenario (as of 2026-10), and how to record the decision |
| [vibesop-init-project in detail](docs/vibesop-init-project.md) | Four entries, decision list, document model, instruction files, check commands |
| [vibesop-init-deployment in detail](docs/vibesop-init-deployment.md) | Service inventory, environment model, release routes, verification, common mistakes |

## Language

- Skill bodies are in English, in one copy, so anyone can review them.
- The agent converses in the user's language; conversation and file language were verified with zero drift.
- Files written into a repository use the chosen document language. `vibesop-init-project` ships Chinese and English templates.
- Public documents of this repository exist in English and Chinese: `README.zh.md` is the Chinese README, the rest live under `docs/`.

## Repository layout

```
skills/                      the skills themselves
  vibesop-init-project/       SKILL.md, references/, templates/zh, templates/en
  vibesop-init-deployment/    SKILL.md, references/, templates/
docs/                        public documentation, English and Chinese per topic
tests/
  check.mjs                   structure checks
  make-fixtures.sh            throwaway repositories for the scenarios
  scenarios/                  acceptance cases
```

## Contributing

`node tests/check.mjs` must pass. [`AGENTS.md`](AGENTS.md) holds the conventions of this repository, which is governed by its own SOP.

## License

[MIT](LICENSE)
