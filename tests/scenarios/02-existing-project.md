# 02 Existing project

Skill: `vibesop-init-project`. Fixture: `legacy`, a private project with one commit on branch `trunk`, an `origin`, a `CLAUDE.md`, and six documents spread under `docs/`.

Before the run, save the starting point:

```bash
git status --short > /tmp/legacy-before.txt
git ls-files > /tmp/legacy-files-before.txt
```

## The user says

```
这个项目的文档越来越乱，帮我把它接入文档治理。
```

## Answers

| Asked about | Answer |
|---|---|
| Visibility | 私有，不打算开源 |
| Instruction files | 转成 AGENTS.md 为主，原来的内容不能丢 |
| Done gate | `npm test` |
| Whether to move or rename existing documents (not expected to be asked; answer only if it is) | 先不动位置 |
| Board | 不用 |
| The plan | 确认 |

## Checks

| # | Command | Expected |
|---|---|---|
| 1 | `git branch --show-current` | `trunk` |
| 2 | `git remote -v` | unchanged: `git@github.com:example/orderdesk.git` |
| 3 | `git log --oneline` | one commit, the original one |
| 4 | `git status --short` | every line starts with a space or with `??`: nothing was moved, staged or untracked |
| 5 | `git diff --stat -- docs README.md src web Dockerfile package.json` | empty: existing documents, the README and the code are untouched |
| 6 | `git status --short docs` | `?? docs/README.md` only: the index is the one new file, and no document was derived from the existing ones |
| 7 | `git ls-files` compared with `/tmp/legacy-files-before.txt` | identical |
| 8 | `head -1 CLAUDE.md` | `@AGENTS.md` |
| 9 | `command grep -cF -e '后端 Express + PostgreSQL，前端 React + Vite（web/ 目录）' -e '接口统一放 src/routes/，返回 { ok, data, error }' -e '改完跑 npm run lint && npm test' AGENTS.md` | `3`: every line of the old `CLAUDE.md` is in `AGENTS.md` word for word |
| 10 | `command grep -n 'docs/_internal' .gitignore AGENTS.md docs/README.md` | empty: this is the tracked layout |
| 11 | `git check-ignore -v CLAUDE.local.md` | a line starting with `.gitignore:` |
| 12 | Read the governance record at the top of `docs/README.md` | visibility private, layout tracked, `AGENTS.md` primary, document language Chinese, board none |
| 13 | Read the document list in `docs/README.md` | all six existing documents, each at its current path; the process documents carry a category; a public or operations document may be registered without one |
| 14 | `test -e CLAUDE.local.md; echo $?` | `1`: the tracked layout creates no `CLAUDE.local.md` |
| 15 | Read the plan table shown before confirmation | no move row |

The final report lists these under what is left for the user. The subject changes none of them:

| Finding | Why |
|---|---|
| The convention names `src/routes/`, which does not exist | instruction file contradicts the repository |
| The `lint` script calls `eslint`, which is not a dependency | a check command that cannot run |

`docs/api.md` lists `POST /api/orders`, which the code lacks. The skill does not compare documents with code, so the report may say that the file differs from the code or leave it unmentioned. In both cases the file is unchanged.

The report also mentions `vibesop-init-deployment`: the fixture has a Dockerfile and a PostgreSQL dependency.
