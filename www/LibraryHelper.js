// LibraryHelper-cordova
// https://github.com/coryjthompson/LibraryHelper-cordova
var exec = require('cordova/exec');

module.exports = {
  compressImage: function (onSuccess, onError, path, jpegCompression) {
    exec(onSuccess, onError, 'LibraryHelper', 'compressImage', [normalizePath(path), jpegCompression]);
  },
  getVideoInfo: function(onSuccess, onError, path) {
    exec(onSuccess, onError, 'LibraryHelper', 'getVideoInfo', [normalizePath(path)]);
  },
  saveImageToLibrary: function (onSuccess, onError, path, albumName) {
    exec(onSuccess, onError, 'LibraryHelper', 'saveImageToLibrary', [normalizePath(path), albumName]);
  },
  saveVideoToLibrary: function (onSuccess, onError, path, albumName) {
    exec(onSuccess, onError, 'LibraryHelper', 'saveVideoToLibrary', [normalizePath(path), albumName]);
  }
};

function normalizePath(path) {
  return path.indexOf('file://') === 0 ? path.slice(7) : path;
}
