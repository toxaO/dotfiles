local utils = require("utils")
local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

local M = {
  patch_global = fn["ddu#custom#patch_global"],
  action = fn["ddu#custom#action"],
  start = fn["ddu#start"],
  sync_action = fn["ddu#ui#sync_action"],
  do_action = fn["ddu#ui#do_action"],
  patch_local = fn["ddu#custom#patch_local"],
  item = {
    is_tree = function()
      return fn["ddu#ui#get_item"]()["isTree"]
    end,
  },
}

function M.win_all()
  return fn.range(1, fn.winnr("$"))
end

function M.win_count()
  return fn.winnr("$")
end

function M.window_choose(args)
  utils.io.begin_debug("window_choose")
  utils.io.debug_echo("args", args.items[1])
  print(args.items[1].action.path)

  utils.try_catch({
    try = function()
      local path = args.items[1].action.path
      if M.win_count() <= 1 then
        vim.cmd("edit " .. path)
        return
      end

      local my_winpick = require("plugins.config.winpick")
      my_winpick.choose_for_focus()
      vim.cmd("edit " .. path)
    end,

    catch = function()
      M.do_action("itemAction", args)
    end,
  })
  utils.io.end_debug("window_choose")
  return 0
end

return M
