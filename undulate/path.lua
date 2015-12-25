-- Path parsing utilities

local path = {}

function path.split(file)
	local buffer = {}
	local current = ""

	for piece in file:gmatch("[^\\/]+") do
		table.insert(buffer, piece)
	end

	if (#buffer == 0) then
		return "."
	end

	return buffer
end

function path.unsplit(file)
	return table.concat(file, "/")
end

function path.join(...)
	return path.normalize(table.concat({...}, "/"))
end

function path.normalize(file)
	local split = path.split(file)
	local out = {}

	for i = 1, #split do
		local v = split[i]

		if (v == "." or v == "") then
			-- nothing
		elseif (v == "..") then
			out[#out] = nil
		else
			table.insert(out, v)
		end
	end

	if (#out == 0) then
		return "."
	end

	return table.concat(out, "/")
end

return path