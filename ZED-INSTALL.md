# Zed 配置安装手册

本文档说明如何在新系统上安装和配置 Zed 编辑器环境。

## 目录

- [配置概览](#配置概览)
- [快速安装](#快速安装)
- [Windows 客户端配置](#windows-客户端配置)
- [扩展插件](#扩展插件)
- [故障排查](#故障排查)
- [维护说明](#维护说明)

## 配置概览

本仓库包含以下 Zed 配置：

| 配置项 | 存储位置 | 安装位置 | 说明 |
|--------|----------|----------|------|
| **Settings** | `.zed/settings.json` | Windows: `%APPDATA%\Zed\settings.json` | 编辑器设置 |
| **Keymap** | `.zed/keymap.json` | Windows: `%APPDATA%\Zed\keymap.json` | 快捷键配置 |
| **Extensions** | `.zed/extensions.txt` | - | 扩展插件列表（13 个） |

### 配置文件说明

- **`settings.json`**: 包含主题、字体、Agent 模型、LSP、界面等所有编辑器设置
- **`keymap.json`**: 从 VS Code Vim 迁移的快捷键映射，Leader 键为 `,`
- **`extensions.txt`**: 纯文本扩展列表，便于脚本批量安装

## 快速安装

### 前置条件

1. 已安装 Zed 编辑器
2. 已克隆本仓库到目标系统
3. `zed` 命令在 PATH 中（用于通过脚本安装扩展）

### 安装步骤

1. **克隆仓库**（如果还没有）

```bash
git clone <仓库地址> ~/ws/env
cd ~/ws/env
```

2. **复制 Zed 配置文件到 Windows 客户端**

在 Windows 客户端，将以下文件复制到 Zed 配置目录：

```text
源文件:  .zed/settings.json  ->  目标: C:\Users\<你的用户名>\AppData\Roaming\Zed\settings.json
源文件:  .zed/keymap.json    ->  目标: C:\Users\<你的用户名>\AppData\Roaming\Zed\keymap.json
```

3. **安装扩展插件**

   运行 `install-zed-extensions.bat` 或 `install-zed-extensions.ps1`。

详细步骤见下文。

## Windows 客户端配置

由于 Zed 的图形界面和配置文件在 Windows 客户端本地管理，以下配置需要在 Windows 客户端手动设置。

### Settings 和 Keymap

#### 方案 1: 从仓库复制到 Windows 客户端（推荐）

1. **打开 Zed 配置目录**

```text
C:\Users\<你的用户名>\AppData\Roaming\Zed\
```

2. **从仓库复制配置文件**

```bash
# 在仓库目录中执行（假设仓库在 WSL/MSYS 环境）
cp .zed/settings.json /c/Users/<你的用户名>/AppData/Roaming/Zed/settings.json
cp .zed/keymap.json /c/Users/<你的用户名>/AppData/Roaming/Zed/keymap.json
```

或在 Windows 文件资源管理器中手动复制 `.zed/` 下的两个文件到上述目录。

3. **重启 Zed**

   重新启动 Zed 使配置生效。

#### 方案 2: 从当前 Windows 客户端导出到仓库

如果你在当前 Windows 客户端修改了 Zed 配置，可以反向同步到仓库：

```bash
# 在仓库目录中执行
cp /c/Users/<你的用户名>/AppData/Roaming/Zed/settings.json .zed/settings.json
cp /c/Users/<你的用户名>/AppData/Roaming/Zed/keymap.json .zed/keymap.json
```

然后提交到 Git：

```bash
git add .zed/
git commit -m "Update zed config"
git push
```

## 扩展插件

本配置包含 13 个扩展插件，主要为主题和语言支持。

### 自动安装（Windows 客户端）

仓库提供了两个 Windows 扩展安装脚本：

1. **批处理脚本** (`install-zed-extensions.bat`):
   - 双击运行即可
   - 适合不熟悉 PowerShell 的用户

2. **PowerShell 脚本** (`install-zed-extensions.ps1`):
   - 右键 -> "使用 PowerShell 运行"
   - 或在 PowerShell 中执行: `\.\install-zed-extensions.ps1`
   - 更现代化，带彩色输出

### 手动安装

在 Zed 中按 `Ctrl+Shift+P` 打开命令面板，输入 `extensions: install extension`，然后搜索并安装以下扩展：

| 扩展 ID | 说明 |
|---------|------|
| `catppuccin` | Soothing pastel theme |
| `cursor` | Cursor IDE theme |
| `github-dark-default` | GitHub Dark theme |
| `html` | HTML language support |
| `kamui-dark-theme` | Kamui dark theme |
| `macos-classic` | macOS Classic theme |
| `make` | Makefile syntax highlighting |
| `midnight-marina` | Ocean inspired theme |
| `new-darcula` | New Darcula theme |
| `one-dark-darkened` | One Dark darkened |
| `one-dark-pro` | One Dark Pro theme |
| `the-dark-side` | The Dark Side theme |
| `vscode-dark-modern` | VSCode Dark Modern theme |

## Linux / macOS 配置路径

如果你在 Linux 或 macOS 上使用 Zed，配置路径为：

```text
~/.config/zed/settings.json
~/.config/zed/keymap.json
```

可以使用符号链接方式同步：

```bash
# 1. 备份现有配置
mv ~/.config/zed/settings.json ~/.config/zed/settings.json.backup.$(date +%Y%m%d)
mv ~/.config/zed/keymap.json ~/.config/zed/keymap.json.backup.$(date +%Y%m%d)

# 2. 创建符号链接
ln -s ~/ws/env/.zed/settings.json ~/.config/zed/settings.json
ln -s ~/ws/env/.zed/keymap.json ~/.config/zed/keymap.json
```

## 故障排查

### 问题 1: zed 命令未找到

**症状**: 运行脚本时提示 `zed: command not found`

**解决方案**:
1. 确认 Zed 已正确安装
2. 将 Zed CLI 添加到 PATH:
   - Windows 默认安装路径: `C:\Users\<你的用户名>\AppData\Local\Zed\`
3. 或者手动在 Zed 扩展面板中安装扩展

### 问题 2: 配置文件复制后未生效

**症状**: 复制 settings.json / keymap.json 后 Zed 行为未改变

**解决方案**:
1. 确认文件路径正确:
   - Windows: `C:\Users\<你的用户名>\AppData\Roaming\Zed\`
2. 检查 JSON 语法是否正确
3. 重启 Zed

### 问题 3: 扩展安装失败

**症状**: 脚本中部分扩展显示 `[失败]`

**解决方案**:
1. 检查网络连接
2. 某些扩展可能已经内置（如 `html`），无需重复安装
3. 手动在 Zed 扩展面板中安装失败的扩展

### 问题 4: 快捷键冲突

**症状**: 某些快捷键不生效

**解决方案**:
1. 打开 Zed 命令面板 (`Ctrl+Shift+P`)
2. 输入 `zed: open keymap` 检查当前 keymap
3. 输入 `zed: open default keymap` 查看默认快捷键
4. 确认 Vim 模式已启用（本 keymap 基于 Vim 模式）

## 维护说明

### 更新配置

在 Windows 客户端修改配置后，同步到仓库：

```bash
cd ~/ws/env
cp /c/Users/<你的用户名>/AppData/Roaming/Zed/settings.json .zed/settings.json
cp /c/Users/<你的用户名>/AppData/Roaming/Zed/keymap.json .zed/keymap.json
git add .zed/
git commit -m "Update zed config"
git push
```

### 更新扩展列表

安装新扩展后，更新 `.zed/extensions.txt`：

```bash
# 在 Zed 命令面板中查看已安装扩展，或手动编辑文件
code .zed/extensions.txt
```

然后同步到仓库：

```bash
git add .zed/extensions.txt
git commit -m "Update zed extensions"
git push
```

## 相关文档

- [主 README](./README.md) - 环境配置总览
- [Cursor 配置安装手册](./CURSOR-INSTALL.md) - Cursor 配置说明

## 支持

如有问题，请查看：
1. 本文档的故障排查部分
2. [Zed 官方文档](https://zed.dev/docs/)
3. [Zed 快捷键文档](https://zed.dev/docs/key-bindings)
