vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

return {
  'ggandor/leap.nvim',
  opts = {
    -- Skip the middle of alphabetic words:
    -- --   foobar[quux]
    -- --   ^----^^^--^^
    preview_filter = function(ch0, ch1, ch2)
      return not (ch1:match '%s' or ch0:match '%a' and ch1:match '%a' and ch2:match '%a')
    end,

    equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' },
  },

  config = function(_, opts)
    -- require('leap.user').set_repeat_keys('<enter>', '<backspace>')
  end,

  -- Optional dependencies
  dependencies = {},
  lazy = false,
}
