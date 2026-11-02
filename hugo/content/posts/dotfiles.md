---
date: '2026-06-07T00:13:11+08:00'
lastmod: '2026-11-02T00:00:00+08:00'
title: 'Dotfiles'
draft: false
showtoc: true
tocopen: false
tags: ['neovim', 'vim', 'dotfiles', 'setup', 'nix']
---



My dotfiles live in one Git repo and are applied with **Nix**: [nix-darwin](https://github.com/nix-darwin/nix-darwin) configures the Mac itself (packages, Homebrew, system defaults) and [Home Manager](https://github.com/nix-community/home-manager) wires the config files into `$HOME`. One command rebuilds the whole machine, so a new Mac goes from zero to my setup in a single step.

I used to manage this with GNU Stow. Stow only handled symlinks; Nix also handles the tools, the apps and the macOS settings, which used to be a manual checklist.

## Repo Layout

```
.dots/
├── flake.nix           # inputs + the "mac" darwin configuration
├── configuration.nix   # system: packages, brew, fonts, macOS defaults
├── home.nix            # user: zsh, starship, symlinks into $HOME
├── rebuild.sh          # apply everything
└── home/               # mirrors $HOME
    ├── .config/nvim/
    ├── .config/ghostty/
    ├── .config/mise/
    ├── .config/starship.toml
    ├── .claude/
    ├── .tmux.conf
    ├── AGENTS.md
    └── CODE.md
```

`home/` mirrors `$HOME`. A file at `home/.config/ghostty/config.ghostty` ends up at `~/.config/ghostty/config.ghostty`.

## Applying the Config

```sh
./rebuild.sh
```

Which runs:

```sh
sudo nix run nix-darwin -- switch --flake ~/lladn/.dots#mac
```

There is also a `rebuild` shell alias for it.

### Live Symlinks

Home Manager normally copies files into the Nix store, which means every config tweak needs a rebuild. To avoid that, `home.nix` uses `mkOutOfStoreSymlink`, which links `~/<path>` straight to the file in the repo:

```nix
home.file = lib.genAttrs [
  ".config/nvim"
  ".config/ghostty"
  ".config/mise"
  ".config/starship.toml"
  ".tmux.conf"
  "CODE.md"
  ".claude/settings.json"
  ".claude/CLAUDE.md"
  ".claude/commands"
] (path: { source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/${path}"; });
```

Edit a file in the repo and it applies right away. A rebuild is only needed when adding a new path.

### Adding a New Dotfile

1. Put it under `home/` at the same path it has under `$HOME`
2. Add that path to the `home.file` list in `home.nix`
3. Run `./rebuild.sh`

---

## System (`configuration.nix`)

### Packages

CLI tools come from nixpkgs instead of Homebrew:

`azure-cli`, `bat`, `dart-sass`, `eza`, `ffmpeg`, `hugo`, `neovim`, `pandoc`, `poppler-utils`, `ripgrep`, `rtk`, `starship`, `uv`

Home Manager adds a few more for the user: `fd`, `fzf`, `jq`, `lazygit`.

The font is **Hack Nerd Font**, also installed through Nix.

### Homebrew, Declaratively

GUI apps and anything not in nixpkgs stay on Homebrew, but managed by [nix-homebrew](https://github.com/zhaofengli/nix-homebrew). `onActivation.cleanup = "zap"` removes anything that is not listed, so the brew list in the repo is the source of truth.

| Type | Packages |
|---|---|
| Brews | `herdr`, `tmux-fingers` |
| Casks | `claude-code`, `ghostty`, `orbstack`, `better-resource-monitor` |

### macOS Defaults

| Area | Setting |
|---|---|
| Appearance | Dark mode |
| Keyboard | Fast key repeat (`KeyRepeat = 2`, `InitialKeyRepeat = 15`), press-and-hold accent popup disabled |
| Text | Auto spelling correction off |
| Dock | Autohide, tile size 48, no recent apps |
| Hot corners | Top right: Notification Center, others disabled |
| Finder | Column view, path bar shown, no desktop icons, all file extensions shown |
| Scroll bars | Only while scrolling |

---

## Runtimes (mise)

Language runtimes are managed with [mise](https://mise.jdx.dev) instead of Nix, since I switch versions per project:

| Tool | Version |
|---|---|
| `go` | latest |
| `node` | LTS |
| `terraform` | 1.13.3 |
| `rust` | latest |
| `tree-sitter-cli` | latest (cargo and npm) |

---

## Neovim

The Neovim config lives in `home/.config/nvim/` and is structured around [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. The namespace used is `lowelad`.

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
| `undofile` | true | Persistent undo across sessions |
| `scrolloff` | 16 | Keeps the cursor away from the screen edge |
| `shortmess` | `+I` | Hides the intro message |

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
| `<leader>e` | Toggle file tree (nvim-tree) |
| `<leader>w` / `<leader>W` | Save current file / save all |
| `<leader>q` / `<leader>Q` | Close current buffer / quit all |
| `<leader>p` | Paste without overwriting register |
| `<leader>/` | Toggle comment (current line) |
| `<leader>s` | Search & replace word under cursor |
| `<leader>t` | Open today's note |
| `<leader>mp` | Toggle markdown render |
| `J` | Join lines, keep cursor position |
| `<C-d>` / `<C-u>` | Half-page scroll, cursor stays centered |
| `n` / `N` | Next/prev search result, centered |

#### Telescope Keymaps

| Key | Action |
|---|---|
| `<leader>ff` | Find files (includes hidden files) |
| `<leader>fg` | Find git-tracked files |
| `<leader>fl` | Live grep |
| `;` | Browse open buffers |

Inside the picker, `<C-j>` / `<C-k>` move the selection. Both find and grep use `ripgrep` with `--hidden`, ignoring `.git/`.

#### Git Keymaps

| Key | Action |
|---|---|
| `<leader>gd` | Diff current file |
| `<leader>gp` | Preview hunk |

#### Visual Mode

| Key | Action |
|---|---|
| `J` / `K` | Move selection down / up |
| `<leader>/` | Toggle comment on selection |

### Plugins

#### UI & Appearance
- **tokyonight.nvim** - colorscheme in `storm` style with transparent background, sidebars and floats
- **lualine.nvim** - statusline themed with tokyonight
- **bufferline.nvim** - tab-style buffer navigation at the top
- **indent-blankline.nvim** - visual indent guides
- **nvim-colorizer.lua** - highlights color codes (`#rrggbb`) inline
- **smear-cursor.nvim** - animated cursor smear effect (color `#d3cdc3`)
- **alpha-nvim** - startup dashboard with a fortune/cowsay header if available, otherwise a fallback ASCII quote; shows day of week in footer
- **render-markdown.nvim** - renders Markdown in the buffer (headings, tables, code blocks)

#### Navigation & Search
- **nvim-tree.lua** - file tree sidebar; shows dotfiles and git-ignored files, follows the current file and cwd
- **telescope.nvim** - fuzzy finder for files, buffers, grep
- **vim-illuminate** - highlights other occurrences of the word under cursor

#### LSP & Completion
- **nvim-lspconfig** + **mason.nvim** + **mason-lspconfig.nvim** - LSP setup with auto-install for:
  - `ts_ls` (TypeScript/JavaScript)
  - `lua_ls` (Lua, configured for Neovim's LuaJIT runtime)
  - `ruff` (Python linter/formatter)
- **nvim-cmp** - completion engine with sources: LSP, buffer, path, luasnip
- **LuaSnip** - snippet engine with VSCode-compatible snippet support
- **fidget.nvim** - LSP progress indicator in the bottom-right corner
- **conform.nvim** - format-on-save; `prettierd` for Markdown, `terraform_fmt` for Terraform, LSP formatting as fallback

#### Code Quality
- **nvim-treesitter** (`main` branch) - syntax highlighting and indentation for: C, Lua, Vim, Vimdoc, Elixir, JavaScript, TypeScript, HTML, Python, Go, Markdown
- **Comment.nvim** - easy comment toggling
- **nvim-autopairs** - auto-closes brackets, quotes, etc.; integrated with nvim-cmp

#### Git
- **gitsigns.nvim** - git diff signs in the gutter, plus file diff and hunk preview

#### Other
- **which-key.nvim** - keybinding popup with 300ms timeout; configured to suppress most preset hints, keeping only what's explicitly registered
- **symbols-outline.nvim** - sidebar showing document symbols (functions, classes, etc.)
- **today.nvim** - opens a daily journal note; notes stored in `~/workspace/notes` using the `templates/jrnl.md` template

---

## Ghostty

Config at `home/.config/ghostty/config.ghostty`.

[Ghostty](https://ghostty.org) is a fast, native terminal emulator.

| Setting | Value |
|---|---|
| Font | Hack Nerd Font, size 12 |
| Cell height | +15% |
| Background opacity | 0.9 with blur |
| Theme | Catppuccin Mocha |
| Title bar style | Transparent (macOS) |
| Title bar proxy icon | Hidden |
| Window buttons | Hidden |
| macOS icon | Blueprint |
| Window size | 224 columns x 62 rows |
| Padding | Balanced |
| Copy on select | System clipboard |

The slight transparency (`0.9`) pairs well with the tokyonight transparent background in Neovim. The terminal background bleeds through, giving a layered look.

---

## Zsh

Zsh is configured entirely in `home.nix` through Home Manager's `programs.zsh`. Oh My Zsh is gone; autosuggestions and syntax highlighting are built-in Home Manager options.

### Prompt (Starship)

The prompt is [Starship](https://starship.rs), enabled with `programs.starship.enable` and configured in `home/.config/starship.toml`:

- Username always shown in bold blue, hostname always shown in bold green (not only over SSH)
- Language modules trimmed to just the symbol (`via 🐹` instead of `via 🐹 v1.23.0`), so the prompt stays short

### Shell Behavior

| Setting | Purpose |
|---|---|
| `autosuggestion.enable` | Fish-style ghost text from history |
| `syntaxHighlighting.enable` | Commands turn green when valid |
| `defaultKeymap = "emacs"` | `^A` / `^E` for line start/end |
| `^F` | Accept the autosuggestion |
| `^X^E` | Edit the current command in `$EDITOR` |
| `hist_verify` | Show history expansions before running them |

`mise activate zsh` runs on startup so the mise runtimes are on `PATH`.

### History

```nix
history = {
  size = 99999;
  save = 99999;
  append = true;
  expireDuplicatesFirst = true;
  ignoreDups = true;
  share = true;
};
```

History is effectively unlimited and shared across sessions.

### Aliases

#### Everyday

| Alias | Command |
|---|---|
| `..` | `cd ..` |
| `vv` | `nvim` |
| `lsg` | `cd ~/workspace` |
| `rebuild` | `~/lladn/.dots/rebuild.sh` |
| `cc` | `claude` |
| `co` | `codex --full-auto` |
| `nm` | `no-mistakes` |

#### Git

| Alias | Command |
|---|---|
| `add` | `git add .` |
| `push` / `gps` | `git push` |
| `pull` / `gp` | `git pull` |
| `m` | `git switch main` |
| `gl` | `git log` |
| `gc` | `git checkout` |
| `gb` | `git branch` |
| `gs` | `git status` |
| `gcb` | Interactive branch switch via `fzf` |
| `gsl` | `git stash list` |
| `gsa0` | `git stash apply stash@{0}` |
| `gss` | `git stash save` |

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

#### AWS

Shortcuts that pin a profile and region, e.g. `aws-prod-euw2` runs `aws --profile prod --region eu-west-2`. There are variants for `prod` and `dev` across `eu-west-1`, `eu-west-2` and `us-east-1`.

#### Modern CLI Replacements

`eza` and `bat` are installed by Nix, so these are always available:

| Alias | Replaces | Tool |
|---|---|---|
| `ls` | `ls` | `eza` |
| `ll` | `ls -lhg` | `eza -lhg` |
| `lla` | `ls -alhg` | `eza -alhg` |
| `tree` | `tree` | `eza --tree` |
| `cat` | `cat` | `bat --paging=never --style=plain` |
| `catt` | - | `bat` (with full features) |
| `cata` | - | `bat --show-all --paging=never` |

### Environment

- `EDITOR` and `VISUAL` set to `nvim`
- `~/.local/bin` added to `PATH`

---

## Claude Code

My [Claude Code](https://claude.com/claude-code) setup is versioned in the same repo, so agent behavior is the same on every machine.

| File | Purpose |
|---|---|
| `home/AGENTS.md` | Agent-agnostic rules, linked to `~/.claude/AGENTS.md` |
| `home/.claude/CLAUDE.md` | Just a pointer that imports `AGENTS.md` |
| `home/CODE.md` | Coding guidelines, imported from `AGENTS.md` |
| `home/.claude/settings.json` | Permissions, hooks, plugins |
| `home/.claude/commands/` | Custom slash commands: `/hotfix`, `/pr-review` |

Keeping the rules in `AGENTS.md` instead of `CLAUDE.md` means other agents that read `AGENTS.md` pick up the same instructions.

The settings allow read-only commands (`ls`, `grep`, `jq`, `terraform plan`, read-only `aws describe-*` / `list-*` / `get-*`) and deny anything destructive (force push, `git reset --hard`, `terraform apply`, AWS writes and secret reads).

---

## tmux (Retired)

`home/.tmux.conf` is still in the repo but no longer maintained. I've moved to `herdr`, installed through Homebrew. The last tmux config used:

- Prefix `C-s`, mouse on, emacs keys in copy and status mode
- vim-style pane navigation (`prefix + h/j/k/l`)
- Windows numbered from 1 and renumbered on close
- Plugins: tmux-sensible, vim-tmux-navigator, catppuccin (mocha), tmux-fingers
