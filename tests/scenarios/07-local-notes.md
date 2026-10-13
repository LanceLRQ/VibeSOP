# 07 Local notes

This case tests two things: that local notes reach every agent through the Docs section of `AGENTS.md`, and that the Claude Code bridge `CLAUDE.local.md` is not written where it would hide `AGENTS.md`. Part 1 runs the skill on a repository that has no `CLAUDE.md`. Part 2 runs no skill: it takes the repository the skill leaves behind and checks that an agent finds the notes by following the one line in `AGENTS.md`.

## Part 1: no bridge without a `CLAUDE.md`

Skill: `vibesop-init-project`. Fixture: `agents-only`, a committed project whose only instruction file is `AGENTS.md`. Two runs, each in a fresh session on its own copy of the fixture.

### The user says

Chinese run:

```
帮这个仓库接入文档治理。
```

English run:

```
Bring this repository under documentation governance.
```

### Answers

| Asked about | Chinese run | English run |
|---|---|---|
| Visibility | 未定 | undecided |
| Instruction files | 保留现有主文件 | keep the current primary file |
| Document language | 公开文件用英文，过程文档用中文 | not expected to be asked |
| Done gate | 用 `npm test` | use `npm test` |
| Remote URL | 跳过 | skip |
| Board | 不用 | none |
| Local-only notes | 预发地址 http://10.20.30.40:8787；0.4 发布前只做重试队列 | Staging base URL http://10.20.30.40:8787; only the retry queue is in scope until 0.4 |
| The plan | 确认 | confirm |

### Checks

Run inside the fixture after the subject has finished.

| # | Command | Expected |
|---|---|---|
| 1 | `ls CLAUDE.md CLAUDE.local.md` | both reported as missing: no second instruction file and no bridge were created |
| 2 | Read the plan table the subject showed before confirmation | no row for `CLAUDE.md` or `CLAUDE.local.md` |
| 3 | `cat docs/_internal/LOCAL.md` | holds the address and the stage from the answers; no placeholder or marker line left |
| 4 | `command grep -n 'LOCAL.md' AGENTS.md` | one line, inside the appended Docs section |
| 5 | `git diff AGENTS.md` | added lines only; the original lines are unchanged |
| 6 | `git status --short` | ` M .gitignore` and ` M AGENTS.md`, nothing else |
| 7 | `git grep -n '10.20.30.40'` | empty: the address is in no tracked file |
| 8 | Read the governance record at the top of `docs/_internal/README.md` | Instruction files is `AGENTS.md only` (`仅 AGENTS.md` in the Chinese run) |

## Part 2: an agent follows the pointer

No skill is involved. This part tests what the skill leaves behind, in any client and with any model. Fixture: `local-notes`, which has no `CLAUDE.local.md`, so the line in `AGENTS.md` is the only route to the notes. Two runs, each in a fresh session on its own copy of the fixture. Of the shared checks in `README.md`, L1 and B1 apply here; the others describe a skill run.

### The user says

Lookup run:

- Chinese: `写一条 curl 命令，检查预发环境的健康检查接口。只回复命令。`
- English: `Write one curl command that checks the health endpoint of the staging environment. Reply with the command only.`

Constraint run:

- Chinese: `把 src/legacy/format.js 里的函数 fmt 改名为 formatAmount。`
- English: `Rename the function fmt in src/legacy/format.js to formatAmount.`

### Answers

None are expected. When the subject of the lookup run asks for the staging address, say "skip" and record the run as failed: it did not read the notes. When the subject of the constraint run asks whether to go ahead in spite of the freeze, say no.

### Checks

| # | Check | Expected |
|---|---|---|
| 1 | Reply of the lookup run | contains `http://10.20.30.40:8787/healthz` |
| 2 | Session log of the lookup run | the subject opened `docs/_internal/LOCAL.md` |
| 3 | Constraint run, `git status --short` | empty: `src/legacy/format.js` is unchanged |
| 4 | Reply of the constraint run | says that `src/legacy/` is frozen and that the rule comes from the local notes |
| 5 | Both runs, `git grep -n '10.20.30.40'` | empty: nothing from the notes was copied into a tracked file |

Record the client and the model. A failure of check 1 or 3 means the line in the Docs section of `AGENTS.md` is not enough for that client, and its wording or a mechanism native to that client is needed. A search tool that honours `.gitignore` does not find the address, which is why following the pointer is the only way to it.
