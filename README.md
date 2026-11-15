# Neovim config

My personal Neovim configuration, used every day on **Windows** and **macOS**.
It started life as a fork of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
and has since been reorganized into small modules, with the focus on Go and Python
development.

- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim), versions pinned in `lazy-lock.json`
- LSP via the built-in client + [Mason](https://github.com/mason-org/mason.nvim) (gopls, pyright, lua_ls)
- Completion: [blink.cmp](https://github.com/saghen/blink.cmp) + LuaSnip
- Formatting on save: [conform.nvim](https://github.com/stevearc/conform.nvim) (gofumpt, isort + black, stylua)
- Debugging: [nvim-dap](https://github.com/mfussenegger/nvim-dap) with Go (delve) and Python (debugpy)
- Fuzzy finding: [Telescope](https://github.com/nvim-telescope/telescope.nvim); file tree: [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim)
- Theme: [kanagawa](https://github.com/rebelot/kanagawa.nvim) (tokyonight and rose-pine are installed too)

## Requirements

Neovim **0.11 or newer** (0.12 recommended).

| Tool | Why | Windows (`winget install …`) | macOS |
| --- | --- | --- | --- |
| Neovim | — | `Neovim.Neovim` | `brew install neovim` |
| git | installs plugins | `Git.Git` | `xcode-select --install` |
| ripgrep | Telescope live grep | `BurntSushi.ripgrep.MSVC` | `brew install ripgrep` |
| C compiler | compiles treesitter parsers | `zig.zig` | `xcode-select --install` |
| tree-sitter CLI | compiles treesitter parsers | `npm install -g tree-sitter-cli` | `npm install -g tree-sitter-cli` |
| Node.js | pyright, markdownlint | `OpenJS.NodeJS.LTS` | `brew install node` |
| Go | gopls, delve, Go tools | `GoLang.Go` | `brew install go` |
| Python 3 | debugpy, black, isort | `Python.Python.3.13` | `brew install python` |
| fd *(optional)* | faster file search | `sharkdp.fd` | `brew install fd` |
| make / cmake *(optional)* | native fzf sorter for Telescope | `Kitware.CMake` | included with Xcode tools |
| Nerd Font *(optional)* | icons | download from [nerdfonts.com](https://www.nerdfonts.com/font-downloads) | `brew install --cask font-jetbrains-mono-nerd-font` |

Set your terminal to use the Nerd Font. If you don't want one, set
`vim.g.have_nerd_font = false` in [`lua/config/options.lua`](lua/config/options.lua).

Missing optional tools only disable the feature that needs them. `:checkhealth config`
lists everything that's missing along with the install command for your OS.

## Install

Back up any existing config first, then clone this repo into Neovim's config directory.

### Windows (PowerShell)

```powershell
# Back up an existing config (skip if you don't have one)
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak

git clone https://github.com/mateenbagheri/kickstart.nvim.git $env:LOCALAPPDATA\nvim
```

### macOS

```bash
# Back up an existing config (skip if you don't have one)
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

git clone https://github.com/mateenbagheri/kickstart.nvim.git ~/.config/nvim
```

### First launch

1. Run `nvim`. lazy.nvim installs itself and every plugin at the versions in `lazy-lock.json`.
2. Mason then installs the language servers, formatters and debuggers in the background.
   Watch progress with `:Mason`.
3. Restart Neovim and run `:checkhealth config` to see if anything is missing.

## Layout

```text
init.lua                 leader key, then loads lua/config/*
lua/
  config/
    options.lua          editor options and diagnostics
    keymaps.lua          general keymaps
    autocmds.lua         yank highlight, autosave, Go organize-imports
    lazy.lua             lazy.nvim bootstrap; imports every file in lua/plugins/
    health.lua           :checkhealth config
  util/
    os.lua               OS detection and path helpers (Windows vs macOS)
  plugins/               one file per area, each returns lazy.nvim specs
    colorscheme.lua  completion.lua  debug.lua  editor.lua  file-tree.lua
    formatting.lua   git.lua  linting.lua  lsp.lua  telescope.lua  treesitter.lua
ftplugin/
  go.lua                 Go buffer settings (real tabs, width 4)
```

## Customizing

- **Add a plugin:** create a new file in `lua/plugins/` that returns a lazy.nvim spec
  (or a list of specs). It's picked up automatically on the next start.
- **Add a language server:** add it to the `servers` table in
  [`lua/plugins/lsp.lua`](lua/plugins/lsp.lua). Mason installs it on the next start.
- **Add a formatter:** add it to `formatters_by_ft` in
  [`lua/plugins/formatting.lua`](lua/plugins/formatting.lua) and to the Mason
  `ensure_installed` list in `lsp.lua`.
- **Add a treesitter parser:** add the language to `filetypes` in
  [`lua/plugins/treesitter.lua`](lua/plugins/treesitter.lua).
- **OS-specific code:** use `require('util.os')` (`is_windows`, `is_mac`, `has(exe)`, …)
  instead of calling `vim.fn.has` directly.

## Keymaps

`<leader>` is `Space`. Press it and wait to see every mapping in which-key.

| Keys | Action |
| --- | --- |
| `<leader>sf` / `<leader>sg` / `<leader>sw` | find files / live grep / grep word under cursor |
| `<leader><leader>` / `<leader>s.` | open buffers / recent files |
| `<leader>sh` / `<leader>sk` / `<leader>sd` | help / keymaps / diagnostics |
| `<leader>sr` / `<leader>sn` | resume last search / search this config |
| `<leader>/` / `<leader>s/` | fuzzy search current buffer / grep open files |
| `\` | reveal the current file in neo-tree (press again to close) |
| `grd` / `grr` / `gri` / `grt` | go to definition / references / implementation / type |
| `grn` / `gra` / `grD` | rename / code action / declaration |
| `gO` / `gW` | document symbols / workspace symbols |
| `<leader>f` | format buffer |
| `<leader>th` | toggle inlay hints |
| `<leader>q` | diagnostics in the location list |
| `<leader>gs` / `<leader>gd` | git status / git diff (fugitive) |
| `<F5>` / `<F1>` / `<F2>` / `<F3>` | debug: start/continue, step into, step over, step out |
| `<leader>b` / `<leader>B` / `<F7>` | toggle breakpoint / conditional breakpoint / toggle debug UI |
| `<C-h/j/k/l>` | move between windows |
| `<Esc><Esc>` | leave terminal mode |

Completion uses blink.cmp's default preset: `<C-y>` accept, `<C-space>` open menu/docs,
`<C-n>`/`<C-p>` select, `<C-e>` close, `<C-k>` signature help.

## Behaviour worth knowing

- **Autosave:** all buffers are written when Neovim loses focus or you leave a buffer.
- **Format on save** for Go, Python and Lua (C/C++ excluded). Go files also get
  `organizeImports` from gopls on save.
- The OS clipboard is shared with Neovim (`unnamedplus`).

## Updating

```text
:Lazy update      update plugins, then commit the new lazy-lock.json
:Lazy restore     go back to the versions in lazy-lock.json (e.g. after pulling on another machine)
:MasonUpdate      update Mason's registry; :Mason to update tools
```

Commit `lazy-lock.json` after updating so both machines stay on the same plugin versions.

## Troubleshooting

- **Start with `:checkhealth config`**, then `:checkhealth` for everything else.
- **No syntax highlighting / treesitter warning at startup:** install the tree-sitter CLI
  and a C compiler (see the requirements table), restart, and run `:Lazy build nvim-treesitter`.
- **Telescope feels slow on Windows:** install `cmake` (and a C compiler), then run
  `:Lazy build telescope-fzf-native.nvim`.
- **Icons show as boxes:** your terminal isn't using a Nerd Font, or set `vim.g.have_nerd_font = false`.
- **Python debugging doesn't start:** check `:Mason` shows `debugpy` installed.
- **Line endings:** `.gitattributes` keeps every file LF on all OSes. If Git shows every
  line changed on Windows, run `git add --renormalize .`.

## Credits

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (MIT).
