# Shell Scripts Collection

A collection of useful bash scripts to automate common operations.

## 📋 Available Scripts

### 🆕 new_post.sh

Script to quickly create new posts for Jekyll blogs.

**Features:**

-   Creates a new markdown file in the `_posts/` folder
-   Automatically generates slug from title
-   Adds YAML front matter with title, date, and layout
-   File format: `YYYY-MM-DD-title-slug.md`

**Usage:**

```bash
new_post "My new post"
```

### 🔄 rename_files.sh

Advanced script to rename files and folders following standardized conventions.

**Features:**

-   Converts spaces and dashes to underscores
-   Transforms everything to lowercase
-   Ignores hidden files and `.DS_Store`
-   Preview mode to see changes before applying
-   Recursive processing from deepest folders

**Options:**

-   `-p, --preview`: Show preview only without renaming
-   `-d, --directory`: Specify target directory
-   `-h, --help`: Show help

**Usage:**

```bash
# Rename in current directory
rename_files

# Preview only
rename_files --preview

# Specific directory
rename_files --directory ~/Documents

# Available aliases
rf              # shortcut for rename_files
rfp             # shortcut for rename_files --preview
```

### 🌐 serve_jekyll_blog.sh

Script to start Jekyll development server with optimized configurations.

**Features:**

-   Verifies we're in a Jekyll project
-   Starts server with drafts enabled
-   Activates livereload for automatic updates
-   Accepts additional parameters

**Usage:**

```bash
serve_jekyll_blog

# With additional parameters
serve_jekyll_blog --port 4001
```

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

---

_Created to simplify daily development and file management operations._
