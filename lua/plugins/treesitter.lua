-- nvim-treesitter (main branch) compiles parsers locally, which needs the
-- `tree-sitter` CLI and a C compiler. Without them, parsers aren't installed
-- and buffers fall back to regex highlighting. Run :checkhealth config to see what's missing.
return {
  'nvim-treesitter/nvim-treesitter',
  config = function()
    local platform = require 'util.os'
    local filetypes = {
      'bash',
      'c',
      'diff',
      'go',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'vim',
      'vimdoc',
    }

    if platform.has 'tree-sitter' and platform.first(platform.c_compilers) then
      require('nvim-treesitter').install(filetypes)
    else
      vim.notify('Treesitter parsers not installed: needs the tree-sitter CLI and a C compiler (see :checkhealth config)', vim.log.levels.WARN)
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('config-treesitter', { clear = true }),
      pattern = filetypes,
      -- pcall: the parser may not be installed yet
      callback = function() pcall(vim.treesitter.start) end,
    })
  end,
}
