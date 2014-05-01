//
//  NSData+Camouflage.h
//  Camouflage
//
//  Created by Kamil Burczyk on 01.05.2014.
//  Copyright (c) 2014 Sigmapoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Camouflage)

- (void)writeToBMPFileInCameraRollWithCompletion:(void(^)(NSURL *assetURL))completion;

+ (void)dataFromBMPFileInCameraRollForURL:(NSURL*)assetURL withCompletion:(void(^)(NSData *data))completion;

@end
