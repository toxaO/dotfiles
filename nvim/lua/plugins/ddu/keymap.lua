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
  local function current_item_action(params)
    fn["ddu#ui#do_action"]("clearSelectAllItems")
    vim.schedule(function()
      fn["ddu#ui#do_action"]("itemAction", params)
    end)
  end

  local function cursor_item_edge(direction)
    local action = direction == "top" and "cursorPrevious" or "cursorNext"
    fn["ddu#ui#do_action"](action, { count = 999999, loop = false })
  end

  local function cursor_source(direction)
    local items = fn["ddu#ui#get_items"]()
    local current = fn["ddu#ui#get_item"]()
    local source_name = current and current.__sourceName or nil
    local cursor_line = fn.line(".")
    if type(items) ~= "table" or source_name == nil then
      return
    end

    if direction == "next" then
      for i = cursor_line + 1, #items do
        if items[i].__sourceName ~= source_name then
          fn["ddu#ui#do_action"]("cursorNext", { count = i - cursor_line, loop = false })
          return
        end
      end
    else
      for i = cursor_line - 1, 1, -1 do
        if items[i].__sourceName ~= source_name then
          while i > 1 and items[i - 1].__sourceName == items[i].__sourceName do
            i = i - 1
          end
          fn["ddu#ui#do_action"]("cursorPrevious", { count = cursor_line - i, loop = false })
          return
        end
      end
    end
  end

  local function common_keymap()
    -- <CR> open --
    keymap.set("n", "<CR>", function()
      if ddu.item.is_tree() then
        ddu.do_action("itemAction", { name = "narrow" })
        fn["ddu#ui#do_action"]("cursorNext")
        return
      end
      current_item_action({ name = "open", params = { command = "tabe" } })
    end, km_opts.bnw)

    -- buffer open --
    keymap.set("n", "b", function()
      current_item_action({ name = "open", params = { command = "edit" }, quit = true })
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
    keymap.set("n", "{", function()
      cursor_source("previous")
    end, km_opts.bnw)
    keymap.set("n", "}", function()
      cursor_source("next")
    end, km_opts.bnw)
    keymap.set("n", "<Home>", function()
      cursor_item_edge("top")
    end, km_opts.bnw)
    keymap.set("n", "<End>", function()
      cursor_item_edge("bottom")
    end, km_opts.bnw)
    -- /cursor --

    -- "v" vsplit --
    keymap.set("n", "v", function()
      return ddu.item.is_tree() and ddu.do_action("expandItem")
      or current_item_action({ name = "open", params = { command = "vsplit" } })
    end, km_opts.bnw)
    -- "h" horizontal split --
    keymap.set("n", "h", function()
      return ddu.item.is_tree() and ddu.do_action("expandItem")
      or current_item_action({ name = "open", params = { command = "split" } })
    end, km_opts.bnw)
    -- "t" tabnew --
    keymap.set("n", "t", function()
      current_item_action({ name = "open", params = { command = "tabe" } })
    end, km_opts.bnw)

    -- "w" window choose --
    keymap.set("n", "w", function()
      current_item_action({ name = "window_choose" })
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

  local function reference_keymap()
    for slot = 1, 4 do
      local current_slot = slot
      keymap.set("n", "m<F" .. slot .. ">", function()
        ddu.do_action("itemAction", { name = "set_reference_dir_" .. current_slot })
      end, km_opts.bnw)
    end
  end

  local function preview_scroll_keymap()
    keymap.set("n", "<C-e>", function()
      ddu.do_action("previewExecute", { command = 'execute "normal! \\<C-e>"' })
    end, km_opts.bnw)
    keymap.set("n", "<C-y>", function()
      ddu.do_action("previewExecute", { command = 'execute "normal! \\<C-y>"' })
    end, km_opts.bnw)
  end

  local function remember_ff_start_options(options)
    local start_options = vim.deepcopy(options)
    start_options.input = nil
    vim.g.ddu_ff_last_start_options = start_options
  end

  local function switch_ff_source(sources, source_params)
    local options = {
      sources = sources,
      sourceParams = source_params or {},
    }
    remember_ff_start_options(options)
    ddu.do_action("updateOptions", options)
    ddu.do_action("redraw", { method = "refreshItems" })
  end

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
      reference_keymap()
      preview_scroll_keymap()
      keymap.set("n", "e", function()
        current_item_action({ name = "open_filer" })
      end, km_opts.bnw)
      keymap.set("n", "f", function()
        ddu.do_action("openFfFromSelectedFileItems")
      end, km_opts.bnw)
      keymap.set("n", "g", function()
        ddu.do_action("itemAction", { name = "grep" })
      end, km_opts.bnw)
      keymap.set("n", "Q", function()
        ddu.do_action("itemAction", { name = "quickfix" })
      end, km_opts.bnw)
      keymap.set("n", "sb", function()
        switch_ff_source({ { name = "buffer" } })
      end, km_opts.bnw)
      keymap.set("n", "sa", function()
        switch_ff_source({ { name = "arglist" } })
      end, km_opts.bnw)
      keymap.set("n", "sf", function()
        local options = {
          sources = { { name = "file_external" } },
          sourceOptions = {
            _ = {
              path = fn["getcwd"](-1, 0),
            },
          },
          sourceParams = {
            file_external = ddu_action.build_file_external_params(),
          },
        }
        remember_ff_start_options(options)
        ddu.do_action("updateOptions", options)
        ddu.do_action("redraw", { method = "refreshItems" })
      end, km_opts.bnw)
      keymap.set("n", "sd", function()
        local options = {
          sources = { { name = "file_external" } },
          sourceOptions = {
            _ = {
              path = fn["getcwd"](-1, 0),
            },
          },
          sourceParams = {
            file_external = ddu_action.build_directory_external_params(),
          },
        }
        remember_ff_start_options(options)
        ddu.do_action("updateOptions", options)
        ddu.do_action("redraw", { method = "refreshItems" })
      end, km_opts.bnw)
      keymap.set("n", "sr", function()
        switch_ff_source({ { name = "mr" } }, { mr = { kind = "mru" } })
      end, km_opts.bnw)
      keymap.set("n", "sR", function()
        local options = {
          sources = { { name = "file_external" } },
          sourceParams = {
            file_external = ddu_action.build_recent_directory_params(),
          },
        }
        remember_ff_start_options(options)
        ddu.do_action("updateOptions", options)
        ddu.do_action("redraw", { method = "refreshItems" })
      end, km_opts.bnw)
      keymap.set("n", "sp", function()
        local options = {
          sources = { { name = "file_external" } },
          sourceOptions = {
            _ = {
              path = fn["expand"](ddu_action.project_root()),
            },
          },
          sourceParams = {
            file_external = ddu_action.build_file_external_params(),
          },
        }
        remember_ff_start_options(options)
        ddu.do_action("updateOptions", options)
        ddu.do_action("redraw", { method = "refreshItems" })
      end, km_opts.bnw)
      keymap.set("n", "sg", function()
        local options = {
          sources = { { name = "file_external" } },
          sourceOptions = {
            _ = {
              path = fn["expand"](ddu_action.project_root()),
            },
          },
          sourceParams = {
            file_external = {
              cmd = {
                "git",
                "ls-files",
                "-co",
                "--exclude-standard",
              },
            },
          },
        }
        remember_ff_start_options(options)
        ddu.do_action("updateOptions", options)
        ddu.do_action("redraw", { method = "refreshItems" })
      end, km_opts.bnw)
      -- selection --
      keymap.set("n", "l", function()
        fn["ddu#ui#do_action"]("toggleSelectItem")
      end, km_opts.bnw)
      keymap.set("n", "L", function()
        fn["ddu#ui#do_action"]("clearSelectAllItems")
      end, km_opts.bnw)
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
      keymap.set("n", "/", function()
        fn["ddu#ui#do_action"]("openFilterWindow")
      end, km_opts.bnw)
      keymap.set("n", "<C-g>", function()
        ddu.do_action("editRgGlobs")
      end, km_opts.bnw)

      -- "p" preview --
      keymap.set("n", "p", function()
        fn["ddu#ui#do_action"]("toggleAutoAction")
      end, km_opts.bnw)

      -- ",x" toggle temporary rg extension ignore --
      keymap.set("n", ",x", function()
        ddu.do_action("toggleRgExcludeExtension")
      end, km_opts.bnw)
      -- ",r" clear temporary rg extension ignores --
      keymap.set("n", ",r", function()
        ddu.do_action("clearRgExcludeExtensions")
      end, km_opts.bnw)
      -- ",X" select extension from visible rg result --
      keymap.set("n", ",X", function()
        ddu.do_action("selectRgExcludeExtensionFromVisibleItems")
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
      reference_keymap()
      preview_scroll_keymap()
      -- "w" --
      keymap.set("n", "w", function()
        current_item_action({ name = "window_choose" })
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

      keymap.set("n", "<PageUp>", function()
        fn["ddu#ui#do_action"]("cursorTreeTop")
      end, km_opts.bnw)
      keymap.set("n", "<PageDown>", function()
        fn["ddu#ui#do_action"]("cursorTreeBottom")
      end, km_opts.bnw)

      -- "/" filter visible items --
      keymap.set("n", "/", function()
        fn["ddu#ui#do_action"]("openFilterWindow")
      end, km_opts.bnw)
      keymap.set("n", "<C-g>", function()
        ddu.do_action("editRgGlobs")
      end, km_opts.bnw)

      keymap.set("n", "Q", function()
        ddu.do_action("itemAction", { name = "quickfix" })
      end, km_opts.bnw)
      keymap.set("n", "g", function()
        ddu.do_action("itemAction", { name = "grep" })
      end, km_opts.bnw)

      -- "p" preview --
      keymap.set("n", "p", function()
        fn["ddu#ui#do_action"]("togglePreview")
      end, km_opts.bnw)

      keymap.set("n", "f",function()
        ddu.do_action("openFfFromSelectedFileItems")
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
