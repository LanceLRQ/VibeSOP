# Open-source preparation

Read this when the entry is Open-source prep, a `LICENSE` is needed, or a leak is suspected.

## 1. Order

1. Look for private content (section 2).
2. Show the plan table.
3. Repair the working tree (section 3).
4. Handle the history. The user decides and runs it (section 4).
5. Add `LICENSE` and `README.md` (sections 6 and 7).
6. Set the Visibility field of the governance record to open source.
7. Write the conclusion line (section 8).

## 2. Look for private content

| Find | Command | Expected |
|---|---|---|
| Tracked files that match an ignore rule | `git ls-files -ci --exclude-standard` | empty |
| Private paths that are tracked | `git ls-files -- docs/_internal CLAUDE.local.md .claude` | empty |
| Private paths that were ever committed | `git log --all --oneline -- docs/_internal CLAUDE.local.md .claude` | empty |
| Where the ignore rules come from | `git check-ignore -v CLAUDE.local.md docs/_internal/probe.md` | two lines, each starting with `.gitignore:` |
| Public files that point to internal docs | `git grep -nI '_internal/' -- . ':!.gitignore'` | hits only in the Docs section of `AGENTS.md` (V4) |
| Other refs | `git tag -l`, `git stash list`, `git branch -a` | a list; each ref keeps its commits alive, so section 4 covers them |

Sensitive strings in tracked files. Start with this list and add the words the user names (customer names, host names, price quotes):

```
git grep -nIi -E \
  -e 'password' \
  -e 'secret' \
  -e 'token' \
  -e 'api[_-]?key' \
  -e 'BEGIN [A-Z ]*PRIVATE KEY' \
  -e '10\.[0-9]+\.[0-9]+\.[0-9]+' \
  -e '172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+' \
  -e '192\.168\.[0-9]+\.[0-9]+'
```

The patterns stand for password, secret, token, API key, private-key header and the three private IPv4 ranges. Go through every hit with the user: each one is either explained or fixed.

Sensitive strings in the history. Run the same command with `$(git rev-list --all)` as the last argument. When the shell reports that the argument list is too long, search with `git log --all --oneline -S '<term>'` once per term.

Leak checks use `git grep` or `command grep`. A shell alias can make a plain `grep -r` skip ignored files, which are the files being checked.

## 3. Repair the working tree

Each of these is a row in the plan table:

- `git rm --cached <path>` untracks a path. Use `-r` for a directory. The file stays on disk and the deletion is staged. The row says so.
- Remove links to internal documents from the README and other public files.
- Add the ignore block (step 5 of `SKILL.md`).

## 4. History

A single commit that holds private content makes the repository not ready to publish. The verdict stays "no" until the user picks and runs one of two routes.

| Route | How | Consequence |
|---|---|---|
| Fresh history | Publish from a new orphan branch or a new repository with one initial commit | All commit records are lost |
| Remove the paths | `git filter-repo --invert-paths --path <path>` | The commit sequence stays and every commit hash changes. The tool is installed separately. |

Both routes share three facts:

- The user takes a backup first.
- Existing clones, forks and backups still hold the old history.
- Every secret that was ever pushed gets rotated.

The user runs these commands. This skill supplies the commands and the consequences.

## 5. From tracked to isolated

Process documents under `docs/<category>/` are already in the history. Ask first whether they can be public. When the answer is yes, they stay where they are as public docs. When the answer is no, section 4 applies.

## 6. LICENSE

The text comes from the GitHub licenses API: `https://api.github.com/licenses/<key>`. The JSON field `body` holds it. Two ways to extract it:

```
curl -fsSL https://api.github.com/licenses/<key> | jq -r .body > LICENSE
curl -fsSL https://api.github.com/licenses/<key> | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>process.stdout.write(JSON.parse(s).body))' > LICENSE
```

Common keys: `mit`, `apache-2.0`, `gpl-3.0`, `agpl-3.0`, `bsd-3-clause`, `bsd-2-clause`, `mpl-2.0`, `unlicense`.

- The MIT and BSD texts contain `[year]` and `[fullname]`. Replace them with the current year and the copyright holder the user confirmed in D4. V10 checks this.
- Every other license text is used as fetched.
- Read the first lines of `LICENSE` after the command. An empty file means the fetch failed. Remove the file, put the row under Left for you, and give `https://choosealicense.com/licenses/<key>/`.
- The license text always comes from the fetch.

## 7. README check

1. The file exists.
2. It says what the project is.
3. It contains no link to internal documents.
4. It has a License section.

## 8. Conclusion line

Write `Ready to publish: yes` or `Ready to publish: no`, followed by the blockers. Write the line in the conversation language.

## 9. Global ignore files

A personal global ignore file and `.git/info/exclude` take effect on this machine only. People who clone the repository get no protection from them. The rules belong in the repository's own `.gitignore`.
