# Client compatibility and known issues

English | [中文](compatibility.zh.md)

## Supported clients

Any client that supports the [Agent Skills](https://agentskills.io) specification can install VibeSOP, which covers the clients supported by the [skills CLI](https://github.com/vercel-labs/skills). Installation is described in the [README](../README.md#install).

## How acceptance was run

The acceptance cases are in [`tests/scenarios/`](../tests/scenarios/README.md), each in Chinese and English. The session under test sees only a throwaway repository and the installed skill, never the case file; a checker goes through the checklist afterwards. Shared checks cover: the language of every reply, the language of written files, whether the session committed on its own, whether anything was written before the plan was confirmed, whether the session asked questions the repository itself answers, questions per batch, and whether the final report was honest.

## Results

| Client / model | Result |
|---|---|
| Claude Code 2.1.296 / claude-sonnet-5-5 | passed, across three regression rounds |
| Codex CLI / gpt-6-astra | passed |
| ZCode / GLM-5.3 | procedure passed; the open-source-prep entry does not trigger on its own, see below |

## Known issues

### The open-source-prep entry does not trigger on some clients

Symptom: when the user says the repository is going public, the skill is not loaded and the model acts on its own. On ZCode, 30 measured runs all failed to trigger, across both GLM-5.3 and GLM-5.3-Flash; without the skill, the model wrote files, committed without being asked, and rewrote git history.

Cause: the skill list ZCode hands to the model carries names only, no descriptions. The model judges by name, "ready to go public" does not match `init-project`, and the skill is skipped. This is about how the client presents the skill list, not about the skill's description — rewriting the description was tested and changed nothing. Claude Code and Codex pass descriptions to the model and are unaffected.

Workaround: on such a client, call the skill by name in the first message: `/vibesop-init-project`.

### Deployment script templates are in Chinese

In this release the script templates of `vibesop-init-deployment` carry Chinese comments and prompts. For any other document language the skill translates them while generating; commands and variable names stay unchanged.

### No plugin manifest yet

There is no plugin manifest; the way to install is `npx skills add LanceLRQ/VibeSOP`.

## Feedback

Reports of runs on other clients and models are welcome as issues, with the client version, the model, and the scenario number.
