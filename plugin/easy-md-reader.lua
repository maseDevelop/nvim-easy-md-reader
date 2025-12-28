if vim.g.loaded_easy_md_reader then
  return
end
vim.g.loaded_easy_md_reader = true

vim.api.nvim_create_user_command("BionicView", function()
  require("easy-md-reader").setup()
  require("easy-md-reader").view()
end, { desc = "Open bionic reading viewer" })

vim.api.nvim_create_user_command("BionicClose", function()
  require("easy-md-reader").close()
end, { desc = "Close bionic reading viewer" })

vim.api.nvim_create_user_command("BionicToggle", function()
  require("easy-md-reader").setup()
  require("easy-md-reader").toggle()
end, { desc = "Toggle bionic reading viewer" })
