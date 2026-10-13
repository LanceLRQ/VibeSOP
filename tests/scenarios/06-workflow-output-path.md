# 06 Output path of a workflow skill

This case tests one assumption of the document model: a rule in `AGENTS.md` is enough to make a workflow skill write its spec into the process-doc directory instead of its own default path.

Skill: `vibesop-init-project` plus a workflow framework that writes specs (superpowers, or its Chinese edition). Fixture: the directory left by a passing run of scenario 01. Work on a copy, in a fresh session.

## The user says

Chinese run:

```
我想加一个功能：老师可以把某一周的课表导出成 PDF。先帮我把需求和设计想清楚，写成规格文档。
```

English run:

```
I want to add a feature: a teacher can export one week of the timetable as a PDF. Help me think the requirements and the design through, and write it up as a spec.
```

## Answers

Answer the framework's questions briefly, in the language of the opening line. When it proposes a design, accept it. When it asks whether to commit the spec, say no.

## Checks

| # | Command | Expected |
|---|---|---|
| 1 | `find docs -name '*.md' -newer AGENTS.md` | the new spec is under `docs/_internal/specs/` |
| 2 | `test -e docs/superpowers; echo $?` | `1`: the framework's default directory was not created |
| 3 | `git status --short` | the spec does not appear: it is ignored |
| 4 | Read `docs/_internal/README.md` | `specs/` is marked as created and the new file is listed |

Record which framework and version ran. A failure here means the rule in the Docs section of `AGENTS.md` needs stronger wording, or the framework needs its own configuration.
