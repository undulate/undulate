"use strict";

const path = require("path");
const readline = require("readline");
const fs = require("fs");

const ROOT = path.resolve(__dirname, "..");

let args = process.argv.splice(3);
let target = args[0] || ".";
target = path.resolve(process.cwd(), target);

let rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
});

function question(text, fallback) {
	if (fallback == null) {
		fallback = "";
	}

	let fallbackText = fallback ? ` (${fallback})` : "";

	return new Promise((resolve, reject) => {
		rl.question(`${text}${fallbackText}: `, v => {
			resolve(v || fallback);
		});
	});
}

function queryField(data, name, fallback, text) {
	return question(text || name, fallback)
		.then(v => {
			data[name] = v;

			return v;
		});
}

function queryFields(fields) {
	let last = Promise.resolve();

	for (let field of fields) {
		last = last.then(() => queryField(...field));
	}

	return last;
}

function writeFile(path, data) {
	return new Promise((resolve, reject) => {
		fs.writeFile(path, data, (err) => {
			if (err) {
				console.error(err);
				reject(err);
				return;
			}

			resolve();
		});
	});
}

function readFile(path) {
	return new Promise((resolve, reject) => {
		fs.readFile(path, "utf8", (err, body) => {
			if (err) {
				console.error(err);
				reject(err);
				return;
			}

			resolve(body);
		});
	})
}

function mkdir(path) {
	return new Promise((resolve, reject) => {
		fs.mkdir(path, (err) => {
			resolve();
		});
	});
}

console.log("target:", target);

let leaf = path.parse(target).base;

let data = {};

queryFields([
	[data, "name", leaf],
	[data, "version", "1.0.0"],
	[data, "description"],
	[data, "license", "MIT"]
])
	.then(() => {
		rl.close();

		data.dependencies = {};

		let body = JSON.stringify(data, null, 2);
		return writeFile(path.resolve(target, "undule.json"), body);
	})
	.then(() => {
		return readFile(path.resolve(ROOT, "runtime.lua"))
			.then(body => {
				return writeFile(path.resolve(target, "undulate.lua"), body);
			});
	})
	.then(() => {
		return mkdir(path.resolve(target, "undules"));
	})
	.then(() => {
		console.log("DONE!");
	});