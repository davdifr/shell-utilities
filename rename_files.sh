#!/bin/bash

# Function to rename files and folders: spaces and dashes -> underscore, all lowercase
rename_files() {
    local target_dir="."
    local preview_only=false
    
    # Handle parameters
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--preview)
                preview_only=true
                shift
                ;;
            -d|--directory)
                target_dir="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: rename_files [options] [directory]"
                echo ""
                echo "Renames files and folders by:"
                echo "- Converting spaces and dashes to underscores"
                echo "- Converting to lowercase"
                echo "- Ignoring .DS_Store and other hidden files"
                echo ""
                echo "Options:"
                echo "  -p, --preview     Show preview only without renaming"
                echo "  -d, --directory   Specify target directory"
                echo "  -h, --help        Show this help"
                echo ""
                echo "Examples:"
                echo "  rename_files                    # Rename in current directory"
                echo "  rename_files -p                 # Preview only"
                echo "  rename_files -d ~/Documents     # Rename in ~/Documents"
                return 0
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done
    
    # Check if directory exists
    if [[ ! -d "$target_dir" ]]; then
        echo "❌ Error: Directory '$target_dir' does not exist!"
        return 1
    fi
    
    cd "$target_dir" || return 1
    echo "📁 Working in: $(pwd)"
    echo ""
    
    # Function to transform name
    transform_name() {
        local name="$1"
        # Convert to lowercase, replace spaces and dashes with underscore
        echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[ -]/_/g'
    }
    
    # Find files and folders that need renaming
    local items_to_rename=()
    local new_names=()
    
    # Collect all items (folders from deepest to shallowest, then files)
    # Exclude .DS_Store and other hidden files/folders
    while IFS= read -r -d '' item; do
        basename_item=$(basename "$item")
        
        # Skip .DS_Store and hidden files/folders
        if [[ "$basename_item" == .DS_Store ]] || [[ "$basename_item" == .* ]]; then
            continue
        fi
        
        new_name=$(transform_name "$basename_item")
        
        if [[ "$basename_item" != "$new_name" ]]; then
            items_to_rename+=("$item")
            new_names+=("$(dirname "$item")/$new_name")
        fi
    done < <(find . -depth \( -type d -o -type f \) -print0)
    
    # If no items to rename
    if [[ ${#items_to_rename[@]} -eq 0 ]]; then
        echo "✅ No files or folders found that need renaming!"
        return 0
    fi
    
    # Show preview
    echo "📋 Items to rename:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local dir_count=0
    local file_count=0
    
    local i=1
    while [[ $i -le ${#items_to_rename[@]} ]]; do
        local old_path="${items_to_rename[$i]}"
        local new_path="${new_names[$i]}"
        local old_name=$(basename "$old_path")
        local new_name=$(basename "$new_path")
        
        if [[ -d "$old_path" ]]; then
            echo "📁 $old_name → $new_name"
            ((dir_count++))
        else
            echo "📄 $old_name → $new_name"
            ((file_count++))
        fi
        ((i++))
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Total: $dir_count folders, $file_count files"
    echo ""
    
    # If preview only, exit
    if [[ "$preview_only" == true ]]; then
        echo "👁️  Preview completed (run without -p to execute renaming)"
        return 0
    fi
    
    # Ask for confirmation
    echo -n "❓ Proceed with renaming? [y/N]: "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Operation cancelled"
        return 0
    fi
    
    # Execute renaming
    echo ""
    echo "🔄 Starting renaming process..."
    
    local success_count=0
    local error_count=0
    
    local i=1
    while [[ $i -le ${#items_to_rename[@]} ]]; do
        local old_path="${items_to_rename[$i]}"
        local new_path="${new_names[$i]}"
        
        if mv "$old_path" "$new_path" 2>/dev/null; then
            echo "✅ $(basename "$old_path") → $(basename "$new_path")"
            ((success_count++))
        else
            echo "❌ Error renaming: $(basename "$old_path")"
            ((error_count++))
        fi
        ((i++))
    done
    
    echo ""
    echo "🎉 Renaming completed!"
    echo "✅ Success: $success_count items"
    if [[ $error_count -gt 0 ]]; then
        echo "❌ Errors: $error_count items"
    fi
}

# Shorter aliases
alias rf='rename_files'
alias rfp='rename_files --preview'
