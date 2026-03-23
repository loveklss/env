# Cursor 配置目录

本目录包含 Cursor IDE 的所有配置文件，用于在新系统上快速部署开发环境。

## 目录结构

```
.cursor/
├── skills/              # Agent Skills (27个)
├── rules/               # AI Rules (2个)
├── mcp.json            # MCP 服务器配置
├── extensions.txt      # 扩展插件列表 (7个)
├── settings.json       # 编辑器设置 (需从 Windows 客户端复制)
├── keybindings.json    # 快捷键配置 (需从 Windows 客户端复制)
└── README.md           # 本文件
```

## 配置统计

- **Skills**: 21 个（不含 GPU 开发 skills）
- **Rules**: 2 个
- **MCP 服务器**: 2 个
- **Extensions**: 7 个

## 配置说明

### Skills (Agent 技能)

位置: `skills/`
安装位置: `~/.agents/skills`
数量: 21 个

包含 21 个 Agent 技能脚本：

**开发工具**:
- `caps-build` - Caps 项目智能构建系统
- `test-runner` - TOPS 测试程序编译运行
- `scp-to-remote` - 文件远程复制工具

**文档处理**:
- `docx` - Word 文档处理
- `pdf` - PDF 文件操作
- `pptx` - PowerPoint 处理
- `markdown-to-confluence` - Markdown 转 Confluence
- `markdown-to-html` - Markdown 转 HTML

**图表生成**:
- `mermaid-diagrams` - Mermaid 图表
- `mermaid-export` - Mermaid 导出
- `excalidraw-diagram` - Excalidraw 图表
- `drawio` - Draw.io 图表

**辅助工具**:
- `jira_helper` - Jira 集成
- `wiki-helper` - Wiki 集成
- `browser-use` - 浏览器自动化
- `brainstorming` - 创意头脑风暴
- `find-skills` - 技能发现
- `frontend-slides` - 前端演示文稿
- `gcusim-download` - GcuSim 下载
- `skill-creator` - 技能创建器
- `three-view-architecture` - 三视图架构分析

**GPU 开发 Skills（单独安装）**:

如需 CUDA、CUTLASS、Triton、SGLang 等 GPU 开发支持，请参考：
- 项目地址: https://github.com/slowlyC/agent-gpu-skills
- 包含 4 个 GPU 专业 skills: `cuda-skill`, `cutlass-skill`, `triton-skill`, `sglang-skill`
- 安装方法:
  ```bash
  git clone https://github.com/slowlyC/agent-gpu-skills.git ~/agent-gpu-skills
  cd ~/agent-gpu-skills
  bash update-repos.sh  # 获取外部源码 (~114MB)
  bash install.sh       # 安装到 Cursor
  ```

**Cursor 专用** (不在本目录，位于 `~/.cursor/skills-cursor/`):
- `create-rule` - 创建 Cursor 规则
- `create-skill` - 创建 Agent Skill
- `update-cursor-settings` - 更新 Cursor 设置

### Rules (AI 规则)

位置: `rules/`
安装位置: `~/.cursor/rules`

包含 2 个规则文件：
- `skill-script-lookup.mdc` - Skill 脚本查找规则，确保优先使用 Skill 目录中的脚本
- `README.md` - 规则说明文档

### MCP (Model Context Protocol)

位置: `mcp.json`
安装位置: `~/.cursor/mcp.json`

配置的 MCP 服务器：
```json
{
  "mcpServers": {
    "local_mcps": {
      "command": "python",
      "args": ["-m", "local_mcps.cli", "main"]
    },
    "drawio": {
      "command": "npx",
      "args": ["--yes", "@next-ai-drawio/mcp-server@latest"]
    }
  }
}
```

### Extensions (扩展插件)

位置: `extensions.txt`

