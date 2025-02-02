local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

local augroup = api.nvim_create_augroup -- Create/get autocommand group
local autocmd = api.nvim_create_autocmd -- Create autocommand

local patch_global=vim.fn["ddc#custom#patch_global"]

local M = {}

function M.setup()
  augroup("ddc_keymap", { clear = true })
  autocmd("InsertEnter", {
    group = ddc_keymap,

    callback = function()

      keymap.set({ "i" }, "<C-n>",
      [[(pum#visible() ? '' : ddc#map#manual_complete()) . pum#map#select_relative(+1)]],
      km_opts.en)

      keymap.set({ "i" }, "<C-p>",
      [[(pum#visible() ? '' : ddc#map#manual_complete()) . pum#map#select_relative(-1)]],
      km_opts.en)

      keymap.set({ "i" }, "<C-y>",
      [[<Cmd>call pum#map#confirm()<CR>]], km_opts.n)

      keymap.set({ "i" }, "<C-e>",
      [[<Cmd>call pum#map#cancel()<CR>]], km_opts.n)

      keymap.set({ "i" }, "<PageDown>",
      [[<Cmd>call pum#map#insert_relative_page(+1)<CR>]], km_opts.n)

      keymap.set({ "i" }, "<PageUp>",
      [[<Cmd>call pum#map#insert_relative_page(-1)<CR>]], km_opts.n)

      keymap.set({ "i" }, "<CR>", function()
        if fn["pum#entered"]() then
          return "<Cmd>call pum#map#confirm()<CR>" or "<CR>"
        else
          return "<CR>"
        end
      end, km_opts.en)

      keymap.set({ "i" }, "<C-m>", function()
        if fn["pum#visible"]() then
          return "<Cmd>call ddc#map#manual_complete()<CR>"
        else
          return "<C-m>"
        end
      end, km_opts.en)

      --keymap.set({ "i", "s" }, "<C-l>", function()
      --  return fn["vsnip#available"](1) == 1 and "<Plug>(vsnip-expand-or-jump)" or "<C-l>"
      --end, { expr = true, noremap = false })
      --keymap.set({ "i", "s" }, "<Tab>", function()
      --  return fn["vsnip#jumpable"](1) == 1 and "<Plug>(vsnip-jump-next)" or "<Tab>"
      --end, { expr = true, noremap = false })
      --keymap.set({ "i", "s" }, "<S-Tab>", function()
      --  return fn["vsnip#jumpable"](-1) == 1 and "<Plug>(vsnip-jump-prev)" or "<S-Tab>"
      --end, { expr = true, noremap = false })
      --keymap.set({ "n", "s" }, "<s>", [[<Plug>(vsnip-select-text)]], { expr = true, noremap = false })
      --keymap.set({ "n", "s" }, "<S>", [[<Plug>(vsnip-cut-text)]], { expr = true, noremap = false })
    end,
  })
end

return M
