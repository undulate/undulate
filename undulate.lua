local loaders = package.searchers or package.loader

local json = (function()
	--[[
		FJSON: A small JSON implementation for Lua
	]]

	local parse = {}

	local config = {
		nan = nil,
		infinity = nil
	}

	local fjson = {
		version = "1.0.0",
		config = config
	}

	local function is_sequence(object)
		local meta = getmetatable(object)
		if (meta and meta.__json_sequence) then
			return true
		end

		if (#object == 0) then
			return false
		end

		for key, value in pairs(object) do
			if (type(key) ~= "number") then
				return false
			end
		end

		local last = 0
		for key in ipairs(object) do
			if (key ~= last + 1) then
				return false
			end

			last = key
		end

		return true
	end

	local function unescape_string(str)
		return (
			object
				:gsub("\\\"", "\"")
				:gsub("\\r", "\r")
				:gsub("\\n", "\n")
				:gsub("\\t", "\t")
				-- todo: unicode sequences
		)
	end

	local function escape_string(str)
		return "\"" .. (str
				:gsub("\"", "\\\"")
				:gsub("\r", "\\r")
				:gsub("\n", "\\n")
				:gsub("\t", "\\t")
			) .. "\""
	end

	local function escape(object, pretty, indent)
		indent = indent or 1

		local typeof = type(object)

		if (typeof == "table") then
			return fjson.encode(object, pretty, indent)
		elseif (typeof == "string") then
			return escape_string(object)
		elseif (typeof == "boolean") then
			return object and "true" or "false"
		elseif (typeof == "number") then
			return object
		elseif (typeof == "nil") then
			return "null"
		else
			return escape(tostring(object))
		end
	end

	function parse.root(parent)
		local first = parent:match("^%s*[%[{]")

		if (first == "{") then
			return parse.object(parent)
		elseif (first == "[") then
			return parse.list(parent)
		else
			error("invalid")
		end
	end

	function parse.object(parent, index)
		local out = {}
		local object = parent:match("%b{}", index)

		local i = 2
		while (true) do
			local start, finish = object:find("%b\"\":", i)

			if (not start) then
				break
			end

			local realkey = object:sub(start + 1, finish - 2)

			i = finish + 1

			local char
			while (true) do
				char = object:sub(i, i)
				if (char == "," or char:match("%s")) then
					i = i + 1
				else
					break
				end
			end

			if (char == "\"") then
				local value = object:match("%b\"\"", i)
				i = i + #value
				out[realkey] = unescape_string(value:sub(2, -2))
			elseif (char:match("[%d%.%-]")) then
				local value, len = parse.number(object, i)
				i = i + len
				out[realkey] = value
			elseif (char == "[") then
				local value, len = parse.list(object, i)
				i = i + len
				out[realkey] = value
			elseif (char == "{") then
				local value, len = parse.object(object, i)
				i = i + len
				out[realkey] = value
			else
				local value, len = parse.constant(object, i)
				i = i + len
				out[realkey] = value
			end
		end

		return out, #object
	end

	function parse.list(parent, index)
		local out = {}
		local list = parent:match("%b[]", index)

		local i = 2
		while i < #list do
			local char = list:sub(i, i)

			if (not char) then
				break
			end

			if (char == "," or char:match("%s")) then
				i = i + 1
			elseif (char == "\"") then
				local value = list:match("%b\"\"", i)
				i = i + #value
				table.insert(out, unescape_string(value:sub(2, -2)))
			elseif (char:match("[%d%.%-]")) then
				local value, len = parse.number(list, i)
				i = i + len
				table.insert(out, value)
			elseif (char == "[") then
				local value, len = parse.list(list, i)
				i = i + len
				table.insert(out, value)
			elseif (char == "{") then
				local value, len = parse.object(list, i)
				i = i + len
				table.insert(out, value)
			else
				local value, len = parse.constant(list, i)
				i = i + len
				table.insert(out, value)
			end
		end

		return out, #list
	end

	function parse.constant(parent, index)
		local value = parent:match("^%w+", index)

		if (value == "null") then
			return nil, 4
		elseif (value == "true") then
			return true, 4
		elseif (value == "false") then
			return false, 5
		end
	end

	function parse.number(parent, index)
		local value = parent:match("^[+%-]?%d+%.?%d*[eE]?[+%-]?%d*", index)

		if (value) then
			return tonumber(value), #value
		end
	end

	function fjson.encode(object, pretty, indent)
		indent = indent or 1
		if (pretty and type(pretty) ~= "string") then
			pretty = "\t"
		end

		local buffer = {}

		if (is_sequence(object)) then
			for i = 1, #object do
				table.insert(buffer, escape(object[i], pretty, indent))
			end

			local comma = ","

			if (pretty) then
				comma = ", "
			end

			return "[" .. table.concat(buffer, comma) .. "]"
		else
			local inline = ""
			local newline = ""
			local comma = ","
			local colon = ":"

			if (pretty) then
				inline = "\n" .. pretty:rep(indent - 1)
				newline = "\n" .. pretty:rep(indent)
				comma = ",\n" .. pretty:rep(indent)
				colon = ": "
			end

			for key, value in pairs(object) do
				table.insert(buffer, escape(tostring(key)) .. colon .. escape(value, pretty, indent + 1))
			end

			return "{" .. newline ..
				table.concat(buffer, comma) ..
				inline .. "}"
		end
	end

	function fjson.decode(object)
		return (parse.root(object))
	end

	return fjson
end)()

local function splitPath(path)
	local out = {}

	for entry in path:gmatch("[^.]+") do
		table.insert(out, entry)
	end

	return out
end

local function getUndule(folder)
	local file = folder .. "/undule.json"
	local handle, err = io.open(file, "rb")

	if (not handle) then
		return nil
	end

	local body  = io:read("*a")
	handle:close()

	return json.decode(body)
end

local function loadFile(file)
	local handle = assert(io.open(file, "rb"))
	local body = handle:read("*a")
	handle:close()

	return (load or loadstring)(file)
end

local function loader(path)
	local split = splitPath(path)
	local handle = io.open("undules/")

	local loadPath = table.remove(split, 1)

	if (#split > 0) then
		loadPath = loadPath .. table.concat(split, "/")
	else
		local undule = getUndule(loadPath)
		if (undule.main) then
			loadPath = loadPath .. "/" .. undule.main
		else
			loadPath = loadPath .. "/init"
		end
	end

	if (not loadPath:match("%.lua$")) then
		loadPath = loadPath .. ".lua"
	end

	print(loadPath)

	return loadFile(loadPath)
end

table.insert(package.searchers or package.loaders, loader)