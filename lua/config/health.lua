-- Health check for this config. Run with :checkhealth config
local platform = require 'util.os'
local health = vim.health

-- Install hints per tool: { windows = 'winget ...', mac = 'brew ...' }
local hints = {
  git = { windows = 'winget install Git.Git', mac = 'xcode-select --install' },
  rg = { windows = 'winget install BurntSushi.ripgrep.MSVC', mac = 'brew install ripgrep' },
  fd = { windows = 'winget install sharkdp.fd', mac = 'brew install fd' },
  unzip = { windows = 'included with Git for Windows', mac = 'preinstalled' },
  make = { windows = 'winget install ezwinports.make', mac = 'xcode-select --install' },
  cmake = { windows = 'winget install Kitware.CMake', mac = 'brew install cmake' },
  ['tree-sitter'] = { windows = 'npm install -g tree-sitter-cli', mac = 'npm install -g tree-sitter-cli' },
  cc = { windows = 'winget install zig.zig', mac = 'xcode-select --install' },
  node = { windows = 'winget install OpenJS.NodeJS.LTS', mac = 'brew install node' },
  go = { windows = 'winget install GoLang.Go', mac = 'brew install go' },
  python = { windows = 'winget install Python.Python.3.13', mac = 'brew install python' },
}

local function hint(name)
  local h = hints[name]
  if not h then return nil end
  return platform.is_windows and h.windows or h.mac
end

---@param name string label shown in the report
---@param exes string[] any of these satisfies the check
---@param level 'error'|'warn'
---@param why string
local function check_tool(name, exes, level, why)
  local found = platform.first(exes)
  if found then
    health.ok(('%s: found `%s`'):format(name, found))
  else
    local msg = ('%s: not found (%s)'):format(name, why)
    local advice = hint(name)
    health[level](msg, advice and { 'Install: ' .. advice } or nil)
  end
end

return {
  check = function()
    health.start 'config: system'
    local uname = vim.uv.os_uname()
    health.info(('OS: %s %s'):format(uname.sysname, uname.release))

    local ver = tostring(vim.version())
    if vim.version.ge(vim.version(), '0.11') then
      health.ok('Neovim ' .. ver)
    else
      health.error('Neovim ' .. ver .. ' is too old; 0.11+ is required')
    end

    if vim.g.have_nerd_font then health.info 'vim.g.have_nerd_font = true: make sure your terminal uses a Nerd Font' end

    health.start 'config: required tools'
    check_tool('git', { 'git' }, 'error', 'needed to install plugins')
    check_tool('rg', { 'rg' }, 'warn', 'needed for Telescope live grep')
    if not platform.is_windows then check_tool('unzip', { 'unzip' }, 'warn', 'Mason uses it to unpack tools') end
    check_tool('tree-sitter', { 'tree-sitter' }, 'warn', 'needed to compile treesitter parsers')
    check_tool('cc', platform.c_compilers, 'warn', 'a C compiler is needed to compile treesitter parsers')

    health.start 'config: optional tools'
    check_tool('fd', { 'fd', 'fdfind' }, 'warn', 'faster file search in Telescope')
    if platform.is_windows then
      if platform.has 'make' then
        check_tool('make', { 'make' }, 'warn', 'builds telescope-fzf-native')
      else
        check_tool('cmake', { 'cmake' }, 'warn', 'builds telescope-fzf-native; without it the slower Lua sorter is used')
      end
    else
      check_tool('make', { 'make' }, 'warn', 'builds telescope-fzf-native and LuaSnip jsregexp')
    end

    health.start 'config: language toolchains'
    check_tool('node', { 'node' }, 'warn', 'needed by pyright and markdownlint')
    check_tool('go', { 'go' }, 'warn', 'needed by gopls, delve and the Go tools Mason installs')
    check_tool('python', { 'python3', 'python' }, 'warn', 'needed by debugpy, black and isort')

    local debugpy = platform.venv_python(platform.mason_path('packages', 'debugpy', 'venv'))
    if platform.has(debugpy) then
      health.ok('debugpy: ' .. debugpy)
    else
      health.warn('debugpy not installed by Mason yet; Python debugging will use the python on PATH', { 'Run :MasonInstall debugpy' })
    end
  end,
}
