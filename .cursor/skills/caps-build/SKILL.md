---
name: caps-build
description: Intelligent build system for Caps project with auto-detection from git changes, container management, and target mapping. Use when compiling Caps, building packages, or when the user mentions building, compiling, or packaging Caps components.
---

# Caps Build System

智能构建系统,自动检测 git 变更并映射到正确的构建目标。

## 快速开始

使用 `scripts/caps-build.sh` 进行构建:

```bash
# 自动检测变更并构建
~/.cursor/skills/caps-build/scripts/caps-build.sh --auto

# 构建并安装到容器 (自动检测容器系统类型)
~/.cursor/skills/caps-build/scripts/caps-build.sh --auto --install

# 仅安装已有的包到容器 (不编译)
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_efsmi_deb

# 构建 RPM 包
~/.cursor/skills/caps-build/scripts/caps-build.sh --rpm --auto

# Debug 构建特定组件
~/.cursor/skills/caps-build/scripts/caps-build.sh --debug package_efsmi_deb

# 强制重新运行 cmake
~/.cursor/skills/caps-build/scripts/caps-build.sh --cmake --auto
```

## 核心功能

### 1. 自动目标检测

使用 `--auto` 标志自动分析 git 变更:
- 检查 `git diff` (未暂存的变更)
- 检查 `git diff --cached` (已暂存的变更)
- 检查 `git ls-files --others` (未跟踪的文件)
- 根据文件路径映射到对应的构建目标

### 2. 容器管理

脚本自动处理容器环境:
- 检测容器是否运行
- 如果未运行,自动启动: `efdocker run dev -u $(id -u):$(id -g)`
- 使用当前用户权限避免权限问题

### 3. 智能 CMake 管理

只在必要时运行 cmake:
- 检测 `build.ninja` 是否存在
- 检测 build type 是否变更 (Debug ↔ Release)
- 使用 `--cmake` 强制重新配置

## 源码到目标映射

| 源码目录 | 构建目标 |
|---------|---------|
| `runtime/`, `lepton/` | `package_topsruntime_deb` |
| `compiler/` | `package_topscc_deb` |
| `devtools/topsprof/` | `package_topsprof_deb` |
| `devtools/topspti/`, `devtools/topspti_external/` | `package_topspti_deb` |
| `devtools/topsgdb/` | `package_topsgdb_deb` |
| `devtools/topsdbgapi/` | `package_topsdbgapi_deb` |
| `devtools/topstx/` | `package_topstx_deb` |
| `devtools/tops_sanitizer/` | `package_tops_sanitizer_deb` |
| `devtools/topsbit/` | `topsbit` |
| `devtools/topsbuf/`, `devtools/topsrt_hook/` | `package_topsruntime_deb` |
| `libs/topscodec/` | `package_topscodec_deb` |
| `libs/topsfile/` | `package_topsfile_deb` |
| `libs/mori/` | `package_mori_gcu_deb` |
| `utilities/efml/`, `utilities/pyefml/` | `package_efml_deb` |
| `utilities/efsmi/` | `package_efsmi_deb` |
| `utilities/efnetq/` | `package_efnetq_client_deb` |
| `utilities/enflame-persistenced/` | `package_enflame_persistenced_deb` |
| `utilities/topsenvcheck/` | `package_topsenvcheck` |
| `samples/` | `package_topscc_samples` |
| `package/`, `kmd/` | `package_kmd` |
| `cmake/` | `package_topsruntime_deb` |

## 所有可用目标

### DEB 包 (默认)
- `package_topsruntime_deb` - Runtime (efdrv + topsrt + lepton)
- `package_topscc_deb` - Compiler (rtcu + topscc + sanitizer)
- `package_topsprof_deb` - Profiler
- `package_topspti_deb` - PTI
- `package_topsgdb_deb` - GDB debugger
- `package_topsdbgapi_deb` - Debug API
- `package_topstx_deb` - TopsTX
- `package_tops_sanitizer_deb` - Sanitizer
- `package_topscodec_deb` - Codec library
- `package_topsfile_deb` - File library
- `package_mori_gcu_deb` - Mori
- `package_efml_deb` - EFML
- `package_efsmi_deb` - EFSMI
- `package_efnetq_client_deb` - EFNETQ client
- `package_efnetq_agent_deb` - EFNETQ agent
- `package_enflame_persistenced_deb` - Persistenced
- `package_kmd` - Kernel mode driver
- `package_topscc_samples` - Samples
- `package_all_deb` - All deb packages
- `package_all` - Everything

### RPM 包
使用 `--rpm` 标志将 `_deb` 替换为 `_rpm`。

## 命令行选项

```bash
Options:
  --src DIR         Caps 源码根目录 (默认: 当前目录)
  --debug           使用 CMAKE_BUILD_TYPE=Debug
  --cmake           强制重新运行 cmake
  --auto            从 git 变更自动检测目标
  --rpm             构建 RPM 包而非 DEB (默认: DEB)
  --install         构建完成后安装包到容器 (需要 sudo 权限)
  --install-only    跳过构建,仅安装已有包到容器 (需要 sudo 权限)
  -j N              并行任务数 (默认: 45)
  -h, --help        显示帮助信息
```

## 使用示例

### 场景 1: 修改了 runtime 代码
```bash
# 自动检测并构建 runtime
~/.cursor/skills/caps-build/scripts/caps-build.sh --auto
```

### 场景 2: 需要 Debug 版本
```bash
# Debug 构建
~/.cursor/skills/caps-build/scripts/caps-build.sh --debug --auto
```

