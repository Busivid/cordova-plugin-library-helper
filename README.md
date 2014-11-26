LibraryHelper-cordova
======================

Library Helper is a cordova plugin to help insert videos or images into the native gallery. Supports IOS and Android

Install
=======

	cordova plugin add https://github.com/coryjthompson/LibraryHelper-cordova.git

Usage
=====
Photo
-----
	libraryHelper.saveImageToLibrary(onSuccess, onError, path, albumName); 
Video
-----
        libraryHelper.saveVideoToLibrary(onSuccess, onError, path, albumName);                                                


Change Log
==========
26/11/2014 - Converted plugin to use cordova 3.x+

13/11/2012 - Optional Callbacks

14/11/2012 - Added the ability to add assets to IOS albums

Author: Cory Thompson (http://coryjthompson.com)

License: http://www.opensource.org/licenses/mit-license.php The MIT License
