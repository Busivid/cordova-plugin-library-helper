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
Add LibraryHelper.java to src/com/greenqloud/plugin/LibraryHelper.java

Add LibraryHelper.js and include it from your html.

Add the following to res/xml/config.xml

	<plugin name="LibraryHelper" value="com.greenqloud.plugin.LibraryHelper"/>


Usage
=====
Photo
-----
	windows.plugins.libraryHelper.saveImageToLibrary(fullPath, {success: successCallback, error: errorCallback}); 
Video
-----
	windows.plugins.libraryHelper.saveVideoToLibrary(fullPath, {success: successCallback, error: errorCallback});


Author: Cory Thompson (http://coryjthompson.com)

License: http://www.opensource.org/licenses/mit-license.php The MIT License