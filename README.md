# LLM Beamer 🚀✨

Supercharge your Neovim experience with AI-powered text completion!

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.5+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

## 🌟 Features

- 🧠 AI-powered text completion using customizable LLM models
- ⚡ Lightning-fast suggestions with multi-beam search
- 🎨 Sleek, non-intrusive UI that respects your Neovim setup
- 🛠 Highly configurable to fit your workflow
- 📚 Context-aware completions that understand your code
- 💾 Persistent storage for your custom prompts and settings

## 📦 Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'maldevide/llm-beamer.nvim',
  requires = {
    'nvim-lua/plenary.nvim'  -- Required for HTTP requests
  },
  config = function()
    require('llm_beamer').setup({
      -- Your configuration here (see Configuration section)
    })
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'maldevide/llm-beamer.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require('llm_beamer').setup({
      -- Your configuration here (see Configuration section)
    })
  end
}
```

## ⚙️ Configuration

LLM Beamer comes with sensible defaults, but you can customize it to your heart's content. Here's a full configuration with all available options:

```lua
require('llm_beamer').setup({
  api_url = "http://your-api-url:5000/v1/chat/completions",
  api_key = "your-api-key",  -- Consider using an environment variable for security
  model = "gpt-3.5-turbo",  -- or any other model supported by your API
  num_words = 5,
  num_beams = 4,
  num_preceding_lines = 10,
  context_window_width = 200,
  max_tokens = 48,
  system_prompt = "Continue the story from where the user leaves off; continue the story, adding new content.",
  debounce_ms = 100,
  temperature = 0.85,
  top_p = 1,
  status_update_interval_ms = 100,
  fold_at = 5,
  debug = false
})
```

### Configuration Options Explained

- `api_url`: The URL of your LLM API endpoint
- `api_key`: Your API key for authentication
- `model`: The name of the LLM model to use
- `num_words`: Number of words to generate in each suggestion
- `num_beams`: Number of alternative suggestions to generate
- `num_preceding_lines`: Number of lines before the cursor to use as context
- `context_window_width`: Width of the suggestion window
- `max_tokens`: Maximum number of tokens to generate
- `system_prompt`: The initial prompt to set the context for the LLM
- `debounce_ms`: Debounce time in milliseconds for API requests
- `temperature`: Controls randomness in generation (0.0 to 1.0)
- `top_p`: Controls diversity via nucleus sampling (0.0 to 1.0)
- `status_update_interval_ms`: Interval for updating the status window
- `fold_at`: Line number to fold the context at
- `debug`: Enable debug logging

## 🎮 Usage

LLM Beamer integrates seamlessly into your Neovim workflow. Here are the default keybindings:

- `<S-Tab>` in insert mode: Activate LLM Beamer
- `<leader>bi` in normal mode: Open info windows
- `<Enter>` in suggestion window: Select suggestion
- `r` in suggestion window: Reroll suggestions
- `<Esc>` in any LLM Beamer window: Close window
- `<leader>bh` in normal mode: Show help window
- `<leader>bs` in normal mode: Save LLM Beamer buffers
- `<leader>bl` in normal mode: Load LLM Beamer buffers

### Commands

- `:LLMBeamer`: Set up or reconfigure LLM Beamer
- `:LLMBeamerSave`: Save the contents of LLM Beamer buffers
- `:LLMBeamerLoad`: Load the contents of LLM Beamer buffers

## 🧠 How It Works

1. When you activate LLM Beamer, it captures the context around your cursor.
2. This context is sent to the configured LLM API.
3. The API generates multiple suggestions based on the context.
4. LLM Beamer displays these suggestions in a sleek, non-intrusive window.
5. You can select a suggestion to insert it into your text, or reroll for new suggestions.

## 🎨 Customization

### Changing Keybindings

You can customize the keybindings in your Neovim configuration:

```lua
vim.api.nvim_set_keymap('i', '<C-Space>', [[<Cmd>lua require('llm_beamer').handle_activation()<CR>]], {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>lb', [[<Cmd>lua require('llm_beamer').create_or_focus_windows()<CR>]], {noremap = true, silent = true})
```

### Custom Prompts

You can customize the system prompt to tailor the LLM's behavior to your needs:

```lua
require('llm_beamer').setup({
  system_prompt = "You are an expert programmer. Complete the code with best practices and optimizations.",
})
```

## 🐛 Troubleshooting

If you encounter any issues:

1. Enable debug mode in the configuration.
2. Check the Neovim error messages (`:messages`).
3. Ensure your API key and URL are correct.
4. Verify your internet connection.

If the problem persists, please open an issue on our GitHub repository with the debug log and a description of the problem.

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit pull requests, report issues, or request features.

## 📜 License

LLM Beamer is released under the MIT License. See the [LICENSE](LICENSE) file for more details.

## 🙏 Acknowledgements

- Thanks to the Neovim team for creating an amazing text editor.
- Shoutout to the creators of plenary.nvim for their HTTP request library.
- And of course, a big thank you to the LLM community for pushing the boundaries of what's possible with AI.

---

Enjoy supercharging your Neovim experience with LLM Beamer! If you find it helpful, consider giving us a star on GitHub. Happy coding! 🚀✨
