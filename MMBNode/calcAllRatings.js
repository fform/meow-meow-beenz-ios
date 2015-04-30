var Parse = require('parse').Parse;
var _ = require('underscore');
var async = require('async');
var fs = require('fs');
var config = require('./config.json');


var env = "prod";
var actuallyDeleteUsers = false;



Parse.initialize(config[env].appid, config[env].clientkey, config[env].masterkey);
Parse.Cloud.useMasterKey();



var query = new Parse.Query(Parse.User);
query.limit(1000);
query.descending('createdAt');
query.select("displayname", "lastAction", "email", "ratings");

query.include("ratings");
query.find({
	success: function (results) {
		console.log("Results %d", results.length);
		async.eachLimit(results, 10, function (user, done) {
			var rating = calculateRating(user.get("ratings").get('beenz'));
			console.log("User %s %d", user.get('displayname'), rating);
			user.save({
				'rating': rating
			}, {
				success: function (o) {
					console.log("Saved", o.get('displayname'));
					done();
				},
				error: function (o, err) {
					console.log("Err", o.get('displayname'), err);
					done();
				}
			});
		});
	},
	error: function (e) {
		console.log("Some Error", e);
	}
});

var calculateRating = function (beenz) {
	var possibleBeenz = 0,
		totalBeenz = 0,
		score = 0;
	for (var i in beenz) {
		totalBeenz += beenz[i][0];
		possibleBeenz += beenz[i][1];
	}
	score = ((totalBeenz / possibleBeenz) * 5);
	return score;
};