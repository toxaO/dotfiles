local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local M = {}

M.fs = require("utils.fs")
M.io = require("utils.io")
M.env = require("utils.env")
M.window = require("utils.window")
M.depends = require("utils.depends")
M.try = require("utils.try")
M.path = require("utils.path")

-- key exists in array
function M.isContainsInArray(set, key)
  return set[key] ~= nil
end

-- 疑似trycatch
M.try_catch = M.try.try_catch

-- 型チェック
-- super thx for @paulcuth!!: https://gist.github.com/paulcuth/1270733
function M.instance_of(subject, super)

	super = tostring(super)
	local mt = getmetatable(subject)

	while true do
		if mt == nil then return false end
		if tostring(mt) == super then return true end

		mt = getmetatable(mt)
	end
end

return M

