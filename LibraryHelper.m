//
//  LibraryHelper-phonegap  
//  http://github.com/coryjthompson/LibraryHelper-phonegap
//

#import "LibraryHelper.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation LibraryHelper
@synthesize callbackId, albumName;


- (void)saveImagetoLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.callbackId = [arguments objectAtIndex: 0];
    NSString* path = [arguments objectAtIndex: 1];
    self.albumName = [arguments objectAtIndex: 2];
    
    CDVPluginResult* pluginResult;
    
    if(!path){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path cannot be null"];
        [self writeJavascript: [pluginResult toErrorCallbackString:self.callbackId]];
        return;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    if(!image){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path not a valid image file"];
        [self writeJavascript: [pluginResult toErrorCallbackString:self.callbackId]];
        return;
    }

    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(assetSavedToLibrary:didFinishSavingWithError:contextInfo:), nil);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if([self.albumName isEqualToString:@"null"]){
        self.albumName = NULL;
    }
    
    [library saveImage:image toAlbum: self.albumName completionBlock:^(NSURL *assetURL, NSError *error) {
        [self assetSavedToLibrary:error];
    } failureBlock:^(NSError *error) {
        [self assetSavedToLibrary:error];
    }];

}


- (void)saveVideoToLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.callbackId = [arguments objectAtIndex: 0];
    NSString* path = [arguments objectAtIndex:1];
    self.albumName = [arguments objectAtIndex: 2];

    
    if (!path || !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum( path ) )
    {
        CDVPluginResult* pluginResult;

        //Video path not valid
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path not a valid video file"];
        [self writeJavascript: [pluginResult toErrorCallbackString:self.callbackId]];
        return;
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if([self.albumName isEqualToString:@"null"]){
        self.albumName = NULL;
    }
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    [library saveVideo:url toAlbum:self.albumName completionBlock:^(NSURL *assetURL, NSError *error) {
        [self assetSavedToLibrary:error];
    } failureBlock:^(NSError *error) {
        [self assetSavedToLibrary:error];
    }];
    
}

- (void)assetSavedToLibrary:(NSError *)error {
    CDVPluginResult* pluginResult;
    
	if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: [error description]];
        [self writeJavascript: [pluginResult toErrorCallbackString: self.callbackId]];
        return;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully Added to Library"];
    [self writeJavascript: [pluginResult toSuccessCallbackString: self.callbackId]];
    
}


- (void)dealloc {
    [self.callbackId release];
    [super dealloc];
}

@end