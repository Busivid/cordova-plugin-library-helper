//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (CustomPhotoAlbum)

//           |image|: the target image to be saved
//       |albumName|: custom album name
// |completionBlock|: block to be executed when succeed to write the image data
//                    to the assets library (camera roll)
//    |failureBlock|: block to be executed when failed to add the asset to the
//                    custom photo album
-(void)saveImage:(UIImage *)image
         toAlbum:(NSString *)albumName
 completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
    failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

//           |videoUrl|: the target video to be saved
//       |albumName|: custom album name
// |completionBlock|: block to be executed when succeed to write the image data
//                    to the assets library (camera roll)
//    |failureBlock|: block to be executed when failed to add the asset to the
//                    custom photo album
-(void)saveVideo:(NSURL *)videoUrl
         toAlbum:(NSString *)albumName
 completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
    failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;
@end