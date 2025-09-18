# 🎯 Cursor Vim 完整配置指南

从 Neovim 迁移到 Cursor 的完整 Vim 配置方案

## 📋 目录
- [快速安装](#快速安装)
- [配置文件说明](#配置文件说明)
- [功能对照表](#功能对照表)
- [快捷键列表](#快捷键列表)
- [故障排除](#故障排除)

## 🚀 快速安装

### 1. 安装必要插件
在 Cursor 中安装以下插件：

**必须安装的插件：**
1. 按 `Cmd+Shift+P` (Mac) 或 `Ctrl+Shift+P` (Windows/Linux)
2. 输入 `Extensions: Install Extensions`
3. 搜索并安装以下插件：
   - **Vim** - VSCode Vim 模拟器

**⚠️ 关于 C++ 插件的说明：**

**如果您已经使用 clangd：**
- ✅ **推荐方案**：继续使用 clangd，无需安装额外插件
- 配置已自动禁用 C++ 插件的 IntelliSense：`"C_Cpp.intelliSenseEngine": "disabled"`
- 函数跳转将使用符号搜索方式

**如果您没有使用 clangd：**
- 可以选择安装 **C/C++** - Microsoft 官方 C++ 支持插件
- 安装后按 `Ctrl+Shift+P` → `C/C++: Edit Configurations (JSON)` 生成配置

### 2. 配置 Settings.json
1. 按 `Cmd+Shift+P` → `Preferences: Open User Settings (JSON)`
2. 将 `cursor-final-settings.json` 的内容复制到您的 settings.json 中

### 3. 配置 Keybindings.json (可选)
1. 按 `Cmd+Shift+P` → `Preferences: Open Keyboard Shortcuts (JSON)`
2. 将 `cursor-keybindings.json` 的内容添加到您的 keybindings.json 中

### 4. 重启 Cursor
配置完成后重启 Cursor 使配置生效。

## 📁 配置文件说明

### cursor-final-settings.json
主要的 Vim 配置文件，包含：
- **基础 Vim 设置** - Leader 键、剪贴板、搜索等
- **快捷键映射** - 所有自定义的 Vim 快捷键
- **界面设置** - 文件浏览器、大纲等行为配置

### cursor-keybindings.json
全局快捷键配置，包含：
- **Esc 退出功能** - 在各种面板中用 Esc 退出
- **AI Composer** - Ctrl+I 调用 AI 助手
- **面板管理** - 统一的面板关闭行为

## 🔄 功能对照表

### Neovim → Cursor 功能映射

| Neovim 功能 | 原快捷键 | Cursor 快捷键 | 说明 |
|-------------|----------|---------------|------|
| **文件管理** |
| Neo-tree | `<leader>wm` | `,wm` | 打开文件浏览器 |
| Outline | `<leader>tl` | `,tl` | 打开符号大纲 |
| 关闭窗口 | `:q` | `,q` 或 `Esc` | 关闭侧边栏 |
| **搜索功能** |
| Telescope find_files | `<leader>ff` | `ff` | 查找文件 |
| Telescope live_grep | `<leader>fg` | `fg` | 全文搜索 |
| Telescope buffers | `<leader>fb` | `fb` | 查找缓冲区 |
| Telescope symbols | `<leader>fs` | `fs` | 查找符号 |
| **代码导航** |
| LSP 定义 | `gd` | `gd` | 跳转到定义 |
| LSP 引用 | `gr` | `gr` | 查找引用 |
| LSP 实现 | `gi` | `gi` | 跳转到实现 |
| LSP 类型 | `gt` | `gt` | 跳转到类型定义 |
| **编辑功能** |
| 注释 | `gcc` | `gcc` | 注释/取消注释 |
| 退出插入 | `jk` | `jk` | 从插入模式回到普通模式 |

## ⌨️ 快捷键列表

### 🗂️ 文件管理
| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `,wm` | 打开文件浏览器 | Normal |
| `,tl` | 打开符号大纲 | Normal |
| `,q` | 关闭侧边栏 | Normal |
| `Esc` | 关闭当前面板 | 面板焦点时 |

### 🔍 搜索功能
| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `ff` | 查找文件 | Normal |
| `fg` | 全文搜索 | Normal |
| `fb` | 查找已打开文件 | Normal |
| `fs` | 查找当前文件符号 | Normal |

### 🧭 代码导航
| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `gd` | 跳转到定义 | Normal |
| `gr` | 查找引用 | Normal |
| `gi` | 跳转到实现 | Normal |
| `gt` | 跳转到类型定义 | Normal |
| `K` | 显示悬浮文档 | Normal |
| `Ctrl+t` | 返回上一个位置 | Normal |

### ✏️ 编辑功能
| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `jk` | 退出插入模式 | Insert |
| `gcc` | 注释/取消注释行 | Normal |
| `gc` | 注释/取消注释选中 | Visual |
| `;` | 高亮光标下单词 | Normal |
| `;;` | 清除高亮 | Normal |

### 📂 缓冲区管理
| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `Ctrl+n` | 下一个文件 | Normal |
| `Ctrl+p` | 上一个文件 | Normal |
| `Ctrl+q` | 关闭当前文件 | Normal |
| `Space` | 切换到上一个文件 | Normal |
| `,bd` | 关闭当前缓冲区 | Normal |

### 🔧 工具功能
| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `,t` | 打开/关闭终端 | Normal |
| `,ca` | 代码操作 | Normal |
| `,rn` | 重命名符号 | Normal |
| `,xx` | 打开问题面板 | Normal |
| `Ctrl+i` | AI Composer | Global |

## 🛠️ 故障排除

### 常见问题

#### 1. 快捷键不生效
**症状**: 按快捷键没有反应
**解决方案**:
- 确认 Vim 插件已安装并启用
- 检查配置是否正确复制到 settings.json
- 重启 Cursor
- 检查是否有其他插件冲突

#### 2. Esc 不能关闭面板
**症状**: 在侧边栏按 Esc 无法关闭
**解决方案**:
- 确认 keybindings.json 配置已添加
- 检查当前焦点是否在面板上
- 尝试先点击面板确保焦点正确

#### 3. 搜索功能不工作
**症状**: `ff`, `fg` 等搜索快捷键不响应
**解决方案**:
- 确认不在插入模式或视觉模式
- 检查 vim.handleKeys 配置
- 尝试重新加载窗口

#### 4. Leader 键不识别
**症状**: 以 `,` 开头的快捷键不工作
**解决方案**:
- 确认 `"vim.leader": ","` 配置存在
- 检查快捷键序列是否正确
- 确保在 Normal 模式下使用

### 🔍 调试步骤

1. **检查 Vim 插件状态**
   - `Cmd+Shift+P` → `Extensions: Show Installed Extensions`
   - 确认 Vim 插件已启用

2. **验证配置加载**
   - `Cmd+Shift+P` → `Preferences: Open User Settings (JSON)`
   - 确认配置已正确添加

3. **测试基础功能**
   - 尝试基本的 Vim 命令 (hjkl, i, Esc)
   - 测试简单的快捷键如 `ff`

4. **重置配置**
   - 如果问题严重，可以删除相关配置重新添加
   - 逐步添加配置项定位问题

## 🎊 高级技巧

### 1. 自定义快捷键
您可以在 settings.json 中添加自己的快捷键：
```json
{
  "before": ["<leader>", "自定义"],
  "commands": ["workbench.action.命令"],
  "description": "说明"
}
```

### 2. 工作流建议
- 使用 `ff` 快速打开文件
- 用 `,wm` 浏览项目结构
- 用 `,tl` 查看代码大纲
- 用 `gr` 查找函数引用
- 用 `,q` 或 `Esc` 快速关闭面板

### 3. 与 AI 结合
- `Ctrl+i` 调用 AI Composer 进行代码生成
- 结合传统 Vim 编辑和 AI 辅助提高效率

## 📚 参考资源

- [Cursor 官方文档](https://docs.cursor.com/)
- [VSCode Vim 插件文档](https://github.com/VSCodeVim/Vim)
- [Neovim 官方文档](https://neovim.io/doc/)

---

🎉 **恭喜！您已成功将 Neovim 配置迁移到 Cursor！**

如果遇到任何问题，请参考故障排除部分或查阅相关文档。祝您编码愉快！

## 🆕 最新更新

### 段落跳转功能（相邻函数间跳转）
- `{{` - 向上跳转到空行（上一个函数）
- `}}` - 向下跳转到空行（下一个函数）

这个功能模拟传统 Vim 的段落跳转行为，通过空行来识别函数边界。

**工作原理**：
- `{` 和 `}` 在 Vim 中用于段落间跳转
- `{{` 快速按两次 `{` 触发向上跳转
- `}}` 快速按两次 `}` 触发向下跳转
- 跳转到空行，通常是函数之间的分隔符

**适用场景**：
```cpp
void function1() {
    // 函数体
}
// <- 空行，{{ 和 }} 会跳转到这里

void function2() {
    // 函数体
}
// <- 空行
```

**使用技巧**：
- ✅ **兼容 clangd** - 使用 Vim 原生功能，无冲突
- ✅ **快速导航** - 在相邻函数间快速移动
- ✅ **适用所有语言** - 基于空行识别，通用性强
- ✅ **符合习惯** - 与传统 Vim 行为一致

**如果跳转不准确**：
可以配合使用其他导航命令：
- `gd` - 跳转到定义（精确跳转）
- `fs` - 查找当前文件符号
- `gr` - 查找引用

## 🆕 快速查看（Peek）功能

### 👁️ 快速预览功能
类似于鼠标右键菜单中的"快速查看"选项，但使用键盘快捷键：

|| 快捷键 | 功能 | 说明 |
||--------|------|------|
|| `,gd` | 快速查看定义 | 在弹出窗口中预览定义，不跳转 |
|| `,gD` | 快速查看声明 | 在弹出窗口中预览声明 |
|| `,gr` | 快速查看引用 | 在弹出窗口中查看所有引用 |
|| `,gi` | 快速查看实现 | 在弹出窗口中预览实现 |
|| `,gt` | 快速查看类型定义 | 在弹出窗口中预览类型定义 |

### 🎯 使用场景：
- **快速预览** - 无需跳转就能查看代码定义
- **保持上下文** - 当前位置不变，只是预览内容
- **多个引用** - 在引用列表中快速浏览
- **代码审查** - 快速了解函数实现而不离开当前位置

### 💡 操作技巧：
- 预览窗口打开后，可以用 `Esc` 关闭
- 在预览窗口中可以继续导航
- `,g` 前缀表示 "Leader + Go"（快速查看）
- 与普通跳转区别：`gd` 直接跳转，`,gd` 预览不跳转
