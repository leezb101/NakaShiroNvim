--[[
Author: LeeZB
Date: 2023-09-22 18:45:28
LastEditors: LeeZB leezb101@126.com
LastEditTime: 2023-09-22 18:47:00
copyright: Copyright © 2019 HeNan DtCloud Network Technology Co.,Lt d.
--]]
local set = vim.o
set.number = true
set.relativenumber = true
set.clipboard = "unnamed"

-- copy后高亮
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end
})
-- keybindings
local opt = { noremap = true, silent = true }
vim.g.mapleader = " "
vim.g.localmapleader = " "
vim.keymap.set("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set("n", "<C-h>", "<C-w>h", opt)
vim.keymap.set("n", "<C-j>", "<C-w>j", opt)
vim.keymap.set("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set("n", "<leader>v", "<C-w>v", opt)
vim.keymap.set("n", "<leader>s", "<C-w>s", opt)
-- 判断是否有count在jk跳转前，决定是否跳转可视行和物理行
vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({})
