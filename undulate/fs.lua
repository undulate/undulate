-- A filesystem wrapper

local ok, lfs = pcall(require, "lfs")

if (lfs) then
	return require("undulate.fs.lfs")
end

local ok, love = pcall(require, "love")

if (love) then
	return require("undulate.fs.love")
end

if (jit) then
	return require("undulate.fs.luajit")
end

error("Undulate requires either LFS or LuaJIT!")