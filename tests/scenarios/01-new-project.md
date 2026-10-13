# 01 New project

Skill: `vibesop-init-project`. Fixtures: `new-zh` (Chinese run), `new-en` (English run). Both are empty directories.

## The user says

Chinese run:

```
我要开一个新项目，叫课表通（kebiao），是帮培训机构排课的 Web 应用。后端 Go（chi + PostgreSQL），前端 React + Vite + TypeScript。帮我把项目初始化一下。
```

English run:

```
I'm starting a new project called Lessonboard, a web app that helps tutoring centres schedule classes. Backend is Go (chi + PostgreSQL), frontend is React + Vite + TypeScript. Please initialize the project for me.
```

## Answers

| Asked about | Chinese run | English run |
|---|---|---|
| Visibility | 开源 | open source |
| Document language | 公开文件用英文，过程文档用中文 | not expected to be asked |
| License | MIT | MIT |
| Copyright holder | 晨光工作室 | Morning Light Studio |
| Remote URL | `git@github.com:example/kebiao.git` | `git@github.com:example/lessonboard.git` |
| Board | 不用 | none |
| Local-only notes | 当前阶段：只做排课核心，暂不做支付。参考项目在 ~/code/ref-scheduler | skip |
| The plan | 确认 | confirm |

## Checks

Run inside the fixture after the subject has finished.

| # | Command | Expected |
|---|---|---|
| 1 | `git branch --show-current` | `main` |
| 2 | `git remote -v` | `origin` with the URL from the answers |
| 3 | `git log --oneline` | fails with "does not have any commits yet" |
| 4 | `ls -A` | `.git`, `.gitignore`, `AGENTS.md`, `CLAUDE.md`, `LICENSE`, `README.md`, `docs`. The Chinese run also has `CLAUDE.local.md`; the English run does not. |
| 5 | `find docs -type f` | `docs/_internal/README.md`; the Chinese run also has `docs/_internal/LOCAL.md` |
| 6 | `find docs -type d -empty` | empty |
| 7 | `head -1 CLAUDE.md` | `@AGENTS.md` |
| 8 | `git check-ignore -v CLAUDE.local.md docs/_internal/probe.md` | two lines, each starting with `.gitignore:` |
| 9 | `git ls-files -ci --exclude-standard` | empty |
| 10 | `command grep -c '^# >>> vibesop' .gitignore` | `1` |
| 11 | `command grep -rnE -e '\{\{[A-Z_]+\}\}' -e '>>> [A-Z_]+' -e '<<< [A-Z_]+' AGENTS.md CLAUDE.md README.md docs/_internal/README.md` | empty |
| 12 | `command grep '^## ' AGENTS.md` | the Done, Docs and Language sections. A Conventions section is acceptable when it holds only the stack the user named. There is no code yet, so Map and Tests are absent. |
| 13 | `wc -l < AGENTS.md` | 30 at most |
| 14 | `head -3 LICENSE` | `MIT License`, then the copyright line with the current year and the holder from the answers |
| 15 | `command grep -n -e '\[year\]' -e '\[fullname\]' LICENSE` | empty |
| 16 | Read the governance record at the top of `docs/_internal/README.md` | six fields: visibility open source, layout isolated, `AGENTS.md` primary, the document language from the answers, board none, today's date |
| 17 | Read `AGENTS.md` | no coding conventions that the user never stated, no directory marked as planned |
| 18 | Read the final report | hands over `git add` and `git commit` as two separate commands, and `git push -u origin main` |
| 19 | `command grep -n 'LOCAL.md' AGENTS.md` | one line, inside the Docs section, in both runs |

Language of the files:

| Run | `README.md`, `AGENTS.md` | `docs/_internal/README.md` |
|---|---|---|
| Chinese | English prose. The project name may appear in Chinese. | Chinese |
| English | English, and `perl -CSD -ne 'print if /\p{Han}/' README.md AGENTS.md docs/_internal/README.md` prints nothing | English |

Local notes:

| Run | `docs/_internal/LOCAL.md` | `CLAUDE.local.md` |
|---|---|---|
| Chinese | exists, written in Chinese, holds the stage and the path from the answers, no placeholder or marker line left | `cat CLAUDE.local.md` prints exactly `@docs/_internal/LOCAL.md` |
| English | absent | absent |

`git status --short` lists neither file in either run.

Companion suggestions in the report:

The checker first runs `ls ~/.claude/skills ~/.agents/skills 2>/dev/null` to see what is installed on the machine.

| Run | Expected |
|---|---|
| Both | items already installed on the machine are not recommended |
| Chinese | among the recommended items, one that has a Chinese variant is named by its Chinese package name (for example `superpowers-zh`, `humanizer-zh`) |
| English | among the recommended items, one that has a Chinese variant is named by its original name; no `-zh` name appears |
