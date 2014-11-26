//  LibraryHelper-cordova 
//  http://github.com/coryjthompson/LibraryHelper-cordova
//

#import "LibraryHelper.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation LibraryHelper
- (void)assetSavedToLibrary:(NSError *)error callbackId:(NSString*)callbackId {
    CDVPluginResult* pluginResult = error
    ? [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: [error description]]
    : [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully Added to Library"];
    
    // [self writeJavascript: [pluginResult toSuccessCallbackString: self.callbackId]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)saveImagetoLibrary:(CDVInvokedUrlCommand *)command {
	NSString* path = [command.arguments objectAtIndex: 0];
	NSString* albumName = [command.arguments objectAtIndex: 1];

    CDVPluginResult* pluginResult = nil;
    
    if(!path) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path cannot be null"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if(!image){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path is not a valid image file"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(assetSavedToLibrary:didFinishSavingWithError:contextInfo:), nil);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveImage:image toAlbum:albumName completionBlock:^(NSURL *assetURL, NSError *error) {
        [self assetSavedToLibrary:error callbackId:command.callbackId];
    } failureBlock:^(NSError *error){
        [self assetSavedToLibrary:error callbackId:command.callbackId];
    }];
}

- (void)saveVideoToLibrary:(CDVInvokedUrlCommand *)command {
    NSString* path = [command.arguments objectAtIndex: 0];
    NSString* albumName = [command.arguments objectAtIndex: 1];
    
    CDVPluginResult* pluginResult = nil;

    if (!path) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path not a valid video file"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (!UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path is not a valid video file"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveVideo:url toAlbum:albumName completionBlock:^(NSURL *assetURL, NSError *error) {
        [self assetSavedToLibrary:error callbackId:command.callbackId];
    } failureBlock:^(NSError *error){
        [self assetSavedToLibrary:error callbackId:command.callbackId];
    }];
}
@end
