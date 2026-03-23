---
name: test-runner
description: Compile and run TOPS test programs with automatic dependency installation and multi-arch support. Use when user wants to compile, test, or run .cpp files, mentions "编译", "测试", "运行", "执行", or provides file/directory paths with compilation intent.
---

# Test Runner

智能编译和执行 TOPS 测试程序，自动处理依赖安装、环境配置和日志收集。

## ⚠️ 重要：AI 行为规范

### 1. 遇到错误时的处理原则

**当编译或运行失败时，AI 必须遵循以下原则：**

- ✅ **仅展示错误日志**：将脚本输出的错误信息原样呈现
- ❌ **不要分析错误**：不要搜索代码、查找定义、分析原因
- ❌ **不要尝试修复**：不要修改代码、不要建议方案
- ✅ **等待用户指示**：让用户决定下一步（修复、切换架构等）

**正确示例**：
```
编译失败了，错误日志如下：
[显示错误日志]
请检查错误信息，需要我帮忙修复吗？
```

**错误示例（不要这样做）**：
```
编译失败了。让我搜索一下代码仓库...
[进行 Grep/Read 操作]
看起来需要使用新的 API...
```

### 2. 智能执行判断

**AI 必须根据用户意图决定是否执行程序：**

- **仅编译**（添加 `--compile-only`）：用户只说"编译"、"compile"、"build"
- **编译+执行**（不添加 `--compile-only`）：用户说"测试"、"运行"、"执行"、"test"、"run"、"execute"，或明确说"编译并运行"

**示例**:
- ❌ 用户说"编译 test.cpp" → 不要自动执行
- ✅ 用户说"测试 test.cpp" → 编译并执行
- ✅ 用户说"运行 test.cpp" → 编译并执行
- ❌ 用户说"编译这个目录" → 不要自动执行
- ✅ 用户说"编译并运行这个目录" → 编译并执行

## 快速开始

```bash
# 编译单个文件（使用缓存的 arch）
~/.cursor/skills/test-runner/scripts/test-runner.sh test.cpp

# 编译并指定 arch（推荐方式）
~/.cursor/skills/test-runner/scripts/test-runner.sh --arch gcu450 test.cpp

# 智能架构识别（新功能）- 自动识别 gcu450 为架构参数
~/.cursor/skills/test-runner/scripts/test-runner.sh gcu450 test.cpp

# 编译多个 arch
~/.cursor/skills/test-runner/scripts/test-runner.sh --arch gcu450 --arch gcu500 test.cpp
~/.cursor/skills/test-runner/scripts/test-runner.sh gcu450 gcu500 test.cpp  # 简化写法

# 编译目录下所有文件
~/.cursor/skills/test-runner/scripts/test-runner.sh --arch gcu450 samples/Samples/0_Introduction/simpleVectorAdd/

# 仅编译不执行
~/.cursor/skills/test-runner/scripts/test-runner.sh --compile-only --arch gcu450 test.cpp

# 仅执行已编译的程序
~/.cursor/skills/test-runner/scripts/test-runner.sh --run-only --arch gcu450 test.cpp
```

## 核心功能

### 1. 智能输入解析

支持多种输入格式：

- **单个文件**: `test.cpp`
- **多个文件**: `test1.cpp test2.cpp test3.cpp`
- **目录**: `samples/Samples/0_Introduction/simpleVectorAdd/`
- **通配符**: `*.cpp` 或 `test*.cpp`

**智能架构识别**（新功能）:
- 自动识别 `gcu400`、`gcu450`、`gcu500` 参数为架构
- 无需显式使用 `--arch` 标志
- 示例: `test-runner.sh gcu450 test.cpp` 等同于 `test-runner.sh --arch gcu450 test.cpp`
- 如果误将架构名作为文件名传入，会给出友好提示

### 2. Arch 缓存机制

- 首次使用时，如果未指定 arch，会询问用户
- 用户指定的 arch 会自动缓存到 `.cursor/skills/test-runner/arch-cache.json`
- 下次编译时，如果不指定 arch，自动使用缓存的 arch
- 始终缓存用户最后一次提到的 arch

**缓存文件格式**:
```json
{
    "last_archs": ["gcu450", "gcu500"],
    "timestamp": "2026-03-18T14:30:00Z"
}
```

### 3. 自动依赖管理

编译前自动检查并安装依赖：

1. **topscc 编译器**: 如果不存在，自动调用 `caps-build` 安装
   - `package_topscc_deb`
   - `package_topsruntime_deb`

