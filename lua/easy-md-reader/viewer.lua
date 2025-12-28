local M = {}

M.state = {
  win = nil,
  buf = nil,
}

-- Open bionic viewer in float or split
function M.open(lines, config)
  if M.is_open() then
    M.close()
  end

  -- Create scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"

  local win
  if config.viewer == "float" then
    win = M.open_float(buf, config)
  else
    win = M.open_split(buf, config)
  end

  M.state.win = win
  M.state.buf = buf

  -- Map q to close
  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = buf, nowait = true })
end

-- Open floating window
function M.open_float(buf, config)
  local opts = config.float_opts or {}
  local width_ratio = opts.width or 0.8
  local height_ratio = opts.height or 0.8

  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor(ui.width * width_ratio)
  local height = math.floor(ui.height * height_ratio)
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = opts.border or "rounded",
    title = " Bionic View ",
    title_pos = "center",
  })

  return win
end

-- Open split window
function M.open_split(buf, config)
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

-- Close viewer
function M.close()
  if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_win_close(M.state.win, true)
  end
  M.state.win = nil
  M.state.buf = nil
end

-- Check if viewer is open
function M.is_open()
  return M.state.win ~= nil and vim.api.nvim_win_is_valid(M.state.win)
end

return M
