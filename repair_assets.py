import os
import re

# 1. Map existing SVGs in assets/images
image_dir = 'assets/images'
existing_svgs = set()
if os.path.exists(image_dir):
    for f in os.listdir(image_dir):
        if f.lower().endswith('.svg'):
            existing_svgs.add(f.lower())

print(f"Found {len(existing_svgs)} SVGs in {image_dir}")

def repair_content(content):
    # a. Fix mangled "Image.asset(filterQuality: FilterQuality.high, '...svg' ...)"
    # Some calls were partially migrated to .svg but still used Image.asset
    def fix_mangled_svg_usage(match):
        params = match.group(1)
        path = match.group(2)
        rest = match.group(3)
        
        # Translate color to colorFilter if present
        color_match = re.search(r'color:\s*(Color\([^)]+\)|Colors\.[a-zA-Z0-9.]+)', params + rest)
        blend_match = re.search(r'colorBlendMode:\s*(BlendMode\.[a-z]+)', params + rest)
        
        replacement = f"SvgPicture.asset('{path}.svg'"
        
        # Add colorFilter if color was found
        if color_match:
            color_val = color_match.group(1)
            blend_val = blend_match.group(1) if blend_match else "BlendMode.srcIn"
            replacement += f", colorFilter: ColorFilter.mode({color_val}, {blend_val})"
            
        # Add remaining parameters (width, height, fit, etc.)
        # Filter out the color/blend/filterQuality params
        other_params = params + rest
        other_params = re.sub(r'filterQuality:\s*FilterQuality\.[a-z]+,?\s*', '', other_params)
        other_params = re.sub(r'color:\s*[^,]+,?\s*', '', other_params)
        other_params = re.sub(r'colorBlendMode:\s*[^,]+,?\s*', '', other_params)
        
        if other_params.strip():
            replacement += f", {other_params.strip().rstrip(',')}"
            
        return replacement + ")"

    # Regex for Image.asset with filterQuality and .svg path
    pattern_mangled = r"Image\.asset\(\s*(.*?)\s*['\"]assets/images/([^'\"]+)\.svg['\"](.*?)\)"
    content = re.sub(pattern_mangled, fix_mangled_svg_usage, content, flags=re.DOTALL)

    # b. Fix remaining .png strings that should be .svg
    def fix_png_strings(match):
        full_path = match.group(0)
        prefix = match.group(1)
        name = match.group(2)
        ext = match.group(3)
        
        if f"{name.lower()}.svg" in existing_svgs:
            return f"{prefix}{name}.svg"
        return full_path

    pattern_png = r"(assets/images/)([^'\"]+)\.(png|jpg)"
    content = re.sub(pattern_png, fix_png_strings, content)

    # c. Convert any remaining "Image.asset('...svg')" to "SvgPicture.asset"
    content = re.sub(r"Image\.asset\(\s*['\"](assets/images/[^'\"]+\.svg)['\"]\s*\)", r"SvgPicture.asset('\1')", content)

    # d. Handle Image.asset with variables if they contain .svg
    # (Optional, might be too risky, but let's check common patterns)
    
    return content

# Process all Dart files
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                original = f.read()
            
            repaired = repair_content(original)
            
            if repaired != original:
                # Ensure flutter_svg is imported
                if 'package:flutter_svg/flutter_svg.dart' not in repaired and 'SvgPicture' in repaired:
                    import_line = "import 'package:flutter_svg/flutter_svg.dart';\n"
                    # Add after last import or at top
                    last_import = repaired.rfind('import ')
                    if last_import != -1:
                        newline = repaired.find('\n', last_import)
                        repaired = repaired[:newline+1] + import_line + repaired[newline+1:]
                    else:
                        repaired = import_line + repaired
                
                with open(filepath, 'w') as f:
                    f.write(repaired)
                print(f"Repaired: {filepath}")

print("Repair complete.")
