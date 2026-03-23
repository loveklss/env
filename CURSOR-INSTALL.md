# Cursor 配置安装手册

本文档说明如何在新系统上安装和配置 Cursor 开发环境。

## 目录

- [配置概览](#配置概览)
- [快速安装](#快速安装)
- [配置说明](#配置说明)
- [Windows 客户端配置](#windows-客户端配置)
- [手动安装](#手动安装)
- [故障排查](#故障排查)
- [卸载说明](#卸载说明)

## 配置概览

本仓库包含以下 Cursor 配置：

| 配置项 | 存储位置 | 安装位置 | 说明 |
|--------|----------|----------|------|
| **Skills** | `.cursor/skills/` | `~/.agents/skills` | Agent 技能脚本（27个） |
| **Rules** | `.cursor/rules/` | `~/.cursor/rules` | AI 行为规则（2个） |
| **MCP** | `.cursor/mcp.json` | `~/.cursor/mcp.json` | MCP 服务器配置 |
| **Extensions** | `.cursor/extensions.txt` | - | 扩展插件列表（7个） |
| **Settings** | `.cursor/settings.json` | Windows 客户端 | 编辑器设置（需手动复制） |
| **Keybindings** | `.cursor/keybindings.json` | Windows 客户端 | 快捷键配置（需手动复制） |

### 配置特点

- **符号链接模式**: 服务器端配置使用符号链接，修改自动同步到仓库
- **Git 版本控制**: 所有配置文件纳入版本控制，便于跨系统同步
- **一键安装**: 提供自动化安装脚本，快速部署到新系统

## 快速安装

### 前置条件

1. 已安装 Cursor 编辑器
2. 已克隆本仓库到目标系统
3. `cursor` 命令在 PATH 中（用于安装扩展）

### 安装步骤

1. **克隆仓库**（如果还没有）

```bash
git clone <仓库地址> ~/ws/env
cd ~/ws/env
```

2. **运行安装脚本**

```bash
bash install-cursor-config.sh
```

脚本会自动完成：
- 备份现有配置（如果存在）
- 创建符号链接到 `~/.agents/skills`, `~/.cursor/rules`, `~/.cursor/mcp.json`
- 安装扩展插件

3. **配置 Windows 客户端**（见下文）

## 配置说明

### 1. Skills（Agent 技能）

**位置**: `.cursor/skills/` → `~/.agents/skills`

包含 21 个 Agent 技能，提供专业领域能力：

- **开发工具**: `caps-build`, `test-runner`, `scp-to-remote`
- **文档处理**: `docx`, `pdf`, `pptx`, `markdown-to-confluence`, `markdown-to-html`
- **图表生成**: `mermaid-diagrams`, `mermaid-export`, `excalidraw-diagram`, `drawio`
- **辅助工具**: `jira_helper`, `wiki-helper`, `browser-use`, `brainstorming`, `find-skills`
- **其他**: `frontend-slides`, `gcusim-download`, `skill-creator`, `three-view-architecture`

**GPU 开发 Skills**: 如需 CUDA、CUTLASS、Triton、SGLang 等 GPU 开发支持，请参考 [agent-gpu-skills](https://github.com/slowlyC/agent-gpu-skills) 项目单独安装。

### 2. Rules（AI 规则）

**位置**: `.cursor/rules/` → `~/.cursor/rules`

包含 2 个规则文件：
- `skill-script-lookup.mdc`: Skill 脚本查找规则
- `README.md`: 规则说明文档

### 3. MCP（Model Context Protocol）

**位置**: `.cursor/mcp.json` → `~/.cursor/mcp.json`

配置的 MCP 服务器：
- `local_mcps`: 本地 MCP 服务
- `drawio`: Draw.io 图表生成服务

### 4. Extensions（扩展插件）

**位置**: `.cursor/extensions.txt`

包含 7 个扩展：
- `bierner.markdown-mermaid` - Mermaid 图表支持
- `fabiospampinato.vscode-highlight` - 语法高亮增强
- `llvm-vs-code-extensions.vscode-clangd` - C/C++ LSP
- `ms-ceintl.vscode-language-pack-zh-hans` - 中文语言包
- `ms-vscode.cmake-tools` - CMake 工具
- `shd101wyy.markdown-preview-enhanced` - Markdown 预览增强
- `topscc-vs-code-extensions.vscode-tlsp` - TOPS LSP

## Windows 客户端配置

由于你使用 **Windows 客户端连接远程服务器**，以下配置需要在 Windows 客户端手动设置。

### Settings 和 Keybindings

#### 方案 1: 从 Windows 导出到仓库（推荐）

1. **在 Windows 客户端，找到配置文件**

```
C:\Users\<你的用户名>\AppData\Roaming\Cursor\User\settings.json
C:\Users\<你的用户名>\AppData\Roaming\Cursor\User\keybindings.json
```

2. **复制到仓库**

将这两个文件复制到本仓库的 `.cursor/` 目录下，然后提交到 Git：

```bash
# 在服务器上
cd ~/ws/env
git add .cursor/settings.json .cursor/keybindings.json
git commit -m "Add Windows client settings and keybindings"
git push
```

3. **在新系统的 Windows 客户端恢复**

从仓库获取文件后，复制到新系统的 Windows 客户端对应位置。

#### 方案 2: 使用现有配置文件

仓库中已有以下配置文件（如果存在）：
- `.config/cursor-final-settings.json`
- `.config/cursor-keybindings.json`

可以将它们复制到 `.cursor/` 目录并重命名：

```bash
cp .config/cursor-final-settings.json .cursor/settings.json
cp .config/cursor-keybindings.json .cursor/keybindings.json
```

然后在 Windows 客户端使用这些文件。

### 扩展插件

#### Linux 服务器端

扩展插件会在运行 `install-cursor-config.sh` 时自动安装。如果安装失败，可以手动安装：

```bash
cursor --install-extension bierner.markdown-mermaid
cursor --install-extension fabiospampinato.vscode-highlight
# ... 其他扩展
```

#### Windows 客户端

由于你使用 Windows 客户端连接远程服务器，Windows 客户端的扩展需要单独安装。

**方法 1: 使用自动脚本（推荐）**

仓库中提供了两个 Windows 扩展安装脚本：

1. **批处理脚本** (`install-cursor-extensions.bat`):
   - 双击运行即可
   - 适合不熟悉 PowerShell 的用户

2. **PowerShell 脚本** (`install-cursor-extensions.ps1`):
   - 右键 -> "使用 PowerShell 运行"
   - 或在 PowerShell 中执行: `.\install-cursor-extensions.ps1`
   - 更现代化，带彩色输出

**方法 2: 手动安装**

在 Cursor 中按 `Ctrl+Shift+X` 打开扩展面板，搜索并安装以下扩展：
- `bierner.markdown-mermaid` - Mermaid 图表支持
- `fabiospampinato.vscode-highlight` - 语法高亮增强
- `llvm-vs-code-extensions.vscode-clangd` - C/C++ LSP
- `ms-ceintl.vscode-language-pack-zh-hans` - 中文语言包
- `ms-vscode.cmake-tools` - CMake 工具
- `shd101wyy.markdown-preview-enhanced` - Markdown 预览增强
- `topscc-vs-code-extensions.vscode-tlsp` - TOPS LSP

## GPU 开发 Skills（可选）

如果你需要 GPU 开发支持（CUDA、CUTLASS、Triton、SGLang），可以单独安装 agent-gpu-skills 项目：

### 安装 agent-gpu-skills

```bash
# 1. 克隆 agent-gpu-skills 仓库
git clone https://github.com/slowlyC/agent-gpu-skills.git ~/agent-gpu-skills
cd ~/agent-gpu-skills

# 2. 获取外部源码 repo (sparse checkout, ~114MB)
bash update-repos.sh

# 3. 安装 skills 到 Cursor
bash install.sh
```

这将安装以下 4 个 GPU 相关 skills：

| Skill | 层级 | 使用场景 |
|-------|------|----------|
| **cuda-skill** | 底层 (PTX/CUDA C++) | 查 PTX 指令、CUDA API、Programming Guide，nsys/ncu 分析 |
| **cutlass-skill** | 中间层 (CUTLASS/CuTeDSL) | 写 CUTLASS/CuTe kernel，查 CuTeDSL 示例 |
| **triton-skill** | 高层 (Python DSL) | 写 Triton/Gluon 内核，查教程和示例 |
| **sglang-skill** | 应用层 (LLM Serving) | SGLang 推理引擎开发，KV cache、Attention backend |

详细说明请参考: https://github.com/slowlyC/agent-gpu-skills

## 手动安装

如果不想使用自动脚本，可以手动创建符号链接：

```bash
# 1. 备份现有配置
mv ~/.agents/skills ~/.agents/skills.backup.$(date +%Y%m%d)
mv ~/.cursor/rules ~/.cursor/rules.backup.$(date +%Y%m%d)
mv ~/.cursor/mcp.json ~/.cursor/mcp.json.backup.$(date +%Y%m%d)

# 2. 创建符号链接
ln -s ~/ws/env/.cursor/skills ~/.agents/skills
ln -s ~/ws/env/.cursor/rules ~/.cursor/rules
ln -s ~/ws/env/.cursor/mcp.json ~/.cursor/mcp.json

# 3. 安装扩展
while read extension; do
    cursor --install-extension "$extension" --force
done < ~/ws/env/.cursor/extensions.txt
```

## 故障排查

### 问题 1: cursor 命令未找到

**症状**: 运行脚本时提示 `cursor: command not found`

**解决方案**:
1. 确认 Cursor 已正确安装
2. 将 Cursor 添加到 PATH:
   ```bash
   # 在 ~/.bashrc 或 ~/.bash_profile 中添加
   export PATH="$PATH:/path/to/cursor/bin"
   ```
3. 或者手动在 Cursor 扩展面板中安装扩展

### 问题 2: 符号链接创建失败

**症状**: `ln: failed to create symbolic link`

**解决方案**:
1. 检查目标目录是否已存在文件
2. 手动删除或备份冲突文件
3. 确保有写入权限

### 问题 3: Skills 不生效

**症状**: Cursor 中无法使用 Skills

**解决方案**:
1. 检查符号链接是否正确创建:
   ```bash
   ls -la ~/.agents/skills
   ls -la ~/.cursor/rules
   ```
2. 重启 Cursor
3. 检查 Skills 文件权限

### 问题 4: MCP 服务器无法启动

**症状**: MCP 相关功能不可用

**解决方案**:
1. 检查 Python 环境（`local_mcps` 需要 Python）
2. 检查 Node.js 环境（`drawio` 需要 npx）
3. 查看 Cursor 日志获取详细错误信息

### 问题 5: Windows 客户端配置不同步

**症状**: 服务器端配置修改后，Windows 客户端未更新

**解决方案**:
- Windows 客户端配置是独立的，需要手动复制文件
- 考虑使用 Git 同步配置文件
- 或使用云同步工具（如 OneDrive）同步配置目录

## 卸载说明

如果需要卸载配置，按以下步骤操作：

```bash
# 1. 删除符号链接
rm ~/.agents/skills
rm ~/.cursor/rules
rm ~/.cursor/mcp.json

# 2. 恢复备份（如果有）
mv ~/.agents/skills.backup.YYYYMMDD ~/.agents/skills
mv ~/.cursor/rules.backup.YYYYMMDD ~/.cursor/rules
mv ~/.cursor/mcp.json.backup.YYYYMMDD ~/.cursor/mcp.json

# 3. 卸载扩展（可选）
cursor --uninstall-extension bierner.markdown-mermaid
# ... 其他扩展
```

## 维护说明

### 更新配置

由于使用符号链接，直接在 Cursor 中修改配置会自动同步到仓库：

```bash
# 查看修改
cd ~/ws/env
git status

# 提交修改
git add .cursor/
git commit -m "Update cursor config"
git push
```

### 添加新 Skill

```bash
# 1. 将新 Skill 添加到 skills 目录
cp -r /path/to/new-skill ~/.agents/skills/

# 2. 由于是符号链接，修改已自动同步到仓库
cd ~/ws/env
git add .cursor/skills/
git commit -m "Add new skill: new-skill"
git push
```

### 更新扩展列表

```bash
# 重新导出扩展列表
cursor --list-extensions > ~/ws/env/.cursor/extensions.txt

# 提交更新
cd ~/ws/env
git add .cursor/extensions.txt
git commit -m "Update extensions list"
git push
```

## 相关文档

- [主 README](./README.md) - 环境配置总览
- [Neovim 配置](./.config/README.md) - Neovim IDE 配置
- [Cursor Vim 指南](./.config/Cursor-Vim-Guide.md) - Vim 模式使用指南

## 支持

如有问题，请查看：
1. 本文档的故障排查部分
2. Cursor 官方文档
3. Skills 目录下各个 Skill 的 README
