# Companion tools

English | [中文](companions.zh.md)

VibeSOP governs only the work around the code; it does not teach an agent how to write code. During a run, `vibesop-init-project` detects which workflow skills are installed on the machine and recommends the ones that fit the project and are missing, each with its source repository and install command. The tables below are the full list, and can be used directly for installation.

## Workflow frameworks (pick one as the main one)

| Framework | Source | Language | Install |
|---|---|---|---|
| superpowers | `obra/superpowers` | English | through the client's plugin marketplace; Claude Code: `/plugin install superpowers@claude-plugins-official` |
| superpowers-zh | npm package `superpowers-zh`, author jnMetaCode | Chinese | `npx superpowers-zh` |
| engineering group of mattpocock/skills | `mattpocock/skills`: `tdd`, `diagnosing-bugs`, `improve-codebase-architecture`, `domain-modeling`, `code-review` | English | `npx skills add mattpocock/skills --skill <name>` |

The three overlap on test-first work, debugging and requirement clarification. Take one as the main framework and add single skills from the others only where a gap exists.

## Single skills

Install commands follow `npx skills add <owner/repo> --skill <name>`.

| Skill | Source | Purpose | Worth installing when |
|---|---|---|---|
| `grill-me` | `mattpocock/skills` | question a plan before work starts | always |
| `frontend-design` | `anthropics/skills` | visual quality of frontends | the project has a frontend |
| `ui-ux-pro-max` | `nextlevelbuilder/ui-ux-pro-max-skill` | UI/UX design reference library | the project has a frontend |
| `huashu-design` | `alchaincyf/huashu-design` | high-fidelity HTML prototypes and design review | there is a frontend and the conversation is in Chinese |
| `agent-browser` | `vercel-labs/agent-browser` | browser automation for verification | the project has a web interface |
| `humanizer` | `blader/humanizer` | remove AI writing traces from documents | the conversation is in English and public docs exist |
| `humanizer-zh` | `op7418/humanizer-zh` | remove AI writing traces from documents | the conversation is in Chinese and public docs exist |
| `git-guardrails-claude-code` | `mattpocock/skills` | block dangerous git commands with a hook | the client is Claude Code |
| `vercel-react-best-practices` | `vercel-labs/agent-skills` | React and Next.js conventions | the project uses React |
| `supabase-postgres-best-practices` | `supabase/agent-skills` | Postgres conventions | the project uses PostgreSQL |

## Code retrieval: CodeGraph

[CodeGraph](https://github.com/colbymchenry/codegraph) builds a local code knowledge graph for AI clients: tree-sitter parsing into SQLite, wired in as an MCP server. One `codegraph_explore` call returns the relevant source, call paths and blast radius, replacing file-by-file grep and Read. It runs fully local, and the index auto-syncs as files change. It covers 20+ languages and connects to Claude Code, Cursor, Codex, opencode, Gemini, Kiro, GitHub Copilot and more.

Its own 2026-08 benchmark (seven real open-source repositories) reports about 88% fewer tool calls and 62% fewer tokens, with zero file reads across all seven. The cost: responses are dense and stay resident in the context window — budget for it on long sessions in a small window.

Three install steps (run them yourself, or let the agent run them after your consent):

```bash
# 1. Install the CLI (macOS / Linux; with Node, npm i -g @colbymchenry/codegraph works too)
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
# 2. Wire up clients: detects installed clients and writes their MCP config
codegraph install
# 3. Build the index inside the project
cd your-project && codegraph init
```

When `vibesop-init-project` finds source code to search and no CodeGraph on the machine, its final report makes the offer as a question: what CodeGraph is, what it saves (one query instead of file-by-file reading), and whether to install it. On your yes, the agent runs the steps as confirmed actions and makes sure `.codegraph/` is ignored by `.gitignore`; declined or unanswered, the commands stay in the report for later. Uninstall is one command, `codegraph uninstall`.

## Progress board

[kanban-hub](https://github.com/lanceLRQ/kanban-hub) is a self-hosted progress board with a command-line tool, `kh`. When it is configured on the machine, `vibesop-init-project` asks whether to connect the repository; it is never forced, and `TASKS.md` is the fallback.

## Interaction with vibesop-init-deployment

When `vibesop-init-project` detects a Dockerfile, a compose file, a server entry point or a database dependency, or an open-source project is about to publish container images, the final report points to `vibesop-init-deployment`. Projects deploying to Kubernetes, serverless or pure static hosting get no such mention.
