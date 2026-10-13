# Glossary

Read this when the conversation or the document language is Chinese. Use the Chinese term in the second column for each English concept, so one concept keeps one name.

## Concepts

| English | 中文 | Notes |
|---|---|---|
| governance | 治理 | Where documents live, which of them are public, what the instruction files say, and the record of those choices |
| governance record | 治理记录 | The table at the top of the index |
| index | 文档索引 | The `README.md` at the root of the process-doc directory |
| process docs | 过程文档 | Documents in the seven categories: research, discussion, specs, plans, audit, reference, ui |
| public docs | 公开文档 | Documents that readers of the project see, such as those under `docs/` |
| isolated layout | 隔离形态 | Process docs in `docs/_internal/`, git-ignored |
| tracked layout | 入库形态 | Process docs committed with the code |
| visibility | 可见性 | D1 |
| open source / undecided / private | 开源 / 未定 / 私有 | The values of D1 and of the Visibility field. The D1 option "private for good" reads 私有（不打算开源）. |
| instruction files | 指令文件 | `AGENTS.md`, `CLAUDE.md`, `CLAUDE.local.md` |
| plan table | 方案表 | The table of step 4 |
| done gate | 完成门槛 | D5: the one command that must pass |
| board | 进度看板 | D6 |
| leak check | 泄露复查 | V1, V3 and V4, and the lookup in `references/open-source.md` |
| managed block | 托管区块 | The block between `# >>> vibesop` and `# <<< vibesop` in `.gitignore` |
| copyright holder | 版权持有者 | D4 |
| document language | 文档语言 | D3 |
| local-only notes | 本机备注 | D8 |
| companions | 配套工具 | Skills and tools listed in `references/companions.md` |
| entry | 入口 | The route a run takes |
| New project / Existing project / Open-source prep / Check | 新项目 / 老项目接入 / 开源准备 / 体检 | The four entries |
| Done / Skipped / Verification / Left for you / Next | 已完成 / 已跳过 / 验证 / 留给你 / 下一步 | The five parts of the report |
| research / discussion / specs / plans / audit / reference / ui | 调研 / 讨论 / 规格 / 计划 / 审查 / 参考 / 界面 | Prose only. Directory names stay in English. |
| isolated / tracked | 隔离 / 入库 | Values of the Layout field |
| AGENTS.md primary, CLAUDE.md imports it | AGENTS.md 为主，CLAUDE.md 导入 | A value of the Instruction files field |
| AGENTS.md only | 仅 AGENTS.md | A value of the Instruction files field |
| CLAUDE.md primary / untouched | CLAUDE.md 为主 / 未改动 | Values of the Instruction files field |
| none | 无 | A value of the Board field |
| public: English; process docs: Chinese | 公开文档：英文；过程文档：中文 | A value of the Document language field |
| Ready to publish: yes / no | 可以公开：是 / 否 | The conclusion line of Open-source prep |
| project name and one-line description | 项目名与一句话简介 | D10 |

## Template headings and record fields

The Chinese templates use these.

| English | 中文 | Notes |
|---|---|---|
| Map | 路径职责 | Section of `AGENTS.md` |
| Conventions | 约定 | Section of `AGENTS.md` |
| Tests | 测试 | Section of `AGENTS.md` |
| Done | 完成标准 | Section of `AGENTS.md`. The report part and the board column are both 已完成. |
| Docs | 文档 | Section of `AGENTS.md` |
| Language | 语言 | Section of `AGENTS.md` |
| Governance record | 治理记录 | Section of the index |
| Categories | 分类 | Section of the index |
| Documents | 现有文档 | Section of the index |
| Local notes | 本机备注 | Title of `docs/_internal/LOCAL.md` |
| Current stage and constraints | 当前阶段与约束 | Section of `docs/_internal/LOCAL.md` |
| Local paths | 本机路径 | Section of `docs/_internal/LOCAL.md` |
| Status | 状态 | Section of the README |
| License | 许可 | Section of the README |
| Tasks / In progress / Next / Done | 任务 / 进行中 / 待办 / 已完成 | Title and columns of `TASKS.md` |
| Layout | 形态 | Governance record field |
| Set up | 接入日期 | Governance record field |
