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

- (void)saveImageToLibrary:(CDVInvokedUrlCommand *)command {
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

//Many thanks to @jbavari
//Parts of this code taken from:
//https://github.com/jbavari/cordova-plugin-video-editor/
- (void)getVideoInfo:(CDVInvokedUrlCommand *)command {
    NSString* srcVideoPath = [command.arguments objectAtIndex: 0];
    NSURL *srcVideoUrl;
    
    CDVPluginResult* pluginResult = nil;
    if (!srcVideoPath) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path not a valid video file"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if ([srcVideoPath rangeOfString:@"://"].location == NSNotFound)
    {
        srcVideoUrl = [NSURL URLWithString:[[@"file://localhost" stringByAppendingString:srcVideoPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        srcVideoUrl = [NSURL URLWithString:[srcVideoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    AVURLAsset *srcAsset = [AVURLAsset assetWithURL: srcVideoUrl];
    
    //Grab the duration
    Float64 duration = CMTimeGetSeconds(srcAsset.duration);
    
    //Grab the thumbnail (thanks http://stackoverflow.com/questions/14742262/ios-get-video-duration-and-thumbnails-without-playing-video)
    AVAssetImageGenerator* generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:srcAsset];
    generator.appliesPreferredTrackTransform = true;

    
    //Get the 1st frame 3 seconds in or half way if the clip is less the 3 seconds
    int frameTimeStart = (duration < 3)
        ? (duration/2)
        : 3;
    
    int frameLocation = 1;
    
    //Grab the frame
    CGImageRef frameRef = [generator copyCGImageAtTime:CMTimeMake(frameTimeStart,frameLocation) actualTime:nil error:nil];
    
    // Get output path
    NSString *dstFileName = [[NSProcessInfo processInfo] globallyUniqueString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *appDocumentPath = [paths objectAtIndex:0];
    
    NSString *thumbnailPath = [appDocumentPath stringByAppendingPathComponent:dstFileName];
    
    // Save image
    NSString *outputFilePath = [thumbnailPath stringByAppendingString:@".jpg"];
    UIImage *uiImage = [UIImage imageWithCGImage:frameRef];
    NSData *jpgData = UIImageJPEGRepresentation(uiImage, 0.9f);
    [jpgData writeToFile:outputFilePath atomically:YES];
    
    //Get Filesize
    NSNumber *fileSize = nil;
    [srcVideoUrl getResourceValue:&fileSize
                       forKey:NSURLFileSizeKey
                        error:nil];
    
    
    NSDictionary *results = @{
                           @"duration" : [NSNumber numberWithLong: ceil(duration)],
                           @"fileSize": fileSize,
                           @"thumbnail" : outputFilePath
    };
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:results];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}
@end
