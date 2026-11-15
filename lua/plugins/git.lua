return {
  { -- Git signs in the gutter
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gd', ':Gdiff<CR>', { desc = 'Git diff' })
      vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Git status' })
    end,
  },
}
