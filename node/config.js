var mysql      = require('mysql');
var connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'hackathon',
  database: 'hackathon'
});

var query = function(query, cb) {
    connection.connect();
    connection.query(query, cb);
    connection.end()
}

exports.query = query;