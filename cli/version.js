"use strict";

const path = require("path");
const fs = require("fs");

let body = fs.readFileSync(path.resolve(__dirname, "../package.json"));
let contents = JSON.parse(body);

console.log(contents.version)