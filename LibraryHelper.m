//
//  LibraryHelper-phonegap
//  https://github.com/coryjthompson/LibraryHelper-phonegap
//
//  Author: Cory Thompson (http://coryjthompson.com)
//  License: http://www.opensource.org/licenses/mit-license.php The MIT License

#import "LibraryHelper.h"

@implementation LibraryHelper
@synthesize callbackId;


- (void)saveImagetoLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.callbackId = [arguments objectAtIndex: 0];
    
    NSString* path = [[arguments objectAtIndex: 0] autorelease];
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

    UIImageWriteToSavedPhotosAlbum(image, self, @selector(assetSavedToLibrary:didFinishSavingWithError:contextInfo:), nil);
}


- (void)saveVideoToLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    self.callbackId = [arguments objectAtIndex: 0];
    CDVPluginResult* pluginResult;

    NSString* path = [[arguments objectAtIndex:1] autorelease];
    
    if (!path || !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum( path ) )
    {
        //Video path not valid
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path not a valid video file"];
        [self writeJavascript: [pluginResult toErrorCallbackString:self.callbackId]];
        return;
    }
    
    UISaveVideoAtPathToSavedPhotosAlbum(path, self,  @selector(assetSavedToLibrary:didFinishSavingWithError:contextInfo:), nil);
    
}

- (void)assetSavedToLibrary:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo  {
	
    CDVPluginResult* pluginResult;
    
	if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: [error description]];
	    [self writeJavascript: [pluginResult toErrorCallbackString:self.callbackId]];
        return;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully Added to Library"];
    [self writeJavascript: [pluginResult toSuccessCallbackString:self.callbackId]];
}

@end