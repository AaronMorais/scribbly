// var yql = require("yql");

// var text = "transformers movie";
// yql.exec("select * from contentanalysis.analyze where text='" + text + "';", function(data) {
// 	var entities = data.query.results.entities.entity;
// 	var categories = data.query.results.yctCategories.yctCategory;
// 	console.log(entities);
// 	console.log(categories);
// });

var express = require("express");

var app = express();

app.get("/save_note", require("save_note"));