local M = {}

M.config = {
  ratio = 0.4,
  min_word_length = 4,
  viewer = "float", -- "float" or "split"
  float_opts = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_user_command("BionicView", function()
    M.view()
  end, { desc = "Open bionic reading viewer" })

  vim.api.nvim_create_user_command("BionicClose", function()
    M.close()
  end, { desc = "Close bionic reading viewer" })

  vim.api.nvim_create_user_command("BionicToggle", function()
    M.toggle()
  end, { desc = "Toggle bionic reading viewer" })

  vim.api.nvim_create_user_command("BionicRatio", function(cmd_opts)
    local new_ratio = tonumber(cmd_opts.args)
    if new_ratio and new_ratio > 0 and new_ratio <= 1 then
      M.config.ratio = new_ratio
      if M.is_open() then
        M.reload()
      end
    else
      vim.notify("Ratio must be between 0 and 1", vim.log.levels.ERROR)
    end
  end, { nargs = 1, desc = "Set bionic emphasis ratio (0-1)" })
end

function M.view()
  local transform = require("easy-md-reader.transform")
  local viewer = require("easy-md-reader.viewer")

  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  if ft ~= "markdown" then
    vim.notify("BionicView only works on markdown files", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local transformed = transform.transform(lines, bufnr, M.config)
  viewer.open(transformed, M.config)
end

function M.close()
  local viewer = require("easy-md-reader.viewer")
  viewer.close()
end

function M.toggle()
  local viewer = require("easy-md-reader.viewer")
  if viewer.is_open() then
    viewer.close()
  else
    M.view()
  end
end

function M.is_open()
  local viewer = require("easy-md-reader.viewer")
  return viewer.is_open()
end

function M.reload()
  M.close()
  M.view()
end

return M
