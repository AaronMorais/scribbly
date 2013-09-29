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
    }
};
