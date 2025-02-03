local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

local u= require("utils")

local M = {}

function M.item_data(args)
  u.io.show_contents("item", args)
end

function M.window_choose(args)
  u.io.begin_debug("window_choose")
  u.io.debug_echo("args", args.items)

  u.try_catch({
    try = function()
      local my_winpick = require("customs.winpick")

      for _, item in pairs(args.items) do
        local path = item.action.path

          if u.window.win_count() <= 1 then
            vim.cmd("edit " .. path)
            -- return
          else
            my_winpick.choose_for_open(path)
          end

      end
    end,

    catch = function()
      M.do_action("itemAction", args)
    end,
  })
  u.io.end_debug("window_choose")
  return 0
end

return M
