# VibeSOP

[English](README.md) | 中文

VibeSOP 是一组项目治理 SOP,以 Agent Skill 的形式发布,覆盖代码之外的四个方面:项目文档的组织与存放、公开与私有内容的隔离、AI 指令文件的内容,以及各套环境的部署。它不依赖特定技术栈,新建与存量仓库均适用;写入仓库的产物全部是纯文本文件,可以直接审阅。

VibeSOP 面向具备软件开发经验的工程师,职责是把代码之外的项目事务纳入统一治理;代码本身如何编写,仍由你惯用的流程框架决定。

## 适用场景

| 场景 | Skill |
|---|---|
| 新建项目,从第一个提交起建立文档与治理规范 | `vibesop-init-project` |
| 存量仓库接入治理:文档分区、AI 指令文件、避免每次会话重复交代背景 | `vibesop-init-project` |
| 仓库准备公开:隔离私有内容、补充 LICENSE、检查泄露 | `vibesop-init-project` |
| 对已治理的仓库做定期检查,确认没有私有内容被追踪 | `vibesop-init-project` |
| 为网站项目搭建 Docker 环境,或增加灰度、内网环境 | `vibesop-init-deployment` |
| 部署文件分散,需要收敛为统一的结构与脚本 | `vibesop-init-deployment` |
| 开源项目发布镜像,提供一行命令的安装方式 | `vibesop-init-deployment` |

## 安装

前提条件:Node.js(npx 可用),以及一个支持 Agent Skills 的客户端。

```bash
npx skills add LanceLRQ/VibeSOP
```