包含 7 个扩展：
1. `bierner.markdown-mermaid` - Mermaid 图表预览
2. `fabiospampinato.vscode-highlight` - 语法高亮增强
3. `llvm-vs-code-extensions.vscode-clangd` - C/C++ Language Server
4. `ms-ceintl.vscode-language-pack-zh-hans` - 中文语言包
5. `ms-vscode.cmake-tools` - CMake 工具
6. `shd101wyy.markdown-preview-enhanced` - Markdown 预览增强
7. `topscc-vs-code-extensions.vscode-tlsp` - TOPS Language Server

### Settings & Keybindings

位置: `settings.json`, `keybindings.json` (需手动添加)
安装位置: Windows 客户端 `C:\Users\<用户名>\AppData\Roaming\Cursor\User\`

这两个文件位于 Windows 客户端，需要手动复制：

1. 从 Windows 客户端导出到本目录
2. 提交到 Git
3. 在新系统的 Windows 客户端恢复

或者使用工程中现有的配置文件：
- `../.config/cursor-final-settings.json`
- `../.config/cursor-keybindings.json`

## 安装方法

### 自动安装（推荐）

```bash
cd /path/to/this/repo
bash install-cursor-config.sh
```

### 手动安装

```bash
# 创建符号链接
ln -s /path/to/this/repo/.cursor/skills ~/.agents/skills
ln -s /path/to/this/repo/.cursor/rules ~/.cursor/rules
ln -s /path/to/this/repo/.cursor/mcp.json ~/.cursor/mcp.json

# 安装扩展
while read ext; do
    cursor --install-extension "$ext" --force
done < /path/to/this/repo/.cursor/extensions.txt
```

## 配置特点

### 符号链接模式

- 服务器端配置使用符号链接，指向本仓库
- 修改配置会自动同步到仓库，便于 Git 管理
- 在 Cursor 中的任何修改都会反映到仓库中

### 版本控制

- 所有配置文件纳入 Git 版本控制
- 敏感文件（sessions、auth）已在 `.gitignore` 中排除
- 支持跨系统同步和回滚

### 一键部署

- 提供自动化安装脚本
- 自动备份现有配置
- 支持快速在新系统上部署

## 维护

### 添加新 Skill

```bash
# 直接添加到 skills 目录（会自动同步到仓库）
cp -r /path/to/new-skill ~/.agents/skills/

# 提交到 Git
cd /path/to/this/repo
git add .cursor/skills/
git commit -m "Add new skill: new-skill"
git push
```

### 更新扩展列表

```bash
# 重新导出扩展列表
cursor --list-extensions > /path/to/this/repo/.cursor/extensions.txt

# 提交更新
cd /path/to/this/repo
git add .cursor/extensions.txt
git commit -m "Update extensions list"
git push
```

### 更新 Rules

```bash
# 直接编辑 rules 文件（会自动同步到仓库）
vim ~/.cursor/rules/skill-script-lookup.mdc

# 提交到 Git
cd /path/to/this/repo
git add .cursor/rules/
git commit -m "Update rules"
git push
```

## 不应提交的文件

以下文件已在 `.gitignore` 中排除，不会被提交：

- `*_sessions.json` - 会话令牌（敏感信息）
- `auth.json` - 认证信息
- `ide_state.json` - IDE 状态
- `projects/` - 项目缓存
- `plans/` - 计划文件

## 相关文档

- [安装手册](../CURSOR-INSTALL.md) - 详细安装说明
- [主 README](../README.md) - 环境配置总览
- [Skills 文档](./skills/) - 各个 Skill 的详细说明

## 故障排查

如果配置不生效：

1. 检查符号链接是否正确：
   ```bash
   ls -la ~/.agents/skills
   ls -la ~/.cursor/rules
   ls -la ~/.cursor/mcp.json
   ```

2. 重启 Cursor

3. 查看 Cursor 日志获取详细错误信息

4. 参考 [CURSOR-INSTALL.md](../CURSOR-INSTALL.md) 的故障排查部分
