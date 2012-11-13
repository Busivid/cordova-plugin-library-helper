LibraryHelper-phonegap
======================

A PhoneGap plugin to insert into the phone's gallery. Supports IOS and Android

Install
=======

IOS
---
Add LibraryHelper.h, LibraryHelper.m, ALAssetsLibrary+CustomPhotoAlbum.m and ALAssetsLibrary+CustomPhotoAlbum.m to your plugins directory.

Add LibraryHelper.js and include it from your html.

Add reference to AssetsLibrary.framework

Add to Cordova.plist Plugins: key:libraryHelper value:LibraryHelper.

Android
-------
Add LibraryHelper.java to src/com/greenqloud/plugin/LibraryHelper.java

Add LibraryHelper.js and include it from your html.

Add the following to res/xml/config.xml

	<plugin name="LibraryHelper" value="com.greenqloud.plugin.LibraryHelper"/>


Usage
=====
Photo
-----
	windows.plugins.libraryHelper.saveImageToLibrary(fullPath, {success: successCallback, error: errorCallback, albumName: "Album Name"}); 
Video
-----
	windows.plugins.libraryHelper.saveVideoToLibrary(fullPath, {success: successCallback, error: errorCallback, albumName: "Album Name"});

Change Log
==========
13/11/2012 - Optional Callbacks

14/11/2012 - Added the ability to add assets to IOS albums

Author: Cory Thompson (http://coryjthompson.com)

License: http://www.opensource.org/licenses/mit-license.php The MIT License