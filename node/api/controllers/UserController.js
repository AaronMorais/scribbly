/**
 * UserController
 *
 * @module		:: Controller
 * @description	:: Contains logic for handling requests.
 */

module.exports = {

    create: function(req, res) {
        res.type("json");

        User.create({token: "test"}).done(function(err, user) {
            if (err) throw err;
            res.send(user);
        });

    }

};
