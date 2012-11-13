//
//  LibraryHelper-phonegap
//	https://github.com/coryjthompson/LibraryHelper-phonegap
//
//  Author: Cory Thompson (http://coryjthompson.com)
//	License: http://www.opensource.org/licenses/mit-license.php The MIT License

var LibraryHelper = function() {
    
}

LibraryHelper.prototype.saveImageToLibrary = function(filePath, params) {
    
    //PhoneGap does not handle null value well
    if(!params.albumName){
        params.albumName = 'null';
    }
    
    PhoneGap.exec(params.success, params.error , "LibraryHelper", "saveImageToLibrary", [filePath, params.albumName]);
};

LibraryHelper.prototype.saveVideoToLibrary = function(filePath, params) {
    
    if(!params.albumName){
        params.albumName = 'null';
    }
    
    PhoneGap.exec(params.success, params.error, "LibraryHelper", "saveVideoToLibrary", [filePath, params.albumName]);
};

if(!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.libraryHelper) {
    window.plugins.libraryHelper = new LibraryHelper();
}
