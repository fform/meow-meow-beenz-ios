var Parse = require('parse').Parse;
var _ = require('underscore');
var fs = require('fs');
var config = require('./config.json');
var env = "prod";

var actuallyDeleteUsers = false;

Parse.initialize(config[env].appid, config[env].clientkey, config[env].masterkey);
Parse.Cloud.useMasterKey();

var userRatings = {
	'beenz': 0
};
var receivedRatings = {};
var userLookup = {
	'beenz': {
		name: 'beenz',
		rating: 0
	}
};
var query = new Parse.Query(Parse.User);
query.limit(1000);
query.descending("lastAction");
query.select("displayname", "lastAction", "email", "ratings");
query.include("ratings");
query.find({
	useMasterKey: true,
	success: function (results) {

		_.each(results, function (user) {
			var id = fmtUserId(user.id);
			if (!userRatings[id]) {
				userRatings[id] = 0;
			}

			var rating = calculateRating(user.get("ratings").get('beenz'), fmtUserId(user.id));
			userLookup[id] = user;
			//console.log(user.get('displayname'), rating, user.get('ratings').get('rating'));
			//console.log(user.id, user.get('displayname'), user.get('email'), user.get('lastAction'), user.get("ratings").get('rating'));
		});

		for (var i in userRatings) {
			//console.log(i, userLookup[i], userRatings[i]);
			var id = fmtUserId(i);
			if (userLookup[id]) {
				userLookup[id].rated = userRatings[i];
			}
		}

		for (var i in receivedRatings) {
			//console.log(i, userLookup[i], userRatings[i]);
			if (userLookup[i]) {
				userLookup[i].received = receivedRatings[i];
			}
		}

		fs.writeFileSync("ratings.json", JSON.stringify({
			'lookup': userLookup,
			'userRatings': userRatings
		}));
		//console.log(userRatings);
		for (var u in userLookup) {
			var uid = fmtUserId(u);
			var user = userLookup[uid];
			//console.log(uid, 'ur:', userRatings[uid], 'rr:', receivedRatings[uid]);
			if (!userRatings[uid] && !receivedRatings[uid]) {
				var secondsOld = (new Date() - user.createdAt) / 1000;
				if (secondsOld > (60 * 60 * 24)) {
					/* Give them 24 hrs to rate or be rated */
					console.log((actuallyDeleteUsers ? "Deleting " : "Should Delete: "), user.id, user.get('displayname'), secondsOld);

					if (actuallyDeleteUsers) {
						user.destroy({
							success: function (o) {
								console.log("Success");
							},
							error: function (o, err) {
								console.log("Error", err, o);
							}
						});
					}
				} else {
					console.log("TS Skip", user.id);
				}


			}
		}

		//console.log("---------------");
		//console.log(userRatings);

	},
	error: function (error) {
		console.log('error', error);
	}
});

var calculateRating = function (beenz, forUserId) {
	var total = 0;
	var score = 0;

	for (var i in beenz) {
		var id = fmtUserId(i);

		if (id !== "beenz") {
			if (userRatings[forUserId]) {
				userRatings[forUserId]++;
			} else {
				userRatings[forUserId] = 1;
			}
		}

		if (forUserId !== "beenz") {
			if (receivedRatings[id]) {
				receivedRatings[id]++;
			} else {
				receivedRatings[id] = 1;
			}
		}

		score += beenz[i][0];
		total += beenz[i][1];
	}

	return (score / total * 5);
};

var fmtUserId = function (uid) {
	return String(uid).replace(/\W/gi, "");
};