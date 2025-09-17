vim.keymap.set('n', '<leader>di', function()
  require('dap').step_into()
end, { desc = 'Debug: Step Into' })

vim.keymap.set('n', '<leader>do', function()
  require('dap').step_over()
end, { desc = 'Debug: Step Over' })

vim.keymap.set('n', '<leader>dO', function()
  require('dap').step_out()
end, { desc = 'Debug: Step Out' })

vim.keymap.set('n', '<leader>dc', function()
  require('dap').continue()
end, { desc = 'Debug: [C]ontinue / Start' })

vim.keymap.set('n', '<leader>dC', function()
  require('dap').run_to_cursor()
end, { desc = '[D]ebug: Run to [C]ursor' })

vim.keymap.set('n', '<leader>ds', function()
  require('dap').close()
end, { desc = '[D]ebug: [S]top' })

vim.keymap.set('n', '<leader>dp', function()
  require('dap').step_back()
end, { desc = '[D]ebug: Step Back (into [Past])' })

vim.keymap.set('n', '<leader>db', function()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })

vim.keymap.set('n', '<leader>dB', function()
  require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Breakpoint' })

vim.keymap.set('n', '<leader>dt', function()
  require('dapui').toggle()
end, { desc = 'Debug: See last session result.' })

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    -- 'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('nvim-dap-virtual-text').setup()

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'netcoredbg',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
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

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- C#

    dap.adapters.coreclr = {
      type = 'executable',
      command = 'netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.adapters.netcoredbg = {
      type = 'executable',
      -- command = vim.fn.exepath 'netcoredbg',
      command = 'netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Launch .NET 8 App',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to .dll: ', vim.fn.getcwd() .. '/bin/Debug/net8.0/', 'file')
        end,
        env = { ASPNETCORE_ENVIRONMENT = 'Development' },
        -- cwd = '${workspaceFolder}',
        cwd = function()
          return vim.fn.input('Workspace folder: ', vim.fn.getcwd() .. '/', 'file')
        end,
        -- Prevent $metadata$ path issues by mapping to /dev/null equivalent
        sourceFileMap = {
          ['C:\\$metadata$'] = '',
          ['/\\$metadata\\$'] = '',
        },
        -- Enable stepping into NuGet package source code
        justMyCode = true,  -- Temporarily disable to avoid $metadata$ issues
        suppressJITOptimizations = true,
        enableStepFiltering = true,  -- Enable to avoid problematic step-into
        requireExactSource = true,
        -- Symbol and source options for NuGet packages - DISABLED to prevent $metadata$ issues
        symbolOptions = {
          searchMicrosoftSymbolServer = false,
          searchNuGetOrgSymbolServer = false,
          searchPaths = {},
          moduleFilter = {
            mode = 'loadAllButExcluded',
            excludedModules = {},
          },
        },
        sourceLinkOptions = {
          ['*'] = { enabled = false },
        },
      },
    }
  end,
}
