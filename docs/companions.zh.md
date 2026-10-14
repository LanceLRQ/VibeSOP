# 配套工具

[English](companions.md) | 中文

VibeSOP 只管代码之外的事务,不指导 Agent 编写代码。`vibesop-init-project` 运行时会检测本机已安装的流程类 skill,在收尾报告中推荐与项目相关且尚未安装的项,每项注明来源仓库与安装命令。下表是完整的推荐清单,也可直接照此安装。

## 流程框架(选一个作为主力)

| 框架 | 来源 | 语言 | 安装 |
|---|---|---|---|
| superpowers | `obra/superpowers` | 英文 | 通过客户端插件市场安装;Claude Code:`/plugin install superpowers@claude-plugins-official` |
| superpowers-zh | npm 包 `superpowers-zh`,作者 jnMetaCode | 中文 | `npx superpowers-zh` |
| mattpocock/skills 工程组 | `mattpocock/skills`:`tdd`、`diagnosing-bugs`、`improve-codebase-architecture`、`domain-modeling`、`code-review` | 英文 | `npx skills add mattpocock/skills --skill <名字>` |

三者在测试先行、调试、需求澄清上有重叠。选一个作为主力,再按项目缺口从其余框架补单个 skill。

## 单技能

安装命令统一为 `npx skills add <owner/repo> --skill <名字>`。

| Skill | 来源 | 用途 | 何时值得装 |
|---|---|---|---|
| `grill-me` | `mattpocock/skills` | 动手前对方案提问 | 总是 |
| `frontend-design` | `anthropics/skills` | 前端视觉质量 | 项目有前端 |
| `ui-ux-pro-max` | `nextlevelbuilder/ui-ux-pro-max-skill` | UI/UX 设计参考库 | 项目有前端 |
| `huashu-design` | `alchaincyf/huashu-design` | 高保真 HTML 原型与设计评审 | 有前端且对话为中文 |
| `agent-browser` | `vercel-labs/agent-browser` | 浏览器自动化验证 | 项目有 web 界面 |
| `humanizer` | `blader/humanizer` | 去除文档的 AI 写作痕迹 | 对话为英文且有公开文档 |
| `humanizer-zh` | `op7418/humanizer-zh` | 去除文档的 AI 写作痕迹 | 对话为中文且有公开文档 |
| `git-guardrails-claude-code` | `mattpocock/skills` | 用 hook 拦截危险的 git 命令 | 客户端为 Claude Code |
| `vercel-react-best-practices` | `vercel-labs/agent-skills` | React 与 Next.js 规范 | 项目使用 React |
| `supabase-postgres-best-practices` | `supabase/agent-skills` | Postgres 规范 | 项目使用 PostgreSQL |

## 代码检索:CodeGraph

[CodeGraph](https://github.com/colbymchenry/codegraph) 为 AI 客户端构建本地代码知识图谱:tree-sitter 解析、SQLite 存储,以 MCP 服务接入。Agent 用一次 `codegraph_explore` 调用即可拿到相关源码、调用链与影响范围,替代逐文件 grep 与 Read;全程本地运行,索引随文件改动自动同步。支持 20 余种语言,可接入 Claude Code、Cursor、Codex、opencode、Gemini、Kiro、GitHub Copilot 等。

官方 2026-08 基准(7 个真实开源仓库)显示:工具调用减少约 88%,token 消耗减少约 62%,七个仓库全部零文件读取。代价是返回的载荷密集、会驻留在上下文窗口,长会话小窗口的场合需要预留预算。

安装三步(自行执行,或同意后由智能体代为执行):

```bash
# 1. 安装 CLI(macOS / Linux;已有 Node 时也可 npm i -g @colbymchenry/codegraph)
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
# 2. 接入客户端:自动检测已装的客户端并写入 MCP 配置
codegraph install
# 3. 在项目内建索引
cd your-project && codegraph init
```

`vibesop-init-project` 检测到项目有源码可检索且本机未安装时,会在收尾报告中建议式询问:CodeGraph 是什么、能省什么(一次查询代替逐文件读码),再问要不要安装。你同意后,智能体按确认过的步骤代为执行,并确认 `.codegraph/` 已被 `.gitignore` 忽略;拒绝或不予回应,命令留在报告里供日后自行执行。卸载一条命令:`codegraph uninstall`。

## 进度看板

[kanban-hub](https://github.com/lanceLRQ/kanban-hub) 是自托管的进度看板,配套命令行工具 `kh`。本机已配置时,`vibesop-init-project` 会询问是否接入仓库;未安装不强制,可退回 `TASKS.md`。

## 与 vibesop-init-deployment 的联动

`vibesop-init-project` 探测到 Dockerfile、compose 文件、服务入口或数据库依赖,或开源项目将发布容器镜像时,会在收尾报告中提示 `vibesop-init-deployment`。部署到 Kubernetes、Serverless 或纯静态托管的项目不提示。
