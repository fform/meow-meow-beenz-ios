var Parse = require('parse').Parse;
var _ = require('underscore');
var emptyImage = require('./emptyImage.js');
var config = require('./config.json');
var env = "prod";


Parse.initialize(config[env].appid, config[env].clientkey, config[env].masterkey);
Parse.Cloud.useMasterKey();


var query = new Parse.Query(Parse.User);
query.limit(1000);

query.find({
	useMasterKey: true,
	success: function (results) {

		_.each(results, function (user) {
			var avatar = user.get('avatar');


			if (avatar === null || avatar.base64 == emptyImage.one || avatar.base64 == emptyImage.two) {
				console.log('updating null image user', user.get('displayname'), user.id);
				user.save({
					avatar: {
						'__type': "Bytes",
						'base64': "R0lGODdhAQABAIAAAAQCBAAAACwAAAAAAQABAAACAkQBADs="
					}
				}, {
					success: function () {
						console.log('ok');
					},
					error: function (e) {
						console.log('error', e);
					}
				});
			}
		});


	},
	error: function (error) {
		console.log('error', error);
	}
});