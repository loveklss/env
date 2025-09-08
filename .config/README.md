# My Neovim IDE - 最终用户手册

## 安装指南 (非 Root 用户)

本指南用于在一个您没有 root/sudo 权限的 Ubuntu 20.04+ 系统上部署此 Neovim 配置。

### 1. 系统依赖检查

本配置的完整功能依赖以下外部工具。请逐一在您的终端中执行 `--version` 命令（如 `git --version`）来检查它们是否已安装。 

*   `git`
*   `gcc` (或 `clang`)
*   `tar`, `curl`, `wget`
*   `global` (GNU Gtags)
*   `exuberant-ctags`

**如果任何一个命令提示 `command not found`，您需要联系您的系统管理员来为您安装对应的软件包**（例如 `build-essential`, `global`, `exuberant-ctags` 等）。

### 2. 安装 Node.js / npm (无需 Sudo)

LSP 服务器 `pyright` 需要 `npm` 来安装。我们可以使用 `nvm` 在您的用户目录下安装它。

```bash
# 1. 下载并运行 nvm 安装脚本
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 2. 安装完成后，关闭并重新打开终端以激活 nvm

# 3. 在新终端中，安装长期支持版的 Node.js (npm 会一同安装)
nvm install --lts
```

### 3. 安装 Neovim (无需 Sudo)

本配置推荐使用 **Neovim v0.10.x** (开发版)。

```bash
# 1. 在您的家目录下创建一个用于存放本地软件的目录
mkdir -p ~/.local/bin

# 2. 下载预编译的 Neovim
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz

# 3. 解压
tar xzvf nvim-linux64.tar.gz

# 4. 将 nvim 程序链接到您的本地 bin 目录
#    注意: 请将 /path/to/your/download/location 替换为您实际的下载路径
ln -s /path/to/your/download/location/nvim-linux64/bin/nvim ~/.local/bin/nvim

# 5. 确保 ~/.local/bin 在您的 PATH 环境变量中。
#    您可以编辑 ~/.profile 或 ~/.bashrc 文件，在末尾加入下面这行：
#    export PATH="$HOME/.local/bin:$PATH"
#    保存后执行 source ~/.profile 或 source ~/.bashrc 使其生效。
```

### 4. 部署本配置

将我们完成的所有配置文件（`init.lua`, `lua/` 等）所在的 `nvim` 文件夹，放置到 Neovim 的标准配置路径下。

```bash
# 假设您的配置文件在 ~/my-nvim-config/nvim
# 备份可能存在的旧配置
mv ~/.config/nvim ~/.config/nvim.bak

# 移动新配置
mv ~/my-nvim-config/nvim ~/.config/
```

### 5. 首次启动与项目设置

1.  **首次启动**: 在终端中执行 `nvim`。`lazy.nvim` 会自动下载和安装所有插件。
2.  **安装 LSP 服务**: Neovim 启动后，执行 `:Mason` 打开管理界面，找到 `pyright`, `clangd` 等，按 `i` 进行安装。
3.  **生成 Gtags/Ctags 数据库**: 在您的项目根目录下，分别执行 `gtags` 和 `ctags -R .`。
4.  **生成 `compile_commands.json` (用于 C/C++)**: 这是让 `clangd` 发挥全部实力的关键。
    *   **对于 CMake 项目**: 在执行 cmake 时加入 `-DCMAKE_EXPORT_COMPILE_COMMANDS=1` 参数。
    *   **对于 Makefile 项目**: 您需要使用一个叫做 `bear` 的工具。如果它已安装，您可以像这样包裹您的 `make` 命令：
        ```bash
        # 如果您通常执行 make，现在请执行：
        bear -- make
        ```

---

## 主要功能与快捷键

### 核心概念: Leader 键

*   本配置的 **Leader 键** 是**逗号 (`,`)**。

### 1. 文件与项目导航

#### 文件浏览器 (`neo-tree`)
*   **`<leader>wm`**: 打开/关闭文件浏览器。
*   在窗口中按 **`<Esc>`**: 关闭窗口。

