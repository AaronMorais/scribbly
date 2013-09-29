/**
 * NoteController
 *
 * @module		:: Controller
 * @description	:: Contains logic for handling requests.
 */
var util = require("util");
var yql = require("yql");
var _ = require('underscore');
var request = require("request");

module.exports = {

    view: function(req, res) {
        res.type("json");

        id = req.param('id');
        userToken = req.param('token');

        if (!id || !userToken) {res.send({error: "Invalid request!"}); return;}

        Note.getCategories(id, function(categories) {
            for (var x in categories) {
                Category.updateViewCount(categories[x].id, parseInt(categories[x].viewCount)+1);
            }

            Category.find().done(function(err, allCategories) {
                var total = _.reduce(allCategories, function(total, category) {
                    return total + parseInt(category.viewCount);
                }, 3);

                for (var x in allCategories) {
                    Category.updateScore(allCategories[x].id, (allCategories[x].viewCount / total) * 100);
                }

                if (categories.length > 0)
                    res.send({success: "Updated category scores."});
                else {
                    res.send({error: "That note does not exist."});
                }
            });
        });
    },

    save: function(req, res) {
        res.type("json");

        text = req.param('text');
        id = req.param('id');
        userToken = req.param('token');

        if (!text || !userToken) {res.send({error: "Invalid request!"}); return;}

        User.findOne({
            token: userToken
        }).done(function(err, user) {
            if (err) console.log(util.inspect(err, false, null));

            if (!user) {res.send({error: "Invalid token!"}); return;}

            var noteCategories = ["Uncategorized"];
            yql.exec("select * from contentanalysis.analyze " + "where text='" + text + "';", function(data){
                var results = data.query.results;
                if (results) {
                    var categories = results.yctCategories;
                    if (categories) {
                        categories = categories.yctCategory;
                        console.log(util.inspect(categories, false, null));
                        if (!categories[0]) {
                            noteCategories = [categories.content];
                        } else {
                            noteCategories = [];
                            for (var x in categories) {
                                noteCategories.push(categories[x].content);
                            }
                        }

                    }
                }

                for (var x in noteCategories) {
                    Category.createIfNotExists(noteCategories[x]);
                }

                if (id) {
                    Note.findOne(id).done(function(err, note) {
                        if (err) console.log(util.inspect(err, false, null));

                        note.text = text;
                        note.primaryCategory = noteCategories[0] || "Uncategorized";
                        note.secondaryCategory = noteCategories[1] || "Uncategorized";
                        note.tertiaryCategory = noteCategories[2] || "Uncategorized";
                        note.save(function() {});

                        res.send(note);
                        updateSynonyms(note.id, note.text);
                    });
                } else {
                    Note.create({
                        text: text,
                        user: user.id,
                        primaryCategory: noteCategories[0] || "Uncategorized",
                        secondaryCategory: noteCategories[1] || "Uncategorized",
                        tertiaryCategory: noteCategories[2] || "Uncategorized"
                    }).done(function(err, note) {
                        if (err) console.log(util.inspect(err, false, null));
                        
                        res.send(note);
                        updateSynonyms(note.id, note.text);
                    });
                }
            });            
        });

    }

};


var updateSynonyms = function(noteID, text) {
    var words = text.split(/\s+/);

    for (var x in words) {
        words[x] = words[x].replace(/\W/g, '')

        SynonymToNote.createIfNotExists(words[x], noteID);
        request('http://words.bighugelabs.com/api/2/d4cdac4c477579e2e31e0d2b90b8e903/' + words[x] + '/json', function(err, resp, body) {
            var body = JSON.parse(body);
            var synonyms = [];
            if (body.noun) synonyms = _.union(synonyms, body.noun.syn);
            if (body.verb) synonyms = _.union(synonyms, body.verb.syn);


            for (var y in synonyms) {
                SynonymToNote.createIfNotExists(synonyms[y], noteID);
            }
        });
    }
}