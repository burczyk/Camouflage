//
//  NSData+Camouflage.m
//  Camouflage
//
//  Created by Kamil Burczyk on 01.05.2014.
//  Copyright (c) 2014 Sigmapoint. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#import "NSData+Camouflage.h"
#import "bmpfile.h"

@implementation NSData (Camouflage)

- (void)writeToBMPFileInCameraRollWithCompletion:(void(^)(NSURL *assetURL))completion
{
    //Each pixel consists of 3 numbers: R G B. Each number has 0-255 range (2^8).
    //That means our bmp_file should have a size of ceil of length/3 and 24-bit depth (3 pixels, 8-bits each)
    long numerOfPixels = ceil(self.length/3.0);
    bmpfile_t *file = bmp_create(numerOfPixels, 1, 24);
    
    unsigned char *dataBytes = (unsigned char*) self.bytes;
    for (int i=0; i<self.length; i+=3) {
        rgb_pixel_t pixel = { dataBytes[i], dataBytes[i+1], dataBytes[i+2] }; //We store data's bytes as pixels where pixel = (data[0], data[1], data[2]) etc.
        bmp_set_pixel(file, i/3, 0, pixel);
    }
    
    //Store temporary .bmp file
    bool success = bmp_save(file, [self temporaryFilePath]);
    
    if (!success) {
        NSLog(@"Error while saving temporary .bmp file");
        completion(nil);
    }
    
    bmp_destroy(file);
    
    //Load temporary .bmp file to UIImage
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:[self temporaryFilePath]]];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Request to save the image to camera roll
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                              orientation:(ALAssetOrientation)[image imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error){
                              if (error) {
                                  NSLog(@"Error while writing image to Photos Album: %@", error);
                                  if (completion) completion(nil);
                              } else {
                                  NSLog(@"Image saved under URL: %@", assetURL);
                                  if (completion) completion(assetURL);
                              }
                          }
     ];
}

+ (void)dataFromBMPFileInCameraRollForURL:(NSURL*)assetURL withCompletion:(void(^)(NSData *data))completion
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            ALAssetRepresentation *repr = [asset defaultRepresentation];
            unsigned char* bytes = malloc((NSInteger) repr.size * sizeof(unsigned char*));
            [repr getBytes:bytes fromOffset:0 length:(NSInteger) repr.size error:nil];
            
            NSData *d = [[NSData alloc] initWithBytesNoCopy:bytes length:(NSInteger) repr.size freeWhenDone:NO];
            if (completion) completion([d subdataWithRange:NSMakeRange(122, d.length-122)]);
        } else {
            NSLog(@"Asset with URL: %@ not found", assetURL);
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error while retrieving data for assetURL <%@> : %@", assetURL, error);
        if (completion) completion(nil);
    }];
}

- (const char*)temporaryFilePath
{
    NSString *fileName = @"tmp.bmp";
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingString:fileName];
    return [path UTF8String];
}

@end
