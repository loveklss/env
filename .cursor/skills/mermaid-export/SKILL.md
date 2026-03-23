---
name: mermaid-export
description: Extract Mermaid diagrams from Markdown files and export them as PNG images. Use when the user wants to convert Mermaid code blocks to image files, mentions "export mermaid", "mermaid to png", "mermaid to image", "save mermaid diagrams", or needs to extract diagrams from .md files for documentation or presentations.
---

# Mermaid Export

Extract Mermaid diagrams from Markdown files and export them as PNG images with automatic environment detection and setup.

## Overview

This skill automates the process of converting Mermaid diagram code blocks in Markdown files into standalone PNG image files. The script automatically:

- Detects and uses the best available environment (local or container)
- Installs mermaid-cli if needed
- Recommends Mermaid 9.3.0 for optimal file size (up to 44% smaller)
- Handles all dependencies and configuration automatically

## Quick Start

Basic usage - the script handles everything automatically:

```bash
scripts/export_mermaid.py document.md
```

The script will:
1. Check for local mermaid-cli + Chrome, or Docker container with Chrome
2. Auto-install mermaid-cli if needed (in container)
3. Export all Mermaid diagrams as PNG images
4. Save images in the same directory as the Markdown file

## Workflow

### Step 1: Run the Export Script

Simply provide the Markdown file path:

```bash
scripts/export_mermaid.py path/to/document.md
```

The script automatically:
- Detects available environment (local or container)
- Checks and installs dependencies if needed
- Exports all diagrams

### Step 2: Optional Parameters

**Create a copy with images (Recommended):**
```bash
scripts/export_mermaid.py document.md --copy-replace
```
This creates a new file `document_with_images.md` with Mermaid replaced by image references. Original file remains unchanged.

**Custom output directory:**
```bash
scripts/export_mermaid.py document.md --output-dir ./images
```

**Replace in original file (with backup):**
```bash
scripts/export_mermaid.py document.md --replace
```
This creates a backup (`.md.bak`) and replaces code blocks in the original file with `![Mermaid Diagram](./image.png)`

**Specify Mermaid version:**
```bash
scripts/export_mermaid.py document.md --version 9.3.0
```

## Script Features

The script automatically handles:

- ✅ Environment detection (local vs container)
- ✅ Dependency checking and installation
- ✅ Chrome/Chromium detection
- ✅ Puppeteer configuration
- ✅ Version management
- ✅ Error handling and recovery
- ✅ Progress reporting

## Environment Support

### Priority 1: Local Environment
If you have mermaid-cli and Chrome installed locally, the script uses them directly.

### Priority 2: Docker Container
If local environment is not available, the script automatically uses a Docker container (e.g., `stephen.hu_dev`) and installs mermaid-cli if needed.

### No Environment Available
The script provides clear installation instructions.

## Version Recommendation

**Mermaid 9.3.0 (Recommended):**
- 44% smaller files on complex diagrams
- 15% smaller overall
- Compatible with Node.js 14+
- Stable and reliable

**Mermaid 11.x:**
- Latest features
- Requires Node.js 18+
- Larger file sizes

The script defaults to 9.3.0 but allows version selection via `--version` parameter.

## Examples

### Example 1: Basic export

```
User: "Export the Mermaid diagrams from the VGP design document"

Agent:
1. Run: scripts/export_mermaid.py runtime/docs/caps_VGP设计文档.md
2. Script automatically detects environment and exports diagrams
3. Report: "Exported 7 diagrams to runtime/docs/"
```

### Example 2: Export to specific directory

```
User: "Extract all Mermaid diagrams from README.md and put them in an images folder"

Agent:
1. Run: scripts/export_mermaid.py README.md --output-dir ./images
2. Report: "Exported 3 diagrams to ./images/"
```

### Example 3: Create copy with images (Recommended)

```
User: "Export diagrams and create a copy of the document with images instead of Mermaid code"

Agent:
1. Run: scripts/export_mermaid.py document.md --copy-replace
2. Report:
   - "Exported 7 diagrams"
   - "Created copy: document_with_images.md"
   - "Original file unchanged"
```

### Example 4: Replace code in original file

```
User: "Convert the Mermaid diagrams in architecture.md to images and update the file"

Agent:
1. Run: scripts/export_mermaid.py architecture.md --replace
2. Report:
   - "Backup created: architecture.md.bak"
   - "Exported 4 diagrams"
   - "Updated architecture.md with image references"
```

## Output

- **PNG images**: Named `{filename}_{index:02d}.png` (e.g., `document_01.png`, `document_02.png`)
- **Transparent background**: Suitable for any document
- **Markdown copy**: `{filename}_with_images.md` when using `--copy-replace`
- **Backup file**: `.md.bak` when using `--replace`
- **Progress reporting**: Clear status for each diagram

## Error Handling

The script handles errors gracefully:
- Missing dependencies → Auto-install or provide instructions
- No Chrome found → Use container or provide install instructions
- Export failures → Continue with remaining diagrams
- Clear error messages for troubleshooting

## Tips

- The script handles all setup automatically - just run it
- Use `--version 9.3.0` for production (smaller files)
- Review exported images to ensure quality
- Use `--replace` cautiously (backup is created automatically)
- The script works in both local and container environments seamlessly
