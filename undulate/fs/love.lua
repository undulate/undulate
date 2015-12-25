local fs = require("love.filesystem")

assert(pcall(love.filesystem.init, "."))
assert(pcall(love.filesystem.setSource, "C:\\"))

local cwd = love.filesystem.getWorkingDirectory()
print(cwd)
print(#love.filesystem.getDirectoryItems("."))

for key, value in pairs(love.filesystem.getDirectoryItems(".")) do
	print(value)
end