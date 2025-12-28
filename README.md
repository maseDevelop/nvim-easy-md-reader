# nvim-easy-md-reader

Bionic-style reading viewer for Markdown in Neovim.

Opens a floating window with transformed text where the first portion of each word is bolded for faster visual parsing. Original buffer remains untouched.

## Requirements

- Neovim >= 0.9.0
- nvim-treesitter with markdown parser

## Installation

### lazy.nvim

```lua
{
  "maseDevelop/nvim-easy-md-reader",
  ft = "markdown",
  opts = {},
}
```

## Configuration

```lua
require("easy-md-reader").setup({
  ratio = 0.4,              -- portion of word to bold (0-1)
  min_word_length = 4,      -- skip words shorter than this
  viewer = "float",         -- "float" or "split"
  float_opts = {
    width = 0.8,            -- percentage of screen
    height = 0.8,
    border = "rounded",
  },
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:BionicView` | Open bionic reading viewer |
| `:BionicClose` | Close viewer |
| `:BionicToggle` | Toggle viewer |
| `:BionicRatio <n>` | Set emphasis ratio (0-1) |

Press `q` in the viewer to close.

## How it works

Transforms prose text to: `**Rea**ding **mark**down **fi**les`

Skips:
- Code blocks
- Inline code
- URLs and file paths
- Short words (< min_word_length)
- ALL CAPS words