2. **gcusim 仿真库**: 如果不存在，自动调用 `gcusim-download` 下载
   - gcu400 → `libgcusim.so`
   - gcu450 → `libgcusim450.so`
   - gcu500 → `libgcusim5.so`

### 4. 多架构支持

- 支持同时指定多个 arch（如 `--arch gcu450 --arch gcu500`）
- 顺序编译每个 arch
- 编译失败时停止当前 arch，继续下一个 arch
- 执行所有成功编译的版本

### 5. 完整日志收集

- **编译日志**: 保存到 `<binary>.compile.log`
- **运行日志**: 保存到 `<binary>.run.log`
- 编译失败时显示完整编译错误
- 执行失败时显示最后 50 行日志

## 架构和环境配置

| 架构 | INTERNAL_GCU_SIM | 仿真库 | 编译选项 |
|------|------------------|--------|---------|
| gcu400 | LIBRA | libgcusim.so | -arch gcu400 |
| gcu450 | LIBRAH | libgcusim450.so | -arch gcu450 |
| gcu500 | DRACO | libgcusim5.so | -arch gcu500 |

## 自然语言触发示例

| 用户输入 | 解析结果 | 是否执行 |
|---------|---------|---------|
| "编译这个文件 test.cpp" | 文件: test.cpp, arch: 使用缓存或询问 | **否** (仅编译) |
| "编译 test.cpp" | 文件: test.cpp, arch: 使用缓存或询问 | **否** (仅编译) |
| "测试 test.cpp 用 gcu450" | 文件: test.cpp, arch: gcu450 | **是** (编译+执行) |
| "运行 test.cpp" | 文件: test.cpp, arch: 使用缓存或询问 | **是** (编译+执行) |
| "编译并运行 simpleVectorAdd/" | 目录下所有 .cpp, arch: 使用缓存或询问 | **是** (编译+执行) |
| "用 gcu450 和 gcu500 测试这些文件" | arch: [gcu450, gcu500], 保存到缓存 | **是** (编译+执行) |
| "编译这个目录" | 目录下所有 .cpp, arch: 使用缓存或询问 | **否** (仅编译) |
| "执行 test.cpp" | 文件: test.cpp, arch: 使用缓存或询问 | **是** (编译+执行) |

### 智能判断规则

AI 应根据用户的关键词判断是否需要执行：

**仅编译（添加 --compile-only）**:
- 用户只说"编译"、"compile"、"build"
- 没有提到"运行"、"执行"、"测试"等词

**编译+执行（不添加 --compile-only）**:
- 用户说"测试"、"test"
- 用户说"运行"、"执行"、"run"、"execute"
- 用户明确说"编译并运行"、"编译并执行"

## 输出位置

编译输出放在源文件同目录下的 `bin/<arch>/` 子目录：

```
test.cpp
└── bin/
    ├── gcu450/
    │   ├── test
    │   ├── test.compile.log
    │   └── test.run.log
    └── gcu500/
        ├── test
        ├── test.compile.log
        └── test.run.log
```

## 编译参数

参考 samples 的 Makefile，使用以下编译参数：

```bash
topscc <source> -std=c++17 -Werror -Wall -arch <arch> \
    -I/opt/tops/include -ltops -lpthread \
    -Wl,-rpath /opt/tops/lib -o <output>
```

## 使用流程

### 场景 1: 首次编译（仅编译）

```bash
# 用户在 Cursor 中说: "编译 test.cpp"
# AI 判断: 用户只说"编译"，不执行
# AI 执行:
1. 检查 arch 缓存 → 无
2. 提示: "请指定架构 (gcu400/gcu450/gcu500)"
3. 用户选择: gcu450
4. 保存 arch 到缓存
5. 检查容器是否运行
6. 检查 topscc → 不存在 → 调用 caps-build 安装
7. 检查 libgcusim450.so → 不存在 → 调用 gcusim-download 下载
8. 配置环境: INTERNAL_GCU_SIM=LIBRAH
9. 编译: topscc test.cpp -arch gcu450 --compile-only → bin/gcu450/test
10. 报告: 编译成功，跳过执行
```

### 场景 2: 测试（编译+执行）

```bash
# 用户: "测试 test2.cpp"
# AI 判断: 用户说"测试"，需要执行
# AI 执行:
1. 检查 arch 缓存 → gcu450
2. 使用缓存 arch
3. 依赖已安装，直接编译
4. 编译 → bin/gcu450/test2
5. 执行 → PASS
```

