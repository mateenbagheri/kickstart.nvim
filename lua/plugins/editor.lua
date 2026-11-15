return {
  { 'NMAC427/guess-indent.nvim', opts = {} },

  { 'tpope/vim-dotenv' },

  { -- Shows pending keybinds
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  { -- Indentation guides, including on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  {
    'nvim-mini/mini.nvim',
    config = function()
      -- Around/inside textobjects, e.g. va) yinq ci'
      require('mini.ai').setup { n_lines = 500 }

      -- Surround: saiw) sd' sr)'
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },
}
