vim.keymap.set('n', '<leader>trt', function()
  require('neotest').run.run()
end, { desc = '[T]est [R]un nearest [T]est' })

vim.keymap.set('n', '<leader>trf', function()
  require('neotest').run.run(vim.fn.expand '%')
end, { desc = '[T]est [R]un current [F]ile' })

vim.keymap.set('n', '<leader>tra', function()
  require('neotest').run.run { vim.fn.getcwd() }
end, { desc = '[T]est [R]un [A]ll (directory)' })

vim.keymap.set('n', '<leader>trl', function()
  require('neotest').run.run_last()
end, { desc = '[T]est [R]un [L]ast' })

-- OR: [T]est [R]un All tests (alternative strategy: run on solution/project; see adapter config)
-- Not universal; can also do e.g. with `%:p:h` and specific root if needed

vim.keymap.set('n', '<leader>tdt', function()
  require('neotest').run.run { strategy = 'dap' }
end, { desc = '[T]est [D]ebug neares[T]est' })
vim.keymap.set('n', '<leader>tdf', function()
  require('neotest').run.run { vim.fn.expand '%', strategy = 'dap' }
end, { desc = '[T]est [D]ebug current [F]ile' })

vim.keymap.set('n', '<leader>ts', function()
  require('neotest').run.stop()
end, { desc = '[T]est [S]top (running tests)' })

vim.keymap.set('n', '<leader>tta', function()
  require('neotest').run.attach()
end, { desc = '[T]est [T]hread [A]ttach (debug process)' })

vim.keymap.set('n', '<leader>to', function()
  require('neotest').output.open()
end, { desc = '[T]est [O]utput' })

vim.keymap.set('n', '<leader>ts', function()
  require('neotest').summary.toggle()
end, { desc = '[T]est [S]ummary Toggle' })

vim.keymap.set('n', '<leader>tfn', function()
  require('neotest').jump.next { status = 'failed' }
end, { desc = '[T]est [F]ailed [N]ext' })
vim.keymap.set('n', '<leader>tfp', function()
  require('neotest').jump.prev { status = 'failed' }
end, { desc = '[T]est [F]ailed [P]revious' })

vim.keymap.set('n', '<leader>tn', function()
  require('neotest').jump.next()
end, { desc = '[T]est [N]ext' })
vim.keymap.set('n', '<leader>tp', function()
  require('neotest').jump.prev()
end, { desc = '[T]est [P]revious' })

return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'Issafalcon/neotest-dotnet',
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-dotnet' {
            dap = {
              -- Extra arguments for nvim-dap configuration
              -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
              args = { justMyCode = false },
              -- Name of your dap adapter, default is 'netcoredbg'
              adapter_name = 'netcoredbg',
            },
            -- Custom test attributes for discovery
            custom_attributes = {
              xunit = { 'MyCustomFactAttribute' },
              nunit = { 'MyCustomTestAttribute' },
              mstest = { 'MyCustomTestMethodAttribute' },
            },
            -- Additional CLI arguments for all 'dotnet test' runs
            dotnet_additional_args = { '--verbosity detailed' },
            -- Project discovery root: "project" or "solution"
            discovery_root = 'project', -- or "solution"
          },
        },
        -- (Optional) Example: set log level for debugging
        log_level = 1,
        mappings = {
          next = '<leader>tn',
          prev = '<leader>tp',
          run = '<leader>tr',
          stop = '<leader>tx',
        },
      }
    end,
  },
}
