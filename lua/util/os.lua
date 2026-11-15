-- OS detection and small helpers shared by the config
local M = {}

M.is_windows = vim.fn.has 'win32' == 1
M.is_mac = vim.fn.has 'macunix' == 1
M.is_linux = not M.is_windows and not M.is_mac

---@param exe string
---@return boolean
function M.has(exe) return vim.fn.executable(exe) == 1 end

---@param list string[]
---@return string|nil first executable found
function M.first(list)
  for _, exe in ipairs(list) do
    if M.has(exe) then return exe end
  end
end

--- Path inside Mason's install directory, e.g. mason_path('packages', 'debugpy')
---@return string
function M.mason_path(...) return vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', ...) end

--- Python executable inside a venv, which differs between Windows and Unix
---@param venv string
---@return string
function M.venv_python(venv)
  if M.is_windows then return vim.fs.joinpath(venv, 'Scripts', 'python.exe') end
  return vim.fs.joinpath(venv, 'bin', 'python')
end

M.c_compilers = { 'cc', 'gcc', 'clang', 'zig', 'cl' }

return M
