#!/usr/bin/env python3
"""
Script to fix invalid UIDs in Godot scene files
This script removes invalid UID references from .tscn files
"""

import os
import re
import glob

def fix_scene_file(file_path):
    """Remove invalid UIDs from a scene file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern to match ext_resource lines with UIDs
        pattern = r'\[ext_resource type="[^"]*" uid="[^"]*" path="([^"]*)" id="([^"]*)"\]'
        
        def replace_uid(match):
            path = match.group(1)
            id_name = match.group(2)
            # Remove the uid attribute, keep only path and id
            return f'[ext_resource type="Texture2D" path="{path}" id="{id_name}"]'
        
        # Apply the replacement
        new_content = re.sub(pattern, replace_uid, content)
        
        # Write back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"Fixed: {file_path}")
        return True
        
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")
        return False

def main():
    """Main function to fix all scene files"""
    # Find all .tscn files
    scene_files = glob.glob("**/*.tscn", recursive=True)
    
    fixed_count = 0
    total_count = len(scene_files)
    
    print(f"Found {total_count} scene files to process...")
    
    for scene_file in scene_files:
        if fix_scene_file(scene_file):
            fixed_count += 1
    
    print(f"\nFixed {fixed_count} out of {total_count} scene files")
    print("Note: You should still reimport all resources in Godot Editor for best results")

if __name__ == "__main__":
    main() 