# Existing project

Read this when the entry is Existing project.

## 1. Inventory

List every document step 1 found. Use one table.

| Path | Content | Category | Committed |
|---|---|---|---|
| the file's path | one sentence, taken from the opening of the file | one of the seven categories in `references/doc-model.md` | yes or no, from `git ls-files` |

## 2. Register in place

The Documents section of the index lists each document at its current path, grouped by category. A move happens when the user asks to reorganise. Each move is its own row in the plan table and runs with `git mv`. The row states that `git mv` stages the rename.

## 3. Categories the project already has

Directories such as `docs/design/` and `docs/adr/` keep their names. The index states the correspondence, for example `docs/design/` is recorded as specs.

## 4. Process docs that are already committed

This applies when D1 is open source or undecided and a process document is in the history. Isolation covers documents written from now on. The committed ones stay in the history. Moving them into `docs/_internal/` untracks them and leaves the history unchanged. Continue with `references/open-source.md`.

## 5. Instruction files

`references/agents-md.md` describes the conversion (D2).

## 6. Contradictions

An instruction file can say something the repository contradicts. Examples: a convention names a directory that does not exist; a document lists an endpoint that the code lacks. List each one under Left for you in the report. The file content stays as it is.

## 7. Fresh clone

The `.gitignore` holds the managed block and the index is missing. Rebuild the local index only:

1. Layout: isolated, judged from the contents of the block.
2. Visibility: ask once, between open source and undecided.
3. Document language: read it from the Language section of `AGENTS.md`.
4. Board: ask again (D6).

## 8. Rerun

A governance record exists. Its values are the defaults. The plan table contains only the items that are missing or differ from the record.

## 9. What onboarding leaves untouched

- source code
- the content of existing documents
- CI configuration
- an existing README
- branch names
- existing remotes

## 10. What onboarding produces

Onboarding produces governance files: the index, the instruction files, the ignore block, and a `LICENSE` and `README.md` when they are missing. When reading existing documents turns up a conclusion that deserves a document of its own, such as a decision recorded in meeting notes, write it into the report as a suggestion.
