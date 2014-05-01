//
//  CamouflageTests.m
//  CamouflageTests
//
//  Created by Kamil Burczyk on 28.04.2014.
//  Copyright (c) 2014 Sigmapoint. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "bmpfile.h"

@interface CamouflageTests : XCTestCase

@end

@implementation CamouflageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateBMP
{
    int i,j;
    
    bmpfile_t *file = bmp_create(10, 10, 24);
    rgb_pixel_t pixel = {128, 64, 0, 0};

    for (i = 0, j = 0; j < 10; ++i, ++j) {
        bmp_set_pixel(file, i, j, pixel);
        pixel.red++;
        pixel.green++;
        pixel.blue++;
//        bmp_set_pixel(file, i + 1, j, pixel);
//        bmp_set_pixel(file, i, j + 1, pixel);
    }
    
    bool success = bmp_save(file, "/Users/kamil/Projekty/Camouflage/plik.bmp");
    bmp_destroy(file);
    
    XCTAssertTrue(success, @"");
    
    UIImage *image = [UIImage imageWithContentsOfFile:@"/Users/kamil/Projekty/Camouflage/plik.bmp"];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"ERROR: %@", error);
    }
}

@end
