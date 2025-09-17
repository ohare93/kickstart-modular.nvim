return {
  'folke/persistence.nvim',
  lazy = false, -- load immediately to ensure VimEnter works
  opts = {
    dir = vim.fn.stdpath 'state' .. '/sessions/', -- directory where session files are saved
    need = 1, -- minimum number of file buffers that need to be open to save
    branch = true, -- use git branch to save session
  },
  keys = {
    {
      '<leader>qs',
      function()
        require('persistence').save()
      end,
      desc = 'Save session',
    },
    {
      '<leader>qS',
      function()
        require('persistence').select()
      end,
      desc = 'Select session',
    },
    {
      '<leader>ql',
      function()
        require('persistence').load()
      end,
      desc = 'Load session for current directory',
    },
    {
      '<leader>qL',
      function()
        require('persistence').load { last = true }
      end,
      desc = 'Load last session',
    },
    {
      '<leader>qd',
      function()
        require('persistence').stop()
      end,
      desc = 'Stop persistence (don\'t save on exit)',
    },
  },
  config = function(_, opts)
    require('persistence').setup(opts)

    -- Directories where sessions should not be saved or restored
    local home = vim.fn.expand '~'
    local disabled_dirs = {
      home,
      home .. '/Downloads',
      home .. '/Desktop',
      '/',
      '/tmp',
    }

    local group = vim.api.nvim_create_augroup('Persistence', { clear = true })

    -- Autosave session on exit
    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = group,
      callback = function()
        local cwd = vim.fn.getcwd()
        for _, path in pairs(disabled_dirs) do
          if path == cwd then
            return -- Don't save in disabled directories
          end
        end
        require('persistence').save()
      end,
    })

    -- Auto-restore session when entering vim without arguments
    vim.api.nvim_create_autocmd('VimEnter', {
      group = group,
      callback = function()
        local cwd = vim.fn.getcwd()
        
        -- Skip disabled directories
        for _, path in pairs(disabled_dirs) do
          if path == cwd then
            require('persistence').stop()
            return
          end
        end

        -- Only load if nvim was started without arguments and not with stdin
        if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
          require('persistence').load()
        else
          require('persistence').stop()
        end
      end,
      nested = true,
    })
  end,
}