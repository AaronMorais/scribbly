/**
 * CategoryController
 *
 * @module		:: Controller
 * @description	:: Contains logic for handling requests.
 */

// var lookupNotes = function(noteIDs, cb, idx, notes) {
//     notes = notes || [];
//     idx = idx || noteIDs.length-1;

//     if (idx == -1) {
//         cb(notes);
//         return;
//     }

//     Note.findOne(noteIDs[idx]).done(function(err, note) {
//         notes.push(note);
//         lookupNotes(noteIDs, cb, idx-1, notes);
//     });
// }

var _ = require("underscore");

module.exports = {
    notes: function(req, res) {
        res.type("json");

        var name = req.param('name');
        var userToken = req.param('token');

        if (!name || !userToken) {res.send({error: "Invalid request!"}); return;}

        User.findOne({
            token: userToken
        }).done(function(err, user) {
            if (err) console.log(util.inspect(err, false, null));

            if (!user) {res.send({error: "Invalid token!"}); return;}
            Note.find({
                user: user.id
            }).done(function(err, notes) {
                res.send(_.filter(notes, function(note) {
                    return  note.primaryCategory == name || 
                            note.secondaryCategory == name ||
                            note.tertiaryCategory == name
                }));
            });
        });
    },

    all: function(req, res) {
        res.type("json");

        var userToken = req.param('token');

        if (!userToken) {res.send({error: "Invalid request!"}); return;}

        var cats = [];
        var finished = function() {
            res.send(cats);
        };

        User.findOne({
            token: userToken
        }).done(function(err, user) {
            if (err) console.log(util.inspect(err, false, null));

            if (!user) {res.send({error: "Invalid token!"}); return;}

            Category.find().done(function(err, categories) {
                for (var x in categories) {
                    (function(ctgry, idx) {
                        User.hasNoteInCategory(user.id, categories[x].name, function(has) {
                            if (has) {
                                cats.push(ctgry);
                            }

                            if (idx == categories.length-1) {
                                finished();
                            }
                        });
                    })(categories[x], x)
                }

                if (categories.length == 0) {
                    finished();
                }
            });
        });
    },

};
