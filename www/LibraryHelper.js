// LibraryHelper-cordova
// https://github.com/coryjthompson/LibraryHelper-cordova
var exec = require('cordova/exec');

module.exports = {	
	saveImageToLibrary: function (onSuccess, onError, path, albumName) {
		exec(onSuccess, onError, 'LibraryHelper', 'saveImageToLibrary', [path, albumName]);
	},
	saveVideoToLibrary: function (onSuccess, onError, path, albumName) {
		exec(onSuccess, onError, 'LibraryHelper', 'saveVideoToLibrary', [path, albumName]);
	}
};
