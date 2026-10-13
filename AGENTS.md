# VibeSOP

A set of agent skills that carry project-governance SOPs. Each skill under `skills/` is self-contained and can be installed on its own with `npx skills add`.

## Map

| Path | Responsibility |
|---|---|
| `skills/<name>/SKILL.md` | The procedure, in English. The single source of truth for that skill. |
| `skills/<name>/references/` | Detail the agent loads on demand, in English. |
| `skills/<name>/templates/` | Files that end up in a user's repository. |
| `tests/check.mjs` | Structure checks for every skill. |
| `tests/make-fixtures.sh` | Builds the throwaway repositories the scenarios run in. |
| `tests/scenarios/` | Scenario cases: what the user says and what must be true afterwards. |

## Conventions

- A skill reads only its own files. It refers to another skill by name.
- A rule is stated once. `SKILL.md` states it; a reference elaborates without repeating it.
- A skill body describes what to ask the user. It contains no sentence meant to be shown to the user as is, because the agent phrases everything in the user's language.
- A change to a template of `vibesop-init-project` is made in `templates/zh/` and `templates/en/` together.
- The script templates of `vibesop-init-deployment` were proven on running projects. A change to them comes with a run of the generated scripts.
- Wording is chosen by the kind of failure it prevents: a recipe for the shape of an output, a required slot in a template for an element that gets forgotten, a boundary statement for an action that belongs to the user.

## Tests

- `node tests/check.mjs` covers frontmatter, file references, English-only bodies and the alignment of the two template sets.
- A change to the wording of a skill is run through the scenarios in `tests/scenarios/`, in Chinese and in English, in a session without user-level instructions.

## Done

A change is done when `node tests/check.mjs` passes.

## Docs

- Public docs live in `docs/`.
- Process docs (research, discussion, specs, plans, audit, reference, ui) live in `docs/_internal/<category>/`. That directory is git-ignored: its files and their content stay out of commits, pull requests and public files.
- The index is `docs/_internal/README.md`. Read it before creating or looking for a process doc, and register new files in it.
- Specs and plans produced by workflow skills go to `docs/_internal/specs/` and `docs/_internal/plans/`, whatever path the skill uses by default.
- Local notes (current stage, hard constraints, paths on this machine) are in `docs/_internal/LOCAL.md`. When that file exists, read it before starting work.

## Language

Public files are written in English, with `README.zh.md` as the Chinese README. Process docs are written in Chinese. Reply to people in the language they write in.
