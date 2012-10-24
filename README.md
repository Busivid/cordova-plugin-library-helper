LibraryHelper-phonegap
======================

A PhoneGap plugin to insert into the phone's gallery. Supports IOS and Android

Install
=======

IOS
---
Add LibraryHelper.h and LibraryHelper.m to your plugins directory.

Add LibraryHelper.js and include it from your html.

Add to Cordova.plist Plugins: key:libraryHelper value:LibraryHelper.

Android
-------
TO BE IMPLEMENTED

Usage
=====
Photo
-----
	windows.plugins.libraryHelper.saveImageToLibrary(fullPath, successfullCallback, errorCallback); 
Video
-----
	windows.plugins.libraryHelper.saveVideoToLibrary(fullPath, successfullCallback, errorCallback);


Author: Cory Thompson (http://coryjthompson.com)

License: http://www.opensource.org/licenses/mit-license.php The MIT License