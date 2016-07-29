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

- (UIImage *)scaleImageToSize:(UIImage*)image maxSize:(CGSize)newSize {
    CGFloat aspectWidth = newSize.width / image.size.width;
    CGFloat aspectHeight = newSize.height / image.size.height;
    CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );
    
    CGRect scaledImageRect = CGRectZero;
    scaledImageRect.size.width = image.size.width * aspectRatio;
    scaledImageRect.size.height = image.size.height * aspectRatio;
    
    UIGraphicsBeginImageContextWithOptions(scaledImageRect.size, NO, 0 );
    [image drawInRect:scaledImageRect];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//Many thanks to @jbavari
//Parts of this code taken from:
//https://github.com/jbavari/cordova-plugin-video-editor/
- (void)getVideoInfo:(CDVInvokedUrlCommand *)command {
    NSString* srcVideoPath = [command.arguments objectAtIndex: 0];
    
    CDVPluginResult* pluginResult = nil;
    if (!srcVideoPath) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Path not a valid video file"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSURL *srcVideoUrl = [srcVideoPath rangeOfString:@"://"].location == NSNotFound
        ? [NSURL URLWithString:[[@"file://localhost" stringByAppendingString:srcVideoPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
        : [NSURL URLWithString:[srcVideoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    AVURLAsset *srcAsset = [AVURLAsset assetWithURL: srcVideoUrl];
    NSString *tmpFileName = [[NSProcessInfo processInfo] globallyUniqueString];
    
    // Get App Document path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *appDocumentPath = [paths objectAtIndex:0];
    
    // Get Duration
    Float64 duration = CMTimeGetSeconds(srcAsset.duration);
    
    // Get Filesize
    NSNumber *fileSize = nil;
    [srcVideoUrl getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
    
    // Generate Image
    UIImage *image;
    NSString *imagePath;
    if (duration == 0) {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:srcVideoUrl]];
        image = [self rotateImage:image];
        
        imagePath = srcVideoPath;
    } else {
        AVAssetImageGenerator* generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:srcAsset];
        generator.appliesPreferredTrackTransform = true;
        
        int frameLocation = 1;
        int frameTimeStart = MIN(duration, 3);
        CGImageRef frameRef = [generator copyCGImageAtTime:CMTimeMake(frameTimeStart,frameLocation) actualTime:nil error:nil];
        image = [UIImage imageWithCGImage:frameRef];
        
        // Optionally Save Image
        imagePath = [[appDocumentPath stringByAppendingPathComponent:tmpFileName] stringByAppendingString:@".jpg"];
        [UIImageJPEGRepresentation(image, 0.96f) writeToFile:imagePath atomically:YES];
    }
    
    // Generate Thumbnail
    UIImage *thumbnail = [self scaleImageToSize: image maxSize: CGSizeMake(320, 180)];
    NSString *thumbnailPath = [[appDocumentPath stringByAppendingPathComponent:tmpFileName] stringByAppendingString:@"_thumb.jpg"];
    [UIImageJPEGRepresentation(thumbnail, 0.96f) writeToFile:thumbnailPath atomically:YES];
    
    NSDictionary *results = @{
        @"duration" : [NSNumber numberWithLong: ceil(duration)],
        @"fileSize": fileSize,
        @"image": imagePath,
        @"thumbnail" : thumbnailPath
    };
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:results];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (UIImage *)rotateImage:(UIImage *) image {
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = bounds.size.width / width;
    
    CGFloat boundHeight;
    CGSize imageSize = CGSizeMake(width, height);
    UIImageOrientation orient = image.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
@end
