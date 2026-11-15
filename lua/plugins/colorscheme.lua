-- Kanagawa is the active theme. The others are installed but only load
-- when selected (e.g. :colorscheme tokyonight or :Telescope colorscheme).
return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000, -- load before other start plugins
    config = function() vim.cmd.colorscheme 'kanagawa-wave' end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = true,
    opts = {
      styles = {
        comments = { italic = false },
      },
    },
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = true,
  },
}
