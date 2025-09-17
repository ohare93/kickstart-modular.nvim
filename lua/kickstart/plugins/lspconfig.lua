-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', function()
            local params = vim.lsp.util.make_position_params(0, 'utf-8')
            -- vim.notify('Making LSP definition request for position: ' .. vim.inspect(params), vim.log.levels.INFO)

            -- First try the standard LSP definition request
            vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
              if err then
                vim.notify('Error in go-to-definition: ' .. tostring(err), vim.log.levels.ERROR)
                return
              end
              -- vim.notify('Result type: ' .. type(result) .. ', isEmpty: ' .. tostring(vim.tbl_isempty(result or {})), vim.log.levels.INFO)
              -- vim.notify('Result content: ' .. vim.inspect(result), vim.log.levels.INFO)

              -- Normalize result to always be an array
              local locations = {}
              if result then
                if type(result) == 'table' then
                  if result.uri then
                    -- Single location object
                    locations = { result }
                  else
                    -- Array of locations
                    locations = result
                  end
                end
              end

              local result_count = #locations
              -- vim.notify('Found ' .. result_count .. ' normalized locations', vim.log.levels.INFO)

              if result_count == 0 then
                -- vim.notify('Standard LSP definition returned no results, trying OmniSharp specific method...', vim.log.levels.INFO)

                -- Try OmniSharp's specific goto definition method
                vim.lsp.buf_request(0, 'o#/v2/gotodefinition', {
                  FileName = vim.api.nvim_buf_get_name(0),
                  Line = params.position.line,
                  Column = params.position.character,
                  WantMetadata = true
                }, function(omnisharp_err, omnisharp_result)
                  if omnisharp_err then
                    vim.notify('OmniSharp goto definition error: ' .. tostring(omnisharp_err), vim.log.levels.ERROR)
                    return
                  end

                  -- vim.notify('OmniSharp result: ' .. vim.inspect(omnisharp_result), vim.log.levels.INFO)

                  -- Check if OmniSharp returned metadata in the expected structure
                  local metadata_source = nil
                  if omnisharp_result and omnisharp_result.Definitions and #omnisharp_result.Definitions > 0 then
                    metadata_source = omnisharp_result.Definitions[1].MetadataSource
                  elseif omnisharp_result and omnisharp_result.MetadataSource then
                    metadata_source = omnisharp_result.MetadataSource
                  end

                  if metadata_source then
                    -- vim.notify('Found metadata source, creating decompiled buffer...', vim.log.levels.INFO)
                    -- Create decompiled buffer directly
                    local bufnr = vim.api.nvim_create_buf(false, true)
                    local buf_name = (metadata_source.TypeName or 'Unknown') .. ' [Decompiled]'

                    vim.api.nvim_buf_set_name(bufnr, buf_name)
                    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'cs')
                    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
                    vim.api.nvim_buf_set_option(bufnr, 'readonly', true)

                    -- Set the decompiled source content
                    local source_lines = vim.split(metadata_source.Source or '', '\n')
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, source_lines)

                    -- Switch to the buffer
                    vim.api.nvim_set_current_buf(bufnr)

                    -- Navigate to the definition line
                    local target_line = omnisharp_result.Line or 1
                    local target_col = omnisharp_result.Column or 0
                    local total_lines = vim.api.nvim_buf_line_count(bufnr)

                    if target_line > total_lines then
                      target_line = total_lines
                    end

                    vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                    -- vim.notify('Opened decompiled source: ' .. buf_name, vim.log.levels.INFO)
                    return
                  end

                  vim.notify('No definition found from any method', vim.log.levels.WARN)
                end)
                return
              end

              -- Check if any results are metadata files
              local metadata_location = nil
              local real_files = {}

              -- vim.notify('LSP returned ' .. result_count .. ' definition results', vim.log.levels.INFO)

              for _, location in ipairs(locations) do
                local uri = location.uri or ''
                -- vim.notify('Found URI: ' .. uri, vim.log.levels.INFO)
                -- Check for both URL-encoded and literal $metadata$ patterns
                if uri:match('%%24metadata%%24') or uri:match('%$metadata%$') then
                  -- vim.notify('Detected as metadata file: ' .. uri, vim.log.levels.INFO)
                  metadata_location = location
                else
                  -- vim.notify('Detected as real file: ' .. uri, vim.log.levels.INFO)
                  table.insert(real_files, location)
                end
              end

              -- vim.notify('Summary: ' .. #real_files .. ' real files, ' .. (metadata_location and '1' or '0') .. ' metadata files', vim.log.levels.INFO)

              -- Use real files if available
              if not vim.tbl_isempty(real_files) then
                require('telescope.builtin').lsp_definitions({ results = real_files })
                return
              end

              -- Handle metadata (decompiled) sources
              if metadata_location then
                local uri = metadata_location.uri
                local range = metadata_location.range

                -- URL decode the URI first
                local decoded_uri = uri:gsub('%%(%x%x)', function(hex)
                  return string.char(tonumber(hex, 16))
                end)
                -- vim.notify('Decoded URI: ' .. decoded_uri, vim.log.levels.INFO)

                -- Extract assembly and type information from decoded URI
                local assembly_match = decoded_uri:match('%$metadata%$[/\\]Project[/\\](.-)Assembly') or
                                      decoded_uri:match('%$metadata%$[/\\]Project[/\\](.-)%Assembly')
                local type_match = decoded_uri:match('Symbol[/\\](.-)%.cs$')

                if not assembly_match or not type_match then
                  vim.notify('Could not parse metadata URI: ' .. uri, vim.log.levels.WARN)
                  return
                end

                -- Format type name properly (replace path separators with dots)
                local type_name = type_match:gsub('[/\\]', '.')

                -- Try multiple OmniSharp methods to get decompiled source
                local function try_decompilation_methods()
                  -- vim.notify('Trying decompilation for: ' .. type_name .. ' from ' .. assembly_match, vim.log.levels.INFO)

                  -- Method 1: Try o#/v2/gotodefinition with the original file (not metadata URI)
                  -- We need to use the original cursor position from our current buffer
                  local current_pos = vim.api.nvim_win_get_cursor(0)
                  vim.lsp.buf_request(0, 'o#/v2/gotodefinition', {
                    FileName = vim.api.nvim_buf_get_name(0), -- Use original file, not metadata URI
                    Line = current_pos[1] - 1, -- Convert to 0-based
                    Column = current_pos[2], -- Already 0-based
                    WantMetadata = true
                  }, function(err1, result1)
                    -- vim.notify('Method 1 result: ' .. vim.inspect({err = err1, result = result1}), vim.log.levels.INFO)

                    -- Check the structure we know works: result.Definitions[1].MetadataSource
                    if result1 and result1.Definitions and #result1.Definitions > 0 then
                      local metadata_source = result1.Definitions[1].MetadataSource
                      if metadata_source then
                        -- Check if buffer already exists first
                        local buf_name = metadata_source.TypeName .. ' [Decompiled]'
                        local existing_bufnr = vim.fn.bufnr(buf_name)

                        if existing_bufnr ~= -1 then
                          -- Buffer already exists, just switch to it and navigate
                          -- vim.notify('Reusing existing decompiled buffer: ' .. buf_name, vim.log.levels.INFO)
                          vim.api.nvim_set_current_buf(existing_bufnr)

                          -- Navigate to the definition line
                          local target_line = range.start.line + 1
                          local target_col = range.start.character
                          local total_lines = vim.api.nvim_buf_line_count(existing_bufnr)

                          if target_line > total_lines then
                            target_line = total_lines
                          end

                          vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                          -- vim.notify('Navigated to existing decompiled source: ' .. metadata_source.TypeName, vim.log.levels.INFO)
                          return
                        end

                        -- vim.notify('Found MetadataSource, requesting actual source content...', vim.log.levels.INFO)

                        -- Request the actual source content using o#/metadata (only if buffer doesn't exist)
                        vim.lsp.buf_request(0, 'o#/metadata', {
                          AssemblyName = metadata_source.AssemblyName,
                          TypeName = metadata_source.TypeName,
                          ProjectName = metadata_source.ProjectName
                        }, function(source_err, source_result)
                          -- vim.notify('Source request result: ' .. vim.inspect({err = source_err, result = source_result}), vim.log.levels.INFO)

                          if source_result and source_result.Source then
                            -- vim.notify('Creating decompiled buffer with source content...', vim.log.levels.INFO)

                            -- Create new buffer (we already checked it doesn't exist)
                            local bufnr = vim.api.nvim_create_buf(false, true)
                            local buf_name = metadata_source.TypeName .. ' [Decompiled]'
                            vim.api.nvim_buf_set_name(bufnr, buf_name)
                            vim.api.nvim_buf_set_option(bufnr, 'filetype', 'cs')
                            vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
                            vim.api.nvim_buf_set_option(bufnr, 'readonly', true)

                            -- Set the decompiled source content
                            local source_lines = vim.split(source_result.Source, '\n')
                            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, source_lines)

                            -- Switch to the buffer
                            vim.api.nvim_set_current_buf(bufnr)

                            -- Navigate to the definition line from the original metadata location
                            local target_line = range.start.line + 1
                            local target_col = range.start.character
                            local total_lines = vim.api.nvim_buf_line_count(bufnr)

                            if target_line > total_lines then
                              target_line = total_lines
                            end

                            vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                            -- vim.notify('Successfully opened decompiled source: ' .. metadata_source.TypeName, vim.log.levels.INFO)
                            return
                          elseif source_result and source_result.source then
                            -- Handle lowercase 'source' field
                            -- vim.notify('Found lowercase source field, creating buffer...', vim.log.levels.INFO)

                            -- Create new buffer (we already checked it doesn't exist)
                            local bufnr = vim.api.nvim_create_buf(false, true)
                            local buf_name = metadata_source.TypeName .. ' [Decompiled]'
                            vim.api.nvim_buf_set_name(bufnr, buf_name)
                            vim.api.nvim_buf_set_option(bufnr, 'filetype', 'cs')
                            vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
                            vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
                            local source_lines = vim.split(source_result.source, '\n')
                            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, source_lines)
                            vim.api.nvim_set_current_buf(bufnr)
                            local target_line = range.start.line + 1
                            local target_col = range.start.character
                            local total_lines = vim.api.nvim_buf_line_count(bufnr)
                            if target_line > total_lines then
                              target_line = total_lines
                            end
                            vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                            -- vim.notify('Successfully opened decompiled source: ' .. metadata_source.TypeName, vim.log.levels.INFO)
                            return
                          else
                            vim.notify('Source request failed or returned no source content', vim.log.levels.WARN)
                          end
                        end)
                        return
                      end
                    end

                    -- Method 2: Try textDocument/hover on metadata URI
                    vim.lsp.buf_request(0, 'textDocument/hover', {
                      textDocument = { uri = uri },
                      position = range.start
                    }, function(err2, result2)
                      -- vim.notify('Method 2 result: ' .. vim.inspect({err = err2, result = result2}), vim.log.levels.INFO)
                      if result2 and result2.contents and type(result2.contents) == 'string' then
                        create_decompiled_buffer(result2.contents, type_name, range)
                        return
                      end

                      -- Method 3: Try o#/decompilation
                      vim.lsp.buf_request(0, 'o#/decompilation', {
                        AssemblyName = assembly_match,
                        TypeName = type_name
                      }, function(err3, result3)
                        -- vim.notify('Method 3 result: ' .. vim.inspect({err = err3, result = result3}), vim.log.levels.INFO)
                        if result3 and result3.Source then
                          create_decompiled_buffer(result3.Source, type_name, range)
                          return
                        end

                        vim.notify('All decompilation methods failed. Assembly: ' .. assembly_match .. ', Type: ' .. type_name, vim.log.levels.WARN)

                        -- Important: Don't fall back to telescope for metadata files
                        -- vim.notify('Skipping telescope fallback for metadata file to avoid errors', vim.log.levels.INFO)
                      end)
                    end)
                  end)
                end

                local function create_decompiled_buffer(source_content, name, target_range)
                  if not source_content or source_content == '' then
                    vim.notify('Empty decompiled source received', vim.log.levels.WARN)
                    return
                  end

                  -- Create buffer with decompiled source
                  local bufnr = vim.api.nvim_create_buf(false, true)
                  local buf_name = name .. ' [Decompiled]'

                  vim.api.nvim_buf_set_name(bufnr, buf_name)
                  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'cs')
                  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
                  vim.api.nvim_buf_set_option(bufnr, 'readonly', true)

                  -- Set the decompiled source content
                  local source_lines = vim.split(source_content, '\n')
                  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, source_lines)

                  -- Switch to the buffer
                  vim.api.nvim_set_current_buf(bufnr)

                  -- Navigate to the definition line
                  local target_line = target_range.start.line + 1
                  local target_col = target_range.start.character
                  local total_lines = vim.api.nvim_buf_line_count(bufnr)

                  if target_line > total_lines then
                    target_line = total_lines
                  end

                  vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                  -- vim.notify('Opened decompiled source: ' .. name, vim.log.levels.INFO)
                end

                try_decompilation_methods()
                return
              end

              -- This should not happen since we handle all cases above
              -- vim.notify('Unexpected: reached fallback with results but no files detected', vim.log.levels.WARN)
            end)
          end, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>.', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })

          -- Code inspection shortcuts
          map('<leader>ih', vim.lsp.buf.hover, '[I]nspect [H]over')
          map('<leader>ii', vim.lsp.buf.signature_help, '[I]nspect S[i]gnature')
          map('<leader>id', vim.diagnostic.open_float, '[I]nspect [D]iagnostics')
          map('<leader>il', vim.diagnostic.setloclist, '[I]nspect [L]ist Diagnostics')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        -- Virtual text configuration
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          prefix = '●',
          -- Only show errors in virtual text
          severity = { min = vim.diagnostic.severity.ERROR },
        },
        -- Disable virtual lines to prevent conflicts
        virtual_lines = false,
        -- Update diagnostics in insert mode too
        update_in_insert = false,
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        
        -- OmniSharp for C# development
        omnisharp = {
          cmd = { 'omnisharp' },
          -- Enable roslyn analyzers support and more
          settings = {
            FormattingOptions = {
              -- Enables support for reading code style, naming convention and analyzer
              -- settings from .editorconfig.
              EnableEditorConfigSupport = true,
            },
            MsBuild = {
              -- If true, MSBuild project system will only load projects for files that
              -- were opened in the editor. This setting is useful for big C# codebases
              -- and allows for faster initialization of code navigation features only
              -- for projects that are relevant to code that is being edited. With this
              -- setting enabled OmniSharp may load fewer projects and may thus display
              -- incomplete reference lists for symbols.
              LoadProjectsOnDemand = false,
            },
            RoslynExtensionsOptions = {
              -- Enables support for roslyn analyzers, code fixes and rulesets.
              EnableAnalyzersSupport = true,
              -- Enables support for showing unimported types and unimported extension
              -- methods in completion lists. When committed, the appropriate using
              -- directive will be added at the top of the current file.
              EnableImportCompletion = true,
              -- Semantic highlighting
              AnalyzeOpenDocumentsOnly = false,
              -- Enable decompilation support
              EnableDecompilationSupport = true,
            },
            Sdk = {
              -- Specifies whether to include preview versions of the .NET SDK
              IncludePrereleases = true,
            },
          },
          -- Fix for Windows paths
          root_dir = function(fname)
            local lspconfig = require 'lspconfig'
            return lspconfig.util.root_pattern('*.sln', '*.csproj', '.git')(fname) or vim.loop.cwd()
          end,
          on_attach = function(client, bufnr)
            -- Disable semantic tokens to prevent conflicts with treesitter
            client.server_capabilities.semanticTokensProvider = false
          end,
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'csharpier', -- C# formatter
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
