# Claude Code 配置安装手册

本文档说明如何在新系统上安装和配置 Claude Code（Anthropic 的 AI 编程助手）环境。

## 目录

- [配置概览](#配置概览)
- [安全说明](#安全说明)
- [快速安装](#快速安装)
- [配置说明](#配置说明)
- [故障排查](#故障排查)
- [维护说明](#维护说明)

## 配置概览

本仓库包含以下 Claude Code 配置：

| 配置项 | 存储位置 | 安装位置 | 说明 |
|--------|----------|----------|------|
| **Settings** | `.claude/settings.json` | `~/.claude/settings.json` | Claude Code 全局设置 |
| **Env 示例** | `.claude/.env.example` | - | 环境变量模板 |

### 不纳入版本控制的文件

以下文件包含机器/用户特定信息，未纳入仓库：

- `~/.claude.json`: 使用统计、机器 ID、用户 ID、项目状态等本地状态文件
- `~/.claude/backups/`: 配置备份
- `~/.claude/history.jsonl`: 历史记录
- `ANTHROPIC_AUTH_TOKEN` 的真实值：已在本仓库配置中替换为占位符

## 安全说明

⚠️ **重要**: `.claude/settings.json` 包含 `ANTHROPIC_AUTH_TOKEN` 字段。本仓库中的该字段已替换为占位符 `<YOUR_ANTHROPIC_AUTH_TOKEN>`。

在安装到本地之前，必须将其替换为你的真实认证令牌。你可以通过以下任一方式提供：

1. **直接修改 `settings.json` 文件**（文件级配置）
2. **设置系统环境变量**（优先级通常高于文件配置）
3. **使用 `.claude/.env.example` 模板创建 `.env` 文件**，然后加载到当前 shell

**切勿将包含真实 token 的配置文件提交到 Git！**

## 快速安装

### 前置条件

1. 已安装 Claude Code（VS Code 扩展或 CLI）
2. 已克隆本仓库到目标系统
3. 拥有可用的 `ANTHROPIC_AUTH_TOKEN`

### 安装步骤

#### 1. 创建 Claude Code 配置目录

```bash
mkdir -p ~/.claude
```

Windows:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude"
```

#### 2. 复制配置文件

```bash
# Linux / macOS / WSL
cp ~/ws/env/.claude/settings.json ~/.claude/settings.json
```

Windows (PowerShell):

```powershell
copy .claude\settings.json $env:USERPROFILE\.claude\settings.json
```

#### 3. 设置认证令牌

编辑 `~/.claude/settings.json`，将 `<YOUR_ANTHROPIC_AUTH_TOKEN>` 替换为真实令牌：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-..."
  }
}
```

或者通过环境变量设置（推荐，避免在文件中保存 secret）：

```bash
# Linux / macOS / WSL
export ANTHROPIC_AUTH_TOKEN="sk-..."
```

Windows (PowerShell):

```powershell
$env:ANTHROPIC_AUTH_TOKEN="sk-..."
```

#### 4. 重启 Claude Code

关闭并重新打开 Claude Code，使配置生效。

## 配置说明

### `.claude/settings.json`

当前配置的主要参数：

| 参数 | 值 | 说明 |
|------|-----|------|
| `ANTHROPIC_BASE_URL` | `https://api.enflame.cn` | API 代理地址 |
| `ANTHROPIC_MODEL` | `kimi-k2.7-code-highspeed` | 默认使用模型 |
| `ANTHROPIC_SMALL_FAST_MODEL` | `deepseek-v4-pro` | 轻量快速模型 |
| `CLAUDE_CODE_DISABLE_UPDATE` | `1` | 禁用自动更新 |
| `CLAUDE_CODE_DISABLE_ANALYTICS` | `1` | 禁用分析上报 |
| `CLAUDE_CODE_MAX_CONTEXT_TOKENS` | `262144` | 最大上下文 token 数 |
| `model` | `kimi-k2.7-code-highspeed` | UI 默认模型 |
| `effortLevel` | `medium` | 默认 effort 级别 |
| `theme` | `dark` | 主题 |

### `.claude/.env.example`

环境变量模板，便于在不修改 `settings.json` 的情况下配置 Claude Code。复制为 `.env` 后加载：

```bash
cp .claude/.env.example .claude/.env
# 编辑 .claude/.env 填入真实 token
source .claude/.env
```

## 故障排查

### 问题 1: Claude Code 无法连接 API

**症状**: 提示认证失败或无法连接

**解决方案**:
1. 确认 `ANTHROPIC_AUTH_TOKEN` 已正确设置
2. 确认 `ANTHROPIC_BASE_URL` 可访问
3. 检查网络连接或代理设置

### 问题 2: 模型不可用

**症状**: 提示模型 `kimi-k2.7-code-highspeed` 不可用

**解决方案**:
1. 确认当前 API 密钥有权访问该模型
2. 将 `ANTHROPIC_MODEL` 和 `model` 改为可用的模型名称

### 问题 3: 配置文件未生效

**症状**: 修改 `~/.claude/settings.json` 后行为未改变

**解决方案**:
1. 确认文件路径正确：
   - Linux/macOS: `~/.claude/settings.json`
   - Windows: `C:\Users\<你的用户名>\.claude\settings.json`
2. 检查 JSON 语法是否正确
3. 重启 Claude Code
4. 环境变量可能覆盖文件配置，检查当前 shell 的环境变量

### 问题 4: 不小心提交了真实 token

**症状**: 真实 `ANTHROPIC_AUTH_TOKEN` 出现在 Git 历史中

**解决方案**:
1. 立即撤销/轮换该 token
2. 使用 `git filter-repo` 或 BFG Repo-Cleaner 从历史中删除敏感信息
3. 重新提交清理后的配置

## 维护说明

### 更新配置

修改本地 `~/.claude/settings.json` 后，反向同步到仓库（注意先移除真实 token）：

```bash
cd ~/ws/env

# Linux / macOS / WSL
cp ~/.claude/settings.json .claude/settings.json

# 确保 token 已替换为占位符（手动检查或脚本替换）
# sed -i 's/"ANTHROPIC_AUTH_TOKEN": "sk-[^"]*"/"ANTHROPIC_AUTH_TOKEN": "<YOUR_ANTHROPIC_AUTH_TOKEN>"/g' .claude/settings.json

git add .claude/settings.json
git commit -m "Update claude code config"
git push
```

### 添加新的环境变量

如需添加新的 Claude Code 环境变量，同时更新：

1. `.claude/settings.json`
2. `.claude/.env.example`
3. 本说明文档中的配置说明表格

## 相关文档

- [主 README](./README.md) - 环境配置总览
- [Cursor 配置安装手册](./CURSOR-INSTALL.md) - Cursor IDE 配置
- [Zed 配置安装手册](./ZED-INSTALL.md) - Zed 编辑器配置

## 支持

如有问题，请查看：
1. 本文档的故障排查部分
2. [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code/overview)
3. [Anthropic API 文档](https://docs.anthropic.com/en/api/getting-started)
