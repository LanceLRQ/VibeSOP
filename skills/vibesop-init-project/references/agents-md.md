# AGENTS.md and the instruction files

Read this when you write or convert `AGENTS.md`, `CLAUDE.md`, `CLAUDE.local.md` or the local notes.

## 1. Purpose

`AGENTS.md` is a working contract. It answers three questions: where a change goes, which tests it needs, and what makes it done. It is not a project brochure.

## 2. What each section holds

| Section | Content | Source |
|---|---|---|
| Opening sentence | What the project is and who uses it | step 1: README or manifest description, or the user's own words; D10 when none of them has it |
| Map | Existing paths and the responsibility of each. Only paths whose role the directory tree does not show | step 1 |
| Conventions | Where each kind of change goes; settled decisions with their reasons | step 1 (existing instruction files), step 3 |
| Tests | Which kind of change needs which kind of test, where tests live, how to run them | step 1 for locations and commands; step 3 for rules the user states |
| Done | The done-gate command | step 1 candidate, confirmed in D5 |
| Docs | The LAYOUT block of the template, kept as written | step 3 (D1, D9) |
| Language | The document language and the conversation language | step 3 (D3) |

Three ways to fill `{{WORKING_LANGUAGE}}`:

| Case | The sentence says |
|---|---|
| English only | Documents are written in English. Replies follow the language the person writes in, and fall back to English when that is unclear. |
| Chinese only | The same two statements for Chinese, written in Chinese. |
| Public English, process docs Chinese | Public files are written in English and process docs in Chinese. Replies follow the language the person writes in, and fall back to Chinese when that is unclear. |

Write the sentences in the document language. The fallback language is the conversation language at the time of setup. Code identifiers, commands and paths stay as written in every case.

## 3. Write what cannot be looked up

The file records reasons, boundaries and the done gate. The repository and `git log` already answer these questions, so the file leaves them out: directory trees, dependency lists, how the code works today, planned work.

## 4. State only established facts

Each sentence is a fact from step 1, a decision from step 3, or something the user stated. A new project without code gets four parts: the opening sentence, Done (the DONE_UNDEFINED block), Docs, Language. Keep the CONVENTIONS block only for decisions the user stated, such as the stack they chose. Delete the other optional blocks together with their marker lines; the headings sit inside their blocks and leave with them. The file grows as decisions land.

## 5. Pass over the layers without interviewing

Look at six layers once each: frontend, backend, data, testing, toolchain, delivery. Record the conventions that already hold. Walking the user through a design layer by layer belongs to brainstorming-style workflows.

## 6. Wording

- Say what to do and where.
- Give a completion condition.
- Point to a file instead of copying its content.
- State each fact in one place.

## 7. Choose the done gate

1. The gate is one command.
2. When several checks exist, pick the script that chains them.
3. Candidates come from script names in the manifests, Makefile targets and CI configuration.
4. When a script calls a tool that is not among the project's dependencies (example: a `lint` script calls `eslint` and `eslint` is not a dependency), say so in the D5 question and list it under Left for you in the report. The command goes into `AGENTS.md` after the user confirms.
5. With no candidate, keep the DONE_UNDEFINED block.

V9 compares every command in `AGENTS.md` with the manifests.

## 8. CLAUDE.md

The first line of `CLAUDE.md` is `@AGENTS.md`. Reason: as soon as one of `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` is present, Claude Code does not read `AGENTS.md` by itself. A sentence such as "see AGENTS.md" does not load it. The import line does. Instructions that only Claude Code needs go after the import line.

## 9. Convert existing instruction files (D2)

| D2 answer | Steps |
|---|---|
| `AGENTS.md` primary, `CLAUDE.md` imports it | Move every line of the old `CLAUDE.md` into `AGENTS.md` unchanged, under the closest matching section. Lines that fit no section go under Conventions. Add the Docs and Language sections. Replace `CLAUDE.md` with the import line. |
| Keep the current primary file | Append the Docs section to that file. No `AGENTS.md` or `CLAUDE.md` is added. |
| Leave untouched | Create the index and the ignore block only. No instruction file is written or changed, `CLAUDE.local.md` included. The report states that no instruction file points to the index or to the local notes. |

When `AGENTS.md` and `CLAUDE.md` both exist, both stay. The Docs section goes into `AGENTS.md`. When `CLAUDE.md` has no import line, "add the import line" becomes a row in the plan table for the user to confirm.

## 10. Local notes

`docs/_internal/LOCAL.md` holds what belongs to one machine or one person: the current stage, hard constraints, local paths of reference projects, intranet addresses. Project rules live in `AGENTS.md`.

The notes sit in a file that no tool owns because `CLAUDE.local.md` is read by Claude Code alone. Every agent reaches `LOCAL.md` through the line about it in the Docs section, which is the last line of the LAYOUT_ISOLATED block.

`CLAUDE.local.md` is a bridge for Claude Code. Its one line imports `docs/_internal/LOCAL.md`, which puts the notes into context at session start without the agent opening the file.

The bridge is written only next to a `CLAUDE.md`. Claude Code reads `AGENTS.md` by itself only while the repository has neither a `CLAUDE.md` nor a `CLAUDE.local.md`, so a `CLAUDE.local.md` without a `CLAUDE.md` hides `AGENTS.md` from it. V12 checks for that state, in repositories this skill did not set up as well.

When a `CLAUDE.local.md` that already exists holds notes of its own, they stay in it. The report says that only Claude Code reads them, and names `docs/_internal/LOCAL.md` as the place every agent reads.

## 11. Instruction files of other tools

`.cursor/rules/`, `GEMINI.md` and `.github/copilot-instructions.md` stay as they are. List them in the report and suggest that they point to `AGENTS.md`. The user decides.
