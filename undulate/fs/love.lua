error("NYI: love.filesystem support")

local fs = require("love.filesystem")

assert(pcall(love.filesystem.init, "."))
assert(pcall(love.filesystem.setSource, "C:\\"))