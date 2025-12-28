local M = {}

-- Node types to skip (code, URLs, etc)
local SKIP_NODE_TYPES = {
  fenced_code_block = true,
  code_fence_content = true,
  code_span = true,
  link_destination = true,
  uri_autolink = true,
  html_block = true,
  html_tag = true,
  info_string = true,
}

-- Check if position falls within any skip range
local function is_in_skip_range(skip_ranges, row, col)
  for _, range in ipairs(skip_ranges) do
    local sr, sc, er, ec = range[1], range[2], range[3], range[4]
    if row > sr and row < er then
      return true
    elseif row == sr and row == er then
      if col >= sc and col < ec then
        return true
      end
    elseif row == sr and col >= sc then
      return true
    elseif row == er and col < ec then
      return true
    end
  end
  return false
end

-- Collect ranges to skip using treesitter
local function collect_skip_ranges(bufnr)
  local ranges = {}
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
  if not ok or not parser then
    return ranges
  end

  local trees = parser:parse()
  if not trees or #trees == 0 then
    return ranges
  end

  local function collect_nodes(node)
    local node_type = node:type()
    if SKIP_NODE_TYPES[node_type] then
      local sr, sc, er, ec = node:range()
      table.insert(ranges, { sr, sc, er, ec })
      return
    end
    for child in node:iter_children() do
      collect_nodes(child)
    end
  end

  for _, tree in ipairs(trees) do
    collect_nodes(tree:root())
  end

  -- Also check inline parser for code_span etc
  local ok_inline, inline_parser = pcall(function()
    return parser:children()["markdown_inline"]
  end)

  if ok_inline and inline_parser then
    local inline_trees = inline_parser:parse()
    for _, tree in ipairs(inline_trees or {}) do
      collect_nodes(tree:root())
    end
  end

  return ranges
end

-- Calculate fixation length for a word
local function get_fixation_length(word, config)
  local len = vim.fn.strchars(word)
  if len < config.min_word_length then
    return 0
  end
  -- Skip ALL CAPS
  if word:match("^%u+$") then
    return 0
  end
  -- Skip paths/URLs
  if word:match("^[/~]") or word:match("://") or word:match("%.%w+$") then
    return 0
  end
  return math.ceil(len * config.ratio)
end

-- Transform a word to bionic format: **Rea**ding
local function transform_word(word, config)
  local alpha_word = word:match("^[%a]+")
  if not alpha_word then
    return word
  end

  local fixation = get_fixation_length(alpha_word, config)
  if fixation <= 0 then
    return word
  end

  local bold_part = word:sub(1, fixation)
  local rest = word:sub(fixation + 1)
  return "**" .. bold_part .. "**" .. rest
end

-- Transform a single line, respecting skip ranges
local function transform_line(line, row, skip_ranges, config)
  local result = {}
  local pos = 1

  while pos <= #line do
    -- Find next word
    local word_start, word_end, word = line:find("([%a]+)", pos)

    if not word_start then
      -- No more words, append rest
      table.insert(result, line:sub(pos))
      break
    end

    -- Append non-word content before this word
    if word_start > pos then
      table.insert(result, line:sub(pos, word_start - 1))
    end

    -- Check if word is in skip range
    if is_in_skip_range(skip_ranges, row, word_start - 1) then
      table.insert(result, word)
    else
      table.insert(result, transform_word(word, config))
    end

    pos = word_end + 1
  end

  return table.concat(result)
end

-- Main transform function
function M.transform(lines, bufnr, config)
  local skip_ranges = collect_skip_ranges(bufnr)
  local result = {}

  for i, line in ipairs(lines) do
    local row = i - 1
    table.insert(result, transform_line(line, row, skip_ranges, config))
  end

  return result
end

return M
