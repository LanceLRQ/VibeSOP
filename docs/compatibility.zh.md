# 客户端兼容性与已知问题

[English](compatibility.md) | 中文

## 支持范围

任何支持 [Agent Skills](https://agentskills.io) 规范的客户端都可以安装 VibeSOP,[skills CLI](https://github.com/vercel-labs/skills) 支持的客户端均在此列。安装方法见 [README](../README.zh.md#安装)。

## 验收方法

验收用例位于 [`tests/scenarios/`](../tests/scenarios/README.md),每个用例含中文与英文两组。运行时被测会话只能看到临时仓库与已安装的 skill,不知道用例内容;验收方在运行后核对检查项。共用检查覆盖:每条回复的语言、写入文件的语言、是否自行提交、确认方案前是否写文件、是否问了仓库本身能回答的问题、每批问题数量、收尾报告是否如实。

## 验收结果

| 客户端 / 模型 | 结果 |
|---|---|
| Claude Code 2.1.296 / claude-sonnet-5-5 | 通过,含三轮回归 |
| Codex CLI / gpt-6-astra | 通过 |
| ZCode / GLM-5.3 | 流程通过;「开源准备」入口不会自然触发,见下 |

## 已知问题

### 「开源准备」入口在部分客户端不触发

现象:用户表达「把仓库准备好公开」这类意图时,skill 未被加载,模型直接操作。实测 ZCode 共 30 次未触发,覆盖 GLM-5.3 与 GLM-5.3-Flash 两个档位;未加载时模型的行为包括直接写入文件、自行提交、改写 git 历史。

原因:ZCode 提供给模型的技能列表只含名称、不含描述。模型按名称判断,「准备公开」与 `init-project` 对不上,于是不加载。这是客户端展示技能列表的方式问题,与 skill 的描述文本无关——重写描述经实测无效。Claude Code 与 Codex 会向模型提供描述,不受影响。

绕过方式:在这类客户端上,首条消息按名称调用:`/vibesop-init-project`。

### 部署脚本模板为中文

本版本的 `vibesop-init-deployment` 脚本模板,注释与提示文字为中文。文档语言非中文时,skill 在生成过程中同步翻译;命令与变量名保持不变。

### 尚无插件清单

未提供 plugin manifest,安装方式为 `npx skills add LanceLRQ/VibeSOP`。

## 反馈

欢迎通过 issue 反馈在其他客户端与模型上的运行表现,附客户端版本、模型名称与所用用例编号。
