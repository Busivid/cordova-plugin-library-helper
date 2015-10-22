//	LibraryHelper-cordova	
//	http://github.com/coryjthompson/LibraryHelper-cordova
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Cordova/CDVPlugin.h>


@interface LibraryHelper : CDVPlugin

- (void)saveImagetoLibrary:(CDVInvokedUrlCommand *)command;
- (void)saveVideoToLibrary:(CDVInvokedUrlCommand *)command;
- (void)getVideoInfo:(CDVInvokedUrlCommand *)command;
@end
