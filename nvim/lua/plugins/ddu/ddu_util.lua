local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")
local u = require("utils")

local augroup = api.nvim_create_augroup -- Create/get autocommand group
local autocmd = api.nvim_create_autocmd -- Create autocommand

local M = {

  ------------------------------
  -- alias
  ------------------------------
  start = fn["ddu#start"],
  patch_global = fn["ddu#custom#patch_global"],
  patch_local = fn["ddu#custom#patch_local"],
  action = fn["ddu#custom#action"],
  get_current = vim.fn['ddu#custom#get_current'],
  sync_action = fn["ddu#ui#sync_action"],
  do_action = fn["ddu#ui#do_action"],
  item = {
    is_tree = function()
      return fn["ddu#ui#get_item"]()["isTree"]
    end,
  },

}

------------------------------
-- functions
------------------------------

function M.toggle(array, needle)
  local idx = -1
  for k, v in pairs(array) do
    if v == needle then idx = k end
  end
  if idx ~= -1 then
    table.remove(array, idx)
  else
    table.insert(array, needle)
  end
  return array
end

function M.window_resize()
  -- window param variables
  local lines = opt.lines:get()
  local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
  local columns = opt.columns:get()
  local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)

  M.patch_global({
    -- ui-ff params --
    uiParams = {
      ff = {
        -- window setting
        winHeight= height,
        winWidth= width,
        winRow= row,
        winCol= col,
      }, -- /ui-ff params
    }, -- /ui params
  })

    -- preview size --
  if width > 155 then
    M.patch_global({
      -- ui-ff params --
      uiParams = {
        ff = {
          -- preview setting
          previewSplit = "vertical",
          previewHeight= height,
          previewWidth= math.floor(width / 2),
        }, -- /ui-ff params

        filer = {
          -- preview setting
          previewHeight= height,
          previewWidth= math.floor(width / 2),
        }
      }, -- /ui params
    })
  else
    M.patch_global({
      -- ui-ff params --
      uiParams = {
        ff = {
          -- preview setting
          previewSplit = "horizontal",
          previewHeight= math.floor(height / 2),
          previewWidth= width,
          previewRow = lines - 5,
        }, -- /ui-ff params

        filer = {
          -- preview setting
          previewHeight= height,
          previewWidth= width,
        }
      }, -- /ui params
    })

  end

end

return M
