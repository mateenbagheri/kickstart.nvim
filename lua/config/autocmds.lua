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
  callback = function(args)
    local client = vim.lsp.get_clients({ bufnr = args.buf, name = 'gopls' })[1]
    if not client then return end

    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = {
      only = { 'source.organizeImports' },
      diagnostics = {},
    }

    -- Synchronous so the edits land before the buffer is written
    local res = client:request_sync('textDocument/codeAction', params, 1000, args.buf)
    for _, action in ipairs(res and res.result or {}) do
      if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding) end
      if type(action.command) == 'table' then
        client:exec_cmd(action.command, { bufnr = args.buf })
      elseif type(action.command) == 'string' then
        client:exec_cmd(action --[[@as lsp.Command]], { bufnr = args.buf })
      end
    end
  end,
})
