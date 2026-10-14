# vibesop-init-project: project governance

English | [中文](vibesop-init-project.zh.md)

`vibesop-init-project` sets up governance a repository can run on for the long term: how documents are laid out, which content stays private, what the AI instruction files say, and where those decisions are recorded. The procedure itself is [`skills/vibesop-init-project/SKILL.md`](../skills/vibesop-init-project/SKILL.md); this page is for users and explains what it does and how decisions are made.

## Four entries

In its first reply the skill picks an entry based on what the repository shows:

| Entry | Condition | What happens |
|---|---|---|
| New project | no commits, or nothing beyond a README and a LICENSE | governance is set up from scratch |
| Existing project | commits plus code or documents, and no governance record | governance is adopted; existing documents are registered in place, every line kept |
| Open-source prep | the repository is going public, or the recorded visibility changes to open source | private content is isolated, history is handled, LICENSE and README are added |
| Check | governance exists and the user asks for verification | check commands run read-only, nothing is written; findings come back as a plan table |

## How a run proceeds

Every entry follows the same course: detect (read-only) → report and pick the entry → decision questions → plan table → write → verify → deliver.

- Detection only reads: git state, existing instruction files, documents, stack and check commands, LICENSE. Facts the repository shows are not asked of the user.
- Decisions come in batches of at most four, each with a default and a one-line reason. A default decides only what an unanswered question resolves to, never whether it is asked.
- The plan table lists every file and command to be created, changed or moved; writing starts after an explicit yes.
- Verification runs each check command; a failing row is reported as failed, never waved through.

## Decision list

| # | Decision | Asked when |
|---|---|---|
| D1 | Visibility: undecided / open source / private for good | every run, first |
| D2 | Instruction files: `AGENTS.md` primary / keep the current primary file / leave untouched | an instruction file exists |
| D3 | Document language: conversation language for everything / English for public files, conversation language for process docs | visibility is not private and the conversation is not in English |
| D4 | License and copyright holder | open source and no `LICENSE` yet |
| D5 | Done gate: the one command that must pass before a change counts as done | a candidate command was detected |
| D6 | Board: kanban-hub / none / `TASKS.md` | every run, last batch |
| D7 | Remote URL | the repository has no `origin` |
| D8 | Local-only notes: current stage, hard constraints, local paths of reference projects | isolated layout and `LOCAL.md` does not exist yet |
| D9 | Directory for process docs: `project-docs/` instead of `docs/` | tracked layout and `docs/` is a doc-site source |
| D10 | Project name and one-line description | neither is in the README, a manifest or the conversation |

Matters outside the table — scaffolding, libraries, code structure — never enter a question batch; they go into the report as suggestions.

## Document model

Visibility (D1) selects the layout. The two layouts differ by a single directory level:

| Visibility | Process docs | Git |
|---|---|---|
| undecided or open source | `docs/_internal/<category>/` | ignored |
| private for good | `docs/<category>/` | committed |

The default is undecided: isolating now costs one ignore rule, while withdrawing a committed document later means rewriting git history.

Process docs fall into seven categories: `research`, `discussion`, `specs`, `plans`, `audit`, `reference`, `ui`. Only an index is created up front; a category directory appears when its first file is written.

The governance record sits at the top of the index: visibility, layout, instruction files, document language, board, onboarding date. The next session and `vibesop-init-deployment` both read their context from there.

## Instruction files

`AGENTS.md` is the primary file, written as a working contract: where a kind of change goes, which tests it needs, when it counts as done. Every statement in it comes from a detected fact, a decision, or something the user stated; no convention is invented. `CLAUDE.md` is a single `@AGENTS.md` line, so every tool reads the same rules.

Machine-local information (current stage, hard constraints, local paths of reference projects) goes into `docs/_internal/LOCAL.md`, which never enters git; an import line in `CLAUDE.local.md` makes Claude Code load it at session start. In an existing repository, previously written instruction files are converted line by line, and lines that contradict the repository are reported.

## Check commands

One list of commands verifies a fresh setup and audits an old one:

- Ignore rules come from the repository's own `.gitignore`, and files that should stay private are in fact ignored
- No tracked file matches an ignore rule
- In the isolated layout, `docs/_internal` and `CLAUDE.local.md` are outside the git index
- No public file points at internal docs
- No written file carries a leftover template placeholder
- Every command named in `AGENTS.md` exists in the repository

## Boundaries

`git commit`, `git push` and history rewrites are executed by the user; the skill only prepares the commands. Visibility, license, copyright holder and remote URL come from the user.

## Language

The conversation uses the user's language; files written into the repository use the chosen document language. Chinese and English templates are included.
