"use strict";

const path = require("path");
const fs = require("fs");

let body = fs.readFileSync(path.resolve(__dirname, "../package.json"));
let contents = JSON.parse(body);

console.log("Undulate v" + contents.version);
console.log(
`Usage: und [command]
	version (-v): Output version and exit
	help (-h): Display this prompt
	init: Initialize a new project
`);