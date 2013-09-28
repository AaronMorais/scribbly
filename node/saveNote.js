var config = require("./config.js");

var saveNote = function(req, res) {
    var text = req.param("text");
    var id = req.param("id");

    if (!text) return;

    // Update
    if (id) {
        
    }
}