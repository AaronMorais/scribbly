/**
 * User
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 *
 */

var bcrypt = require("bcrypt");

module.exports = {

    attributes: {
        token: "STRING"
    },

    beforeCreate: function(values, next) {
        bcrypt.genSalt(10, function(err, salt) {
            bcrypt.hash((Math.random() * 10000000000000 + 10000000).toString(36), salt, function(err, hash) {
                values.token = hash;
                next();
            });
        });
    },

    hasNoteInCategory: function(id, categoryName, cb) {
        var calledCB = false;
        User.findOne(id).done(function(err, user) {
            Note.find({user: user.id}, function(err, notes) {
                for (var x in notes) {
                    Note.getCategories(notes[x].id, function(categories) {
                        for (var y in categories) {
                            if (categoryName == categories[y].name) {
                                if (!calledCB) {
                                    calledCB = true;
                                    cb(true);
                                }
                                return;
                            }
                        }
                    });
                }
            });
        });
        if (!calledCB)
            cb(false);
    }

};
