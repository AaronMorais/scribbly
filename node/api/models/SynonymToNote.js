/**
 * SynonymToNote
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 *
 */

module.exports = {

    attributes: {
        synonym: {
            type: "string",
            required: true
        },
        note: {
            type: "int",
            required: true
        },
        toJSON: function() {
            var obj = this.toObject();
            obj.note = parseInt(obj.note);
            return obj;
        }
    },

    createIfNotExists: function(synonym, note) {
        SynonymToNote.findOne({
            synonym: synonym,
            note: note
        }).done(function(err, stn) {
            if (!stn) {
                SynonymToNote.create({synonym: synonym, note: note}).done(function() {});
            }
        });
    }

};
