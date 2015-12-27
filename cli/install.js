"use strict";

let args = process.argv.splice(3);

let packages = args.filter(v => !v.startsWith("-"));

console.log("Install packages:\n\t" + packages.join("\n\t"));