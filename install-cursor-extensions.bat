@echo off
REM Cursor 扩展安装脚本 (Windows 客户端)
REM 用途：在 Windows 客户端安装所有扩展插件
REM 使用方法：双击运行或在 CMD 中执行

echo ========================================
echo Cursor 扩展安装脚本 (Windows)
echo ========================================
echo.

REM 检查 cursor 命令是否可用
where cursor >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 cursor 命令
    echo 请确保 Cursor 已正确安装并添加到 PATH 环境变量
    echo.
    echo 你可以手动在 Cursor 中安装以下扩展：
    echo   1. 按 Ctrl+Shift+X 打开扩展面板
    echo   2. 搜索并安装以下扩展：
    echo.
    echo      - bierner.markdown-mermaid
    echo      - fabiospampinato.vscode-highlight
    echo      - llvm-vs-code-extensions.vscode-clangd
    echo      - ms-ceintl.vscode-language-pack-zh-hans
    echo      - ms-vscode.cmake-tools
    echo      - shd101wyy.markdown-preview-enhanced
    echo      - topscc-vs-code-extensions.vscode-tlsp
    echo.
    pause
    exit /b 1
)

echo 开始安装扩展...
echo.

set installed=0
set failed=0

echo [1/7] 安装 bierner.markdown-mermaid (Mermaid 图表支持)
cursor --install-extension bierner.markdown-mermaid --force
if %errorlevel% equ 0 (
    echo [成功] bierner.markdown-mermaid
    set /a installed+=1
) else (
    echo [失败] bierner.markdown-mermaid
    set /a failed+=1
)
echo.

echo [2/7] 安装 fabiospampinato.vscode-highlight (语法高亮增强)
cursor --install-extension fabiospampinato.vscode-highlight --force
if %errorlevel% equ 0 (
    echo [成功] fabiospampinato.vscode-highlight
    set /a installed+=1
) else (
    echo [失败] fabiospampinato.vscode-highlight
    set /a failed+=1
)
echo.

echo [3/7] 安装 llvm-vs-code-extensions.vscode-clangd (C/C++ LSP)
cursor --install-extension llvm-vs-code-extensions.vscode-clangd --force
if %errorlevel% equ 0 (
    echo [成功] llvm-vs-code-extensions.vscode-clangd
    set /a installed+=1
) else (
    echo [失败] llvm-vs-code-extensions.vscode-clangd
    set /a failed+=1
)
echo.

echo [4/7] 安装 ms-ceintl.vscode-language-pack-zh-hans (中文语言包)
cursor --install-extension ms-ceintl.vscode-language-pack-zh-hans --force
if %errorlevel% equ 0 (
    echo [成功] ms-ceintl.vscode-language-pack-zh-hans
    set /a installed+=1
) else (
    echo [失败] ms-ceintl.vscode-language-pack-zh-hans
    set /a failed+=1
)
echo.

echo [5/7] 安装 ms-vscode.cmake-tools (CMake 工具)
cursor --install-extension ms-vscode.cmake-tools --force
if %errorlevel% equ 0 (
    echo [成功] ms-vscode.cmake-tools
    set /a installed+=1
) else (
    echo [失败] ms-vscode.cmake-tools
    set /a failed+=1
)
echo.

echo [6/7] 安装 shd101wyy.markdown-preview-enhanced (Markdown 预览增强)
cursor --install-extension shd101wyy.markdown-preview-enhanced --force
if %errorlevel% equ 0 (
    echo [成功] shd101wyy.markdown-preview-enhanced
    set /a installed+=1
) else (
    echo [失败] shd101wyy.markdown-preview-enhanced
    set /a failed+=1
)
echo.

echo [7/7] 安装 topscc-vs-code-extensions.vscode-tlsp (TOPS LSP)
cursor --install-extension topscc-vs-code-extensions.vscode-tlsp --force
if %errorlevel% equ 0 (
    echo [成功] topscc-vs-code-extensions.vscode-tlsp
    set /a installed+=1
) else (
    echo [失败] topscc-vs-code-extensions.vscode-tlsp
    set /a failed+=1
)
echo.

echo ========================================
echo 安装完成
echo ========================================
echo 成功: %installed% 个
echo 失败: %failed% 个
echo.

if %failed% gtr 0 (
    echo 部分扩展安装失败，请检查网络连接或手动在 Cursor 中安装
)

echo.
echo 按任意键退出...
pause >nul
