/**
 * Category
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 *
 */

var util = require("util");

module.exports = {
    attributes: {
        name: {
            type: "STRING",
            required: true
        },
        score: {
            type: "INT",
            required: true
        },
        viewCount: {
            type: "INT",
            defaultsTo: 0
        }
    },

    createIfNotExists: function(name) {
        Category.findOne({name: name}).done(function(err, category) {
            if (!category) {
                Category.create({name: name, score: 1}).done(function(err, ctg) {});
            }
        });
    },

    updateViewCount: function(id, viewCount) {
        console.log(id);
        Category.findOne(id).done(function(err, category) {
            category.viewCount = viewCount;
            category.save(function(){});
        });
    },

    updateScore: function(id, score) {
        Category.findOne(id).done(function(err, category) {
            category.score = Math.round(score);
            category.save(function(){});
        });
    }
};
