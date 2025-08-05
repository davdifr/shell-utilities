#!/bin/bash

# Function to serve your Jekyll blog with drafts and livereload
serve_jekyll_blog() {
    if [[ ! -f "_config.yml" ]]; then
        echo "❌ Not in a Jekyll project directory (missing _config.yml)"
        return 1
    fi

    bundle exec jekyll serve --drafts --livereload "$@"
}

