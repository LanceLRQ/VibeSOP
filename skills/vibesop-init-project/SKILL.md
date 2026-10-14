---
name: vibesop-init-project
description: Use when a repository is about to be made public or open-sourced, before the visibility switch or the first public push, while private notes, local config or internal docs may still be tracked or sit in the git history and no LICENSE is chosen; when starting a new project; when bringing an existing repository under documentation governance; or when checking that internal docs and AI instruction files are set up and not leaking. Involves AGENTS.md, CLAUDE.md, docs/_internal, public vs internal docs, .gitignore isolation, LICENSE. 中文触发：仓库准备公开、开源前准备、开源准备、初始化项目、新项目起步、老项目接入治理、文档分区、内部文档隔离、泄露检查。
---

# VibeSOP: init-project

Sets up governance for a repository: where documents live, which of them are public, what the AI instruction files say, and where those choices are recorded so the next session finds them. It works on any stack, for new and existing repositories. Scaffolding code and deciding how code is written are outside it.

**Core rule: detect facts, ask only for choices, show the plan before writing, verify with commands, report what actually happened.**

## Language

This file is in English so that anyone can review it. That says nothing about the language to use with the user.

- **Talking to the user:** use the language of the user's own messages, from the first reply on. This covers questions, tables and the final report. Commands, paths, file names and code stay as they are.
- **Files written into the repository:** use the document language (decision D3). Start from `templates/zh/` for Chinese and `templates/en/` for English. For any other language, take `templates/en/` and translate while filling it in.
- **Chinese wording:** `references/glossary.md` fixes the Chinese term for each concept in this file. Use those terms so one thing keeps one name.
- A language set explicitly by the user or by the project's instruction files takes precedence over all of the above.

## Who does what

| This skill runs | The user runs (hand over the exact command) |
|---|---|
| Read-only inspection | `git add`, `git commit`, `git push` |
| `git init -b <branch>` when there is no repository | Anything that rewrites history |
| `git remote add origin <url>` when there is no `origin` | Installing other skills or tools, unless the user asks this session for the agent to do the install |
| The rows of the plan table the user confirmed | |

## Flow

### 1. Detect (read-only)

