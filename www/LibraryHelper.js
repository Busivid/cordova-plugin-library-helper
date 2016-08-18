// LibraryHelper-cordova
// https://github.com/coryjthompson/LibraryHelper-cordova
var exec = require('cordova/exec');

module.exports = {	
        compressImage: function (onSuccess, onError, path, jpegCompression) {
                exec(onSuccess, onError, 'LibraryHelper', 'compressImage', [path, jpegCompression]);
        },
	getVideoInfo: function(onSuccess, onError, path) {
		exec(onSuccess, onError, 'LibraryHelper', 'getVideoInfo', [path]);
	},
	saveImageToLibrary: function (onSuccess, onError, path, albumName) {
		exec(onSuccess, onError, 'LibraryHelper', 'saveImageToLibrary', [path, albumName]);
	},
	saveVideoToLibrary: function (onSuccess, onError, path, albumName) {
		exec(onSuccess, onError, 'LibraryHelper', 'saveVideoToLibrary', [path, albumName]);
	}
};
