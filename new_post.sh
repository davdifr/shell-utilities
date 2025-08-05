#!/bin/bash

# Function to create a new post with a given title
new_post() {
    local title_slug=$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
    local date=$(date +%Y-%m-%d)
    local filename="_posts/${date}-${title_slug}.md"
    echo "---" > "$filename"
    echo "title: \"$1\"" >> "$filename"
    echo "date: $(date +'%Y-%m-%d %H:%M:%S %z')" >> "$filename"
    echo "layout: post" >> "$filename"
    echo "---" >> "$filename"
    echo "" >> "$filename"
    echo "📝 Created: $filename"
}
