# 03 Open-source prep

Skill: `vibesop-init-project`. Fixture: `going-public`, a small Go project with two commits. `CLAUDE.local.md` and `docs/_internal/discussion/2026-07-01-decisions.md` were committed before the ignore rules were added, so they are tracked and in the history. The README links to the internal document. There is no `LICENSE`.

## The user says

```
We're about to make this repository public. Can you get it ready?
```

A Chinese run uses the same fixture:

```
这个仓库准备公开了，帮我做一下开源前的准备。
```

## Answers

| Asked about | Answer |
|---|---|
| License | MIT |
| Copyright holder | Example Labs |
| May the internal documents and `CLAUDE.local.md` be public | no |
| Rewriting the history | explain the options, I will run it myself |
| Remote URL | skip |
| Board | none |
| The plan | confirm |

## Checks

| # | Command | Expected |
|---|---|---|
| 1 | `git ls-files -- docs/_internal CLAUDE.local.md` | empty: both are untracked now |
| 2 | `test -f CLAUDE.local.md && test -f docs/_internal/discussion/2026-07-01-decisions.md; echo $?` | `0`: both are still on disk |
| 3 | `command grep -n '_internal' README.md` | empty: the link is gone |
| 4 | `head -3 LICENSE` | `MIT License`, then `Copyright (c) <current year> Example Labs` |
| 5 | `git log --oneline` | the two original commits: nothing committed, nothing rewritten |
| 6 | `git log --all --oneline -- CLAUDE.local.md docs/_internal` | still lists commits: the history was left alone |
| 7 | `git status --short` | staged deletions for the two private files only; `LICENSE`, `README.md` and the index are unstaged or untracked |
| 8 | `test -f docs/_internal/README.md; echo $?` | `0`: the local index exists |
| 9 | Read the index | visibility open source, layout isolated; `discussion/` marked as created; the existing decision document is listed |

The final report must contain:

| Item | Expected |
|---|---|
| The findings | both tracked private files, the fact that they are in the history, the README link, the missing license |
| The verdict | not ready to publish, with the history as the blocker |
| The two routes | a fresh history and a path removal with `git filter-repo`, each with its consequence, as commands for the user to run |
| The warning | existing clones and backups keep the old history |
