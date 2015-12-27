#!/usr/bin/env node
"use strict";

const commandMap = {
	"-h": "help",
	"-v": "version"
};

let args = process.argv;
let cmd = args[2];

if (!cmd) {
	cmd = "help";
}

if (commandMap[cmd]) {
	cmd = commandMap[cmd];
}

try {
	require("../cli/" + cmd);
} catch(e) {
	if (e.code === "MODULE_NOT_FOUND") {
		console.error(`Unknown command "${cmd}"; try "und help"`);
		return;
	}

	throw e;
}