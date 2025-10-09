-- Generate lazy-lock.json from installed plugins
local lazy_dir = vim.fn.expand('~/.local/share/nvim/lazy')
local lockfile_path = '/home/jmo/Development/kickstart-modular.nvim/lazy-lock.json'

local plugins = {}

-- Read directory entries
local items = vim.fn.readdir(lazy_dir)

for _, name in ipairs(items) do
  local plugin_path = lazy_dir .. '/' .. name
  local git_dir = plugin_path .. '/.git'

  -- Check if it's a git repository
  if vim.fn.isdirectory(git_dir) == 1 then
    -- Get the current commit hash
    local cmd = string.format('cd %s && git rev-parse HEAD 2>/dev/null', vim.fn.shellescape(plugin_path))
    local commit = vim.fn.system(cmd):gsub('%s+$', '')

    if vim.v.shell_error == 0 and commit ~= '' then
      -- Get the branch name
      local branch_cmd = string.format('cd %s && git branch --show-current 2>/dev/null', vim.fn.shellescape(plugin_path))
      local branch = vim.fn.system(branch_cmd):gsub('%s+$', '')

      plugins[name] = {
        branch = (branch ~= '' and branch ~= 'HEAD') and branch or vim.NIL,
        commit = commit,
      }

      print('Locked: ' .. name .. ' @ ' .. commit:sub(1, 7))
    end
  end
end

-- Write lockfile in pretty format
local file = io.open(lockfile_path, 'w')
if file then
  file:write('{\n')

  local plugin_names = vim.tbl_keys(plugins)
  table.sort(plugin_names)

  for i, name in ipairs(plugin_names) do
    local plugin = plugins[name]
    file:write(string.format('  "%s": {', name))

    if plugin.branch ~= vim.NIL then
      file:write(string.format('\n    "branch": "%s",', plugin.branch))
    end

    file:write(string.format('\n    "commit": "%s"\n', plugin.commit))
    file:write('  }')

    if i < #plugin_names then
      file:write(',')
    end

    file:write('\n')
  end

  file:write('}\n')
  file:close()

  print('\nGenerated lockfile at: ' .. lockfile_path)
  print('Locked ' .. #plugin_names .. ' plugins')
else
  print('ERROR: Could not open ' .. lockfile_path .. ' for writing')
end
