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
    }

};
