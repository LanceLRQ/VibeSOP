# 05 Deployment

Skill: `vibesop-init-deployment`. Fixtures: `deploy-zh` (Chinese run), `deploy-en` (English run). Both are copies of `legacy`: an Express backend with PostgreSQL, a React and Vite frontend under `web/`, a Dockerfile, no governance record.

## The user says

Chinese run:

```
帮这个项目把部署环境搭起来。
```

English run:

```
Set up the deployment environments for this project.
```

## Answers

Take the recommended default for every question. Where the subject gives no default:

| Asked about | Chinese run | English run |
|---|---|---|
| Release route | 私有项目 | private project |
| Environments | 本地开发 + 生产 | local dev + production |
| How images reach the server | 在服务器上克隆仓库直接构建 | clone the repository on the server and build there |
| Deploy account | 已加入 docker 组的普通用户 | a regular user in the docker group |
| Existing HTTP entry on the server | 没有 | none |
| The service inventory, the decision table | 确认 | confirm |

## Checks

Replace `<deploy>` and `<scripts>` with the directories the run chose (the defaults are `deploy` and `scripts`).

| # | Command | Expected |
|---|---|---|
| 1 | `git log --oneline` | one commit, the original one |
| 2 | `ls <scripts>` | a dev script and a production script |
| 3 | the loop under this table | no `FAIL` line |
| 4 | `command grep -rnE '\{\{[A-Z_]+\}\}' <deploy> <scripts>` | empty |
| 5 | `command grep -rnE -e '^# >>> [A-Z_]+' -e '^# <<< [A-Z_]+' <deploy> <scripts>` | empty: optional blocks were kept or removed together with their markers |
| 6 | `test -f <deploy>/README.md; echo $?` | `0`: the decision table is written down |
| 7 | `git check-ignore -v .env` | a line naming an ignore rule |
| 8 | `git status --short` | only new and modified files; nothing staged |

```bash
for f in <scripts>/*.sh; do bash -n "$f" || echo "FAIL $f"; done
```

Process, read from the conversation:

| Item | Expected |
|---|---|
| The service inventory | shown as a table and confirmed before any question |
| The first question after that | the release route, asked alone |
| The questions | in batches of four at most, each with a recommended default and a reason |
| The decision table | shown and confirmed before any file is written; skipped modules are named with the reason |
| The hand-over | lists what the user must do: fill `.env`, prepare the server, set up the proxy or domain |
| Never done | `docker push`, a login to a server, `git commit`, `git push` |

Language of the generated files:

| Run | Expected |
|---|---|
| Chinese | comments, prompts and `<deploy>/README.md` in Chinese |
| English | `perl -CSD -ne 'print "$ARGV:$.: $_" if /\p{Han}/' <scripts>/*.sh <deploy>/README.md` prints nothing. The templates carry Chinese text; the skill translates it while generating. |
