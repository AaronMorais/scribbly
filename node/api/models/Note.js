/**
 * Note
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 *
 */

var _ = require("underscore");

module.exports = {
    attributes: {
        text: {
            type: 'TEXT',
            required: true
        },
        user: {
            type: 'INT',
            required: true
        },
        primaryCategory: {
            type: "string",
            required: true
        },
        secondaryCategory: {
            type: "string",
            required: true
        },
        tertiaryCategory: {
            type: "string",
            required: true
        },
        toJSON: function() {
            var obj = this.toObject();
            obj.user = parseInt(obj.user);
            return obj;
        }
    },

    getCategories: function(id, cb) {
        Note.findOne(id).done(function(err, note) {
            if (!note) {
                cb([]);
                return;
            }

            var numCategoriesLookedUp = 0;

            Category.find().done(function(err, categories) {
                categories = _.filter(categories, function(category) {
                    return  category.name == note.primaryCategory ||
                            category.name == note.secondaryCategory ||
                            category.name == note.tertiaryCategory
                });
                cb(categories);
            });

            // cb([note.primaryCategory, note.secondaryCategory, note.tertiaryCategory]);
        });
    }
};
