return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
    { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
    { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
    { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
    { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
    { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Set Breakpoint' },
    -- Reopen the UI to see the last session's output (e.g. after an unhandled exception)
    { '<F7>', function() require('dapui').toggle() end, desc = 'Debug: See last session result.' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    local platform = require 'util.os'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {
        -- Default handler sets up every installed adapter...
        function(config) require('mason-nvim-dap').default_setup(config) end,
        -- ...except Python, which dap-python configures below
        python = function() end,
      },
      ensure_installed = {
        'delve',
        'python', -- debugpy
      },
    }

    -- Plain unicode icons so the UI works without a Nerd Font
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    require('dap-go').setup {
      delve = {
        -- Delve can't run detached on Windows
        detached = not platform.is_windows,
      },
      dap_configurations = {
        {
          type = 'go',
          name = 'Debug file',
          request = 'launch',
          program = '${file}',
        },
        {
          type = 'go',
          name = 'Debug package (current dir)',
          request = 'launch',
          program = '${fileDirname}',
        },
        {
          type = 'go',
          name = 'Debug module root (fix cmd/ cases)',
          request = 'launch',
          program = '${workspaceFolder}',
        },
      },
    }

    -- Python: use Mason's debugpy venv (Scripts\python.exe on Windows, bin/python elsewhere),
    -- falling back to whatever python is on PATH
    local debugpy_python = platform.venv_python(platform.mason_path('packages', 'debugpy', 'venv'))
    if not platform.has(debugpy_python) then debugpy_python = platform.first { 'python3', 'python' } or 'python' end
    require('dap-python').setup(debugpy_python)
  end,
}
