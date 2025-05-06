-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have coliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Navigation

vim.keymap.set('n', '<leader>k', ':e#<cr>', { desc = 'Swap to last open buffer' })

-- Text Manipulation

vim.keymap.set('n', 'x', '"_x', { desc = 'Cut without adding to any registry' })
vim.keymap.set('v', 'x', '"_x', { desc = 'Cut without adding to any registry' })

vim.keymap.set('n', 'X', '"_d', { desc = 'Delete without adding to any registry' })
vim.keymap.set('v', 'X', '"_d', { desc = 'Delete without adding to any registry' })

vim.keymap.set('n', 'XX', '"_dd', { desc = 'Delete whole line without adding to any registry' })

vim.keymap.set('n', 'c', '"cc', { desc = 'Change without adding to any registry' })

-- Meta

vim.keymap.set('n', '<leader>vv', ':source $MYVIMRC<cr>', { desc = 'Reload vimrc' })

-- nmap <leader>a ggVG"+y
--

-- nnoremap Q :q<CR>
-- " Open the vimrc file anytime
-- nnoremap <LEADER>rc :e $HOME/.config/nvim/init.vim<CR>
-- nnoremap <LEADER>rv :e .nvimrc<CR>
-- nnoremap <LEADER>sv :source $MYVIMRC<CR>
--
-- augroup NVIMRC
--     autocmd!
--     autocmd BufWritePost *.nvimrc exec ":so %"
-- augroup END
-- " Copy to system clipboard
-- vnoremap Y "+y
-- " Search
-- noremap <LEADER><CR> :nohlsearch<CR>
-- " Adjacent duplicate words
-- noremap <LEADER>dw /\(\<\w\+\>\)\_s*\1
-- " Space to Tab
-- nnoremap <LEADER>tt :%s/    /\t/g
-- vnoremap <LEADER>tt :s/    /\t/g
--
-- nnoremap <LEADER>gm :cprev<CR>zvzz
-- nnoremap <LEADER>gk :cnext<CR>zvzz
--
-- nnoremap n nzz
-- nnoremap N Nzz
--
--
-- " Switch to alternate file
-- noremap <LEADER>w <C-^>
--
--
--
-- " ==================== Insert Mode Cursor Movement ====================
-- inoremap <C-a> <ESC>A
--
--
-- " ==================== Command Mode Cursor Movement ====================
-- cnoremap <C-a> <Home>
-- cnoremap <C-e> <End>
-- cnoremap <C-p> <Up>
-- cnoremap <C-n> <Down>
-- cnoremap <C-b> <Left>
-- cnoremap <C-f> <Right>
-- cnoremap <M-b> <S-Left>
-- cnoremap <M-w> <S-Right>
--
--
-- " ==================== Window management ====================
-- " Use <space> + new arrow keys for moving the cursor around windows
-- noremap <LEADER>w <C-w>w
-- noremap <LEADER>k <C-w>k
-- noremap <LEADER>j <C-w>j
-- noremap <LEADER>h <C-w>h
-- noremap <LEADER>l <C-w>l
-- noremap qf <C-w>o
-- " Disable the default s key
-- noremap s <nop>
-- " split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
-- noremap sk :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
-- noremap sj :set splitbelow<CR>:split<CR>
-- noremap sh :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
-- noremap sl :set splitright<CR>:vsplit<CR>
-- " Resize splits with arrow keys
-- " noremap <C-up> :res +5<CR>
-- " noremap <C-down> :res -5<CR>
-- " noremap <C-left> :vertical resize-5<CR>
-- " noremap <C-right> :vertical resize+5<CR>
-- " Place the two screens up and down
-- noremap sh <C-w>t<C-w>K
-- " Place the two screens side by side
-- noremap sv <C-w>t<C-w>H
-- " Rotate screens
-- noremap srh <C-w>b<C-w>K
-- noremap srv <C-w>b<C-w>H
-- " Press <SPACE> + q to close the window below the current window
-- noremap <LEADER>q <C-w>j:q<CR>
--
--
-- " ==================== Tab management ====================
-- " Create a new tab with tu
-- noremap tk :tabe<CR>
-- noremap tK :tab split<CR>
-- " Move around tabs with tn and ti
-- noremap th :-tabnext<CR>
-- noremap tl :+tabnext<CR>
-- " Move the tabs with tmn and tmi
-- nnoremap Q :q<CR>
-- noremap tml :+tabmove<CR>
--
--
--
-- " TODOS:
-- "
-- " 1. Ctrl G is lazy git. Remap and test
-- " 2. CTRLP plugin is for C#? Find out why
-- " 3.Ctrl F is Rg? What do
-- " 4. Tab for >>?
-- "
--

-- vim: ts=2 sts=2 sw=2 et
