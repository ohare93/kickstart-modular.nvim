vim.keymap.set({ 'n', 'i' }, '<leader>ac', '<cmd>PrtChatNew<cr>', { desc = '[A]I [C]hat New' })
vim.keymap.set('v', '<leader>ac', ":<C-u>'<,'>PrtChatNew<cr>", { desc = '[A]I [C]hat New (visual)' })

vim.keymap.set({ 'n', 'i' }, '<leader>at', '<cmd>PrtChatToggle<cr>', { desc = '[A]I [T]oggle Popup Chat' })
vim.keymap.set({ 'n', 'i' }, '<leader>af', '<cmd>PrtChatFinder<cr>', { desc = '[A]I [F]ind Chat' })

vim.keymap.set({ 'n', 'i' }, '<leader>ar', '<cmd>PrtRewrite<cr>', { desc = '[A]I [R]ewrite Inline' })
vim.keymap.set('v', '<leader>ar', ":<C-u>'<,'>PrtRewrite<cr>", { desc = '[A]I [R]ewrite (visual)' })

vim.keymap.set('n', '<leader>aj', '<cmd>PrtRetry<cr>', { desc = '[A]I Retry (No [J]; not clear as mnemonic, suggest custom? Can omit [J].)' })

vim.keymap.set({ 'n', 'i' }, '<leader>aa', '<cmd>PrtAppend<cr>', { desc = '[A]I [A]ppend' })
vim.keymap.set('v', '<leader>aa', ":<C-u>'<,'>PrtAppend<cr>", { desc = '[A]I [A]ppend (visual)' })

vim.keymap.set({ 'n', 'i' }, '<leader>ao', '<cmd>PrtPrepend<cr>', { desc = '[A]I [P]repend' }) -- Note: 'o' mapped to [P]repend may not align! Recommend either using [O] or clarify.
-- For clarity, I suggest below:
vim.keymap.set({ 'n', 'i' }, '<leader>ao', '<cmd>PrtPrepend<cr>', { desc = '[A]I [O]ther Command: Prepend' })
-- Alternatively, if "o" stands for something like "output" or "over", you need to clarify. If not, this is confusing and best not to use inconsistent []s.
vim.keymap.set('v', '<leader>ao', ":<C-u>'<,'>PrtPrepend<cr>", { desc = '[A]I [O]ther Command: Prepend (visual)' })

vim.keymap.set('v', '<leader>ae', ":<C-u>'<,'>PrtEnew<cr>", { desc = '[A]I [E]new (visual)' })

vim.keymap.set({ 'n', 'i', 'v', 'x' }, '<leader>as', '<cmd>PrtStop<cr>', { desc = '[A]I [S]top' })
vim.keymap.set({ 'n', 'i', 'v', 'x' }, '<leader>ai', ":<C-u>'<,'>PrtComplete<cr>", { desc = '[A]I [I]nteractive Complete (visual)' })

vim.keymap.set('n', '<leader>ax', '<cmd>PrtContext<cr>', { desc = '[A]I [X]tract/Context File' })
vim.keymap.set('n', '<leader>an', '<cmd>PrtModel<cr>', { desc = '[A]I [N]ew Model Selection' })
vim.keymap.set('n', '<leader>ap', '<cmd>PrtProvider<cr>', { desc = '[A]I [P]rovider Selection' })
vim.keymap.set('n', '<leader>aq', '<cmd>PrtAsk<cr>', { desc = '[A]I [Q]uestion' })

vim.keymap.set('n', '<leader>ap', 'ggVG<cmd>PrtChatPaste<cr>', { desc = '[A]I [P]aste File into chat' })
vim.keymap.set('v', '<leader>ap', ":<C-u>'<,'>PrtChatPaste<cr>", { desc = '[A]I [P]aste Selection into chat' })

vim.keymap.set('n', '<leader>ar', '<cmd>PrtChatResponde<cr>', { desc = '[A]I Chat [R]espond' })

