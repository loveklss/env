#!/usr/bin/env python3
"""Convert Markdown to Confluence Wiki Markup."""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

def convert_markdown_to_wiki_markup(markdown_content, mermaid_images=None):
    """Convert Markdown to Confluence Wiki Markup.
    
    Args:
        markdown_content: The markdown content to convert
        mermaid_images: List of mermaid image filenames (e.g., ['doc_01.png', 'doc_02.png'])
    """
    lines = markdown_content.split('\n')
    result_lines = []
    i = 0
    in_code_block = False
    code_lang = ''
    mermaid_index = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Code block start
        code_match = re.match(r'^```(\w*)', line)
        if code_match and not in_code_block:
            lang = code_match.group(1) or ''
            # Skip mermaid blocks and insert image placeholder
            if lang.lower() == 'mermaid':
                # Find end of mermaid block and skip
                i += 1
                while i < len(lines) and not lines[i].startswith('```'):
                    i += 1
                i += 1  # Skip the closing ```
                # Insert image reference
                result_lines.append('')
                if mermaid_images and mermaid_index < len(mermaid_images):
                    result_lines.append(f'!{mermaid_images[mermaid_index]}!')
                    mermaid_index += 1
                else:
                    result_lines.append('!mermaid_placeholder.png!')
                result_lines.append('')
                continue
            
            # Start code block
            if lang:
                result_lines.append(f'{{code:language={lang}}}')
            else:
                result_lines.append('{code}')
            in_code_block = True
            i += 1
            continue
        
        # Code block end
        if in_code_block and line.startswith('```'):
            result_lines.append('{code}')
            in_code_block = False
            i += 1
            continue
        
        # Inside code block - keep as is
        if in_code_block:
            result_lines.append(line)
            i += 1
            continue
        
        # Horizontal rule (must be before headings to avoid conflict)
        if re.match(r'^-{3,}$', line.strip()):
            result_lines.append('----')
            i += 1
            continue

        # Headings
        heading_match = re.match(r'^(#{1,6})\s+(.+)$', line)
        if heading_match:
            level = len(heading_match.group(1))
            content = heading_match.group(2)
            result_lines.append(f'h{level}. {content}')
            i += 1
            continue
        
        # Unordered list
        if re.match(r'^[-*+]\s+', line):
            content = re.sub(r'^[-*+]\s+', '', line)
            # Convert inline formatting
            content = convert_inline_wiki(content)
            result_lines.append(f'* {content}')
            i += 1
            continue
        
        # Ordered list
        ol_match = re.match(r'^(\d+)\.\s+(.+)$', line)
        if ol_match:
            content = ol_match.group(2)
            content = convert_inline_wiki(content)
            result_lines.append(f'# {content}')
            i += 1
            continue
        
        # Table
        if '|' in line and line.strip().startswith('|'):
            table_lines = []
            while i < len(lines) and '|' in lines[i]:
                table_lines.append(lines[i])
                i += 1
            result_lines.extend(convert_table_to_wiki(table_lines))
            continue
        
        # Empty line
        if not line.strip():
            result_lines.append('')
            i += 1
            continue
        
        # Normal paragraph
        content = convert_inline_wiki(line.strip())
        result_lines.append(content)
        i += 1
    
    return '\n'.join(result_lines)

def convert_inline_wiki(text):
    """Convert inline Markdown to Wiki Markup."""
    # Bold (must be before italic to avoid conflict)
    # Use a placeholder to avoid conflict with italic conversion
    text = re.sub(r'\*\*(.+?)\*\*', r'__BOLD__\1__/BOLD__', text)
    # Italic
    text = re.sub(r'\*(.+?)\*', r'_\1_', text)
    # Replace bold placeholders with Wiki markup
    text = text.replace('__BOLD__', '*').replace('__/BOLD__', '*')
    # Inline code
    text = re.sub(r'`([^`]+)`', r'{{\1}}', text)
    # Links
    text = re.sub(r'\[([^\]]+)\]\(([^\)]+)\)', r'[\2|\1]', text)
    return text

