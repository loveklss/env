@echo off
REM Zed 扩展安装脚本 (Windows 客户端)
REM 用途：在 Windows 客户端安装所有 Zed 扩展插件
REM 使用方法：双击运行或在 CMD 中执行

echo ========================================
echo Zed 扩展安装脚本 (Windows)
echo ========================================
echo.

REM 检查 zed 命令是否可用
where zed >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 zed 命令
    echo 请确保 Zed 已正确安装并添加到 PATH 环境变量
    echo.
    echo 你可以手动在 Zed 中安装以下扩展：
    echo   1. 按 Ctrl+Shift+P 打开命令面板
    echo   2. 输入 "extensions: install extension"
    echo   3. 搜索并安装以下扩展：
    echo.
    echo      - catppuccin
    echo      - cursor
    echo      - github-dark-default
    echo      - html
    echo      - kamui-dark-theme
    echo      - macos-classic
    echo      - make
    echo      - midnight-marina
    echo      - new-darcula
    echo      - one-dark-darkened
    echo      - one-dark-pro
    echo      - the-dark-side
    echo      - vscode-dark-modern
    echo.
    pause
    exit /b 1
)

echo 开始安装扩展...
echo.

set installed=0
set failed=0

echo [1/13] 安装 catppuccin (Soothing pastel theme)
zed --install-extension catppuccin --force
if %errorlevel% equ 0 (
    echo [成功] catppuccin
    set /a installed+=1
) else (
    echo [失败] catppuccin
    set /a failed+=1
)
echo.

echo [2/13] 安装 cursor (Cursor IDE theme)
zed --install-extension cursor --force
if %errorlevel% equ 0 (
    echo [成功] cursor
    set /a installed+=1
) else (
    echo [失败] cursor
    set /a failed+=1
)
echo.

echo [3/13] 安装 github-dark-default (GitHub Dark theme)
zed --install-extension github-dark-default --force
if %errorlevel% equ 0 (
    echo [成功] github-dark-default
    set /a installed+=1
) else (
    echo [失败] github-dark-default
    set /a failed+=1
)
echo.

echo [4/13] 安装 html (HTML language support)
zed --install-extension html --force
if %errorlevel% equ 0 (
    echo [成功] html
    set /a installed+=1
) else (
    echo [失败] html
    set /a failed+=1
)
echo.

echo [5/13] 安装 kamui-dark-theme (Kamui dark theme)
zed --install-extension kamui-dark-theme --force
if %errorlevel% equ 0 (
    echo [成功] kamui-dark-theme
    set /a installed+=1
) else (
    echo [失败] kamui-dark-theme
    set /a failed+=1
)
echo.

echo [6/13] 安装 macos-classic (macOS Classic theme)
zed --install-extension macos-classic --force
if %errorlevel% equ 0 (
    echo [成功] macos-classic
    set /a installed+=1
) else (
    echo [失败] macos-classic
    set /a failed+=1
)
echo.

echo [7/13] 安装 make (Makefile syntax highlighting)
zed --install-extension make --force
if %errorlevel% equ 0 (
    echo [成功] make
    set /a installed+=1
) else (
    echo [失败] make
    set /a failed+=1
)
echo.

echo [8/13] 安装 midnight-marina (Ocean inspired theme)
zed --install-extension midnight-marina --force
if %errorlevel% equ 0 (
    echo [成功] midnight-marina
    set /a installed+=1
) else (
    echo [失败] midnight-marina
    set /a failed+=1
)
echo.

echo [9/13] 安装 new-darcula (New Darcula theme)
zed --install-extension new-darcula --force
if %errorlevel% equ 0 (
    echo [成功] new-darcula
    set /a installed+=1
) else (
    echo [失败] new-darcula
    set /a failed+=1
)
echo.

echo [10/13] 安装 one-dark-darkened (One Dark darkened)
zed --install-extension one-dark-darkened --force
if %errorlevel% equ 0 (
    echo [成功] one-dark-darkened
    set /a installed+=1
) else (
    echo [失败] one-dark-darkened
    set /a failed+=1
)
echo.

echo [11/13] 安装 one-dark-pro (One Dark Pro theme)
zed --install-extension one-dark-pro --force
if %errorlevel% equ 0 (
    echo [成功] one-dark-pro
    set /a installed+=1
) else (
    echo [失败] one-dark-pro
    set /a failed+=1
)
echo.

echo [12/13] 安装 the-dark-side (The Dark Side theme)
zed --install-extension the-dark-side --force
if %errorlevel% equ 0 (
    echo [成功] the-dark-side
    set /a installed+=1
) else (
    echo [失败] the-dark-side
    set /a failed+=1
)
echo.

echo [13/13] 安装 vscode-dark-modern (VSCode Dark Modern theme)
zed --install-extension vscode-dark-modern --force
if %errorlevel% equ 0 (
    echo [成功] vscode-dark-modern
    set /a installed+=1
) else (
    echo [失败] vscode-dark-modern
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
    echo 部分扩展安装失败，请检查网络连接或手动在 Zed 中安装
)

echo.
echo 按任意键退出...
pause >nul