-- parrot.nvim configuration for Neovim plugin manager.
-- Defines the plugin, dependencies, and provider API keys for various AI text generation backends.
-- Uncomment and set your API keys in the respective provider sections to enable them.
-- By default, enables Perplexity provider using 'PERPLEXITY_API_KEY' from environment variables.
-- Other supported providers include Anthropic, Gemini, Groq, Mistral, Ollama, OpenAI, Github, Nvidia, Xai, etc.
return {
  'frankroeder/parrot.nvim',
  tag = 'v1.8.0',
  dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
  opts = {
    providers = {
      pplx = {
        name = 'Perplexity',
        api_key = vim.env.PERPLEXITY_API_KEY,
        endpoint = 'https://api.perplexity.ai/chat/completions',
        topic = {
          model = 'sonar-pro',
        },
        models = {
          'sonar',
          'sonar-pro',
          'sonar-reasoning',
          'sonar-reasoning-pro',
          'sonar-deep-research',
        },
      },
    },
    chat_dir = "~/Development/ai/parrot/chats",
    state_dir = "~/Development/ai/parrot/state",
    hooks = {
      Complete = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted."
        ]]
        local model_obj = prt.get_model 'command'
        prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
      end,
      CompleteFullContext = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{filecontent}}
        ```

        Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted.
        ]]
        local model_obj = prt.get_model 'command'
        prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
      end,
      CompleteMultiContext = function(prt, params)
        local template = [[
        I have the following code from {{filename}} and other realted files:

        ```{{filetype}}
        {{multifilecontent}}
        ```

        Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted.
        ]]
        local model_obj = prt.get_model 'command'
        prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
      end,
      Explain = function(prt, params)
        local template = [[
        Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
        Break down the code's functionality, purpose, and key components.
        The goal is to help the reader understand what the code does and how it works.

        ```{{filetype}}
        {{selection}}
        ```

        Use the markdown format with codeblocks and inline code.
        Explanation of the code above:
        ]]
        local model = prt.get_model 'command'
        prt.logger.info('Explaining selection with model: ' .. model.name)
        prt.Prompt(params, prt.ui.Target.new, model, nil, template)
      end,
      FixBugs = function(prt, params)
        local template = [[
        You are an expert in {{filetype}}.
        Fix bugs in the below code from {{filename}} carefully and logically:
        Your task is to analyze the provided {{filetype}} code snippet, identify
        any bugs or errors present, and provide a corrected version of the code
        that resolves these issues. Explain the problems you found in the
        original code and how your fixes address them. The corrected code should
        be functional, efficient, and adhere to best practices in
        {{filetype}} programming.

        ```{{filetype}}
        {{selection}}
        ```

        Fixed code:
        ]]
        local model_obj = prt.get_model 'command'
        prt.logger.info('Fixing bugs in selection with model: ' .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
      end,
      Optimize = function(prt, params)
        local template = [[
        You are an expert in {{filetype}}.
        Your task is to analyze the provided {{filetype}} code snippet and
        suggest improvements to optimize its performance. Identify areas
        where the code can be made more efficient, faster, or less
        resource-intensive. Provide specific suggestions for optimization,
        along with explanations of how these changes can enhance the code's
        performance. The optimized code should maintain the same functionality
        as the original code while demonstrating improved efficiency.

        ```{{filetype}}
        {{selection}}
        ```

        Optimized code:
        ]]
        local model_obj = prt.get_model 'command'
        prt.logger.info('Optimizing selection with model: ' .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
      end,
      UnitTests = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please respond by writing table driven unit tests for the code above.
        ]]
        local model_obj = prt.get_model 'command'
        prt.logger.info('Creating unit tests for selection with model: ' .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
      end,
      Debug = function(prt, params)
        local template = [[
        I want you to act as {{filetype}} expert.
        Review the following code, carefully examine it, and report potential
        bugs and edge cases alongside solutions to resolve them.
        Keep your explanation short and to the point:

        ```{{filetype}}
        {{selection}}
        ```
        ]]
        local model_obj = prt.get_model 'command'
        prt.logger.info('Debugging selection with model: ' .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
      end,
      CommitMsg = function(prt, params)
        local futils = require 'parrot.file_utils'
        if futils.find_git_root() == '' then
          prt.logger.warning 'Not in a git repository'
          return
        else
          local template = [[
          I want you to act as a commit message generator. I will provide you
          with information about the task and the prefix for the task code, and
          I would like you to generate an appropriate commit message using the
          conventional commit format. Do not write any explanations or other
          words, just reply with the commit message.
          Start with a short headline as summary but then list the individual
          changes in more detail.

          Here are the changes that should be considered by this message:
          ]] .. vim.fn.system 'git diff --no-color --no-ext-diff --staged'
          local model_obj = prt.get_model 'command'
          prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
        end
      end,
      SpellCheck = function(prt, params)
        local chat_prompt = [[
        Your task is to take the text provided and rewrite it into a clear,
        grammatically correct version while preserving the original meaning
        as closely as possible. Correct any spelling mistakes, punctuation
        errors, verb tense issues, word choice problems, and other
        grammatical mistakes.
        ]]
        prt.ChatNew(params, chat_prompt)
      end,
      CodeConsultant = function(prt, params)
        local chat_prompt = [[
          Your task is to analyze the provided {{filetype}} code and suggest
          improvements to optimize its performance. Identify areas where the
          code can be made more efficient, faster, or less resource-intensive.
          Provide specific suggestions for optimization, along with explanations
          of how these changes can enhance the code's performance. The optimized
          code should maintain the same functionality as the original code while
          demonstrating improved efficiency.

          Here is the code
          ```{{filetype}}
          {{filecontent}}
          ```
        ]]
        prt.ChatNew(params, chat_prompt)
      end,
      ProofReader = function(prt, params)
        local chat_prompt = [[
        I want you to act as a proofreader. I will provide you with texts and
        I would like you to review them for any spelling, grammar, or
        punctuation errors. Once you have finished reviewing the text,
        provide me with any necessary corrections or suggestions to improve the
        text. Highlight the corrected fragments (if any) using markdown backticks.

        When you have done that subsequently provide me with a slightly better
        version of the text, but keep close to the original text.

        Finally provide me with an ideal version of the text.

        Whenever I provide you with text, you reply in this format directly:

        ## Corrected text:

        {corrected text, or say "NO_CORRECTIONS_NEEDED" instead if there are no corrections made}

        ## Slightly better text

        {slightly better text}

        ## Ideal text

        {ideal text}
        ]]
        prt.ChatNew(params, chat_prompt)
      end,
    },
  },
}
