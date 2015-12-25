local json = require("undulate.json")
local fs = require("undulate.fs")
local path = require("undulate.path")

local undulate = {
	version = "0.1.0",
	installDirectory = installDirectory,
	json = json,
	fs = fs,
	path = path
}

function undulate.getUnduleFilePath(from)
	from = from or fs.getWorkingDirectory()
	from = path.normalize(from)

	local current = path.split(from)

	repeat
		local file = path.join(path.unsplit(current), "undule.json")

		if (fs.isFile(file)) then
			return file
		end
	until #cd == 0

	return nil
end

return undulate