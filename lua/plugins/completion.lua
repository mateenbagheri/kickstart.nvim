return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = '2.*',
      -- jsregexp (regex snippet transforms) needs `make`; skipped on Windows where the build usually fails
      build = (function()
        local platform = require 'util.os'
        if platform.is_windows or not platform.has 'make' then return end
        return 'make install_jsregexp'
      end)(),
      opts = {},
    },
  },
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    -- 'default': <c-y> accepts, <c-space> opens menu/docs, <c-n>/<c-p> select, <c-e> hides, <c-k> signature
    keymap = { preset = 'default' },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'lua' },
    signature = { enabled = true },
  },
}