### 场景 3: 多 arch 编译

```bash
# 用户: "用 gcu450 和 gcu500 测试 test.cpp"
# AI 执行:
1. 解析 arch: [gcu450, gcu500]
2. 保存到缓存
3. 编译 gcu450 → bin/gcu450/test
4. 编译 gcu500 → bin/gcu500/test
5. 执行 bin/gcu450/test → PASS
6. 执行 bin/gcu500/test → PASS
7. 显示汇总结果
```

### 场景 4: 编译目录（仅编译）

```bash
# 用户: "编译这个目录 samples/Samples/0_Introduction/simpleVectorAdd/"
# AI 判断: 用户只说"编译"，不执行
# AI 执行:
1. 查找目录下所有 .cpp 文件
2. 使用缓存 arch 或询问
3. 依次编译所有文件 (--compile-only)
4. 报告编译结果，跳过执行
```

## 参数智能识别

### 架构参数自动识别

脚本会自动识别 `gcu400`、`gcu450`、`gcu500` 作为架构参数，无需显式使用 `--arch` 标志：

```bash
# 传统方式（仍然支持）
test-runner.sh --arch gcu450 test.cpp

# 简化方式（自动识别）
test-runner.sh gcu450 test.cpp

# 多架构简化方式
test-runner.sh gcu450 gcu500 test.cpp
```

### 错误提示改进

**场景 1: 架构参数被误当作文件**

```bash
# 用户输入: test-runner.sh test.cpp gcu500
# 输出:
⚠ Found architecture 'gcu500' in file list. Did you mean '--arch gcu500'?
⚠ Skipping 'gcu500' as it's not a valid file/directory path.
```

**场景 2: 无效的架构参数**

```bash
# 用户输入: test-runner.sh --arch gcu600 test.cpp
# 输出:
✗ Invalid architecture: gcu600
ℹ Available archs: gcu400, gcu450, gcu500
```

**场景 3: 自动识别架构**

```bash
# 用户输入: test-runner.sh gcu450 test.cpp
# 输出:
⚠ Architecture 'gcu450' detected without --arch flag
ℹ Auto-adding architecture: gcu450
ℹ Found 1 file(s) to process
```

## 错误处理

### ⚠️ AI 行为准则：遇到错误时只展示，不分析

**重要：当编译或运行失败时，AI 必须：**

1. ✅ **仅展示错误日志**：将脚本输出的错误信息原样呈现给用户
2. ❌ **不要进行代码分析**：不要搜索代码仓库、不要查找 API 定义、不要分析错误原因
3. ❌ **不要尝试修复**：不要修改源代码、不要建议修复方案、不要进一步调试
4. ✅ **简单说明**：仅用 1-2 句话说明"编译/运行失败，错误日志如上"
5. ✅ **等待用户指示**：让用户决定下一步操作（修复代码、切换架构、查看其他文件等）

**示例 - 正确的 AI 响应**:

```
编译失败了，错误日志如下：

=== Compilation Error Log ===
test.cpp:10:5: error: use of undeclared identifier 'foo'
    foo();
    ^
1 error generated.
=== End of Log ===

请检查错误信息，需要我帮忙修复吗？
```

**示例 - 错误的 AI 响应（不要这样做）**:

```
编译失败了。让我搜索一下代码仓库中 'foo' 的定义...
[进行多次 Grep/Read 操作]
看起来 'foo' 函数在 gcu500 中不可用，需要使用新的 API...
[继续分析和建议修复方案]
```

### 编译失败

```
✗ Compilation failed for test.cpp (gcu450)

=== Compilation Error Log ===
test.cpp:10:5: error: use of undeclared identifier 'foo'
    foo();
    ^
1 error generated.
=== End of Log ===
```

- 显示完整编译错误日志
- 停止当前 arch 的编译
- 继续下一个 arch（如果有）
- **AI 只展示错误，不进行进一步分析**

### 执行失败

```
✗ FAIL: test (gcu450) [exit code: 1]

=== Last 50 lines of execution log ===
[ERROR] Memory allocation failed
[ERROR] Test assertion failed at line 42
=== End of Log ===

Full log saved to: bin/gcu450/test.run.log
```

- 显示最后 50 行日志
- 保存完整日志到文件
- 继续执行其他成功编译的版本
- **AI 只展示错误，不进行进一步分析**

### 依赖缺失

