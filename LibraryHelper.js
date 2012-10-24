//
//  LibraryHelper-phonegap
//	https://github.com/coryjthompson/LibraryHelper-phonegap
//
//  Author: Cory Thompson (http://coryjthompson.com)
//	License: http://www.opensource.org/licenses/mit-license.php The MIT License

var LibraryHelper = function() {
    
}

LibraryHelper.prototype.saveImageToLibrary = function(filePath, success, error) {
    PhoneGap.exec(success, error , "LibraryHelper", "saveImageToLibrary", [filePath]);
};

LibraryHelper.prototype.saveVideoToLibrary = function(filePath, success, error) {
    PhoneGap.exec(success, error, "LibraryHelper", "saveVideoToLibrary", [filePath]);
};

if(!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.libraryHelper) {
    window.plugins.libraryHelper = new LibraryHelper();
}