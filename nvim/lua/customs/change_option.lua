local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.ddu.ddu_util")
local u = require("utils")
local km_opts = require("const.keymap")

local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local M ={}

local function toggle(array, needle)
  local idx = -1
  for k, v in pairs(array) do
    if v == needle then idx = k end
  end
  if idx ~= -1 then
    table.remove(array, idx)
  else
    table.insert(array, needle)
  end
  -- print(vim.inspect(array))
  u.io.debug_echo("[insered matchers]", array)
  return array
end

function M.toggle_hidden(ui_name, source_name)
  local cur = vim.fn['ddu#custom#get_current'](ui_name)
  local opts = cur['sourceOptions'] or {}
  local opts_all = opts[source_name] or {}
  local matchers = opts_all['matchers'] or {}
  u.io.debug_echo("[matchers]", matchers)
  --print(vim.inspect(matchers))
  return toggle(matchers, 'matcher_hidden')
end
