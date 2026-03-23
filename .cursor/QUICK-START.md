# Cursor 配置快速开始

## 一键安装

```bash
cd /path/to/this/repo
bash install-cursor-config.sh
```

## 配置内容

| 配置 | 数量 | 说明 |
|------|------|------|
| Skills | 21个 | Agent 技能脚本（不含 GPU skills） |
| Rules | 2个 | AI 行为规则 |
| MCP | 2个 | Model Context Protocol 服务器 |
| Extensions | 7个 | 编辑器扩展插件 |

**GPU 开发**: 如需 CUDA/CUTLASS/Triton/SGLang 支持，请参考 https://github.com/slowlyC/agent-gpu-skills

## 安装后检查

```bash
# 检查符号链接
ls -la ~/.agents/skills
ls -la ~/.cursor/rules
ls -la ~/.cursor/mcp.json

# 检查扩展
cursor --list-extensions
```

## Windows 客户端配置

### 1. 安装扩展插件

在 Windows 上运行以下脚本之一：

```powershell
# 批处理脚本（双击运行）
install-cursor-extensions.bat

# PowerShell 脚本（推荐，带彩色输出）
.\install-cursor-extensions.ps1
```

### 2. 复制配置文件

需要手动复制以下文件到 Windows 客户端：

**源位置**: `.cursor/settings.json`, `.cursor/keybindings.json`

**目标位置**: `C:\Users\<用户名>\AppData\Roaming\Cursor\User\`

```powershell
# 在 Windows PowerShell 中执行
copy <仓库路径>\.cursor\settings.json C:\Users\<用户名>\AppData\Roaming\Cursor\User\
copy <仓库路径>\.cursor\keybindings.json C:\Users\<用户名>\AppData\Roaming\Cursor\User\
```

## 常用命令

```bash
# 更新配置（从远程仓库）
cd /path/to/this/repo
git pull

# 提交配置修改
cd /path/to/this/repo
git add .cursor/
git commit -m "Update cursor config"
git push

# 重新导出扩展列表
cursor --list-extensions > .cursor/extensions.txt
```

## 故障排查

### Skills 不生效

```bash
# 检查符号链接
ls -la ~/.agents/skills

# 重新创建链接
rm ~/.agents/skills
ln -s /path/to/this/repo/.cursor/skills ~/.agents/skills

# 重启 Cursor
```

### 扩展安装失败

```bash
# 手动安装扩展
cursor --install-extension bierner.markdown-mermaid --force
cursor --install-extension fabiospampinato.vscode-highlight --force
# ... 其他扩展
```

### MCP 服务器无法启动

```bash
# 检查 Python 环境
python --version

# 检查 Node.js 环境
node --version
npx --version

# 查看 Cursor 日志
```

## 详细文档

- [完整安装手册](../CURSOR-INSTALL.md)
- [配置说明](./README.md)
- [主 README](../README.md)
