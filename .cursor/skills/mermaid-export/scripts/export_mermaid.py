#!/usr/bin/env python3
"""
Mermaid Export Script - Extract Mermaid diagrams from Markdown and export as PNG

Automatically detects and uses the best available environment:
1. Local mermaid-cli + Chrome (if available)
2. Docker container with Chrome (fallback)
3. Provides installation instructions if neither is available

Recommended: Mermaid 9.3.0 for optimal file size and compatibility

Usage:
    export_mermaid.py <markdown_file> [--replace] [--output-dir <dir>] [--version <version>]

Examples:
    export_mermaid.py document.md
    export_mermaid.py document.md --replace
    export_mermaid.py document.md --output-dir ./images
    export_mermaid.py document.md --version 9.3.0
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def run_command(cmd, capture=True, check=True):
    """Run shell command with error handling"""
    try:
        if capture:
            result = subprocess.run(cmd, capture_output=True, text=True, check=check)
            return result.returncode == 0, result.stdout, result.stderr
        else:
            result = subprocess.run(cmd, check=check)
            return result.returncode == 0, "", ""
    except subprocess.CalledProcessError as e:
        return False, e.stdout if hasattr(e, 'stdout') else "", e.stderr if hasattr(e, 'stderr') else str(e)
    except FileNotFoundError:
        return False, "", f"Command not found: {cmd[0]}"


def check_chrome_available():
    """Check if Chrome/Chromium is available locally"""
    chrome_paths = [
        '/usr/bin/google-chrome',
        '/usr/bin/chromium-browser',
        '/usr/bin/chromium',
    ]
    
    for path in chrome_paths:
        if os.path.exists(path):
            return True, path
    
    # Check puppeteer cache
    cache_dir = os.path.expanduser('~/.cache/puppeteer')
    if os.path.exists(cache_dir):
        for root, dirs, files in os.walk(cache_dir):
            for file in files:
                if 'chrome' in file.lower() and os.access(os.path.join(root, file), os.X_OK):
                    return True, os.path.join(root, file)
    
    return False, None


def check_docker_container():
    """Check if Docker container with Chrome is available"""
    success, stdout, _ = run_command(['docker', 'ps', '--filter', 'name=stephen.hu_dev', '--format', '{{.Names}}'], check=False)
    if success and 'stephen.hu_dev' in stdout:
        # Verify Chrome in container
        success, _, _ = run_command(['docker', 'exec', 'stephen.hu_dev', 'which', 'chromium-browser'], check=False)
        if success:
            return True, 'stephen.hu_dev'
    return False, None


def check_mmdc_version(use_container=False, container_name=None):
    """Check mermaid-cli version"""
    if use_container:
        success, stdout, _ = run_command(['docker', 'exec', container_name, 'mmdc', '--version'], check=False)
    else:
        success, stdout, _ = run_command(['mmdc', '--version'], check=False)
    
    if success:
        return stdout.strip()
    return None


def install_mermaid_cli(version='9.3.0', use_container=False, container_name=None):
    """Install or upgrade mermaid-cli to specified version"""
    install_cmd = f'PUPPETEER_SKIP_DOWNLOAD=true npm install -g @mermaid-js/mermaid-cli@{version}'
    
    if use_container:
        print(f"Installing mermaid-cli {version} in container {container_name}...")
        success, _, stderr = run_command(['docker', 'exec', container_name, 'bash', '-c', install_cmd], check=False)
    else:
        print(f"Installing mermaid-cli {version} locally...")
        success, _, stderr = run_command(['bash', '-c', install_cmd], check=False)
    
    if success:
        print(f"✓ Successfully installed mermaid-cli {version}")
        return True
    else:
        print(f"✗ Failed to install mermaid-cli: {stderr}")
        return False


def setup_puppeteer_config(use_container=False, container_name=None, chrome_path=None):
    """Setup Puppeteer configuration for Chrome"""
    if not use_container:
        return  # Local mmdc handles this automatically
    
    config_content = '''{
  "executablePath": "/usr/bin/chromium-browser",
  "args": ["--no-sandbox", "--disable-setuid-sandbox"]
}'''
    
    config_path = '/tmp/puppeteer-config.json'
    
    # Create config in container
    cmd = ['docker', 'exec', container_name, 'bash', '-c', f"cat > {config_path} << 'EOF'\n{config_content}\nEOF"]
    run_command(cmd, check=False)


def check_environment():
    """Check and setup environment, return execution mode"""
    print("Checking environment...")
    
    # Check local setup
    has_local_mmdc = shutil.which('mmdc') is not None
    has_chrome, chrome_path = check_chrome_available()
    
    if has_local_mmdc and has_chrome:
        version = check_mmdc_version()
        print(f"✓ Found local mermaid-cli (version: {version})")
        print(f"✓ Found Chrome at: {chrome_path}")
        return 'local', None, version
    
    # Check container
    has_container, container_name = check_docker_container()
    if has_container:
        version = check_mmdc_version(use_container=True, container_name=container_name)
        if version:
            print(f"✓ Found mermaid-cli in container {container_name} (version: {version})")
            return 'container', container_name, version
        else:
            print(f"⚠ Container {container_name} found but mermaid-cli not installed")
            print("Installing mermaid-cli in container...")
            if install_mermaid_cli(use_container=True, container_name=container_name):
                setup_puppeteer_config(use_container=True, container_name=container_name)
                return 'container', container_name, '9.3.0'
    
    # No suitable environment found
    print("\n✗ No suitable environment found")
    print("\nRecommended setup:")
    print("  Option 1: Install locally (best performance)")
    print("    1. npm install -g @mermaid-js/mermaid-cli@9.3.0")
    print("    2. Install Chrome: sudo apt-get install chromium-browser")
    print("\n  Option 2: Use Docker container")
    print("    - Ensure container with Chrome is running")
    print("    - Script will auto-install mermaid-cli in container")
    sys.exit(1)


def extract_mermaid_blocks(content):
    """Extract all Mermaid code blocks from Markdown content"""
    pattern = r'```mermaid\n(.*?)```'
    matches = re.findall(pattern, content, re.DOTALL)
    return matches


def export_mermaid_to_png(mermaid_content, output_path, mode, container_name=None):
    """Export a single Mermaid diagram to PNG"""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.mmd', delete=False) as tmp:
        tmp.write(mermaid_content)
        tmp_path = tmp.name
    
    try:
        if mode == 'container':
            # Use container
            container_tmp = f'/tmp/{os.path.basename(tmp_path)}'
            container_out = f'/tmp/{os.path.basename(output_path)}'
            
            run_command(['docker', 'cp', tmp_path, f'{container_name}:{container_tmp}'])
            
            success, _, stderr = run_command([
                'docker', 'exec', container_name, 'mmdc',
                '-i', container_tmp,
                '-o', container_out,
                '-b', 'transparent',
                '-p', '/tmp/puppeteer-config.json'
            ], check=False)
            
            if success:
                run_command(['docker', 'cp', f'{container_name}:{container_out}', output_path])
                run_command(['docker', 'exec', container_name, 'rm', '-f', container_tmp, container_out], check=False)
                return True
            else:
                print(f"    Error: {stderr}")
                return False
        else:
            # Use local
            success, _, stderr = run_command([
                'mmdc',
                '-i', tmp_path,
                '-o', output_path,
                '-b', 'transparent'
            ], check=False)
            
            if not success:
                print(f"    Error: {stderr}")
            return success
    
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)


def replace_mermaid_with_images(content, image_paths):
    """Replace Mermaid code blocks with image references"""
    pattern = r'```mermaid\n(.*?)```'
    image_index = 0
    
    def replacer(match):
        nonlocal image_index
        if image_index < len(image_paths):
            image_name = os.path.basename(image_paths[image_index])
            image_index += 1
            return f'![Mermaid Diagram](./{image_name})'
        return match.group(0)
    
    return re.sub(pattern, replacer, content, flags=re.DOTALL)


def main():
    parser = argparse.ArgumentParser(
        description='Extract Mermaid diagrams from Markdown and export as PNG',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s document.md
  %(prog)s document.md --copy-replace
  %(prog)s document.md --copy-replace --output-dir ./images
  %(prog)s document.md --replace
  %(prog)s document.md --version 9.3.0

Recommended: 
  - Use --copy-replace to create a copy with images (safe, original unchanged)
  - Use Mermaid 9.3.0 for optimal file size (up to 44%% smaller)
        """
    )
    parser.add_argument('markdown_file', help='Path to the Markdown file')
    parser.add_argument('--replace', action='store_true',
                       help='Replace Mermaid code blocks with image references in original file (creates backup)')
    parser.add_argument('--copy-replace', action='store_true',
                       help='Create a copy of markdown with Mermaid replaced by images (recommended)')
    parser.add_argument('--output-dir',
                       help='Directory to save exported images (default: same as markdown file)')
    parser.add_argument('--version', default='9.3.0',
                       help='Mermaid CLI version to install if needed (default: 9.3.0)')
    
    args = parser.parse_args()
    
    # Check and setup environment
    mode, container_name, current_version = check_environment()
    
    # Check version and offer upgrade
    if current_version and current_version != args.version:
        print(f"\nCurrent version: {current_version}, requested: {args.version}")
        response = input(f"Upgrade to {args.version}? (y/N): ")
        if response.lower() == 'y':
            install_mermaid_cli(args.version, mode == 'container', container_name)
    
    # Process markdown file
    markdown_path = Path(args.markdown_file)
    if not markdown_path.exists():
        print(f"Error: File not found: {markdown_path}")
        sys.exit(1)
    
    with open(markdown_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    mermaid_blocks = extract_mermaid_blocks(content)
    
    if not mermaid_blocks:
        print("No Mermaid diagrams found in the file.")
        return
    
    print(f"\nFound {len(mermaid_blocks)} Mermaid diagram(s)")
    
    output_dir = Path(args.output_dir) if args.output_dir else markdown_path.parent
    output_dir.mkdir(parents=True, exist_ok=True)
    
    basename = markdown_path.stem
    exported_images = []
    
    print(f"\nExporting diagrams...")
    for idx, mermaid_content in enumerate(mermaid_blocks, start=1):
        output_filename = f"{basename}_{idx:02d}.png"
        output_path = output_dir / output_filename
        
        print(f"  [{idx}/{len(mermaid_blocks)}] {output_filename}...", end=' ')
        
        if export_mermaid_to_png(mermaid_content, str(output_path), mode, container_name):
            exported_images.append(str(output_path))
            print("✓")
        else:
            print("✗")
    
    # Handle replacement
    if args.copy_replace and exported_images:
        # Create a copy with replaced content
        copy_path = markdown_path.parent / f"{markdown_path.stem}_with_images.md"
        new_content = replace_mermaid_with_images(content, exported_images)
        with open(copy_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"\n✓ Created copy with images: {copy_path}")
        print(f"✓ Original file unchanged: {markdown_path}")
    
    elif args.replace and exported_images:
        # Replace in original file (with backup)
        backup_path = markdown_path.with_suffix('.md.bak')
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        new_content = replace_mermaid_with_images(content, exported_images)
        with open(markdown_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"\n✓ Backup created: {backup_path}")
        print(f"✓ Updated {markdown_path} with image references")
    
    print(f"\n✓ Successfully exported {len(exported_images)}/{len(mermaid_blocks)} diagram(s) to {output_dir}")


if __name__ == '__main__':
    main()
