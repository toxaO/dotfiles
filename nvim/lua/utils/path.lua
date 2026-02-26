local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt

local M = {}

function M.path2name(path)
  return path:match("([^/\\]+)[/\\]*$")
end

return M
