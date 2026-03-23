# Windows 客户端配置安装指南

本文档专门说明如何在 Windows 客户端上配置 Cursor。

## 前提条件

- 已在 Linux 服务器上运行 `install-cursor-config.sh`
- 已克隆本仓库到 Windows 本地（或通过网络访问）
- Cursor 已安装在 Windows 上

## 配置项说明

由于你使用 **Windows 客户端连接远程 Linux 服务器**，以下配置需要在 Windows 客户端单独设置：

| 配置项 | 说明 | 位置 |
|--------|------|------|
| **扩展插件** | 编辑器扩展 | Windows 客户端 |
| **Settings** | 编辑器设置 | Windows 客户端 |
| **Keybindings** | 快捷键配置 | Windows 客户端 |

而以下配置在 Linux 服务器端：

| 配置项 | 说明 | 位置 |
|--------|------|------|
| **Skills** | Agent 技能 | Linux 服务器 (~/.agents/skills) |
| **Rules** | AI 规则 | Linux 服务器 (~/.cursor/rules) |
| **MCP** | MCP 服务器 | Linux 服务器 (~/.cursor/mcp.json) |

## 安装步骤

### 步骤 1: 安装扩展插件

仓库中提供了两个自动安装脚本，任选其一：

#### 方法 A: 批处理脚本（简单）

1. 在文件资源管理器中找到 `install-cursor-extensions.bat`
2. 双击运行
3. 等待安装完成

#### 方法 B: PowerShell 脚本（推荐）

1. 在文件资源管理器中找到 `install-cursor-extensions.ps1`
2. 右键 -> "使用 PowerShell 运行"
3. 如果提示执行策略错误，在 PowerShell 中运行：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
4. 等待安装完成

#### 方法 C: 手动安装

如果脚本无法运行，可以手动在 Cursor 中安装：

1. 在 Cursor 中按 `Ctrl+Shift+X` 打开扩展面板
2. 搜索并安装以下 7 个扩展：

| 扩展 ID | 说明 |
|---------|------|
| `bierner.markdown-mermaid` | Mermaid 图表预览 |
| `fabiospampinato.vscode-highlight` | 语法高亮增强 |
| `llvm-vs-code-extensions.vscode-clangd` | C/C++ Language Server |
| `ms-ceintl.vscode-language-pack-zh-hans` | 中文语言包 |
| `ms-vscode.cmake-tools` | CMake 工具 |
| `shd101wyy.markdown-preview-enhanced` | Markdown 预览增强 |
| `topscc-vs-code-extensions.vscode-tlsp` | TOPS Language Server |

### 步骤 2: 复制配置文件

#### 方法 A: 使用 PowerShell 命令

```powershell
# 替换 <仓库路径> 为实际路径，例如 D:\workspace\env
$repoPath = "<仓库路径>"
$userPath = "$env:APPDATA\Cursor\User"

# 备份现有配置（可选）
if (Test-Path "$userPath\settings.json") {
    Copy-Item "$userPath\settings.json" "$userPath\settings.json.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
}
if (Test-Path "$userPath\keybindings.json") {
    Copy-Item "$userPath\keybindings.json" "$userPath\keybindings.json.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
}

# 复制新配置
Copy-Item "$repoPath\.cursor\settings.json" "$userPath\settings.json"
Copy-Item "$repoPath\.cursor\keybindings.json" "$userPath\keybindings.json"

Write-Host "配置文件已复制完成！" -ForegroundColor Green
```

#### 方法 B: 手动复制

1. 打开文件资源管理器，导航到仓库的 `.cursor` 目录
2. 复制 `settings.json` 和 `keybindings.json`
3. 打开 Windows 用户配置目录：
   - 按 `Win+R`
   - 输入 `%APPDATA%\Cursor\User`
   - 按回车
4. 粘贴文件，覆盖现有配置

### 步骤 3: 重启 Cursor

配置文件复制完成后，重启 Cursor 使配置生效。

## 配置内容说明

### settings.json 主要配置

