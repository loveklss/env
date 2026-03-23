# Caps Build Skill

在 Cursor AI 助手中智能编译 Caps 工程。

## 在 Cursor 中使用

直接用自然语言告诉 AI 助手你要编译什么，AI 会自动识别并调用此 Skill。

### 常用指令示例

| 对 AI 说 | AI 会做什么 |
|---|---|
| "编译 caps" | 自动检测 git 变更，构建对应组件 |
| "编译 efsmi" | 构建 efsmi 组件 |
| "编译 debug 版本的 efsmi" | 构建 efsmi 的 debug 版本 |
| "编译 runtime" | 构建 runtime 组件 |
| "编译我改动的代码" | 分析 git 变更，自动选择构建目标 |
| "重新 cmake 后编译 runtime" | 强制重新配置后构建 runtime |
| "编译所有 deb 包" | 构建所有 deb 包 |
| "编译 efsmi 和 efml" | 批量构建多个组件 |
| "构建 rpm 包" | 构建 rpm 格式的包 |
| "debug 编译 runtime" | 构建 runtime 的 debug 版本 |

### AI 助手的自动行为

1. **智能触发**：当你提到"编译"、"构建"、"build"、"compile"等关键词时自动激活
2. **容器管理**：自动检测容器状态，未运行时自动启动
3. **构建目录**：自动创建和管理 `runtime_build/` 目录
4. **CMake 配置**：智能判断是否需要重新运行 cmake
5. **目标检测**：从 git 变更自动识别需要构建的组件
6. **并行编译**：自动使用多核并行加速编译
7. **权限处理**：确保构建产物具有正确的文件权限

## 使用场景

### 场景 1：日常开发 - 快速编译变更

```
你: "编译我改的代码"

AI: 自动分析 git 变更
    检测到修改了 runtime/efdrv/src/core/hal/hal.cpp
    自动构建 package_topsruntime_deb
```

### 场景 2：调试 - Debug 版本

```
你: "编译 debug 版本的 runtime"

AI: 检测当前构建类型
    切换到 Debug 模式
    重新配置 cmake
    构建 debug 版本
```

### 场景 3：发布 - RPM 包

```
你: "构建 rpm 包"

AI: 分析 git 变更
    构建对应的 rpm 格式包
```

### 场景 4：配置变更 - 强制 CMake

```
你: "重新 cmake 后编译"

AI: 强制重新运行 cmake
    重新生成构建配置
    构建目标组件
```

### 场景 5：多组件 - 批量构建

```
你: "编译 runtime 和 efsmi"

AI: 依次构建 runtime 和 efsmi
    生成对应的 deb 包
```

## 源码到组件映射

AI 会根据你修改的源码路径自动选择构建目标：

| 修改的源码目录 | 自动构建的组件 |
|---------|---------|
| `runtime/`, `lepton/` | Runtime (efdrv + topsrt + lepton) |
| `compiler/` | Compiler (rtcu + topscc + sanitizer) |
| `devtools/topsprof/` | Profiler |
| `devtools/topspti/` | PTI |
| `devtools/topsgdb/` | GDB debugger |
| `libs/topscodec/` | Codec library |
| `libs/mori/` | Mori |
| `utilities/efml/` | EFML |
| `utilities/efsmi/` | EFSMI |
| `kmd/` | Kernel mode driver |
| `samples/` | Samples |

完整映射表见 [SKILL.md](SKILL.md)。

## 可用的构建目标

### DEB 包（默认）

- `package_topsruntime_deb` - Runtime (efdrv + topsrt + lepton)
- `package_topscc_deb` - Compiler
- `package_topsprof_deb` - Profiler
- `package_topspti_deb` - PTI
- `package_topsgdb_deb` - GDB debugger
- `package_topscodec_deb` - Codec library
- `package_mori_gcu_deb` - Mori
- `package_efml_deb` - EFML
- `package_efsmi_deb` - EFSMI
- `package_kmd` - Kernel mode driver
- `package_all_deb` - All deb packages

### RPM 包

使用 `--rpm` 标志构建 rpm 格式的包。

## 常见问题

### 容器未运行怎么办？

AI 会自动启动容器，无需手动操作。如果自动启动失败，可以手动运行：
```bash
efdocker run dev -u $(id -u):$(id -g)
```

### 构建失败怎么办？

1. 检查编译错误信息
2. 确认源码没有语法错误
3. 可以尝试："重新 cmake 后编译"
4. 或者清理后重新构建："清理构建目录后编译"

### 自动检测没有找到目标？

- 确认有 git 变更：`git status`
- 直接指定组件名称："编译 runtime"
- 如果没有变更，默认会构建 runtime

### 需要 Debug 版本？

直接说："编译 debug 版本的 xxx"，AI 会自动切换到 Debug 模式。

### 需要 RPM 包？

直接说："构建 rpm 包"，AI 会自动使用 rpm 格式。

## 最佳实践

1. **优先使用自动检测**：说"编译我改的代码"，让 AI 自动识别
2. **开发时用 Debug**：获得更好的调试信息
3. **发布前用 Release**：获得更好的性能（默认）
4. **让 AI 管理容器**：无需手动启动或管理容器
5. **遇到问题重新 cmake**：配置问题时说"重新 cmake 后编译"

## 与 Rule 的区别

| 特性 | Rule (旧方式) | Skill (新方式) |
|---|---|---|
| 加载方式 | 每次对话自动加载 | 需要时才加载 |
| 上下文占用 | 始终占用 | 按需占用 |
| 适用场景 | 全局规则 | 特定任务 |
| 触发机制 | 自动应用 | 智能触发 |

Skill 方式更节省 token，只在需要编译时才加载相关知识。
