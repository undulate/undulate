#!/bin/env luajit

local args = {...}
local target = args[1]
local command = args[2]

if (not command) then
	command = "help"
elseif (command == "und") then
	command = "help"
end

local commandMap = {
	["-h"] = "help",
	["-v"] = "version"
}

if (commandMap[command]) then
	command = commandMap[command]
end

-- Hooray for globals!
CLI_COMMAND = command
CLI_TARGET = target

local result, err = pcall(require, "cli." .. command)
if (not result) then
	print(err)
	print("Unknown und command '" .. args[2] .. "'")
	os.exit(1)
end