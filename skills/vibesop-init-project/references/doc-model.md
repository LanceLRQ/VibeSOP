# Document model

Read this when you choose the layout, create or name a process document, or meet a worktree or doc-site question.

## 1. Two layouts

D1 selects the layout. The table lists what differs between them.

| | isolated | tracked |
|---|---|---|
| Chosen when D1 is | undecided or open source | private for good |
| Process docs live in | `docs/_internal/<category>/` | `docs/<category>/`, or `<D9 directory>/<category>/` when `docs/` is a doc-site source |
| Committed | no, git-ignored | yes |
| Index | `docs/_internal/README.md` | `docs/README.md`, or `<D9 directory>/README.md` |
| Local notes (D8) | `docs/_internal/LOCAL.md`, plus a one-line `CLAUDE.local.md` for Claude Code when a `CLAUDE.md` exists | not asked, not created |
| Leak check (V1, V3, V4) | runs | not run |
| `.gitignore` template | `gitignore-isolated.txt` | `gitignore-tracked.txt` |

In `templates/<language>/AGENTS.md.template`, `{{DOCS_ROOT}}` is `docs` or the D9 directory.

## 2. Why undecided means isolated

Isolating a repository now takes one ignore rule. Once a process document is committed, taking it out of the repository later means rewriting history.

## 3. Seven categories

| Directory | Answers | Naming | Holds |
|---|---|---|---|
| `research/` | What did we look into? | `NN-topic.md` | Raw material: competitor studies, technology selection |
| `discussion/` | Why did we decide this? | `YYYY-MM-DD-topic.md` | The reasons for a decision and the options that were rejected |
| `specs/` | What are we building? | `YYYY-MM-DD-topic.md` | The settled shape of the thing |
| `plans/` | How do we deliver it? | `YYYY-MM-DD-topic.md` | Delivery plans, including milestones and phase plans |
| `audit/` | Was it done right? | `AUDIT-YYYY-MM-DD-topic.md` | Review reports and acceptance checklists |
| `reference/` | What do we look up again and again? | free | Tables consulted repeatedly: API route tables, error codes |
| `ui/` | What does it look like? | free | Prototypes, design specs, design drafts |

Telling neighbours apart:

- `discussion/` records the reason and the rejected options. `specs/` records the shape that was settled.
- A document that holds both goes to the category of its main body. The index notes the other half.

## 4. Index rules

1. Initialization creates the index under the process-doc root, and `LOCAL.md` next to it when D8 has content. Category directories come later.
2. A category directory is created when its first file is written. The same step registers the file and marks the directory as created in the index.
3. Documents that exist before onboarding are registered in the Documents section at their current paths.

## 5. Governance record

The record sits at the top of the index and has six fields. A Chinese record takes its values from `references/glossary.md`.

| Field | Values |
|---|---|
| Visibility | `open source`, `undecided`, `private` |
| Layout | `isolated`, `tracked` |
| Instruction files | `AGENTS.md primary, CLAUDE.md imports it`, `AGENTS.md only`, `CLAUDE.md primary`, `untouched` |
| Document language | a language name; when public and process docs differ, `public: English; process docs: Chinese` |
| Board | `kanban-hub`, `TASKS.md`, `none` |
| Set up | `YYYY-MM-DD` |

## 6. Output paths of other skills

| Skill | Default output | Handling |
|---|---|---|
| superpowers `brainstorming` | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` | Belongs in `specs/` |
| superpowers `writing-plans` | `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` | Belongs in `plans/` |
| mattpocock/skills `domain-modeling` | `CONTEXT.md` at the repository root and `docs/adr/` | That skill designs them as committed, shared files, so they stay in place. In the isolated layout, when the user wants them private, add ignore lines below the managed block. |

The Docs section of `AGENTS.md` already names the destination of specs and plans, so the instruction files need no further lines for these skills.

## 7. Promote a process document to a public document

Promotion is a rewrite. Write a reader-facing version as a new file under `docs/`. The process document stays where it is and stays ignored.

## 8. Three ways to ignore `.claude/`

1. **Whole directory (default).** The block contains `.claude/`.
2. **Tracked files exist.** When `git ls-files .claude` prints anything, replace `.claude/` in the block with `.claude/settings.local.json`. The tracked files stay tracked.
3. **The team shares `settings.json`.** Replace `.claude/` in the block with these two lines:

   ```
   .claude/*
   !.claude/settings.json
   ```

   A negation line cannot re-include a file whose parent directory is ignored, which is why `.claude/*` replaces `.claude/`. Step 5 keeps the lines it finds in the block, so this edit survives a later run.

## 9. Worktrees

Ignored files are absent from a new worktree. Claude Code can copy them in: it reads a `.worktreeinclude` file at the repository root (gitignore syntax) and copies the ignored files that match. After creating a worktree, confirm the copy with `ls CLAUDE.local.md docs/_internal/LOCAL.md` before relying on it.

- Copies are independent. An edit in a worktree copy does not return to the main checkout.
- `CLAUDE.local.md` and `docs/_internal/LOCAL.md` can be listed in `.worktreeinclude`. List both: the first imports the second by a relative path.
- Process documents are written to the main checkout's `docs/_internal/` by absolute path, so the main checkout stays the single source.

## 10. Backup and sync

The process documents of an isolated layout have no git history and no backup. Two routes exist: kanban-hub can sync documents that are not committed, or the user keeps them in a private repository or a cloud drive.

## 11. When `docs/` is a doc-site source

Step 1 detects this from `docs/.vitepress/`, `docusaurus.config.*`, `mkdocs.yml` or `docs/conf.py`.

- **tracked layout:** the site publishes everything under `docs/`, process documents included. Process documents go to a separate directory at the repository root, chosen in D9 (default `project-docs/`). The index is `<directory>/README.md`.
- **isolated layout:** `docs/_internal/` is not committed, so CI builds cannot see it. A local preview can render it. Exclude it in the site configuration: `srcExclude` in VitePress, `exclude_docs` in MkDocs. Docusaurus skips directories whose names start with an underscore by default.
