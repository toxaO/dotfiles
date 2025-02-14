local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.ddu.ddu_util")
local ddu_action = require("plugins.ddu.action")
local u = require("utils")
local km_opts = require("const.keymap")

local augroup = api.nvim_create_augroup -- Create/get autocommand group
local autocmd = api.nvim_create_autocmd -- Create autocommand

local M = {}


------------------------------
-- ※ starter keymapはui側ファイルで設定
------------------------------

function M.setup()

  ------------------------------
  -- common
  ------------------------------
  local function common_keymap()
    -- <CR> open --
    keymap.set("n", "<CR>", function()
      return ddu.item.is_tree() and ddu.do_action("itemAction", { name = "narrow" })
      and fn["ddu#ui#do_action"]("cursorNext")
      or ddu.do_action("itemAction", { quit = true })
    end, km_opts.bnw)

    -- buffer open --
    keymap.set("n", "b", function()
      ddu.do_action("itemAction", { name = "open", quit = false })
    end, km_opts.bnw)

    -- cursor --
    keymap.set("n", "j", function()
      b.multiCursorSelection = 0
      b.SelectStartLine = 0
      fn["ddu#ui#do_action"]("cursorNext", {loop = true})
    end, km_opts.bnw)
    keymap.set("n", "k", function()
      b.multiCursorSelection = 0
      b.SelectStartLine = 0
      fn["ddu#ui#do_action"]("cursorPrevious", {loop = true})
    end, km_opts.bnw)
    -- /cursor --

    -- "v" vsplit --
    keymap.set("n", "v", function()
      return ddu.item.is_tree() and ddu.do_action("expandItem")
      or ddu.do_action("itemAction", { name = "open", params = { command = "vsplit" } })
    end, km_opts.bnw)
    -- "s" split --
    keymap.set("n", "s", function()
      return ddu.item.is_tree() and ddu.do_action("expandItem")
      or ddu.do_action("itemAction", { name = "open", params = { command = "split" } })
    end, km_opts.bnw)
    -- "t" tabnew --
    keymap.set("n", "t", function()
      fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "tabe" } })
    end, km_opts.bnw)

    -- "w" window choose --
    keymap.set("n", "w", function()
      fn["ddu#ui#do_action"]("itemAction", { name = "window_choose" })
    end, km_opts.bnw)

    -- "q" quit --
    keymap.set("n", "q", function()
      fn["ddu#ui#do_action"]("quit")
    end, km_opts.bnw)
    -- <C-C> cancel --
    keymap.set({"n", "i"}, "<C-C>", function()
      fn["ddu#ui#do_action"]("quit")
    end, km_opts.bnw)
    --  <Esc> Escape --
    keymap.set("n", "<Esc>", function()
      fn["ddu#ui#do_action"]("quit")
    end, km_opts.bnw)

    -- "a" choose action --
    keymap.set("n", "a", function()
      fn["ddu#ui#do_action"]("chooseAction")
    end, km_opts.bnw)

    -- "o" expand --
    keymap.set("n", "o", function()
      fn["ddu#ui#do_action"]("expandItem", {mode = "toggle"})
    end, km_opts.bnw)
    -- "O" all expand --
    keymap.set("n", "O", function()
      fn["ddu#ui#do_action"]("expandItem", {mode = "toggle", maxLevel = -1})
    end, km_opts.bnw)
    -- "r" rename --
    keymap.set("n", "r", function()
      ddu.do_action("itemAction", { name = "rename" })
    end, km_opts.bnw)
    -- "C" cd --
    keymap.set("n", "C", function()
      local path = fn["ddu#ui#get_item"]()["action"]["path"]
      print('change to "' .. path .. '" !')
      ddu.do_action("itemAction", { name = "cd" })
    end, km_opts.bnw)
    -- "c" copy --
    keymap.set("n", "c", function()
      fn["ddu#ui#multi_actions"]({ {"itemAction", {name = "copy"}}, {"clearSelectAllItems"} })
    end, km_opts.bnw)
    -- "x" cut --
    keymap.set("n", "x", function()
      ddu.do_action("itemAction", { name = "cut" })
    end, km_opts.bnw)
    -- "X" excution --
    keymap.set("n", "X", function()
      ddu.do_action("itemAction", { name = "executeSystem" })
    end, km_opts.bnw)
    -- "P" --
    keymap.set("n", "P", function()
      ddu.do_action("itemAction", { name = "paste" })
    end, km_opts.bnw)
    -- "m" --
    keymap.set("n", "m", function()
      ddu.do_action("itemAction", { name = "move" })
    end, km_opts.bnw)
    -- "n" --
    keymap.set("n", "n", function()
      ddu.do_action("itemAction", { name = "newFile" })
    end, km_opts.bnw)
    -- "N" --
    keymap.set("n", "N", function()
      ddu.do_action("itemAction", { name = "newDirectory" })
    end, km_opts.bnw)
    -- "y" --
    keymap.set("n", "y", function()
      fn["ddu#ui#multi_actions"]({ {"itemAction", {name = "yank"}}, {"clearSelectAllItems"} })
    end, km_opts.bnw)
    -- "d" --
    keymap.set("n", "d", function()
      ddu.do_action("itemAction", { name = "trash" })
    end, km_opts.bnw)
    -- "D" --
    keymap.set("n", "D", function()
      ddu.do_action("itemAction", { name = "delete" })
    end, km_opts.bnw)
    -- "<C-l>" --
    keymap.set("n", "<C-L>", function()
      ddu.do_action("checkItems")
    end, km_opts.bnw)
    -- "." --
    vim.keymap.set('n', '.', function()
      ddu.do_action("toggleHidden")
    end, km_opts.ebsw)
    -- /action --
  end -- /common keymaps

  ------------------------------
  -- ff keymap
  ------------------------------
    ------------------------------
    -- normal keymap
    ------------------------------

  local ddu_ff_keymap = vim.api.nvim_create_augroup("ddu_ff_keymap", { clear = true })
  vim.api.nvim_create_autocmd("filetype", {
    group = ddu_ff_keymap,
    pattern = "ddu-ff",
    callback = function()
      -- common --
      common_keymap()
      -- selection --
      keymap.set("n", "l", function()
        fn["ddu#ui#do_action"]("toggleSelectItem")
      end, km_opts.bnw)
      keymap.set("n", "L", function()
        fn["ddu#ui#do_action"]("clearSelectAllItems")
      end, km_opts.bnw)
      keymap.set("n", "*", function()
        fn["ddu#ui#do_action"]("toggleSelectItem")
      end, km_opts.bnw)
      -- /selection --
      -- shift cursor --
      keymap.set("n", "J", function()
        -- 選択開始の状態 --
        if b.SelectStartLine == 0 or b.SelectStartLine == nil then
          b.SelectStartLine = fn["getpos"](".")[2]
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorNext")
          ddu.do_action("toggleSelectItem")
        -- カーソルが選択開始より上にいる --
        elseif fn["getpos"](".")[2] < b.SelectStartLine then
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorNext")
        -- カーソルが選択開始以下にいる --
        elseif b.SelectStartLine <= fn["getpos"](".")[2] then
          ddu.do_action("cursorNext")
          ddu.do_action("toggleSelectItem")
        end
      end, km_opts.bnw)
      keymap.set("n", "K", function()
        -- 選択開始 --
        if b.SelectStartLine == 0 or b.SelectStartLine == nil then
          b.SelectStartLine = fn["getpos"](".")[2]
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorPrevious")
          ddu.do_action("toggleSelectItem")
        -- カーソルが選択開始以上にいる --
        elseif fn["getpos"](".")[2] <= b.SelectStartLine then
          ddu.do_action("cursorPrevious")
          ddu.do_action("toggleSelectItem")
        -- カーソルが選択開始より下にいる --
        elseif b.SelectStartLine < fn["getpos"](".")[2] then
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorPrevious")
        end
      end, km_opts.bnw)
      -- /shift cursor --

      -- filtering --
      keymap.set("n", "i", function()
        fn["ddu#ui#do_action"]("openFilterWindow")
      end, km_opts.bnw)

      -- "p" preview --
      keymap.set("n", "p", function()
        fn["ddu#ui#do_action"]("toggleAutoAction")
      end, km_opts.bnw)

    end,
  }) -- /ff normal keymaps --

  vim.api.nvim_create_autocmd("filetype", {
    group = ddu_ff_keymap,
    pattern = "ddu-ff-filter",
    ------------------------------
    -- insert(filtering) keymap
    ------------------------------
    callback = function()
      keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], km_opts.bnw)
      keymap.set({ "n", "i" }, "<C-C>", function()
        fn["ddu#ui#do_action"]("quit")
      end, km_opts.bnw)
      keymap.set("n", "<Esc>", function()
        fn["ddu#ui#do_action"]("quit")
      end, km_opts.bnw)
    end,
  })
      -- /ff filtering keymaps --
    -- /ff keymaps --

    -- filer keymaps --
  local ddu_filer_keymap = vim.api.nvim_create_augroup("ddu_filer_keymap", { clear = true })
  vim.api.nvim_create_autocmd("filetype", {
    group = ddu_filer_keymap,
    pattern = "ddu-filer",
    callback = function()
      -- common --
      common_keymap()
      -- "w" --
      keymap.set("n", "w", function()
        fn["ddu#ui#do_action"]("itemAction", { name = "window_choose" })
      end, km_opts.bnw)
      -- /open --

      -- selection --
      -- "l" --
      keymap.set("n", "l", function()
        fn["ddu#ui#do_action"]("toggleSelectItem")
      end, km_opts.bnw)
      -- "L" --
      keymap.set("n", "L", function()
        fn["ddu#ui#do_action"]("clearSelectAllItems")
      end, km_opts.bnw)
      -- "*" --
      keymap.set("n", "*", function()
        fn["ddu#ui#do_action"]("toggleAllItems")
      end, km_opts.bnw)
      -- /selection --
      -- shift cursor --
      keymap.set("n", "J", function()
        -- 選択開始の状態 --
        if b.SelectStartLine == 0 or b.SelectStartLine == nil then
          b.SelectStartLine = fn["getpos"](".")[2]
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorNext")
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorNext")
        -- カーソルが選択開始より上にいる --
        elseif fn["getpos"](".")[2] < b.SelectStartLine then
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorNext")
        -- カーソルが選択開始以下にいる --
        elseif b.SelectStartLine <= fn["getpos"](".")[2] then
          ddu.do_action("cursorNext")
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorNext")
        end
      end, km_opts.bnw)
      keymap.set("n", "K", function()
        -- 選択開始 --
        if b.SelectStartLine == 0 or b.SelectStartLine == nil then
          b.SelectStartLine = fn["getpos"](".")[2]
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorPrevious")
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorPrevious")
        -- カーソルが選択開始以上にいる --
        elseif fn["getpos"](".")[2] <= b.SelectStartLine then
          ddu.do_action("cursorPrevious")
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorPrevious")
        -- カーソルが選択開始より下にいる --
        elseif b.SelectStartLine < fn["getpos"](".")[2] then
          ddu.do_action("toggleSelectItem")
          ddu.do_action("cursorPrevious")
        end
      end, km_opts.bnw)
      -- /shift cursor --

      -- "i" --
      keymap.set("n", "i", function()
        local path = fn["fnamemodify"](fn["input"]("cwd: ", b.ddu_ui_filer_path, "file"), ":p")
          fn["ddu#ui#do_action"]("itemAction",
              {
                name = "narrow",
                params = {
                  path = path,
                }
              }
            )
        fn["ddu#ui#do_action"]("cursorNext")
      end, km_opts.bnw)

      -- "p" preview --
      keymap.set("n", "p", function()
        fn["ddu#ui#do_action"]("togglePreview")
      end, km_opts.bnw)

      -- "f" --
      keymap.set("n", "f",function()
        local path = fn["ddu#ui#get_item"]()["action"]["path"]
        fn["ddu#ui#do_action"]("quit")
        fn["ddu#start"]({
          name = "file_rec",
          sourceOptions = {
            _ = {
              path = path
            },
          }
        })
      end, km_opts.bnw)

      -- "^" --
      keymap.set("n", "^", function()
        ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand(g.my_initvim_path) } })
      end, km_opts.bnw)
      -- "\" --
      keymap.set("n", ",", function()
        ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand("~/dotfiles/mydotfiles") } })
      end, km_opts.bnw)
      -- "|" --
      keymap.set("n", "|", function()
        ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand("~/repos") } })
      end, km_opts.bnw)
      -- "~" --
      keymap.set("n", "~", function()
        ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand("~") } })
      end, km_opts.bnw)
      -- "=" --
      keymap.set("n", "=", function()
        ddu.do_action("itemAction", { name = "narrow", params = { path = fn["getcwd"]() } })
      end, km_opts.bnw)
      -- <BS> --
      keymap.set("n", "<BS>", function()
        ddu.do_action("itemAction", { name = "narrow", params = { path = ".." } })
      end, km_opts.bnw)

    end,
  })
    -- /filer keymaps --
  -- /ddu keymaps --
end

return M