| Fact | Where to look |
|---|---|
| Git state | `git rev-parse --is-inside-work-tree`, `git branch --show-current`, `git remote -v`, `git log --oneline -1` |
| Earlier governance | a `# >>> vibesop` block in `.gitignore`; a governance record at the top of `docs/_internal/README.md` or `docs/README.md` |
| Instruction files | `AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`, plus other tools' files such as `.cursor/rules/`, `GEMINI.md`, `.github/copilot-instructions.md` |
| Existing documents | `git ls-files '*.md' 'docs/**'` and untracked files under `docs/` |
| Stack and check commands | manifests (`package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, …), `Makefile`, CI config. Read the script names; do not run them. |
| `docs/` is a doc-site source | `docs/.vitepress/`, `docusaurus.config.*`, `mkdocs.yml`, `docs/conf.py` |
| Tracked files under `.claude/` | `git ls-files .claude` |
| `LICENSE`, `README` | present or not |
| Deployable parts | a Dockerfile or compose file, a server entry point, a database dependency |
| Companion tools | skills visible in this session, and the companion lookup below this table |

The companion lookup prints the installed companions and nothing else. Run it as written, with the skill directory of the current client added to the `ls` when it is not one of the four. `references/companions.md` tells how to read the output.

```bash
ls ~/.claude/skills .claude/skills ~/.agents/skills .agents/skills 2>/dev/null | grep -iE 'superpowers|grill-me|frontend-design|ui-ux-pro-max|huashu-design|agent-browser|humanizer|git-guardrails|react-best-practices|postgres-best-practices|kanban-hub|vibesop' | sort -u
command -v kh; ls ~/.kanban-hub/config.yaml
command -v codegraph
```

### 2. Report and name the entry

When the conversation is in Chinese, read `references/glossary.md` before writing this first reply.

Tell the user what was found and what is missing, as a short list. Then name the entry and the reason.

| Entry | Condition |
|---|---|
| **New project** | no commits, or nothing in the repository beyond a README and a LICENSE. Read `references/next-steps.md`. |
| **Existing project** | commits plus source or documents, and no governance record. Read `references/existing-project.md`. |
| **Open-source prep** | the user says the repository is going public, or the recorded visibility changes to open source. Read `references/open-source.md`. |
| **Check** | governance exists and the user wants it verified. Run steps 1 and 6 only and write nothing. Offer fixes as a plan table. |

When the `# >>> vibesop` block exists but the index does not (a fresh clone of an isolated layout), use **Existing project** and restore only the local index.

### 3. Decide

The questions of a run are the rows of the table below whose *Ask when* holds. Facts from step 1 are stated, and the user corrects them if they are wrong.

1. List the D numbers that apply to this run, followed by any question the reference of the entry tells you to ask. That list is the whole questionnaire.
2. Ask them in table order, four to a batch, with D6 moved to the end. One numbered item carries one decision, so nine items make batches of 4, 4 and 1. One message carries one batch; the next batch goes out after the answers arrive.
3. Each question carries its default and a one-line reason. The default is what an unanswered question resolves to. A row whose default is `skip` is asked like every other row.
4. Use the client's question tool when it has one, otherwise a numbered list.

Anything else that seems to need deciding, such as scaffolding, libraries or code structure, goes into the Next part of the report as a suggestion.

| # | Decision | Options, default first | Ask when |
|---|---|---|---|
| D1 | Visibility | undecided, open source, private for good | always, first |
| D2 | Instruction files | `AGENTS.md` primary with `CLAUDE.md` importing it; keep the current primary file; leave untouched | an instruction file already exists. A new project takes the first option. |
| D3 | Document language | conversation language for everything; English for public files and conversation language for process docs | D1 is not private and the conversation is not in English. Otherwise use the conversation language and show it in the plan. |
| D4 | License and copyright holder | no default | D1 is open source and there is no `LICENSE`. Offer `git config user.name` as a suggestion for the holder. |
| D5 | Done gate: the one command that must pass before a change counts as done | the candidates found in step 1 | at least one candidate exists |
| D6 | Board | kanban-hub when it is configured on this machine, none, `TASKS.md` | always, last batch |
| D7 | Remote URL | skip | the repository has no `origin` |
| D8 | Local-only notes: current stage, hard constraints, local paths of reference projects | skip | isolated layout, and `docs/_internal/LOCAL.md` does not exist yet |
| D9 | Directory for process docs | `project-docs/` | tracked layout and `docs/` is a doc-site source |
| D10 | Project name and one-line description | the directory name; no default for the description | they are in neither the README, a manifest, nor the user's messages |

D1 selects the layout. Everything else about the two layouts is in `references/doc-model.md`.

| D1 | Layout | Process docs | Git |
|---|---|---|---|
| undecided, open source | isolated | `docs/_internal/<category>/` | ignored |
| private for good | tracked | `docs/<category>/` | committed |

Default to undecided because isolating now costs one ignore rule, while removing a committed document later means rewriting history.

### 4. Plan table

Show the decisions, then one table, and wait for an explicit yes. A changed answer means an updated table and a new confirmation.

| Decision | Value | Source |
|---|---|---|
| each D number on the list of step 3 | the value this run uses | the user's answer, or the default the user left standing |

A number on the list that was never put to the user is asked now, before the table is shown.

| Path or command | Action | Note |
|---|---|---|
| each file, each git command | create, append block, convert, move, untrack, run, leave as is | source template, or why |

Three rules shape the rows for files that already exist:

- **A document stays where it is.** The index registers it at its current path. A move is a separate row, done with `git mv`, and it appears for a file the user named or a destination the user gave. Documents that would sit better elsewhere go into the report as a suggestion.
- **An instruction file keeps every line.** Conversion moves text between files without rewording it. Lines that contradict the repository go into the report.
- **Onboarding writes governance files only**: index, instruction files, ignore block, and `LICENSE` or `README` when missing. Material worth extracting from existing documents goes into the report as a suggestion.

### 5. Write

| File | Template | When | Rule |
|---|---|---|---|
| `.gitignore` | `gitignore-isolated.txt`, `gitignore-tracked.txt` | always | One block between `# >>> vibesop` and `# <<< vibesop`. Append it when it is absent. When it exists, add the lines it lacks and keep the rest. When `git ls-files .claude` prints anything, ignore `.claude/settings.local.json` in place of `.claude/`. |
| `AGENTS.md` | `AGENTS.md.template` | D2 first option | Follow `references/agents-md.md`. Every statement is a fact from step 1, a decision from step 3, or something the user stated. A section with nothing established is left out. |
| `CLAUDE.md` | `CLAUDE.md.template` | D2 first option | Its first line is `@AGENTS.md`. |
| Index | `docs-index.md.template` | always | `docs/_internal/README.md` in the isolated layout, `docs/README.md` in the tracked one. The governance record sits at its top. |
| `docs/_internal/LOCAL.md` | `LOCAL.md.template` | D8 has content | Only what belongs to this machine or this person. Agents find it through the Docs section of the instruction file. |
| `CLAUDE.local.md` | `CLAUDE.local.md.template` | `LOCAL.md` and a `CLAUDE.md` both exist once the plan is carried out. Never under the D2 option *leave untouched*. | One import line, so that Claude Code loads the notes at session start. An existing file keeps its lines and gets the line added. |
| `README.md` | `README.md.template` | none exists | |
| `LICENSE` | fetched, see `references/open-source.md` | D4 answered | |
| `TASKS.md` | `TASKS.md.template` | D6 is `TASKS.md` | Next to the index. |

- For the other two D2 options, `references/agents-md.md` says which file receives the Docs section.
- When D3 splits the language, `AGENTS.md`, `README.md` and the `.gitignore` block use the public language. The index, `LOCAL.md` and `TASKS.md` use the process-doc language.
- A category directory is created at the moment its first file is written, and the index is updated in the same step.
- A new repository gets `git init -b main` unless the user named another branch. An existing repository keeps its branch name.
- Templates use `{{NAME}}` placeholders and optional blocks between `>>> NAME` and `<<< NAME` marker lines. Fill every placeholder. Keep a block without its marker lines, or delete it with them.

### 6. Verify

Run every row that applies and read the output.

| # | Applies to | Command | Expected |
|---|---|---|---|
| V1 | isolated | `git check-ignore -v CLAUDE.local.md docs/_internal/probe.md` | two lines, each starting with `.gitignore:`. A path under the home directory or `.git/info/exclude` protects this machine only. |
| V2 | all | `git ls-files -ci --exclude-standard` | empty: no tracked file matches an ignore rule |
| V3 | isolated | `git ls-files -- docs/_internal CLAUDE.local.md` | empty |
| V4 | isolated | `git grep --untracked -nI '_internal/' -- . ':!.gitignore'` | hits only in the Docs section of `AGENTS.md` |
| V5 | all | `command grep -nE -e '\{\{[A-Z_]+\}\}' -e '>>> [A-Z_]+' -e '<<< [A-Z_]+' <each file written>` | empty |
| V6 | `AGENTS.md` primary | `command grep -n '^@AGENTS.md$' CLAUDE.md` | one line |
| V7 | all | `find <process-doc root> -type d -empty` | empty |
| V8 | all | compare the directories under the process-doc root with the index | every directory is marked as created in the index |
| V9 | all | compare each command named in `AGENTS.md` with the manifests | every command exists in the repository |
| V10 | D4 answered | `command grep -n -e '\[year\]' -e '\[fullname\]' LICENSE` | empty |
| V11 | all | `git status --short` | only rows of the confirmed plan; staged entries only from confirmed `git mv` or `git rm --cached` rows |
| V12 | `CLAUDE.local.md` and `AGENTS.md` both exist | `ls CLAUDE.md .claude/CLAUDE.md 2>/dev/null` | at least one path. With neither file, Claude Code loads `CLAUDE.local.md` and no longer reads `AGENTS.md`. |

A row that fails is fixed and re-run, or reported as failed with its output.

### 7. Deliver

Report in five parts:

1. **Done**: files written and commands run, verbatim.
2. **Skipped**: what and why.
3. **Verification**: each row with pass or fail.
4. **Left for you**: what to review; the first commit as two separate commands, `git add` followed by the paths that `git status --short` shows as modified or untracked, each written out, then `git commit -m "<type>: <summary>"`. The user makes this commit as its author, so the message is that one line and the hand-over ends there: attribution or co-author lines that a client asks an agent to add belong to commits the agent makes itself, and this is not one of them; the push command with the branch name and remote that `git branch --show-current` and `git remote -v` print; anything found that this run did not change.
5. **Next**: relevant companions that are not installed, with their install commands from `references/companions.md`; `vibesop-init-deployment` when deployable parts were detected; kanban-hub when it is not installed. On the new-project entry with no manifest detected, the route of `references/next-steps.md` comes first: requirements, then stack selection, then scaffolding, then `vibesop-init-deployment`.

## Red lines

- `git commit`, `git push` and history rewrites belong to the user.
- A file is written, moved, untracked or deleted only after its plan row is confirmed.
- Visibility, license, copyright holder and remote URL come from the user.
- `AGENTS.md` states only what was detected, decided, or stated by the user.
- Leak checks use `git grep` or `command grep`. A shell alias can make plain `grep -r` skip ignored files, which are the files being checked.
- A failed check is reported as failed.

## References

| File | Read when |
|---|---|
| `references/doc-model.md` | choosing the layout, creating or naming a process document, a worktree or doc-site question comes up |
| `references/agents-md.md` | writing or converting `AGENTS.md`, `CLAUDE.md`, `CLAUDE.local.md` or the local notes |
| `references/existing-project.md` | entry is Existing project |
| `references/next-steps.md` | entry is New project and no manifest was detected, or the user asks what comes next or how to choose a stack |
| `references/open-source.md` | entry is Open-source prep, a `LICENSE` is needed, or a leak is suspected |
| `references/companions.md` | step 1 companion detection and the Next part of the report |
| `references/glossary.md` | the conversation or the document language is Chinese |
