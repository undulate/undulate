local lfs = require("lfs")

local fs = {}

function fs.getWorkingDirectory()
	return lfs.currentdir()
end

function fs.isDirectory(dir)
	local stat = lfs.attributes(dir, "mode")

	return stat == "directory"
end

function fs.isFile(file)
	local stat = lfs.attributes(file, "mode")

	return stat == "file"
end

return fs