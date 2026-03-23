---
name: markdown-to-confluence
description: Convert Markdown documents to Confluence Wiki Markup format (.txt). Use when the user wants to convert .md files to Confluence wiki format, export documentation to wiki, or mentions "confluence", "wiki format", "wiki markup". Generates Wiki Markup text that can be directly pasted into Confluence editor, with automatic code block conversion and Mermaid diagram placeholders.
---

# Markdown to Confluence Converter

Convert Markdown documents to Confluence Wiki Markup format for direct paste into Confluence editor.

## Usage

**Basic usage (with automatic Mermaid export)**:
```bash
python scripts/md2wiki.py input.md -o output.txt
```

**Skip Mermaid export**:
```bash
python scripts/md2wiki.py input.md --no-mermaid-export
```

If `-o` is not specified, output file will be `input.txt` (same name as input with .txt extension).

**Features**:
- Automatically detects and exports Mermaid diagrams as PNG images
- Uses actual image filenames in Wiki Markup (no manual replacement needed)
- Falls back to placeholders if export fails

## Output Format

**Confluence Wiki Markup** - Plain text format that Confluence automatically recognizes and converts to rich text when pasted.

## Supported Markdown Elements

| Markdown | Wiki Markup | Confluence Display |
|----------|-------------|-------------------|
| `# Heading` | `h1. Heading` | Level 1 heading |
| `## Heading` | `h2. Heading` | Level 2 heading |
| `### Heading` | `h3. Heading` | Level 3 heading |
| `**bold**` | `*bold*` | Bold text |
| `*italic*` | `_italic_` | Italic text |
| `` `code` `` | `{{code}}` | Monospace text |
| `[text](url)` | `[url\|text]` | Hyperlink |
| `- item` | `* item` | Bullet list |
| `1. item` | `# item` | Numbered list |
| ````code```` | `{code}...{code}` | Code macro |
| ````mermaid```` | `!document_01.png!` | Image reference |

## Code Block Conversion

Markdown code blocks are converted to Confluence code macros:

**Input**:
````markdown
```cpp
struct example {
    int value;
};
```
````

**Output**:
```
{code:language=cpp}
struct example {
    int value;
};
{code}
```

**Confluence Display**: Editable code macro with syntax highlighting

Supported languages: `cpp`, `c`, `python`, `bash`, `java`, `javascript`, `go`, `rust`, `sql`, `yaml`, `json`, `xml`, `html`, `css`

## Mermaid Diagram Handling

**Automatic Export (Default)**:

The script automatically detects Mermaid code blocks and exports them as PNG images using the `mermaid-export` skill:

**Input**:
````markdown
```mermaid
graph TD
    A --> B
```
````

**Output**:
```
!document_01.png!
```

**Workflow**:
1. Script detects Mermaid blocks in Markdown
2. Automatically exports diagrams as PNG (e.g., `document_01.png`, `document_02.png`)
3. Converts Markdown to Wiki Markup with actual image filenames
4. Paste into Confluence editor and upload the PNG attachments

**Manual Mode**:

Use `--no-mermaid-export` to skip automatic export and use placeholders:

```bash
python scripts/md2wiki.py document.md --no-mermaid-export
```

This will use `!mermaid_placeholder.png!` that you can manually replace later.

## Examples

### Convert single file

```bash
python scripts/md2wiki.py document.md -o document.txt
```

### Convert to default output

```bash
python scripts/md2wiki.py document.md
# Creates document.txt
```

### Complete workflow with automatic Mermaid export

```bash
# 1. Convert Markdown to Wiki Markup (automatically exports Mermaid diagrams)
python scripts/md2wiki.py caps_VGP设计文档.md

# Output:
# 🎨 Exporting Mermaid diagrams...
# ✅ Exported 7 Mermaid diagrams: caps_VGP设计文档_01.png, caps_VGP设计文档_02.png, ...
# ✅ 转换完成: caps_VGP设计文档.md → caps_VGP设计文档.txt

# 2. Open and copy the output
cat caps_VGP设计文档.txt
# Select all (Ctrl+A) and copy (Ctrl+C)

# 3. Paste into Confluence editor (Ctrl+V)

# 4. Upload the exported PNG images as attachments
# Files: caps_VGP设计文档_01.png, caps_VGP设计文档_02.png, etc.

# 5. Preview and publish (no manual replacement needed!)
```

### Manual workflow (skip Mermaid export)

```bash
# 1. Convert without Mermaid export
python scripts/md2wiki.py caps_VGP设计文档.md --no-mermaid-export

# 2. Paste into Confluence editor

# 3. Manually export and upload Mermaid diagrams

# 4. Replace placeholders
# Search: mermaid_placeholder.png
# Replace: actual_image_name.png
```

## Notes

- Output format is **plain text** (.txt), not XML
- Can be **directly pasted** into Confluence editor
- Confluence automatically converts Wiki Markup to rich text
- Code blocks are **fully editable** after pasting
- Inline code uses `{{...}}` syntax (displays as monospace text)
- **Mermaid diagrams are automatically exported** and referenced with actual filenames
- Mermaid export requires `mermaid-export` skill to be installed
- If Mermaid export fails, placeholders are used as fallback
- All special characters are preserved (no escaping needed in Wiki Markup)
- Tables require proper Markdown table syntax with header separator
- UTF-8 encoding is used for proper Chinese character support

## Dependencies

- **mermaid-export skill**: Required for automatic Mermaid diagram export
- The script will gracefully fall back to placeholders if mermaid-export is not available
