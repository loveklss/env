# Cursor 扩展安装脚本 (Windows 客户端 - PowerShell)
# 用途：在 Windows 客户端安装所有扩展插件
# 使用方法：右键 -> "使用 PowerShell 运行" 或在 PowerShell 中执行

Write-Host "========================================" -ForegroundColor Blue
Write-Host "Cursor 扩展安装脚本 (Windows)" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 扩展列表
$extensions = @(
    @{id="bierner.markdown-mermaid"; name="Mermaid 图表支持"},
    @{id="fabiospampinato.vscode-highlight"; name="语法高亮增强"},
    @{id="llvm-vs-code-extensions.vscode-clangd"; name="C/C++ LSP"},
    @{id="ms-ceintl.vscode-language-pack-zh-hans"; name="中文语言包"},
    @{id="ms-vscode.cmake-tools"; name="CMake 工具"},
    @{id="shd101wyy.markdown-preview-enhanced"; name="Markdown 预览增强"},
    @{id="topscc-vs-code-extensions.vscode-tlsp"; name="TOPS LSP"}
)

# 检查 cursor 命令是否可用
$cursorCmd = Get-Command cursor -ErrorAction SilentlyContinue
if (-not $cursorCmd) {
    Write-Host "[错误] 未找到 cursor 命令" -ForegroundColor Red
    Write-Host ""
    Write-Host "请确保 Cursor 已正确安装并添加到 PATH 环境变量" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "你可以手动在 Cursor 中安装以下扩展：" -ForegroundColor Yellow
    Write-Host "  1. 按 Ctrl+Shift+X 打开扩展面板"
    Write-Host "  2. 搜索并安装以下扩展："
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
        $result = & cursor --install-extension $ext.id --force 2>&1
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
    Write-Host "部分扩展安装失败，请检查网络连接或手动在 Cursor 中安装" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "按 Enter 键退出"
