#!/usr/bin/env bash
# Build throwaway fixture projects for the scenario tests in tests/scenarios/.
# Usage: bash tests/make-fixtures.sh <target-dir>
set -euo pipefail

target="${1:?usage: make-fixtures.sh <target-dir>}"
mkdir -p "$target"

g() { git -C "$1" -c user.name=fixture -c user.email=fixture@example.invalid "${@:2}"; }

# --- new-zh / new-en: brand-new projects (empty directories) -----------------
mkdir -p "$target/new-zh" "$target/new-en"

# --- legacy: an existing private project with scattered, tracked docs --------
# Default branch is deliberately "trunk" and origin already exists.
d="$target/legacy"
mkdir -p "$d/docs/notes" "$d/src" "$d/web/src"
cat > "$d/package.json" <<'EOF'
{
  "name": "orderdesk",
  "private": true,
  "scripts": {
    "dev": "node src/server.js",
    "lint": "eslint .",
    "test": "node --test",
    "build": "npm --prefix web run build"
  },
  "dependencies": { "express": "^5.1.0", "pg": "^8.16.0" }
}
EOF
cat > "$d/web/package.json" <<'EOF'
{
  "name": "orderdesk-web",
  "private": true,
  "scripts": { "dev": "vite", "build": "vite build" },
  "dependencies": { "react": "^19.1.0", "react-dom": "^19.1.0" },
  "devDependencies": { "vite": "^7.1.0" }
}
EOF
printf 'import express from "express";\nconst app = express();\napp.get("/api/health", (_req, res) => res.json({ ok: true }));\napp.listen(3000);\n' > "$d/src/server.js"
printf 'import { createRoot } from "react-dom/client";\ncreateRoot(document.getElementById("root")).render(<h1>OrderDesk</h1>);\n' > "$d/web/src/main.jsx"
printf 'FROM node:22-alpine\nWORKDIR /app\nCOPY . .\nRUN npm ci && npm run build\nCMD ["node", "src/server.js"]\n' > "$d/Dockerfile"
printf 'node_modules/\ndist/\n' > "$d/.gitignore"
cat > "$d/README.md" <<'EOF'
# OrderDesk

内部订单工作台：销售录单、仓库拣货、财务对账共用一套系统。

## 启动

npm install && npm run dev
EOF
cat > "$d/CLAUDE.md" <<'EOF'
# OrderDesk

- 后端 Express + PostgreSQL，前端 React + Vite（web/ 目录）
- 接口统一放 src/routes/，返回 { ok, data, error }
- 改完跑 npm run lint && npm test
EOF
cat > "$d/docs/设计方案.md" <<'EOF'
# 订单状态机设计（定稿）

草稿 → 已提交 → 已拣货 → 已发货 → 已对账。任何状态可取消，取消后不可恢复。
EOF
cat > "$d/docs/notes/2026-08-03-会议纪要.md" <<'EOF'
# 2026-08-03 评审会

结论：对账不做自动冲销，原因是财务要求每笔人工确认。否决了“批量自动对账”方案。
EOF
cat > "$d/docs/plan.md" <<'EOF'
# 实施计划

- M1 录单与拣货（已完成）
- M2 对账（进行中）
- M3 报表
EOF
cat > "$d/docs/api.md" <<'EOF'
# 接口速查

GET /api/health  健康检查
POST /api/orders 创建订单
EOF
cat > "$d/docs/deploy.md" <<'EOF'
# 部署说明

服务器上 docker build 后直接 docker run，端口 3000。
EOF
cat > "$d/docs/竞品调研.md" <<'EOF'
# 竞品调研

对比了三款进销存产品的对账流程，原始笔记见下。
EOF
git init -q -b trunk "$d"
g "$d" remote add origin git@github.com:example/orderdesk.git
g "$d" add -A
g "$d" commit -q -m "chore: import project"

# --- going-public: private files were committed before being ignored ---------
d="$target/going-public"
mkdir -p "$d/docs/_internal/discussion" "$d/cmd/tapekit"
printf 'module example.com/tapekit\n\ngo 1.25\n' > "$d/go.mod"
printf 'package main\n\nfunc main() {}\n' > "$d/cmd/tapekit/main.go"
cat > "$d/README.md" <<'EOF'
# tapekit

Index and browse LTO tape archives without loading the tapes.

See the [design notes](docs/_internal/discussion/2026-07-01-decisions.md) for background.
EOF
cat > "$d/CLAUDE.md" <<'EOF'
# tapekit

Go CLI. Run `go test ./...` before finishing a change.
EOF
cat > "$d/CLAUDE.local.md" <<'EOF'
# Local notes

