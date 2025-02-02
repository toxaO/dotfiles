local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")
local u = require("utils")

local augroup = api.nvim_create_augroup -- Create/get autocommand group
local autocmd = api.nvim_create_autocmd -- Create autocommand

local M = {}

function M.setup()
end

return M
