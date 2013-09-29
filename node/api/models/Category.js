/**
 * Category
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 *
 */

var util = require("util");
var yql = require("yql");

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
        },
        image: {
            type: "STRING"
        },

        toJSON: function() {
            var obj = this.toObject();
            obj.score = parseInt(obj.score);
            obj.viewCount = parseInt(obj.score);

            return obj;
        },
    },

    createIfNotExists: function(name) {
        Category.findOne({name: name}).done(function(err, category) {
            if (!category) {
                Category.create({name: name, score: 1}).done(function(err, ctg) {
                    // var tags = ctg.name.split(/\s+/).join(",").replace(",&", "");
                    // yql.exec("select * from flickr.photos.search where tags='" + tags + "' and sort='relevance' and media='photos' and api_key='649afbc21db07cfa8d0a625590d3c1d9'", function(resp) {
                    //     resp = resp.query;
                    //     if (!resp.results) {next(); return;}
                    //     if (!resp.results.photo) {next(); return;}
                    //     if (!resp.results.photo[0]) {next(); return;}
                    //     var photo = resp.results.photo[0];
                    //     ctg.image = "http://farm" + photo.farm + ".staticflickr.com/" + photo.server + "/" + photo.id + "_" + photo.secret + ".jpg";
                    //     ctg.save(function(){});
                    // });
                });
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