Staging box: ssh ops@10.20.30.40 (internal only)
EOF
cat > "$d/docs/_internal/discussion/2026-07-01-decisions.md" <<'EOF'
# Decisions

Vendor quote from Acme Storage is confidential: USD 48k per library.
EOF
git init -q -b main "$d"
g "$d" add -A
# A machine-wide ignore file may already exclude these; force them in so the
# fixture reproduces the leak everywhere.
g "$d" add -f CLAUDE.local.md docs/_internal
g "$d" commit -q -m "feat: initial import"
printf 'docs/_internal/\nCLAUDE.local.md\n' > "$d/.gitignore"
g "$d" add .gitignore
g "$d" commit -q -m "chore: ignore internal docs"

# --- deploy-zh / deploy-en: copies of legacy for the deployment scenario --------
cp -R "$target/legacy" "$target/deploy-zh"
cp -R "$target/legacy" "$target/deploy-en"

# --- agents-only: a committed project whose only instruction file is AGENTS.md --
d="$target/agents-only"
mkdir -p "$d/src"
cat > "$d/package.json" <<'EOF'
{
  "name": "hookrelay",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
EOF
cat > "$d/src/relay.js" <<'EOF'
export function relay(event, queues) {
  const queue = queues[event.source];
  if (!queue) throw new Error(`no queue for source ${event.source}`);
  return queue.push(event.payload);
}
EOF
cat > "$d/README.md" <<'EOF'
# hookrelay

Forwards incoming webhooks to internal queues.
EOF
printf 'node_modules/\n' > "$d/.gitignore"
cat > "$d/AGENTS.md" <<'EOF'
# hookrelay

Forwards incoming webhooks to internal queues.

- Handlers live in `src/`, one file per source system.
- Run `npm test` before finishing a change.
EOF
git init -q -b main "$d"
g "$d" add -A
g "$d" commit -q -m "chore: import project"

# --- local-notes: agents-only after governance was set up (isolated layout) -----
# The Docs section and the ignore block are read from the English templates, so
# the fixture always carries their current wording. There is no CLAUDE.local.md:
# the line in AGENTS.md is the only route to the notes.
tpl="$(cd "$(dirname "$0")" && pwd)/../skills/vibesop-init-project/templates/en"
cp -R "$target/agents-only" "$target/local-notes"
d="$target/local-notes"
mkdir -p "$d/src/legacy"
printf 'export const healthPath = "/healthz";\n' > "$d/src/health.js"
printf 'export function fmt(cents) { return (cents / 100).toFixed(2); }\n' > "$d/src/legacy/format.js"
{
  cat <<'EOF'
# hookrelay

Forwards incoming webhooks to internal queues.

## Conventions

- Handlers live in `src/`, one file per source system.
- Run `npm test` before finishing a change.

## Done

A change is done when `npm test` passes.

## Docs

EOF
  awk '/<<< LAYOUT_ISOLATED/{f=0} f{print} />>> LAYOUT_ISOLATED/{f=1}' "$tpl/AGENTS.md.template"
  cat <<'EOF'

## Language

Documents are written in English. Replies follow the language the person writes in, and fall back to English when that is unclear.
EOF
} > "$d/AGENTS.md"
grep -q 'LOCAL.md' "$d/AGENTS.md" || { echo "no LAYOUT_ISOLATED block in $tpl/AGENTS.md.template" >&2; exit 1; }
printf '@AGENTS.md\n' > "$d/CLAUDE.md"
{ printf 'node_modules/\n\n'; cat "$tpl/gitignore-isolated.txt"; } > "$d/.gitignore"
g "$d" add -A
g "$d" commit -q -m "chore: set up governance"
# Ignored files: they exist on disk only, as they would after a real setup.
mkdir -p "$d/docs/_internal"
cat > "$d/docs/_internal/README.md" <<'EOF'
# hookrelay internal docs

## Governance record

| Item | Value |
|---|---|
| Visibility | undecided |
| Layout | isolated |
| Instruction files | AGENTS.md primary, CLAUDE.md imports it |
| Document language | English |
| Board | none |
| Set up | 2026-09-01 |
EOF
cat > "$d/docs/_internal/LOCAL.md" <<'EOF'
# Local notes

This file is git-ignored. It holds what belongs to this machine or this person. Project rules live in `AGENTS.md`.

## Current stage and constraints

- Stage: only the retry queue is in scope until the 0.4 release.
- Hard constraint: `src/legacy/` is frozen. Decline any change to it and say so.

## Local paths

- Staging base URL: http://10.20.30.40:8787
EOF

echo "fixtures ready in $target: new-zh new-en legacy going-public deploy-zh deploy-en agents-only local-notes"
