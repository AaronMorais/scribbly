/**
 * Note
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 *
 */

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
        }
    },

    getCategories: function(id, cb) {
        Note.findOne(id).done(function(err, note) {
            if (!note) {
                cb([]);
                return;
            }

            var numCategoriesLookedUp = 0;

            Category.find({
                or: [
                    {name: note.primaryCategory},
                    {name: note.secondaryCategory},
                    {name: note.tertiaryCategory}
                ]
            }).done(function(err, categories) {
                cb(categories);
            });

            // cb([note.primaryCategory, note.secondaryCategory, note.tertiaryCategory]);
        });
    }
};
