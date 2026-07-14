# 开发环境配置仓库

本仓库包含个人开发环境的完整配置，支持快速在新系统上部署一致的开发环境。

## 目录

- [配置概览](#配置概览)
- [Cursor 配置](#cursor-配置)
- [Claude Code 配置](#claude-code-配置)
- [Zed 配置](#zed-配置)
- [Vim/Neovim 配置](#vimneovim-配置)
- [Shell 配置](#shell-配置)
- [快速安装](#快速安装)

## 配置概览

本仓库包含以下配置：

| 配置类型 | 位置 | 说明 |
|---------|------|------|
| **Cursor** | `.cursor/` | Cursor IDE 配置（Skills、Rules、MCP、扩展） |
| **Claude Code** | `.claude/` | Claude Code 配置（Settings、环境变量模板） |
| **Zed** | `.zed/` | Zed 编辑器配置（Settings、Keymap、扩展） |
| **Neovim** | `.config/nvim/` | Neovim IDE 完整配置 |
| **Vim** | `.vimrc`, `.vim/` | 传统 Vim 配置 |
| **Bash** | `.bashrc`, `.bash_profile` | Bash Shell 配置 |
| **Tmux** | `.tmux.conf`, `.tmux/` | 终端复用器配置 |
| **其他** | `hbpConfig/` | 历史配置和工具脚本 |

## Cursor 配置

### 快速安装

#### Linux 服务器端

```bash
# 1. 克隆仓库
git clone <仓库地址> ~/ws/env
cd ~/ws/env

# 2. 运行 Cursor 配置安装脚本
bash install-cursor-config.sh
```

#### Windows 客户端

```powershell
# 安装扩展插件（二选一）
.\install-cursor-extensions.bat      # 批处理脚本
.\install-cursor-extensions.ps1      # PowerShell 脚本（推荐）

# 复制配置文件到客户端
copy .cursor\settings.json C:\Users\<你的用户名>\AppData\Roaming\Cursor\User\
copy .cursor\keybindings.json C:\Users\<你的用户名>\AppData\Roaming\Cursor\User\
```

### 配置内容

- **Skills (21个)**: Agent 技能脚本，提供专业领域能力
  - 开发工具: `caps-build`, `test-runner`, `scp-to-remote`
  - 文档处理: `docx`, `pdf`, `pptx`, `markdown-to-confluence`, `markdown-to-html`
  - 图表生成: `mermaid-diagrams`, `mermaid-export`, `excalidraw-diagram`, `drawio`
  - 辅助工具: `jira_helper`, `wiki-helper`, `browser-use`, `brainstorming`, `find-skills`
  - 其他: `frontend-slides`, `gcusim-download`, `skill-creator`, `three-view-architecture`
  - **GPU 开发**: 请参考 [agent-gpu-skills](https://github.com/slowlyC/agent-gpu-skills) 单独安装

- **Rules (2个)**: AI 行为规则
  - `skill-script-lookup.mdc`: Skill 脚本查找规则
  - `README.md`: 规则说明文档

- **MCP (2个服务器)**: Model Context Protocol 服务器配置
  - `local_mcps`: 本地 MCP 服务
  - `drawio`: Draw.io 图表生成服务

- **Extensions (7个)**: 扩展插件
  - Mermaid、语法高亮、C/C++ LSP、中文语言包、CMake、Markdown 预览、TOPS LSP

**GPU 开发 Skills（可选）**: 如需 CUDA/CUTLASS/Triton/SGLang 支持，请参考 [agent-gpu-skills](https://github.com/slowlyC/agent-gpu-skills)

详细说明请参考: [CURSOR-INSTALL.md](./CURSOR-INSTALL.md)

## Claude Code 配置

### 快速安装

```bash
# 1. 创建配置目录
mkdir -p ~/.claude

# 2. 复制配置文件（注意替换 ANTHROPIC_AUTH_TOKEN）
cp ~/ws/env/.claude/settings.json ~/.claude/settings.json

# 3. 设置认证令牌
export ANTHROPIC_AUTH_TOKEN="<你的真实 token>"
```

### 配置内容

- **Settings**: Claude Code 全局设置，包含 API 代理地址、默认模型、环境变量开关等
- **Env 模板**: `.claude/.env.example` 提供环境变量配置参考

⚠️ **安全提示**: 仓库中的 `settings.json` 已将 `ANTHROPIC_AUTH_TOKEN` 替换为占位符，使用前必须填入真实 token，且不要将包含真实 token 的文件提交到 Git。

详细说明请参考: [CLAUDE-INSTALL.md](./CLAUDE-INSTALL.md)

## Zed 配置

### 快速安装

#### Windows 客户端

```powershell
# 安装扩展插件（二选一）
.\install-zed-extensions.bat      # 批处理脚本
.\install-zed-extensions.ps1      # PowerShell 脚本（推荐）

# 复制配置文件到客户端
copy .zed\settings.json C:\Users\<你的用户名>\AppData\Roaming\Zed\
copy .zed\keymap.json C:\Users\<你的用户名>\AppData\Roaming\Zed\
```

#### Linux / macOS

```bash
# 使用符号链接同步配置
ln -s ~/ws/env/.zed/settings.json ~/.config/zed/settings.json
ln -s ~/ws/env/.zed/keymap.json ~/.config/zed/keymap.json
```

### 配置内容

- **Settings**: 编辑器设置，包含主题、字体、Agent 模型、LSP、界面等
- **Keymap**: 从 VS Code Vim 迁移的快捷键映射，Leader 键为 `,`
- **Extensions (13个)**: 主题和语言支持扩展

详细说明请参考: [ZED-INSTALL.md](./ZED-INSTALL.md)

## Vim/Neovim 配置

### Neovim IDE

位置: `.config/nvim/`

完整的 Neovim IDE 配置，包含：
- LSP 支持（Pyright、Clangd）
- 文件浏览器（Neo-tree）
- 模糊搜索（Telescope）
- 代码补全（nvim-cmp）
- Git 集成（Fugitive）
- 符号导航（Gtags + LSP）

详细说明请参考: [.config/README.md](./.config/README.md)

### 传统 Vim

位置: `.vimrc`, `.vim/`

传统 Vim 配置，使用 Vundle 管理插件。

## Shell 配置

### Bash

- `.bashrc`: 普通终端配置
- `.bash_profile`: Tmux 终端配置
- `.bash_it/`: Bash-it 框架

### Tmux

- `.tmux.conf`: 主配置文件
- `.tmux.conf.local`: 本地自定义配置
- `.tmux/`: Tmux 插件和主题

## 快速安装

### 1. 克隆仓库

```bash
git clone <仓库地址> ~/ws/env
cd ~/ws/env
```

### 2. 安装 Cursor 配置

```bash
bash install-cursor-config.sh
```

### 3. 安装 Vim/Shell 配置

```bash
# 复制配置文件
cp .vimrc .bashrc .bash_profile .tmux.conf .tmux.conf.local ~/

# 复制目录
cp -r .vim .tmux .hbpConfig ~/

# 安装 Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# 安装 fzf
git clone https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# 安装 bash-it
git clone https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh

# 安装 powerline fonts
git clone https://github.com/powerline/fonts.git /tmp/fonts
cd /tmp/fonts
./install.sh

# 安装 tmux 插件管理器
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# 在 tmux 中按 Ctrl+q I 安装插件

# 替换用户名
sed -i 's/qhu/<你的用户名>/g' ~/.bashrc ~/.bash_profile

# 安装 Vim 插件
vim +PluginInstall +qall
```

### 4. 安装 Neovim 配置（可选）

```bash
# 复制 Neovim 配置
cp -r .config/nvim ~/.config/

# 安装 Node.js (用于 LSP)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts

# 首次启动 Neovim 会自动安装插件
nvim
```

详细说明请参考: [.config/README.md](./.config/README.md)

## 注意事项

- `.bashrc` 用于普通终端
- `.bash_profile` 用于 Tmux
- 需要替换配置文件中的用户名 `qhu` 为你的用户名
- Cursor 配置使用符号链接，修改会自动同步到仓库
- 敏感文件（sessions、auth）已在 `.gitignore` 中排除

## 相关文档

- [Cursor 安装手册](./CURSOR-INSTALL.md) - Cursor 配置详细说明
- [Neovim 配置手册](./.config/README.md) - Neovim IDE 使用指南
- [Cursor Vim 指南](./.config/Cursor-Vim-Guide.md) - Vim 模式使用技巧

## 维护

### 更新配置

```bash
cd ~/ws/env
git pull
```

### 提交修改

```bash
cd ~/ws/env
git add .
git commit -m "Update config"
git push
```

由于 Cursor 配置使用符号链接，在 Cursor 中的修改会自动反映到仓库中。
