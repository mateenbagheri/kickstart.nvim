local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name) return vim.api.nvim_create_augroup('config-' .. name, { clear = true }) end

autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = augroup 'highlight-yank',
  callback = function() vim.hl.on_yank() end,
})

autocmd({ 'FocusLost', 'BufLeave' }, {
  desc = 'Autosave all buffers',
  group = augroup 'autosave',
  command = 'silent! wall',
})

autocmd('BufWritePre', {
  desc = 'Organize Go imports on save',
  group = augroup 'go-organize-imports',
  pattern = '*.go',
  callback = function()
    local params = vim.lsp.util.make_range_params(0, 'utf-8')
    params.context = {
      only = { 'source.organizeImports' },
      diagnostics = {},
    }

    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 1000)

    for _, res in pairs(result or {}) do
      for _, action in pairs(res.result or {}) do
        if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8') end
        if action.command then vim.lsp.buf.execute_command(action.command) end
      end
    end
  end,
})
