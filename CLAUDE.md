# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal Neovim configuration based on **kickstart.nvim** - a minimal, single-file, well-documented starting point for Neovim configuration. This is NOT a distribution but a customizable configuration meant to be understood line-by-line.

**Key Philosophy**: Every line of code should be readable and understandable. The configuration is intentionally kept in a single `init.lua` file to serve as both configuration and documentation.

## Architecture

### Core Structure

- **`init.lua`**: Single-file configuration containing all plugin definitions, keymaps, options, and autocommands
- **`lua/theme-sync.lua`**: Custom module for automatic theme switching based on system appearance (Mac) or environment variables
- **`lua/custom/plugins/`**: Directory for user-added custom plugins (currently empty)
- **`lua/kickstart/plugins/`**: Optional modular plugins (debug, indent_line, neo-tree, lint, gitsigns, autopairs)

### Plugin Management

Uses **lazy.nvim** as the plugin manager. All plugins are defined in the `require('lazy').setup({...})` call in `init.lua`.

#### Key Plugins

- **LSP**: `nvim-lspconfig` with Mason for automatic LSP installation
- **Completion**: `blink.cmp` with LuaSnip for snippets
- **Fuzzy Finding**: `telescope.nvim` with fzf-native
- **Syntax**: `nvim-treesitter` for advanced syntax highlighting
- **Formatting**: `conform.nvim` for code formatting
- **Git**: `gitsigns.nvim` for git integration
- **Theme**: `catppuccin` with automatic light/dark switching
- **AI**: `github/copilot.vim` and `codecompanion.nvim`
- **Tmux**: `vim-tmux-navigator` for seamless tmux/vim navigation
- **Mini**: `mini.nvim` collection (statusline, surround, ai textobjects)

### LSP Configuration

LSP servers are configured in the `servers` table (line 672-716):
- `clangd`: C/C++ with custom flags for background indexing and clang-tidy
- `rust_analyzer`: Rust support
- `lua_ls`: Lua with Neovim-specific settings

Mason automatically installs configured LSP servers and tools via `mason-tool-installer`.

### Theme System

The custom `theme-sync.lua` module provides:
1. **Environment-based switching**: Reads `MAC_THEME` environment variable
2. **macOS detection**: Automatically detects system appearance on Mac
3. **Manual toggle**: `<leader>tt` or `:ToggleTheme` command
4. **Flavors**: Catppuccin Frappe (dark) and Latte (light)

## Common Commands

### Plugin Management
```vim
:Lazy                 " View plugin status
:Lazy update         " Update all plugins
:Lazy clean          " Remove unused plugins
:Lazy sync           " Install, update, and clean
```

### LSP & Mason
```vim
:Mason               " Open Mason UI to manage LSP servers
:LspInfo             " Show LSP server status
:checkhealth         " Check Neovim health (useful for debugging)
```

### Formatting
```vim
<leader>f            " Format current buffer (conform.nvim)
```

### Telescope (Fuzzy Finding)
```vim
<leader>sf           " Search files
<leader>sg           " Live grep (search in files)
<leader>sw           " Search current word
<leader>sh           " Search help
<leader>sk           " Search keymaps
<leader>sd           " Search diagnostics
<leader>sr           " Resume last search
<leader>sn           " Search Neovim config files
<leader>/            " Fuzzy search in current buffer
<leader><leader>     " Find existing buffers
```

### LSP Keymaps (available when LSP attaches)
```vim
grd                  " Go to definition
grr                  " Go to references
gri                  " Go to implementation
grt                  " Go to type definition
grn                  " Rename symbol
gra                  " Code action
gO                   " Document symbols
gW                   " Workspace symbols
<leader>th           " Toggle inlay hints
```

### Git
```vim
<leader>h            " Git hunk operations (visual/normal mode)
```

### Window Navigation
```vim
<C-h>, <C-j>, <C-k>, <C-l>    " Navigate between splits (works with tmux)
```

### Diagnostics
```vim
<leader>q            " Open diagnostic quickfix list
```

## Configuration Guidelines

### Adding New Plugins

Add plugins directly to the `require('lazy').setup({...})` table in `init.lua`. Examples:
```lua
'owner/repo',                              -- Simple plugin
{ 'owner/repo', opts = {} },              -- Plugin with auto-setup
{ 'owner/repo', config = function() ... end }  -- Plugin with custom config
```

For more organized structure, add plugins to `lua/custom/plugins/` (they won't be auto-loaded unless imported).

### Modifying LSP Servers

1. Add server to the `servers` table (line 672)
2. Optionally configure with `cmd`, `filetypes`, `capabilities`, or `settings`
3. Add to `ensure_installed` list if you want Mason to auto-install it

### Customizing Options

All Vim options are set using `vim.o.*` (lines 96-166). Key settings:
- Leader key: `<space>` (must be set before plugins load)
- Line numbers: enabled by default
- Mouse: enabled
- Clipboard: syncs with system clipboard
- Timeouts: 300ms for keymaps

### Enabling Optional Plugins

Uncomment the require statements around lines 1016-1021:
```lua
require 'kickstart.plugins.debug',
require 'kickstart.plugins.neo-tree',
-- etc.
```

## Development Workflow

1. **Edit config**: Modify `init.lua` or create modules in `lua/`
2. **Reload**: Restart Neovim or use `:source $MYVIMRC`
3. **Sync plugins**: Run `:Lazy sync` if you added/removed plugins
4. **Check health**: Run `:checkhealth` to diagnose issues
5. **Check LSP**: Run `:LspInfo` to verify language servers are attached

## External Dependencies

Required tools:
- `git`, `make`, `unzip`, C compiler (gcc)
- `ripgrep` - for grep functionality in Telescope
- `fd` (fd-find) - for file finding in Telescope
- Clipboard tool: `xclip`/`xsel` (Linux), built-in (Mac/Windows)
- Nerd Font: optional, set `vim.g.have_nerd_font = true` if installed

Language-specific:
- `npm` for TypeScript
- `go` for Golang
- Respective language toolchains for other languages

## Special Features

### Theme Synchronization
Theme automatically syncs on startup based on:
1. `MAC_THEME` environment variable (set by external script)
2. macOS system appearance (when running on Mac)
3. Falls back to Frappe (dark) on servers

### Neovim Version Compatibility
The config includes compatibility handling for both Neovim 0.10 (stable) and 0.11 (nightly), particularly around LSP method support checking (line 579-585).

### Tmux Integration
Seamless navigation between Neovim splits and tmux panes using `<C-h/j/k/l>` via `vim-tmux-navigator`.
