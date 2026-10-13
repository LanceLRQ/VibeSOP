# 04 Check

Skill: `vibesop-init-project`. Fixture: the directory left by a passing run of scenario 01. Work on a copy.

Plant a leak, then save the starting point:

```bash
git add -f docs/_internal/README.md
git status --short > /tmp/check-before.txt
```

The index of the internal docs is now tracked although an ignore rule covers it.

## The user says

Chinese run:

```
帮我检查一下这个项目的文档治理有没有问题。
```

English run:

```
Check whether the documentation governance of this project is still in order.
```

## Answers

The subject may offer to repair what it finds. Decline, so that the read-only behaviour can be checked:

| Asked about | Answer |
|---|---|
| Whether to apply the repair | 先不用 / not now |

## Checks

| # | Command | Expected |
|---|---|---|
| 1 | `git status --short` compared with `/tmp/check-before.txt` | identical: the check wrote nothing and staged nothing |
| 2 | `git log --oneline` | still no commits |

The report must contain:

| Item | Expected |
|---|---|
| The entry | the subject names this run as a check, without asking the setup questions again |
| The failing checks | the tracked file under `docs/_internal/`, reported as a failure with the command output |
| The passing checks | listed as passing, each by name |
| The repair | offered as a plan with `git rm --cached docs/_internal/README.md`, not carried out |