def convert_table_to_wiki(table_lines):
    """Convert Markdown table to Wiki Markup."""
    if len(table_lines) < 2:
        return []
    
    result = []
    for idx, line in enumerate(table_lines):
        cells = [c.strip() for c in line.strip('|').split('|')]
        
        # Skip separator line
        if idx == 1 and re.match(r'^[-:\s|]+$', line):
            continue
        
        # Header row
        if idx == 0:
            wiki_cells = [f'||{convert_inline_wiki(c)}||' for c in cells]
            result.append(''.join(wiki_cells))
        else:
            wiki_cells = [f'|{convert_inline_wiki(c)}|' for c in cells]
            result.append(''.join(wiki_cells))
    
    return result

def has_mermaid_blocks(markdown_content):
    """Check if markdown content has mermaid code blocks."""
    return bool(re.search(r'^```mermaid', markdown_content, re.MULTILINE))

def export_mermaid_diagrams(input_path):
    """Export mermaid diagrams using mermaid-export skill.
    
    Returns:
        List of exported image filenames (e.g., ['doc_01.png', 'doc_02.png'])
    """
    # Get the mermaid-export script path
    skill_dir = Path(__file__).parent.parent.parent / 'mermaid-export' / 'scripts'
    export_script = skill_dir / 'export_mermaid.py'
    
    if not export_script.exists():
        print(f"⚠️  Warning: mermaid-export script not found at {export_script}", file=sys.stderr)
        print(f"   Mermaid diagrams will use placeholder images", file=sys.stderr)
        return None
    
    try:
        print(f"🎨 Exporting Mermaid diagrams...")
        result = subprocess.run(
            [sys.executable, str(export_script), str(input_path)],
            capture_output=True,
            text=True,
            check=True
        )
        
        # Parse output to find exported image files
        output_dir = input_path.parent
        base_name = input_path.stem
        
        # Find all exported mermaid images
        mermaid_images = sorted(output_dir.glob(f'{base_name}_[0-9][0-9].png'))
        
        if mermaid_images:
            image_names = [img.name for img in mermaid_images]
            print(f"✅ Exported {len(image_names)} Mermaid diagrams: {', '.join(image_names)}")
            return image_names
        else:
            print(f"⚠️  No Mermaid images found after export", file=sys.stderr)
            return None
            
    except subprocess.CalledProcessError as e:
        print(f"⚠️  Warning: Failed to export Mermaid diagrams: {e}", file=sys.stderr)
        print(f"   stdout: {e.stdout}", file=sys.stderr)
        print(f"   stderr: {e.stderr}", file=sys.stderr)
        print(f"   Mermaid diagrams will use placeholder images", file=sys.stderr)
        return None
    except Exception as e:
        print(f"⚠️  Warning: Error exporting Mermaid diagrams: {e}", file=sys.stderr)
        print(f"   Mermaid diagrams will use placeholder images", file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(description='Convert Markdown to Confluence Wiki Markup')
    parser.add_argument('input', help='Input Markdown file')
    parser.add_argument('-o', '--output', help='Output file (default: input_name.txt)')
    parser.add_argument('--no-mermaid-export', action='store_true',
                       help='Skip automatic Mermaid diagram export')
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    output_path = Path(args.output) if args.output else input_path.with_suffix('.txt')

    markdown_content = input_path.read_text(encoding='utf-8')
    
    # Check for mermaid blocks and export if needed
    mermaid_images = None
    if not args.no_mermaid_export and has_mermaid_blocks(markdown_content):
        mermaid_images = export_mermaid_diagrams(input_path)
    
    wiki_markup = convert_markdown_to_wiki_markup(markdown_content, mermaid_images)

    output_path.write_text(wiki_markup, encoding='utf-8')
    print(f"✅ 转换完成: {args.input} → {output_path}")
    print(f"📄 输出文件: {output_path}")
    
    if mermaid_images:
        print(f"\n📊 Mermaid 图表:")
        for img in mermaid_images:
            print(f"   - {img}")
        print(f"\n💡 使用方法:")
        print(f"   1. 打开输出文件")
        print(f"   2. 全选复制(Ctrl+A, Ctrl+C)")
        print(f"   3. 在Confluence编辑器中粘贴(Ctrl+V)")
        print(f"   4. 上传 Mermaid 图片作为附件")
        print(f"   5. 图片引用已自动更新为实际文件名")
    else:
        print(f"\n💡 使用方法:")
        print(f"   1. 打开输出文件")
        print(f"   2. 全选复制(Ctrl+A, Ctrl+C)")
        print(f"   3. 在Confluence编辑器中粘贴(Ctrl+V)")

if __name__ == '__main__':
    main()
