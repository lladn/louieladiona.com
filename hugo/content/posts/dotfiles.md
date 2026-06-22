---
date: '2026-06-07T00:13:11+08:00'
title: 'Dotfiles'
draft: false
showtoc: true
tocopen: false
tags: ['neovim', 'vim', 'dotfiles', 'setup']
---



My dotfiles are managed using **Git** and **GNU Stow**. The idea is simple — keep all config files in one repo, and use Stow to create symlinks from the repo into the right places on the filesystem. This makes it trivial to replicate the setup on a new machine.

## Managing Dotfiles with GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager. Instead of manually copying config files or remembering where each one lives, Stow handles creating the symlinks for you.

Install it via Homebrew (or your distro's package manager):

```sh
brew install stow
```

The repo is structured so that each top-level folder mirrors the target directory structure relative to `$HOME`. For example, the `nvim/` folder contains `.config/nvim/`, which Stow will symlink to `~/.config/nvim/`.

To apply a config:

```sh
stow -vt ~ nvim
```

To remove it:

```sh
stow -D nvim
```

---

## Neovim

The Neovim config lives in `nvim/.config/nvim/` and is structured around [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. The namespace used is `lowelad`.

### Entry Point

```
init.lua
  └── require("lowelad")
        └── lowelad/init.lua
              ├── vim.g.mapleader = " "
              ├── require("lowelad.lazy_init")   -- bootstraps lazy.nvim
              ├── require("lowelad.remap")        -- all keymaps
              └── require("lowelad.set")          -- editor settings
```

### Editor Settings (`set.lua`)

| Setting | Value | Purpose |
|---|---|---|
| Colorscheme | `tokyonight` (storm) | Dark theme with transparency |
| Clipboard | `unnamedplus` | Syncs yank with system clipboard |
| Line numbers | `nu` + `relativenumber` | Absolute current line, relative others |
| Tab size | 2 spaces | `tabstop`, `softtabstop`, `shiftwidth` all set to 2 |
| `expandtab` | true | Spaces instead of tabs |
| `smartindent` | true | Auto-indent on new lines |
| `wrap` | false | No line wrapping |
| `incsearch` | true | Incremental search as you type |
| `termguicolors` | true | 24-bit color support |

### Keymaps (`remap.lua`)

Keymaps are managed via [which-key.nvim](https://github.com/folke/which-key.nvim), so pressing `<leader>` (Space) shows a popup of available bindings.

#### LSP Keymaps (active when LSP attaches)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gl` / `<leader>ld` | Open diagnostic float |
| `K` | Show hover docs |
| `<leader>la` | Code action |
| `<leader>lr` | References |
| `<leader>ln` | Rename symbol |
| `<leader>lw` | Workspace symbol |
| `[d` / `]d` | Next / previous diagnostic |

Format-on-save is enabled automatically via `BufWritePre` using the attached LSP client.

#### General Keymaps

| Key | Action |
|---|---|
| `<leader>e` | Open file explorer (netrw) |
| `<leader>p` | Paste without overwriting register |
| `<leader>/` | Toggle comment (current line) |
| `<leader>s` | Search & replace word under cursor |
| `<leader>t` | Open today's note |
| `J` | Join lines, keep cursor position |
| `<C-d>` / `<C-u>` | Half-page scroll, cursor stays centered |
| `n` / `N` | Next/prev search result, centered |
| `Q` | Disabled (no accidental Ex mode) |

#### Telescope Keymaps

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Find git-tracked files |
| `<leader>fl` | Live grep |
| `;` | Browse open buffers |

#### Visual Mode

| Key | Action |
|---|---|
| `J` / `K` | Move selection down / up |
| `<leader>/` | Toggle comment on selection |

### Plugins

#### UI & Appearance
- **tokyonight.nvim** — colorscheme in `storm` style with transparent background
- **lualine.nvim** — statusline themed with tokyonight
- **bufferline.nvim** — tab-style buffer navigation at the top
- **indent-blankline.nvim** — visual indent guides
- **nvim-colorizer.lua** — highlights color codes (`#rrggbb`) inline
- **smear-cursor.nvim** — animated cursor smear effect (color `#d3cdc3`)
- **alpha-nvim** — startup dashboard with a fortune/cowsay header if available, otherwise a fallback ASCII art; shows day of week in footer

#### Navigation & Search
- **nvim-tree.lua** — file tree sidebar; shows dotfiles and git-ignored files
- **telescope.nvim** — fuzzy finder for files, buffers, grep
- **vim-illuminate** — highlights other occurrences of the word under cursor

#### LSP & Completion
- **nvim-lspconfig** + **mason.nvim** + **mason-lspconfig.nvim** — LSP setup with auto-install for:
  - `tsserver` (TypeScript/JavaScript)
  - `lua_ls` (Lua, configured for Neovim's LuaJIT runtime)
  - `ruff` (Python linter/formatter)
- **nvim-cmp** — completion engine with sources: LSP, buffer, path, luasnip
- **LuaSnip** — snippet engine with VSCode-compatible snippet support
- **fidget.nvim** — LSP progress indicator in the bottom-right corner
- **conform.nvim** — format-on-save; runs `prettierd` for Markdown files

#### Code Quality
- **nvim-treesitter** — syntax highlighting and indentation for: C, Lua, Vim, Elixir, JavaScript, TypeScript, HTML, Python
- **Comment.nvim** — easy comment toggling
- **nvim-autopairs** — auto-closes brackets, quotes, etc.; integrated with nvim-cmp

#### Git
- **gitsigns.nvim** — shows git diff signs in the gutter (added, changed, deleted lines)

#### Other
- **which-key.nvim** — keybinding popup with 300ms timeout; configured to suppress most preset hints, keeping only what's explicitly registered
- **symbols-outline.nvim** — sidebar showing document symbols (functions, classes, etc.)
- **today.nvim** — opens a daily journal note; notes stored in `~/workspace/notes` using the `templates/jrnl.md` template

---

## tmux

Config at `tmux/.tmux.conf`. Managed with [TPM (tmux Plugin Manager)](https://github.com/tmux-plugins/tpm).

### General Settings

| Setting | Value |
|---|---|
| Prefix | `C-s` (replaces default `C-b`) |
| Terminal | `tmux-256color` |
| Status bar position | Top |
| Mouse | Enabled |

### Pane Navigation

vim-style pane switching with the prefix:

| Key | Direction |
|---|---|
| `prefix + h` | Left |
| `prefix + j` | Down |
| `prefix + k` | Up |
| `prefix + l` | Right |

`C-l` is bound to clear screen and scrollback history.

`r` reloads the tmux config live (`source-file ~/.tmux.conf`).

### Plugins

- **tmux-sensible** — sane defaults
- **catppuccin/tmux** — primary status bar theme
- **rose-pine/tmux** — alternative rose-pine theme (currently active for styling)
- **vim-tmux-navigator** — seamless navigation between tmux panes and Neovim splits
- **kube-tmux** — shows current Kubernetes context and namespace in the status bar
- **tmux-fingers** — hints mode for quickly copying text from the terminal

### Status Bar

```
status-left  = "" (empty)
status-right = application name | session name
```

The rose-pine theme is configured with:
- Directory shown in status (`@rose_pine_directory on`)
- Current program shown as window name
- Current pane directory shown as window name
- Transparent background (`@rose_pine_bar_bg_disable on`)
- Kubernetes context prepended to the right side via kube-tmux
- Separators: ` ➔ ` between fields

### Session Init Script (`tmux_init.sh`)

A helper script that bootstraps a standard tmux session:

```
Session: "|"
  Window 0: "w"  → zsh
  Window 1: "c"  → zsh
```

Run it to get a consistent starting workspace.

---

## Ghostty

Config at `ghostty/.config/ghostty/config`.

[Ghostty](https://ghostty.org) is a fast, native terminal emulator.

| Setting | Value |
|---|---|
| Font size | 12 |
| Background opacity | 0.9 (slight transparency) |
| Theme | Catppuccin Macchiato |
| Title bar style | Transparent (macOS) |
| Title bar proxy icon | Hidden |
| macOS icon | Blueprint |
| Window height | 60 rows |
| Window width | 143 columns |

The slight transparency (`0.9`) pairs well with the tokyonight transparent background in Neovim — the terminal background bleeds through, giving a layered look.

---

## Zsh (`.zshrc`)

Shell is Zsh with [Oh My Zsh](https://ohmyzsh.sh) and the [Spaceship](https://spaceship-prompt.sh/) prompt theme.

### Prompt (Spaceship)

The prompt order is trimmed down to only what's relevant:

```
time → user → host → dir → git → node → ruby → xcode → swift → golang → docker → venv → newline → char
```

Key customizations:
- Always show username (`SPACESHIP_USER_SHOW=always`)
- No extra newline before prompt
- Prompt character: `❯ ` (same for success and failure)

### Plugins

| Plugin | Purpose |
|---|---|
| `git` | Git aliases and prompt info |
| `zsh-autosuggestions` | Fish-style command suggestions from history |
| `zsh-syntax-highlighting` | Real-time syntax coloring in the prompt |

### History

```sh
HISTSIZE=99999
SAVEHIST=99999
```

With `appendhistory`, `share_history`, dedup options enabled — history is effectively unlimited and shared across sessions.

### Aliases

#### Kubernetes

| Alias | Command |
|---|---|
| `k` | `kubectl` |
| `kns` | `kubens` |
| `ktx` | `kubectx` |
| `kgps` | `kubectl get pods` |
| `kgp` | `kubectl get pod` |
| `kdes` | `kubectl describe` |
| `kdel` | `kubectl delete` |
| `kaf` | `kubectl apply -f` |
| `klog` | `kubectl logs` |

#### Git

| Alias | Command |
|---|---|
| `gl` | `git log` |
| `gc` | `git checkout` |
| `gb` | `git branch` |
| `gp` | `git pull` |
| `gs` | `git status` |
| `gps` | `git push` |
| `gcb` | Interactive branch switch via `fzf` |
| `gsl` | `git stash list` |
| `gsa0` | `git stash apply stash@{0}` |
| `gss` | `git stash save` |

#### Modern CLI Replacements

These only activate if the tool is installed:

| Alias | Replaces | Tool |
|---|---|---|
| `ls` | `ls` | `eza` |
| `ll` | `ls -lhg` | `eza -lhg` |
| `lla` | `ls -alhg` | `eza -alhg` |
| `tree` | `tree` | `eza --tree` |
| `cat` | `cat` | `bat --paging=never --style=plain` |
| `catt` | — | `bat` (with full features) |
| `cata` | — | `bat --show-all` |

#### Other

| Alias | Purpose |
|---|---|
| `v` | Open neovim |
| `lsg` | `cd ~/workspace` |
| `shutdown` | Terminate the WSL distro |
| `reboot` | Restart WSL |

### Environment

- `EDITOR=nvim`
- Homebrew on Linux: `/home/linuxbrew/.linuxbrew/bin` added to `PATH`
- WSL distro name set to `Ubuntu` for shutdown/reboot aliases
- `unsetopt beep` — no terminal bell