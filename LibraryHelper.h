//
//	LibraryHelper-phonegap	
//	http://github.com/coryjthompson/LibraryHelper-phonegap
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Cordova/CDVPlugin.h>

@interface LibraryHelper : CDVPlugin {
    NSString *callbackId;

}

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, copy) NSString *albumName;

- (void) saveImageToLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) saveVideoToLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
@end