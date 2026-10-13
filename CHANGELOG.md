# Changelog

## Unreleased

First public release.

### Added

- `vibesop-init-project`: governance for a repository in four entries (new project, existing project, open-source prep, check). Two layouts for process docs, `AGENTS.md` as the primary instruction file, a governance record at the top of the docs index, and one list of verification commands shared by setup and check. Templates in Chinese and English.
- `vibesop-init-deployment`: Docker-based environments for web projects (local dev, production, optional intranet and gray), a private route and an open-source route with Docker Hub publishing and a one-line installer.
- `tests/check.mjs` for structure checks, `tests/make-fixtures.sh` and `tests/scenarios/` for acceptance runs in Chinese and English.

### Known gaps

- The script templates of `vibesop-init-deployment` carry Chinese comments and prompts. The skill translates them while generating when the document language is not Chinese.
- No plugin manifest yet. Install with `npx skills add LanceLRQ/VibeSOP`.
