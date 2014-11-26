//  LibraryHelper-phonegap
//	https://github.com/coryjthompson/LibraryHelper-phonegap
//
//  Author: Cory Thompson (http://coryjthompson.com)
//	License: http://www.opensource.org/licenses/mit-license.php The MIT License
var exec = require('cordova/exec');

module.exports = {	
	saveImageToLibrary: function (onSuccess, onError, path, albumName) {
		exec(onSuccess, onError, 'LibraryHelper', 'saveImageToLibrary', [path, albumName]);
	},
	saveVideoToLibrary: function (onSuccess, onError, path, albumName) {
		exec(onSuccess, onError, 'LibraryHelper', 'saveVideoToLibrary', [path, albumName]);
	}
};
