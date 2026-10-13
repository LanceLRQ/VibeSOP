# VibeSOP

[English](README.md) | 中文

一组项目治理的 SOP，以 Agent Skill 的形式发布。管四件事：项目的文档放在哪、哪些不公开、AI 指令文件里写什么、各套环境怎么部署。

VibeSOP 面向已经会做软件的工程师，负责把代码之外的项目事务理顺。代码本身怎么写，交给你惯用的流程框架。

## 它是什么，不是什么

| 是 | 不是 |
|---|---|
| Agent 照着执行的流程：探测、请你做选择、给出方案、写入、验证、汇报 | 代码生成器或项目脚手架 |
| 不限技术栈，新项目和老项目都能用 | 命令行工具，或一套固定的技术栈 |
| 落在你仓库里的几个纯文本文件，一分钟能看完 | 接管你工作方式的框架 |

## 包含的 skill

| Skill | 什么时候用 |
|---|---|
| [`vibesop-init-project`](skills/vibesop-init-project/SKILL.md) | 开新项目、给老项目接入治理、准备开源、检查有没有私有内容泄露 |
| [`vibesop-init-deployment`](skills/vibesop-init-deployment/SKILL.md) | 为网站项目搭建基于 Docker 的各套环境，或搭建 Docker Hub 发布加一键安装 |

两个 skill 各自独立，可以只装一个。

## 安装

```bash
npx skills add LanceLRQ/VibeSOP
```

[skills CLI](https://github.com/vercel-labs/skills) 会问你装哪几个、装给哪个客户端。常用参数：`--skill <名字>` 只装一个，`-g` 全局安装，`--list` 先看不装。

## 使用

用你自己的语言说要做什么，或者直接按名字调用：

```
帮我把这个老项目接入文档治理。
Initialize this project.
/vibesop-init-project
```

## `vibesop-init-project` 做什么

**第一个决定是可见性。** 它决定用哪种形态，两种形态只差一层目录。

| 可见性 | 过程文档 | Git |
|---|---|---|
| 开源，或还没想好 | `docs/_internal/<分类>/` | 忽略 |
| 私有且不打算开源 | `docs/<分类>/` | 入库 |

过程文档分七类：`research`、`discussion`、`specs`、`plans`、`audit`、`reference`、`ui`。初始化时只建一份索引，分类目录在写入第一个文件时才出现。

**把 `AGENTS.md` 写成工作契约。** 它告诉 Agent 一处改动该放哪、需要什么测试、怎样算完成。`CLAUDE.md` 导入它，各种工具读到的是同一份规则。老项目里它会先问你再转换，你原来写的每一行都保留。

**治理记录。** 可见性、形态、文档语言、进度看板记在索引顶部。下一次会话从这里读，部署 skill 也从这里读。

**可以反复跑的体检。** 同一组命令既验证刚做完的初始化，也检查很久以前做的：忽略规则来自仓库自己的 `.gitignore`、没有本该私有却被追踪的文件、公开文件没有指向内部文档。

**留给你做的事。** `git commit`、`git push` 和一切改写历史的操作。skill 只把命令给你。

## `vibesop-init-deployment` 做什么

它从服务清单开始：每个能独立运行的进程，连同它的构建方式、端口和数据目录。之后分批提问，动手之前先给你一张决策表。

| 路线 | 产出 |
|---|---|
| 私有项目 | 管理脚本，加每个环境一份 compose 文件。默认本地开发和生产，内网和灰度按需添加。镜像推到私有仓库，或在服务器上直接构建。 |
| 开源项目 | Docker Hub 上的公开镜像、由 tag 触发的发布流水线，以及用户一行命令就能跑的单文件安装脚本。 |

Kubernetes、Serverless 和纯静态托管不在范围内。

## 语言

- skill 正文只有一份，用英文写，方便所有人审阅。
- Agent 用你说话的语言跟你对话。
- 写进你仓库的文件用你选定的文档语言。`vibesop-init-project` 自带中文和英文两套模板。
- 已知不足：这一版里 `vibesop-init-deployment` 的脚本模板，注释和提示文字是中文。文档语言不是中文时，skill 会在生成的同时翻译它们。

## 配套工具

VibeSOP 不教 Agent 怎么写代码。`vibesop-init-project` 会查看你已经装了哪些流程类 skill，再推荐和项目相关的，每一项都写明来源仓库。进度管理方面，你在用 [kanban-hub](https://github.com/lanceLRQ/kanban-hub) 的话它会接上。

## 状态

早期版本。验收用例在 [`tests/scenarios/`](tests/scenarios/README.md)，每个用例都有中文和英文两组。欢迎反馈它在你的客户端和模型上的表现。

## 仓库结构

```
skills/
  vibesop-init-project/      SKILL.md、references/、templates/zh、templates/en
  vibesop-init-deployment/   SKILL.md、references/、templates/
tests/
  check.mjs                  结构检查
  make-fixtures.sh           生成验收用的临时仓库
  scenarios/                 验收用例
```

## 参与贡献

`node tests/check.mjs` 必须通过。本仓库按自己的 SOP 治理，约定写在 [`AGENTS.md`](AGENTS.md)。

## 许可

[MIT](LICENSE)
