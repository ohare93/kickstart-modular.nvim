-- parrot.nvim configuration for Neovim plugin manager.
-- Defines the plugin, dependencies, and provider API keys for various AI text generation backends.
-- Uncomment and set your API keys in the respective provider sections to enable them.
-- By default, enables Perplexity provider using 'PERPLEXITY_API_KEY' from environment variables.
-- Other supported providers include Anthropic, Gemini, Groq, Mistral, Ollama, OpenAI, Github, Nvidia, Xai, etc.
return {
  'frankroeder/parrot.nvim',
  dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
  opts = {
    providers = {
      -- anthropic = {
      --   api_key = os.getenv "ANTHROPIC_API_KEY",
      -- },
      -- gemini = {
      --   api_key = os.getenv "GEMINI_API_KEY",
      -- },
      -- groq = {
      --   api_key = os.getenv "GROQ_API_KEY",
      -- },
      -- mistral = {
      --   api_key = os.getenv "MISTRAL_API_KEY",
      -- },
      pplx = {
        api_key = vim.env.PERPLEXITY_API_KEY,
      },
      -- provide an empty list to make provider available (no API key required)
      -- ollama = {},
      -- openai = {
      --   api_key = os.getenv "OPENAI_API_KEY",
      -- },
      -- github = {
      --   api_key = os.getenv "GITHUB_TOKEN",
      -- },
      -- nvidia = {
      --   api_key = os.getenv "NVIDIA_API_KEY",
      -- },
      -- xai = {
      --   api_key = os.getenv "XAI_API_KEY",
      -- },
    },
  },
}
