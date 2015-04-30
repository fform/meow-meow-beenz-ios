var Parse = require('parse').Parse;
var _ = require('underscore');
var async = require('async');
var fs = require('fs');
var config = require('./config.json');
var imports = {
	'users': require('./import/_User.json').results,
	'ratings': require('./import/Ratings.json').results
};

var env = "dev";


Parse.initialize(config[env].appid, config[env].clientkey, config[env].masterkey);
Parse.Cloud.useMasterKey();

var Ratings = Parse.Object.extend("Ratings");
var Users = Parse.Object.extend("_User");

var query = new Parse.Query(Parse.User);

query.limit(10);

query.find({
	success: function (results) {
		async.eachSeries(results, function (userObj, done) {
			var user = _(imports.users).find(function (v) {
				return v.username === userObj.get('username');
			});
			if (!user) {
				console.log("Couldn't find", user);
				done();
				return;
			}
			var robj = _(imports.ratings).find(function (v) {
				return v.objectId === user.ratings.objectId;
			});


			userObj.save({
				'avatar': user.avatar
			}, {
				success: function (r) {
					console.log("Saved User");
					done();
				},
				error: function (m, e) {
					console.log("New User Save Error", e);
				}
			});

		});
	},
	error: function (e) {
		console.log("Some Error", e);
	}
});

/*"bcryptPassword": "$2a$10$6N/j7RSWkYVfAJe7swatZ.HddZx9zGf8xgLnHipd7C5mvgWs6hyTS",
        "createdAt": "2014-03-10T23:28:32.042Z",
        "displayname": "Beth F.",
        "lastAction": {
            "__type": "Date",
            "iso": "2014-05-07T02:56:32.617Z"
        },
        "objectId": "pRRkyH7Xo0",
        "rating": 2.7604797790045916,
        "ratings": {
            "__type": "Pointer",
            "className": "Ratings",
            "objectId": "P6e7cdN2w8"
        },
        "sessionToken": "vqxyfmwrgz20xqdegob1fj31a",
        "updatedAt": "2014-05-29T01:46:39.687Z",
        "username": "Beth"
        */