[skills CLI](https://github.com/vercel-labs/skills) 会询问安装哪些 skill 以及目标客户端。默认安装至当前项目,随仓库提交、团队共用;加 `-g` 则安装至用户目录,所有项目可用。安装完成后新开会话即可生效。

| 参数 | 作用 |
|---|---|
| `--skill <名字>` | 仅安装指定的 skill,可重复传入;`--skill '*'` 安装全部 |
| `-g` | 全局安装 |
| `-a <客户端>` | 指定目标客户端,如 `-a claude-code`、`-a zcode`、`-a codex` |
| `--list` | 仅查看仓库中有哪些 skill,不安装 |
| `-y` | 跳过确认 |

安装后可通过 `npx skills list` 确认,通过 `npx skills remove` 卸载。两个 skill 相互独立,可单独安装。

### 由 AI 代为安装

将下面这段文本原样发送给你的 AI 客户端,即可由其完成安装:

```text
请为我安装 VibeSOP 的两个治理 skill:
1. 先确认本机正在使用的 AI 客户端(claude-code、zcode、codex 等),然后运行
   npx skills add LanceLRQ/VibeSOP --skill vibesop-init-project --skill vibesop-init-deployment -g -a <客户端> -y
2. 运行 npx skills list -g,确认两个 skill 均已安装,并告知安装路径。
仅执行安装,不要运行这两个 skill 本身。
```

## 使用

用你惯用的语言描述需求,或直接按名称调用:

```
帮我把这个老项目接入文档治理。
Initialize this project.
/vibesop-init-project
```

按名称调用最为可靠:部分客户端只向模型提供 skill 名称,自然触发可能失败,详见[客户端兼容性与已知问题](docs/compatibility.zh.md)。这两个 skill 所做的是仓库级决定,建议使用客户端中能力最强的模型运行。

## 两个 skill

### `vibesop-init-project`:项目治理

为仓库建立文档分区、`AGENTS.md` 工作契约、治理记录,以及一组可重复执行的检查命令。支持四个入口:新项目、存量项目、开源准备、检查。可见性是首先确定的决策:过程文档放在被忽略的 `docs/_internal/`,或入库的 `docs/`,两种形态仅相差一层目录。

详细说明:[`docs/vibesop-init-project.zh.md`](docs/vibesop-init-project.zh.md) · 流程原文:[`skills/vibesop-init-project/SKILL.md`](skills/vibesop-init-project/SKILL.md)

### `vibesop-init-deployment`:部署环境

面向包含服务进程的网站项目。从服务清单入手,分批确认所需环境与镜像仓库,生成本地开发、生产(以及按需的灰度、内网)各套 Docker compose 环境与管理脚本;开源项目可走 Docker Hub 发布与一行命令安装的路线。

详细说明:[`docs/vibesop-init-deployment.zh.md`](docs/vibesop-init-deployment.zh.md) · 流程原文:[`skills/vibesop-init-deployment/SKILL.md`](skills/vibesop-init-deployment/SKILL.md)

## 理念

两个 skill 遵循同一套工作方式:先探测,再提问,给出方案,经确认后写入,用命令验证,如实汇报。能从仓库读取的事实不向用户提问,只问选择;问题分批提出,每批至多四项,每项附带默认值与一句理由;方案表获得确认之前,不写入任何文件。

以下红线约束 Agent 的行为:

- `git commit`、`git push` 以及一切改写历史的操作由用户执行,skill 仅准备好命令
- 未经询问的值不写入磁盘,不存在静默决定
- 密码、密钥、token 只进入被忽略的文件,入库的仅有 `*.example` 模板
- 部署 skill 到生成文件为止:不执行 `docker push`,不登录服务器,不触碰线上环境

代码的编写方式不在管辖范围内。选型、脚手架等事项,它会推荐已安装的流程类 skill 接手,每项注明来源仓库,完整清单见[配套工具](docs/companions.zh.md)。

## 边界与不适用场景

| 场景 | 原因 |
|---|---|
| 编写代码、技术选型、搭建脚手架 | 仅治理代码之外的事务,代码编写交由流程框架 |
| Kubernetes、Serverless、纯静态托管 | 部署 skill 仅覆盖基于 Docker compose 的部署方式,遇到时会明确说明不在范围内 |
| 无人值守运行,或集成至 CI | 每项决定均需用户确认,它不是自动化脚本 |
| 期望其代为提交、推送 | git 操作刻意保留给用户,skill 仅准备命令 |

## 相关文档

| 文档 | 内容 |
|---|---|
| [客户端兼容性与已知问题](docs/compatibility.zh.md) | 各客户端验收结果;「开源准备」入口不触发的问题、原因与绕过方式 |
| [配套工具](docs/companions.zh.md) | 建议搭配使用的第三方 skill 与流程框架清单,附来源与安装命令 |
| [技术选型指南](docs/tech-selection.zh.md) | 从需求到技术栈的路径、按场景的主流候选(截至 2026-10)与决策记录方法 |
| [vibesop-init-project 详解](docs/vibesop-init-project.zh.md) | 四个入口、决策清单、文档模型、指令文件、检查命令 |
| [vibesop-init-deployment 详解](docs/vibesop-init-deployment.zh.md) | 服务清单、环境模型、发布路线、验证与常见错误 |

## 语言

- skill 正文仅一份,以英文编写,便于所有人审阅。
- Agent 以用户所用语言对话;对话语言与文件语言均经验证无漂移。
- 写入仓库的文件采用所选的文档语言,`vibesop-init-project` 内置中文与英文两套模板。
- 本仓库的公开文档中英各一份,`README.zh.md` 为中文版,其余见 `docs/`。

## 仓库结构

```
skills/                      skill 实现
  vibesop-init-project/       SKILL.md、references/、templates/zh、templates/en
  vibesop-init-deployment/    SKILL.md、references/、templates/
docs/                        公开文档,每个主题中英各一份
tests/
  check.mjs                   结构检查
  make-fixtures.sh            生成验收用的临时仓库
  scenarios/                  验收用例
```

## 参与贡献

`node tests/check.mjs` 必须通过。本仓库按自身 SOP 治理,约定写在 [`AGENTS.md`](AGENTS.md)。

## 许可

[MIT](LICENSE)
