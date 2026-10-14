# Companions

Read this when you interpret the companion detection of step 1 and when you write the Next part of the report.

## 1. Reading the detection result

Step 1 gives three things: the skills visible in this session, the names the companion lookup printed, and the two `kh` lookups.

- A companion whose name shows up in the session list or in the lookup output is installed. A directory name may carry a version suffix.
- The lookup pattern in `SKILL.md` covers the names in sections 3 to 5. A companion added to this file is added to that pattern.
- kanban-hub is configured on this machine when `command -v kh` prints a path and `~/.kanban-hub/config.yaml` exists.
- CodeGraph is installed when `command -v codegraph` prints a path.

## 2. Presentation rules

- List the items that are not installed and relate to this project.
- Choose the variant that matches the conversation language and write its own name, `superpowers-zh` in a Chinese conversation and `superpowers` in an English one.
- Give each item one sentence of purpose.
- Install commands default to the user. Phrase the item as an offer, not an order. When the user asks the agent to do the install in this conversation, run the steps as confirmed actions and report the result; a declined or unanswered offer ends there, with the commands left in the report.
- Every install command names a repository from this file. A search by name returns unrelated repositories that share the name.

## 3. Workflow frameworks

Pick one framework as the main one.

| Framework | Source | Language | Install |
|---|---|---|---|
| superpowers | `obra/superpowers` | English | Through the client's plugin marketplace; the README of `obra/superpowers` lists the command for each client. Claude Code: `/plugin install superpowers@claude-plugins-official` |
| superpowers-zh | npm package `superpowers-zh`, author jnMetaCode | Chinese | `npx superpowers-zh` |
| engineering group of mattpocock/skills | `mattpocock/skills`: `tdd`, `diagnosing-bugs`, `improve-codebase-architecture`, `domain-modeling`, `code-review` | English | `npx skills add mattpocock/skills --skill <name>` |

The frameworks overlap on test-first work, debugging and requirement clarification. Take one as the main framework and add from the others only the skills that fill a gap.

## 4. Single skills

Install commands follow `npx skills add <owner/repo> --skill <name>`. A repository that hosts one skill installs with `npx skills add <owner/repo>`.

| Skill | Source | Language | Purpose | Suggest when | Install |
|---|---|---|---|---|---|
| `grill-me` | `mattpocock/skills` | English | Question a plan before work starts | always | `npx skills add mattpocock/skills --skill grill-me` |
| `frontend-design` | `anthropics/skills` | English | Visual quality of frontends | the project has a frontend | `npx skills add anthropics/skills --skill frontend-design` |
| `ui-ux-pro-max` | `nextlevelbuilder/ui-ux-pro-max-skill` | English | UI and UX design reference library | the project has a frontend | `npx skills add nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max` |
| `huashu-design` | `alchaincyf/huashu-design` | descriptions in Chinese | High-fidelity HTML prototypes and design review | the project has a frontend and the conversation is in Chinese | `npx skills add alchaincyf/huashu-design` |
| `agent-browser` | `vercel-labs/agent-browser` | English | Browser automation for verification | the project has a web interface | `npx skills add vercel-labs/agent-browser` |
| `humanizer` | `blader/humanizer` | English | Remove AI writing traces from documents | the conversation is in English and public docs exist | `npx skills add blader/humanizer` |
| `humanizer-zh` | `op7418/humanizer-zh` | Chinese | Remove AI writing traces from documents | the conversation is in Chinese and public docs exist | `npx skills add op7418/humanizer-zh` |
| `git-guardrails-claude-code` | `mattpocock/skills` | English, Claude Code only | Block dangerous git commands with a hook | the client is Claude Code | `npx skills add mattpocock/skills --skill git-guardrails-claude-code` |
| `vercel-react-best-practices` | `vercel-labs/agent-skills` | English | React and Next.js conventions | step 1 detects React | `npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices` |
| `supabase-postgres-best-practices` | `supabase/agent-skills` | English | Postgres conventions | step 1 detects PostgreSQL | `npx skills add supabase/agent-skills --skill supabase-postgres-best-practices` |

## 5. kanban-hub

kanban-hub (https://github.com/lanceLRQ/kanban-hub) is a self-hosted progress board with a command-line tool, `kh`.

| State | Handling |
|---|---|
| Configured on this machine | D6 asks whether to connect this repository. Connecting goes through kanban-hub's own skill and registration flow, which this skill does not repeat. |
| Not installed | The Next part of the report introduces it in one sentence and gives the link. It needs its own server deployment. |
| The user does not use it | D6 offers `TASKS.md`. |

Two facts:

- kanban-hub writes `.kanban-hub/` into `.git/info/exclude` itself, so `.gitignore` stays as it is.
- It can sync documents that are not committed.

## 6. CodeGraph

CodeGraph (https://github.com/colbymchenry/codegraph) is a local code knowledge graph for coding agents: tree-sitter parsing into SQLite, exposed as an MCP server. One `codegraph_explore` call returns the relevant source with call paths and blast radius, replacing file-by-file grep and Read. It runs fully local, covers 20+ languages, and auto-syncs as files change.

| State | Handling |
|---|---|
| `command -v codegraph` prints a path | installed; do not suggest it |
| no path, and the project has source code | offer it in the Next part as a question: what it is (a local code-graph MCP tool), what it saves (one query instead of file-by-file reading; fewer tool calls and tokens), the one cost (dense responses stay resident in the context window), then ask whether to install it. Adapt the wording; do not recite this file |
| greenfield with no code yet | do not offer it; there is nothing to index |

When the user says yes to the install:

1. Show the steps below as plan rows and run them after confirmation. The user may equally choose to run them personally.
2. `codegraph install` rewrites agent MCP configs; name the clients it reports touching.
3. Run `codegraph init` in the project directory.
4. Make sure `.codegraph/` is ignored: add the line to the `# >>> vibesop` block when no existing rule catches it.
5. Report what was installed, where, and that `codegraph uninstall` reverses all of it.

```bash
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh   # or: npm i -g @colbymchenry/codegraph
codegraph install        # wires the MCP server into the agents it detects
codegraph init           # per project; builds the .codegraph/ index
```

Two facts:

- `.codegraph/` is a local index: it goes into `.gitignore` and is never committed.
- Uninstall is one command, `codegraph uninstall`.

## 7. vibesop-init-deployment

Mention `vibesop-init-deployment` under Next when step 1 finds a Dockerfile, a compose file, a server entry point or a database dependency, or when an open-source project will publish container images. A project that deploys to Kubernetes, serverless or pure static hosting gets no mention.

## 8. Skills that write documents into the repository

The section "Output paths of other skills" in `references/doc-model.md` lists where their output goes.
