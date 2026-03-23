#!/bin/bash

# Cursor 配置一键安装脚本
# 用途：在新系统上通过符号链接方式部署 Cursor 配置
# 使用方法：bash install-cursor-config.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录（工程目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_CONFIG_DIR="${SCRIPT_DIR}/.cursor"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Cursor 配置安装脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "工程目录: ${GREEN}${SCRIPT_DIR}${NC}"
echo -e "配置源目录: ${GREEN}${CURSOR_CONFIG_DIR}${NC}"
echo ""

# 检查配置目录是否存在
if [ ! -d "${CURSOR_CONFIG_DIR}" ]; then
    echo -e "${RED}错误: 配置目录不存在: ${CURSOR_CONFIG_DIR}${NC}"
    exit 1
fi

# 备份函数
backup_if_exists() {
    local target=$1
    if [ -e "${target}" ] || [ -L "${target}" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}备份现有配置: ${target} -> ${backup}${NC}"
        mv "${target}" "${backup}"
    fi
}

# 创建符号链接函数
create_symlink() {
    local source=$1
    local target=$2
    local description=$3

    if [ ! -e "${source}" ]; then
        echo -e "${YELLOW}跳过 ${description}: 源文件不存在 (${source})${NC}"
        return
    fi

    echo -e "${BLUE}安装 ${description}...${NC}"

    # 创建目标目录（如果不存在）
    local target_dir=$(dirname "${target}")
    mkdir -p "${target_dir}"

    # 备份现有配置
    backup_if_exists "${target}"

    # 创建符号链接
    ln -s "${source}" "${target}"
    echo -e "${GREEN}✓ 已创建符号链接: ${target} -> ${source}${NC}"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}1. 安装 Skills 配置${NC}"
echo -e "${BLUE}========================================${NC}"
create_symlink "${CURSOR_CONFIG_DIR}/skills" "${HOME}/.agents/skills" "Agent Skills"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}2. 安装 Rules 配置${NC}"
echo -e "${BLUE}========================================${NC}"
create_symlink "${CURSOR_CONFIG_DIR}/rules" "${HOME}/.cursor/rules" "AI Rules"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}3. 安装 MCP 配置${NC}"
echo -e "${BLUE}========================================${NC}"
create_symlink "${CURSOR_CONFIG_DIR}/mcp.json" "${HOME}/.cursor/mcp.json" "MCP 服务器配置"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}4. 安装扩展插件${NC}"
echo -e "${BLUE}========================================${NC}"

EXTENSIONS_FILE="${CURSOR_CONFIG_DIR}/extensions.txt"
if [ -f "${EXTENSIONS_FILE}" ]; then
    echo -e "${BLUE}从 ${EXTENSIONS_FILE} 读取扩展列表...${NC}"
    echo ""

    # 检查 cursor 命令是否可用
    if ! command -v cursor &> /dev/null; then
        echo -e "${YELLOW}警告: 'cursor' 命令未找到，跳过扩展安装${NC}"
        echo -e "${YELLOW}请确保 Cursor 已安装并且 cursor 命令在 PATH 中${NC}"
        echo -e "${YELLOW}你可以稍后手动运行以下命令安装扩展:${NC}"
        echo ""
        while IFS= read -r extension || [ -n "$extension" ]; do
            # 跳过空行和注释
            [[ -z "$extension" || "$extension" =~ ^[[:space:]]*# ]] && continue
            echo "  cursor --install-extension ${extension}"
        done < "${EXTENSIONS_FILE}"
    else
        installed_count=0
        failed_count=0

        while IFS= read -r extension || [ -n "$extension" ]; do
            # 跳过空行和注释
            [[ -z "$extension" || "$extension" =~ ^[[:space:]]*# ]] && continue

            echo -e "${BLUE}安装扩展: ${extension}${NC}"
            if cursor --install-extension "${extension}" --force; then
                echo -e "${GREEN}✓ 已安装: ${extension}${NC}"
                ((installed_count++))
            else
                echo -e "${RED}✗ 安装失败: ${extension}${NC}"
                ((failed_count++))
            fi
            echo ""
        done < "${EXTENSIONS_FILE}"

        echo -e "${GREEN}扩展安装完成: ${installed_count} 个成功, ${failed_count} 个失败${NC}"
    fi
else
    echo -e "${YELLOW}未找到扩展列表文件，跳过${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}5. Windows 客户端配置说明${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}注意: settings.json 和 keybindings.json 需要在 Windows 客户端手动配置${NC}"
echo ""
echo -e "如果你已经将这些文件放到工程目录，请按以下步骤操作:"
echo ""
echo -e "1. 在 Windows 客户端，打开以下目录:"
echo -e "   ${GREEN}C:\\Users\\<你的用户名>\\AppData\\Roaming\\Cursor\\User\\${NC}"
echo ""
echo -e "2. 从工程目录复制以下文件（如果存在）:"
echo -e "   - ${CURSOR_CONFIG_DIR}/settings.json"
echo -e "   - ${CURSOR_CONFIG_DIR}/keybindings.json"
echo ""
echo -e "3. 粘贴到 Windows 客户端的 User 目录，覆盖现有文件"
echo ""
echo -e "详细说明请参考: ${GREEN}${SCRIPT_DIR}/CURSOR-INSTALL.md${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "已安装的配置:"
echo -e "  ${GREEN}✓${NC} Skills:  ~/.agents/skills -> ${CURSOR_CONFIG_DIR}/skills"
echo -e "  ${GREEN}✓${NC} Rules:   ~/.cursor/rules -> ${CURSOR_CONFIG_DIR}/rules"
echo -e "  ${GREEN}✓${NC} MCP:     ~/.cursor/mcp.json -> ${CURSOR_CONFIG_DIR}/mcp.json"
echo -e "  ${GREEN}✓${NC} Extensions: 已安装（或需要手动安装）"
echo ""
echo -e "${YELLOW}提示: 配置通过符号链接同步，修改会自动反映到工程目录${NC}"
echo ""