### 场景 3: 构建多个组件
```bash
# 手动指定多个目标
~/.cursor/skills/caps-build/scripts/caps-build.sh package_topsruntime_deb package_efsmi_deb
```

### 场景 4: 构建 RPM 包
```bash
# 构建 RPM 包
~/.cursor/skills/caps-build/scripts/caps-build.sh --rpm --auto
```

### 场景 5: CMake 配置变更
```bash
# 强制重新运行 cmake
~/.cursor/skills/caps-build/scripts/caps-build.sh --cmake --auto
```

### 场景 6: 构建并安装包
```bash
# 自动检测、构建并安装到容器
~/.cursor/skills/caps-build/scripts/caps-build.sh --auto --install

# 构建并安装特定组件到容器
~/.cursor/skills/caps-build/scripts/caps-build.sh package_efsmi_deb --install

# 构建 RPM 包并安装到容器
~/.cursor/skills/caps-build/scripts/caps-build.sh --rpm --auto --install
```

### 场景 7: 仅安装已有包 (不编译)
```bash
# 仅安装 efsmi 包到容器
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_efsmi_deb

# 仅安装 runtime 包到容器
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_topsruntime_deb

# 仅安装所有包到容器
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_all_deb
```

## 工作流程

1. **分析变更**: 如果使用 `--auto`,扫描 git 变更
2. **映射目标**: 根据文件路径映射到构建目标
3. **检查容器**: 确保开发容器运行中
4. **检测系统**: 如果需要安装,自动检测容器系统类型 (DEB/RPM)
5. **CMake 配置**: 仅在必要时运行 cmake (install-only 模式跳过)
6. **并行构建**: 使用 ninja 并行构建目标 (install-only 模式跳过)
7. **安装包**: 如果使用 `--install`,在容器中自动安装包 (需要 sudo)

## 容器权限说明

为避免构建产物权限问题,容器应以当前用户身份运行:

```bash
efdocker run dev -u $(id -u):$(id -g)
```

脚本会自动使用此命令启动容器,确保生成的文件具有正确的所有权。

## 故障排查

### 容器未运行
脚本会自动检测并启动容器。如果启动失败,手动运行:
```bash
efdocker run dev -u $(id -u):$(id -g)
```

### CMake 配置错误
强制重新配置:
```bash
~/.cursor/skills/caps-build/scripts/caps-build.sh --cmake --auto
```

### 构建失败
检查具体目标:
```bash
# 查看构建日志
~/.cursor/skills/caps-build/scripts/caps-build.sh package_topsruntime_deb
```

## 安装功能

### 两种安装模式

#### 1. 构建并安装 (`--install`)
构建完成后自动安装包到容器:
```bash
~/.cursor/skills/caps-build/scripts/caps-build.sh --auto --install
~/.cursor/skills/caps-build/scripts/caps-build.sh package_efsmi_deb --install
```

#### 2. 仅安装模式 (`--install-only`)
跳过编译,直接安装已有的包到容器:
```bash
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_efsmi_deb
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_topsruntime_deb
```

### 自动系统检测

脚本会自动检测容器中的包管理系统:
- **检测到 dpkg**: 使用 `sudo dpkg -i` + `sudo apt-get install -f -y`
- **检测到 rpm**: 使用 `sudo rpm -Uvh --force`
- **无法检测**: 报错退出

这意味着你**不需要手动指定 --rpm**,脚本会根据容器实际系统自动选择。

### 安装逻辑
- 根据目标名称自动查找对应的包文件 (支持 .deb 和 .rpm)
- 如果目标是 `package_all_*`,安装构建目录中的所有包
- 如果找不到对应的包文件,显示警告但不中断流程
- **所有安装操作在容器内执行**,不影响宿主机环境

### 注意事项
- **安装需要容器内 sudo 权限**,脚本会自动使用 sudo
- 只在用户明确使用 `--install` 或 `--install-only` 时才安装
- `--install-only` 模式会跳过 cmake 和 ninja 构建步骤
- 安装失败不会影响构建结果
- 包安装到容器中,方便在容器环境中测试

## 最佳实践

1. **优先使用 --auto**: 让脚本自动检测需要构建的组件
2. **Debug 构建**: 开发时使用 `--debug` 获得更好的调试信息
3. **增量构建**: 脚本默认增量构建,只重新编译变更的文件
4. **并行构建**: 默认使用 45 个并行任务,可用 `-j` 调整
5. **容器管理**: 让脚本自动管理容器,无需手动启动
6. **快速测试**: 使用 `--install-only` 快速安装已有包,无需重新编译
7. **系统自适应**: 安装时无需指定 --rpm,脚本自动检测容器系统类型
8. **谨慎安装**: 只在测试验证时使用 `--install`,避免误覆盖容器中的系统包

## 注意事项

- 脚本必须从 Caps 源码根目录运行,或使用 `--src` 指定
- 构建目录固定为 `$(dirname $CAPS_SRC)/runtime_build`
- 如果无法检测到目标,默认构建 `package_topsruntime_deb`
- RPM 和 DEB 包不能同时构建,需分别运行
- **安装功能需要容器内 sudo 权限**,只在用户明确要求时使用 `--install` 或 `--install-only`
- 包安装到容器中,不会影响宿主机环境
- 安装时会自动检测容器系统类型 (DEB/RPM),无需手动指定
- `--install-only` 模式适合快速测试已编译好的包,无需重新编译
