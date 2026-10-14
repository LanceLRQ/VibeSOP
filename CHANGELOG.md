# Changelog

## Unreleased

First public release.

### Added

- `vibesop-init-project`: a next-steps route for the new-project entry (`references/next-steps.md`): requirements first, then stack selection, then scaffolding, then `vibesop-init-deployment`. A public tech-selection guide (`docs/tech-selection.md`, `docs/tech-selection.zh.md`) carries the method and the mainstream candidates per scenario, as of 2026-10.
- A frontier tier for tech selection, entered only by explicit user choice, with a toolchain/runtime risk split and a no-migration rule for running projects. CodeGraph (`colbymchenry/codegraph`) is offered for local code-graph retrieval as a suggestive question; the agent runs the install only on an explicit yes.
- `vibesop-init-project`: governance for a repository in four entries (new project, existing project, open-source prep, check). Two layouts for process docs, `AGENTS.md` as the primary instruction file, a governance record at the top of the docs index, and one list of verification commands shared by setup and check. Templates in Chinese and English.
- `vibesop-init-deployment`: Docker-based environments for web projects (local dev, production, optional intranet and gray), a private route and an open-source route with Docker Hub publishing and a one-line installer.
- `tests/check.mjs` for structure checks, `tests/make-fixtures.sh` and `tests/scenarios/` for acceptance runs in Chinese and English.

### Known gaps

- The script templates of `vibesop-init-deployment` carry Chinese comments and prompts. The skill translates them while generating when the document language is not Chinese.
- No plugin manifest yet. Install with `npx skills add LanceLRQ/VibeSOP`.