- **Vim 模式**: Leader 键为 `,`，支持系统剪贴板
- **智能搜索**: 大小写智能匹配
- **C/C++ 支持**: 禁用默认 IntelliSense，使用 Clangd
- **文件排除**: 自动排除 `.cache` 目录
- **丰富的快捷键**: Normal、Visual、Insert 模式的 Vim 快捷键

### keybindings.json 主要配置

- `Ctrl+I`: 触发 Composer Agent 模式
- `Escape`: 关闭各种面板（侧边栏、终端、搜索等）
- `Ctrl+Q`: 完全禁用（避免误触退出）

## 验证安装

### 检查扩展

1. 在 Cursor 中按 `Ctrl+Shift+X`
2. 查看已安装的扩展列表
3. 确认 7 个扩展都已安装

### 检查配置

1. 在 Cursor 中按 `Ctrl+,` 打开设置
2. 搜索 `vim.leader`，应该显示为 `,`
3. 按 `Escape` 键，侧边栏应该关闭

### 检查快捷键

1. 按 `Ctrl+I`，应该打开 Composer Agent 模式
2. 按 `Ctrl+Q`，应该没有任何反应（已禁用）

## 故障排查

### 问题 1: PowerShell 脚本无法运行

**症状**: 提示"无法加载文件，因为在此系统上禁止运行脚本"

**解决方案**:
```powershell
# 以管理员身份打开 PowerShell，运行：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 问题 2: cursor 命令未找到

**症状**: 脚本提示找不到 cursor 命令

**解决方案**:
1. 确认 Cursor 已正确安装
2. 将 Cursor 添加到 PATH 环境变量
3. 或者使用手动安装方法（在 Cursor 扩展面板中安装）

### 问题 3: 配置文件复制后不生效

**症状**: 复制配置文件后，设置没有改变

**解决方案**:
1. 确认文件复制到了正确的位置：`%APPDATA%\Cursor\User\`
2. 完全关闭 Cursor（包括系统托盘图标）
3. 重新启动 Cursor
4. 如果还不生效，检查文件权限

### 问题 4: 扩展安装失败

**症状**: 某些扩展安装失败

**解决方案**:
1. 检查网络连接
2. 在 Cursor 扩展面板中手动搜索并安装失败的扩展
3. 某些扩展可能需要特定的依赖，查看扩展说明

## 配置同步

### 从 Windows 导出配置到仓库

如果你在 Windows 客户端修改了配置，想要同步到仓库：

```powershell
# 复制配置到仓库
$repoPath = "<仓库路径>"
$userPath = "$env:APPDATA\Cursor\User"

Copy-Item "$userPath\settings.json" "$repoPath\.cursor\settings.json"
Copy-Item "$userPath\keybindings.json" "$repoPath\.cursor\keybindings.json"

# 提交到 Git
cd $repoPath
git add .cursor/settings.json .cursor/keybindings.json
git commit -m "Update Windows client settings"
git push
```

### 从仓库更新 Windows 配置

如果仓库中的配置有更新，想要同步到 Windows 客户端：

```powershell
# 在仓库目录
git pull

# 复制到 Windows 客户端
$repoPath = Get-Location
$userPath = "$env:APPDATA\Cursor\User"

Copy-Item "$repoPath\.cursor\settings.json" "$userPath\settings.json"
Copy-Item "$repoPath\.cursor\keybindings.json" "$userPath\keybindings.json"
```

## 相关文档

- [主安装手册](./CURSOR-INSTALL.md) - 完整安装说明
- [快速开始](./cursor/QUICK-START.md) - 快速参考
- [主 README](./README.md) - 环境配置总览

## 总结

Windows 客户端配置包括：
- ✅ 7 个扩展插件（通过脚本或手动安装）
- ✅ settings.json（编辑器设置）
- ✅ keybindings.json（快捷键配置）

配置完成后，你的 Windows Cursor 客户端将拥有：
- 完整的 Vim 模式支持
- C/C++ 开发环境（Clangd）
- Markdown 和 Mermaid 支持
- 中文界面
- 优化的快捷键布局
