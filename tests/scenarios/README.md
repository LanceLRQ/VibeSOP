# Scenarios

Each file here is one acceptance case for a skill: what the user says, how the user answers, and what must be true afterwards. They are run by hand or by a driver agent, in any client and with any model.

## Two sessions, two roles

| Role | Sees | Does |
|---|---|---|
| Subject | the fixture directory and the installed skill, nothing else | receives the user's lines and works |
| Checker | the scenario file and the fixture directory after the run | runs the checks and records the result |

The subject session never reads the scenario file. A subject that has seen the expected result is no longer a test.

## Prepare

1. Build the fixtures in a scratch directory:

   ```bash
   bash tests/make-fixtures.sh /tmp/vibesop-fixtures
   ```

2. Install the skills where the client under test finds them. A global install keeps the fixtures clean, and the `git status` checks below assume it:

   ```bash
   npx skills add /path/to/VibeSOP -g -a <agent> -y
   ```

3. If the client also has an older skill that answers to the same request, call the skill by name in the first line (`/vibesop-init-project …`) and note that in the result.

4. Start the subject session inside the fixture directory of the scenario. Use a fresh session for every scenario.

## Play the user

- Send the opening line exactly as written, in one language. The line never says which language to answer in.
- Answer only what the subject asks. Take the answer from the scenario's answer table and phrase it in the same language as the opening line.
- When the subject asks something the table does not cover, accept its default. When it offers no default, say "skip".
- When the subject shows a plan and asks for confirmation, confirm. Before confirming, list the files in the fixture: nothing may have been written yet.
- Never ask the subject to switch language. Count every reply that arrives in the wrong language.

## Checks shared by every scenario

| # | Check | Expected |
|---|---|---|
| L1 | Language of every reply, the first one included | the language of the opening line |
| L2 | Language of the files written | the document language chosen in the run |
| L3 | Times the user had to ask for a language | 0 |
| B1 | `git log --oneline` before and after | same commits: the subject made none |
| B2 | Files written before the plan was confirmed | none |
| B3 | Questions about facts the repository shows (stack, whether git exists, whether a remote exists) | none |
| B4 | Questions per batch | 4 at most |
| B5 | Final report | names what was done, what was skipped, each check with its result, what is left for the user, what comes next |

## Record

One row per run.

| Scenario | Language | Client | Model | L1 | L2 | L3 | B1–B5 | Scenario checks | Notes |
|---|---|---|---|---|---|---|---|---|---|

Write down the wording of anything that failed. A slip in the wording of a skill is fixed from the exact sentence the subject produced.

## Files

| File | Skill | Fixture |
|---|---|---|
| `01-new-project.md` | `vibesop-init-project` | `new-zh`, `new-en` |
| `02-existing-project.md` | `vibesop-init-project` | `legacy` |
| `03-open-source-prep.md` | `vibesop-init-project` | `going-public` |
| `04-check.md` | `vibesop-init-project` | the result of scenario 01 |
| `05-deployment.md` | `vibesop-init-deployment` | `deploy-zh`, `deploy-en` |
| `06-workflow-output-path.md` | `vibesop-init-project` with a workflow framework | the result of scenario 01 |
| `07-local-notes.md` | `vibesop-init-project` (part 1), none (part 2) | `agents-only`, `local-notes` |