#### 模糊搜索 (`telescope`)
*   **`<leader>ft`**: 使用 `filenametags` 文件查找项目中的**文件**。
*   **`<leader>ff`**: 查找项目中的任意**文件**。
*   **`<leader>fg`**: 全文**搜索**一个字符串。
*   **`<leader>fb`**: 查找已打开的**文件** (Buffers)。

### 2. 代码与符号导航

#### 智能导航 (LSP + Gtags 混合模式)
*   **`gd`**: **跳转到定义** (LSP 优先, Gtags 为辅)。
*   **`gD`**: **跳转到声明** (LSP 优先, Gtags 为辅)。
*   **`gr`**: **查找引用** (LSP 优先, Gtags 为辅)。
*   **`<leader>fs`**: 查找当前文件**符号** (LSP 优先, Gtags 为辅)。

#### LSP 专属快捷键 (仅在LSP激活时有效)
*   **`gi`**: 跳转到**实现**。
*   **`gy`**: 跳转到**类型定义**。
*   **`K`**: 显示悬浮**文档**。

#### 符号大纲 (`symbols-outline`)
*   **`<leader>tl`**: 打开/关闭当前文件的符号大纲侧边栏。

### 3. 编辑与代码写作

#### 语法高亮 (`nvim-treesitter`)
*   **功能**: 由 `nvim-treesitter` 提供，基于代码结构进行高亮，比传统方式更精准、快速。

#### 括号自动补全 (`nvim-autopairs`)
*   **功能**: 自动补全 `()` `[]` `{}` `""` `''` 等成对符号。

#### 代码补全 (`nvim-cmp`)
*   **功能**: 输入时自动弹出补全建议（不包含LSP源）。
*   **`<Tab>` / `<S-Tab>`**: 在建议中上下选择或跳转代码片段。
*   **`<CR>`**: 确认补全。

#### 快速移动 (`flash.nvim`)
*   **`s` + `[字符]`**: 按 `s` 后，输入任意字符，即可在屏幕上所有匹配项之间快速跳转。

#### 多重/搜索高亮
*   **`;`**: (MultipleSearch) 高亮光标下的单词。
*   **`;;`**: 清除所有高亮（包括普通搜索和多重高亮）。
*   **`*`**: (Vim 原生功能) 查找光标下单词，并跳转到下一个。

#### 注释 (`Comment.nvim`)
*   **`gcc`**: 注释/取消注释当前行。
*   **`gc` + `[动作]`**: 注释指定范围。

#### 成对符号环绕 (`nvim-surround`)
*   **`ysiw"`**: 将当前单词用双引号环绕。
*   **`ds"`**: 删除外层的双引号。
*   **`cs"'`**: 将外层的双引号更改为单引号。

#### 书签 (`vim-bookmarks`)
*   **`mm`**: 添加/删除书签。
*   **`mn` / `mp`**: 在书签之间前后跳转。

### 4. 视觉与界面

#### 顶部标签栏 (`bufferline`)
*   **功能**: 在顶部显示所有已打开的文件，呈标签页样式。

#### 缩进模式切换
*   **`<F9>`**: 在“4个宽度的硬 Tab”和“2个宽度的软 Tab (空格)”之间循环切换。

#### 缩进参考线 (`indent-blankline`)
*   **功能**: 代码中会自动显示垂直的缩进线。

#### 光标形状
*   在普通模式下为**方块**，在插入模式下会自动变为**竖线**。

#### LSP 诊断信息
*   **默认关闭**：所有错误、警告等诊断信息默认不显示。

### 5. Git 集成 (`vim-fugitive`)
*   **`:Git`** 或 **`:G`**: 打开 Git 状态窗口。

### 6. 窗口与缓冲区管理
*   **`<C-N>` / `<C-P>`**: 在打开的文件之间前后切换。
*   **`<leader>bd`**: 关闭当前文件。

---

## 如何管理插件
*   所有插件都在 `lua/plugins/` 目录下定义。
*   您可以打开 Neovim 后输入 **`:Lazy`** 命令来查看插件管理界面。