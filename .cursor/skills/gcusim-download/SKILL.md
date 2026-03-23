---
name: gcusim-download
description: Download GcuSim simulator libraries from artifact.enflame.cn. Use when user wants to download, update, or install gcusim, libgcusim, simulator libraries, or mentions gcu400/gcu450/gcu500 simulator, or says "下载gcusim", "更新gcusim", "下载仿真库".
---

# GcuSim Download Skill

自动下载和管理 GcuSim 仿真库的工具。

## 快速开始

```bash
# 下载所有架构的最新版本
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --all

# 下载指定架构的最新版本
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --arch gcu450

# 下载指定版本
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --version 4.5.4

# 下载指定架构的指定版本
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --arch gcu450 --version 4.5.4

# 指定下载目录（默认为当前目录）
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --all --dir /path/to/dir
```

## 架构和版本对应关系

| 架构 | 版本前缀 | 仿真库文件 | INTERNAL_GCU_SIM | 说明 |
|------|---------|-----------|------------------|------|
| GCU400 | 4.0.x | libgcusim.so | LIBRA | Libra L300/L600/L900 |
| GCU450 | 4.5.x | libgcusim450.so | LIBRAH | Libra-H (GCU410) |
| GCU500 | 5.0.x | libgcusim5.so | DRACO | Draco 系列 |

### 版本号规则

版本号格式为 `A.B.C`，其中：
- `A.B` 是架构号（固定：4.0、4.5、5.0）
- `C` 是版本号，采用**字典序比较**（逐位比较数字字符）

例如版本大小比较：
- `5.0.9` > `5.0.47`（因为 `9` > `4`）
- `5.0.25` > `5.0.241`（因为 `2=2`，但 `5` > `4`）
- `5.0.9` > `5.0.241` > `5.0.25` > `5.0.47`

## 自然语言触发示例

当用户说以下内容时，调用对应的脚本命令：

| 用户输入 | 执行命令 | 说明 |
|---------|---------|------|
| "下载gcusim" | `--all` | 下载所有架构最新版 |
| "更新gcusim" | `--all` | 下载所有架构最新版 |
| "下载gcu450" | `--arch gcu450` | 下载 GCU450 最新版 |
| "更新gcu450仿真库" | `--arch gcu450` | 下载 GCU450 最新版 |
| "下载4.5.4" | `--version 4.5.4` | 下载所有架构的 4.5.4 版本 |
| "下载454版本" | `--version 4.5.4` | 支持简写格式 |
| "下载gcu450 4.5.4" | `--arch gcu450 --version 4.5.4` | 指定架构和版本 |

## 版本号格式支持

脚本支持多种版本号格式：

- **完整格式**: `4.5.4` → `4.5.4`
- **省略点**: `454` → `4.5.4`
- **主版本**: `45` → 自动查找 4.5.x 最新版本

## 使用流程

### 1. 基本用法

```bash
# 进入项目根目录
cd /home/stephen.hu/ws/gitee/caps

# 下载所有架构最新版本到根目录
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --all
```

### 2. 下载后使用

```bash
# 配置环境变量
export LD_LIBRARY_PATH=/home/stephen.hu/ws/gitee/caps:$LD_LIBRARY_PATH

# 使用 GCU450 仿真
export INTERNAL_GCU_SIM=LIBRAH

# 编译和运行
cd samples/Samples/0_Introduction/simpleVectorAdd
make TARGET_TOPS_ARCH=gcu450
./bin/gcu450/simpleVectorAdd
```

## 脚本参数说明

### 必选参数（至少一个）

- `--all`: 下载所有架构（gcu400, gcu450, gcu500）的最新版本
- `--arch <arch>`: 下载指定架构，可选值: `gcu400`, `gcu450`, `gcu500`
- `--version <version>`: 下载指定版本，支持格式: `4.5.4`, `454`, `45`

### 可选参数

- `--dir <directory>`: 指定下载目录，默认为当前目录
- `--verbose`: 显示详细日志
- `--dry-run`: 仅显示将要执行的操作，不实际下载

## 工作原理

1. **版本检测**: 访问 `http://artifact.enflame.cn/ui/native/release_center/GCUSIM/`，解析 HTML 获取最新版本号
2. **版本过滤**: 仅保留目录名完全由数字和小数点组成的版本，自动过滤带特殊字符的版本（如 `4.5.4_profile`、`1.0.81(super)` 等）
3. **版本号解析**: 将简写格式（如 `454`）转换为完整格式（`4.5.4`）
4. **下载**: 使用 `curl` 从 artifact 服务器下载对应的 `.so` 文件，支持断点续传和自动重试
5. **覆盖**: 直接覆盖目标目录中的同名文件
6. **验证**: 检查文件是否下载成功，显示文件大小

## 错误处理

- **网络错误**: 显示错误信息，提示检查网络连接
- **版本不存在**: 提示版本号不存在，建议使用 `--list` 查看可用版本
- **权限错误**: 提示使用 sudo 或更改目标目录
- **下载失败**: 保留原文件（如果存在），不覆盖

## 注意事项

1. 需要能够访问燧原内网 `artifact.enflame.cn`
2. 下载的文件会直接覆盖同名文件，无备份
3. 默认下载到项目根目录，确保有写入权限
4. 建议在下载前确认当前工作目录

## 高级用法

### 列出可用版本

```bash
# 列出所有可用版本
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --list

# 列出指定架构的可用版本
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --list --arch gcu450
```

### 批量下载

```bash
# 下载多个版本到不同目录
for ver in 4.5.3 4.5.4 4.5.5; do
    ~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh \
        --arch gcu450 --version $ver --dir gcusim-$ver
done
```

## 示例会话

**用户**: "下载一下gcusim"

**Claude 执行**:
```bash
cd /home/stephen.hu/ws/gitee/caps
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --all
```

**输出**:
```
Downloading GcuSim libraries...
✓ Detected latest versions:
  - GCU400: 4.0.5
  - GCU450: 4.5.4
  - GCU500: 5.0.1

Downloading libgcusim.so (4.0.5)...
✓ Downloaded to /home/stephen.hu/ws/gitee/caps/libgcusim.so (45.2 MB)

Downloading libgcusim450.so (4.5.4)...
✓ Downloaded to /home/stephen.hu/ws/gitee/caps/libgcusim450.so (48.1 MB)

Downloading libgcusim5.so (5.0.1)...
✓ Downloaded to /home/stephen.hu/ws/gitee/caps/libgcusim5.so (52.3 MB)

All downloads completed successfully!
```
