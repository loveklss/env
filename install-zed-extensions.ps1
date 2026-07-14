# Zed 扩展安装脚本 (Windows 客户端 - PowerShell)
# 用途：在 Windows 客户端安装所有 Zed 扩展插件
# 使用方法：右键 -> "使用 PowerShell 运行" 或在 PowerShell 中执行

Write-Host "========================================" -ForegroundColor Blue
Write-Host "Zed 扩展安装脚本 (Windows)" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 扩展列表
$extensions = @(
    @{id="catppuccin"; name="Soothing pastel theme"},
    @{id="cursor"; name="Cursor IDE theme"},
    @{id="github-dark-default"; name="GitHub Dark theme"},
    @{id="html"; name="HTML language support"},
    @{id="kamui-dark-theme"; name="Kamui dark theme"},
    @{id="macos-classic"; name="macOS Classic theme"},
    @{id="make"; name="Makefile syntax highlighting"},
    @{id="midnight-marina"; name="Ocean inspired theme"},
    @{id="new-darcula"; name="New Darcula theme"},
    @{id="one-dark-darkened"; name="One Dark darkened"},
    @{id="one-dark-pro"; name="One Dark Pro theme"},
    @{id="the-dark-side"; name="The Dark Side theme"},
    @{id="vscode-dark-modern"; name="VSCode Dark Modern theme"}
)

# 检查 zed 命令是否可用
$zedCmd = Get-Command zed -ErrorAction SilentlyContinue
if (-not $zedCmd) {
    Write-Host "[错误] 未找到 zed 命令" -ForegroundColor Red
    Write-Host ""
    Write-Host "请确保 Zed 已正确安装并添加到 PATH 环境变量" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "你可以手动在 Zed 中安装以下扩展：" -ForegroundColor Yellow
    Write-Host "  1. 按 Ctrl+Shift+P 打开命令面板"
    Write-Host "  2. 输入 \"extensions: install extension\""
    Write-Host "  3. 搜索并安装以下扩展："
    Write-Host ""
    foreach ($ext in $extensions) {
        Write-Host "     - $($ext.id) ($($ext.name))"
    }
    Write-Host ""
    Read-Host "按 Enter 键退出"
    exit 1
}

Write-Host "开始安装扩展..." -ForegroundColor Green
Write-Host ""

$installed = 0
$failed = 0
$total = $extensions.Count

for ($i = 0; $i -lt $total; $i++) {
    $ext = $extensions[$i]
    $num = $i + 1
    
    Write-Host "[$num/$total] 安装 $($ext.id) ($($ext.name))" -ForegroundColor Cyan
    
    try {
        $result = & zed --install-extension $ext.id --force 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[成功] $($ext.id)" -ForegroundColor Green
            $installed++
        } else {
            Write-Host "[失败] $($ext.id)" -ForegroundColor Red
            $failed++
        }
    } catch {
        Write-Host "[失败] $($ext.id) - $_" -ForegroundColor Red
        $failed++
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Blue
Write-Host "安装完成" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host "成功: $installed 个" -ForegroundColor Green
Write-Host "失败: $failed 个" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($failed -gt 0) {
    Write-Host "部分扩展安装失败，请检查网络连接或手动在 Zed 中安装" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "按 Enter 键退出"
