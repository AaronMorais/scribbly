var config = require("./config.js");

var saveNote = function(req, res) {
    var text = req.param("text");
    var id = req.param("id");

    if (!text) res.send("");

    res.type("json");

    // Update
    if (id) {
        config.query("UPDATE notes SET text = " + text + " WHERE id = " + id +
            " AND time_updated = CURDATE();",
        function(err, rows, fields){
            if (err) throw err;

            res.send({
                id: id,
                text: text,
                categories: [1, 2, 3]
            });
        });
    } else {
        config.query("INSERT INTO notes(text, time_created, time_updated)" + 
            " VALUES(" + text + ", CURDATE(), CURDATE());");
        config.query("SELECT LAST_INSERT_ID();");
    }
}

module.exports = saveNote;