return {
  'tummetott/unimpaired.nvim',
  event = 'VeryLazy',
  opts = {
    default_mappings = false,

    mappings = {
      -- -- Buffers
      -- bnext = {
      --   map = ']b',
      --   desc = 'Go to [count] next buffer (bnext)',
      --   dotrepeat = true,
      -- },
      -- bprevious = {
      --   map = '[b',
      --   desc = 'Go to [count] previous buffer (bprevious)',
      --   dotrepeat = true,
      -- },
      -- bfirst = {
      --   map = '[B',
      --   desc = 'Go to first buffer in list (bfirst)',
      --   dotrepeat = true,
      -- },
      -- blast = {
      --   map = ']B',
      --   desc = 'Go to last buffer in list (blast)',
      --   dotrepeat = true,
      -- },
      --
      -- -- Arguments
      -- next = {
      --   map = ']a',
      --   desc = 'Go to [count] next argument (next)',
      --   dotrepeat = true,
      -- },
      -- prev = {
      --   map = '[a',
      --   desc = 'Go to [count] previous argument (prev)',
      --   dotrepeat = true,
      -- },
      --
      -- -- Quickfix List
      -- cnext = {
      --   map = ']q',
      --   desc = 'Go to next quickfix item (cnext)',
      --   dotrepeat = true,
      -- },
      -- cprevious = {
      --   map = '[q',
      --   desc = 'Go to previous quickfix item (cprevious)',
      --   dotrepeat = true,
      -- },
      -- cfirst = {
      --   map = '[Q',
      --   desc = 'Go to first quickfix item (cfirst)',
      --   dotrepeat = true,
      -- },
      -- clast = {
      --   map = ']Q',
      --   desc = 'Go to last quickfix item (clast)',
      --   dotrepeat = true,
      -- },
      --
      -- -- Location List
      -- lnext = {
      --   map = ']l',
      --   desc = 'Go to next location list item (lnext)',
      --   dotrepeat = true,
      -- },
      -- lprevious = {
      --   map = '[l',
      --   desc = 'Go to previous location list item (lprevious)',
      --   dotrepeat = true,
      -- },
      -- lfirst = {
      --   map = '[L',
      --   desc = 'Go to first location list item (lfirst)',
      --   dotrepeat = true,
      -- },
      -- llast = {
      --   map = ']L',
      --   desc = 'Go to last location list item (llast)',
      --   dotrepeat = true,
      -- },
      --
      -- -- Linewise movements
      -- move_down = {
      --   map = ']e',
      --   desc = 'Move line down (move_down)',
      --   dotrepeat = false,
      -- },
      -- move_up = {
      --   map = '[e',
      --   desc = 'Move line up (move_up)',
      --   dotrepeat = false,
      -- },
      -- blank_above = {
      --   map = '[<Space>',
      --   desc = 'Insert a new line above',
      --   dotrepeat = false,
      -- },
      -- blank_below = {
      --   map = ']<Space>',
      --   desc = 'Insert a new line below',
      --   dotrepeat = false,
      -- },
      --
      -- -- Option toggling
      -- wrap = {
      --   map = 'yow',
      --   desc = 'Toggle wrap',
      --   dotrepeat = false,
      -- },
      -- list = {
      --   map = 'yol',
      --   desc = 'Toggle listchars option',
      --   dotrepeat = false,
      -- },
      -- number = {
      --   map = 'yon',
      --   desc = 'Toggle line numbers',
      --   dotrepeat = false,
      -- },
      -- relativenumber = {
      --   map = 'yor',
      --   desc = 'Toggle relative line numbers',
      --   dotrepeat = false,
      -- },
      -- spell = {
      --   map = 'yos',
      --   desc = 'Toggle spell checking',
      --   dotrepeat = false,
      -- },
      -- cursorline_column = {
      --   map = 'yoc',
      --   desc = 'Toggle cursorline and cursorcolumn',
      --   dotrepeat = false,
      -- },
      --
      -- File navigation
      file_next = {
        map = ']f',
        desc = 'Go to next file in directory',
        dotrepeat = true,
      },
      file_previous = {
        map = '[f',
        desc = 'Go to previous file in directory',
        dotrepeat = true,
      },
    },

    ignored_filetypes = {},
    custom_mappings = {},
    buffer_local = false,
    undo_breakpoints = false,

    options = {
      tracked = {},
      untracked = {},
      global = false,
    },
  },
}
