//
//  LibraryHelper-phonegap
//	https://github.com/coryjthompson/LibraryHelper-phonegap
//
//  Author: Cory Thompson (http://coryjthompson.com)
//	License: http://www.opensource.org/licenses/mit-license.php The MIT License

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface LibraryHelper : CDVPlugin {
    NSString *callbackId;

}

@property (nonatomic, copy) NSString *callbackId;

- (void) saveImageToLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) saveVideoToLibrary:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end