// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
// 
Parse.Cloud.useMasterKey();

Parse.Cloud.beforeSave(Parse.User, function (req, res) {
	if (!req.object.get('rating')) {
		console.log('need to set rating');
		req.object.set('rating', 1);
	}
	res.success();
});

Parse.Cloud.afterDelete(Parse.User, function (req) {
	console.log("Delete");
	var rating = req.object.get('ratings');
	query = new Parse.Query("Ratings");
	query.equalTo("objectId", rating.id);
	query.find({
		success: function (ratings) {
			Parse.Object.destroyAll(ratings, {
				success: function () {},
				error: function (error) {
					console.error("Error deleting related ratings " + error.code + ": " + error.message);
				}
			});
		},
		error: function (error) {
			console.error("Error finding related comments " + error.code + ": " + error.message);
		}
	});

});

Parse.Cloud.beforeSave("Ratings", function (req, res) {
	var beenz = req.object.get('beenz');

	//console.log(req.user.get('objectId'), calculateRating(beenz));
	try {
		req.user.save({
			'lastAction': new Date()
		});

	} catch (e) {}
	res.success();
});

Parse.Cloud.afterSave("Ratings", function (req) {
	var beenz = req.object.get('beenz');
	var score = calculateRating(beenz);
	var query = new Parse.Query(Parse.User);
	try {
		query.find({
			success: function (results) {
				if (results) {
					var usr = results[0];
					if (usr) {
						usr.set('rating', score);
						usr.set('lastRanked', new Date());
					} else {
						throw "User is bogus";
					}
				} else {
					throw "Couldnt find target user";
				}
			},
			error: function (findError) {
				throw findError;
			}
		});
	} catch (e) {
		console.log(e);
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