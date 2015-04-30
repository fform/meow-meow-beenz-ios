var Parse = require('parse').Parse;
var _ = require('underscore');
var async = require('async');
var fs = require('fs');
var config = require('./config.json');

var env = "prod";


Parse.initialize(config[env].appid, config[env].clientkey, config[env].masterkey);
Parse.Cloud.useMasterKey();

/**
 * This is hacky and you just fill in the user's email on demand and deploy it
 */
/*
Parse.User.requestPasswordReset("user-email", {
	success: function () {
		// Password reset request was sent successfully
		console.log('sent password reset');
	},
	error: function (error) {
		// Show the error message somewhere
		console.log('couldnt send rest');
	}
});
*/