```
⚠ topscc not found, installing...
ℹ Installing topscc and topsruntime packages...
✓ topscc and topsruntime installed

⚠ libgcusim450.so not found, downloading...
✓ libgcusim450.so downloaded
```

自动调用相关 skill 安装依赖。

## 高级用法

### 仅编译不执行

```bash
~/.cursor/skills/test-runner/scripts/test-runner.sh --compile-only --arch gcu450 test.cpp
```

### 仅执行已编译程序

```bash
~/.cursor/skills/test-runner/scripts/test-runner.sh --run-only --arch gcu450 test.cpp
```

### 清理编译输出

```bash
~/.cursor/skills/test-runner/scripts/test-runner.sh --clean test.cpp
```

### 不使用缓存

```bash
~/.cursor/skills/test-runner/scripts/test-runner.sh --no-cache --arch gcu450 test.cpp
```

### 详细输出

```bash
~/.cursor/skills/test-runner/scripts/test-runner.sh --verbose --arch gcu450 test.cpp
```

## 与其他 Skill 集成

### 集成 caps-build

自动安装编译器和运行时：
```bash
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_topscc_deb
~/.cursor/skills/caps-build/scripts/caps-build.sh --install-only package_topsruntime_deb
```

### 集成 gcusim-download

自动下载仿真库：
```bash
~/.cursor/skills/gcusim-download/scripts/download-gcusim.sh --arch gcu450
```

## 容器环境

所有编译和执行都在 `caps_dev` 容器中进行：

- **容器名称**: `caps_dev`
- **工作目录**: `/workspace` (映射到项目根目录)
- **环境变量**: 
  - `INTERNAL_GCU_SIM`: 根据 arch 设置
  - `LD_LIBRARY_PATH`: `/workspace:/opt/tops/lib`

## 注意事项

1. 需要 `caps_dev` 容器运行（脚本会自动启动）
2. 需要安装 `jq` 用于 JSON 处理
3. 编译输出会覆盖同名文件
4. 日志文件会保留，便于调试
5. arch 缓存跨会话持久化

## 示例会话

### 示例 1: 仅编译

**用户**: "编译 samples/Samples/0_Introduction/simpleVectorAdd/simpleVectorAdd.cpp 用 gcu450"

**Claude 执行**:
```bash
cd /home/stephen.hu/ws/gitee/caps
~/.cursor/skills/test-runner/scripts/test-runner.sh \
    --compile-only \
    --arch gcu450 \
    samples/Samples/0_Introduction/simpleVectorAdd/simpleVectorAdd.cpp
```

**输出**:
```
ℹ Found 1 file(s) to process
ℹ Preparing for arch: gcu450
✓ topscc found
✓ libgcusim450.so found

ℹ Compiling 1 file(s) for gcu450...

ℹ Compiling simpleVectorAdd.cpp for gcu450...
✓ Compiled: .../bin/gcu450/simpleVectorAdd
✓ All files compiled successfully for gcu450

ℹ Compile-only mode, skipping execution
```

### 示例 2: 编译并执行

**用户**: "测试 samples/Samples/0_Introduction/simpleVectorAdd/simpleVectorAdd.cpp 用 gcu450"

**Claude 执行**:
```bash
cd /home/stephen.hu/ws/gitee/caps
~/.cursor/skills/test-runner/scripts/test-runner.sh \
    --arch gcu450 \
    samples/Samples/0_Introduction/simpleVectorAdd/simpleVectorAdd.cpp
```

**输出**:
```
ℹ Found 1 file(s) to process
ℹ Preparing for arch: gcu450
✓ topscc found
✓ libgcusim450.so found

ℹ Compiling 1 file(s) for gcu450...

ℹ Compiling simpleVectorAdd.cpp for gcu450...
✓ Compiled: .../bin/gcu450/simpleVectorAdd
✓ All files compiled successfully for gcu450

ℹ Executing 1 test(s)...

ℹ Executing simpleVectorAdd (gcu450)...
✓ PASS: simpleVectorAdd (gcu450)

================================
Test Results Summary
================================
Total: 1
PASS: 1
FAIL: 0
================================
```

## 容器权限说明

脚本在容器中执行所有命令时，使用 `-u "$(id -u):$(id -g)"` 参数以当前用户身份运行，确保：

- 生成的 bin 目录和可执行文件属于当前用户
- 编译日志和运行日志文件属于当前用户
- 避免权限问题导致的文件无法访问或修改
