##Camouflage

`Camouflage` is a category of NSData that allows you to store it as .bmp file in iOS Camera Roll and read it from there.

Camera Roll, Contacts and at some point Keychain are the only places where you can store and access data between apps.

I figured out that you can store bytes as pixels in .bmp file and place it in Camera Roll and iOS will not protest ;)

###Usage
There are just 2 methods:

```objective-c
- (void)writeToBMPFileInCameraRollWithCompletion:(void(^)(NSURL *assetURL))completion;

+ (void)dataFromBMPFileInCameraRollForURL:(NSURL*)assetURL withCompletion:(void(^)(NSData*))completion;
```

First one stores data as .bmp file and returns `assetURL` of form `assets-library://asset/asset.BMP?id=1C762023-58C9-42EA-93C6-CE02459185BF&ext=BMP` in completion block.

Second one return stored data by given URL in completion block.

###Use case
**Share data between apps without sending it to the server!**

Write NSData to Photo Library, get it's URL and pass it to other app by opening second app's specific URL with particular parameter, or just store a URL on the server, retrieve it in another app and open NSData written before from URL, e.g.:
`assets-library://asset/asset.BMP?id=DAD5C945-B5EB-4D68-9FBC-D70081E95E01&ext=BMP`

```objective-c
[NSData dataFromBMPFileInCameraRollForURL:[NSURL URLWithString:@"assets-library://asset/asset.BMP?id=DAD5C945-B5EB-4D68-9FBC-D70081E95E01&ext=BMP"] withCompletion:^(NSData *data) {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
}];
```                

**You don't need to be root to share data between apps!**

###Installation
Use [cocoapods](http://cocoapods.org/):

```
pod 'Camouflage'
```

or drag & drop 4 files:

```
NSData+Camouflage.h
NSData+Camouflage.m
bmpfile.h
bmpfile.c
```
into your project, add `AssetsLibrary.framework` as Linked Framework and play :)

###Sample project
[CamouflageTest](https://github.com/burczyk/CamouflageTest) is a project that tests behavior of library, e.g.

```objective-c
[data writeToBMPFileInCameraRollWithCompletion:^(NSURL *assetURL) {
    [NSData dataFromBMPFileInCameraRollForURL:assetURL withCompletion:^(NSData *data) {
        NSLog(@"data length after load from bmp: %d", data.length);
        NSLog(@"STRING: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    }];
}];
```

###Sample result
`CamouflageTest` has e.g. this method that downloads image from URL, saves it as NSData, restores it and shows it on the screen:

```objective-c
- (void)testImageWritingAndReading
{
    //sorry for that, but synchronous call is simpler to show you the results
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://placekitten.com/200/200"]];
    
    NSLog(@"data length before save: %d", data.length);
    
    [data writeToBMPFileInCameraRollWithCompletion:^(NSURL *assetURL) {
        [NSData dataFromBMPFileInCameraRollForURL:assetURL withCompletion:^(NSData *data) {
            NSLog(@"data length after load from bmp: %d", data.length);
            UIImageView *image = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithData:data]];
            image.frame = CGRectMake(0, 0, 200, 200);
            [self.view addSubview:image];
        }];
    }];
}
```

Result looks like this:
![Place kitten example](https://raw.githubusercontent.com/burczyk/Camouflage/master/assets/placekitten.png)

On the same time you Photo Library will have additional file, but remember it looks completly different! Original file is flatten to 1px-height .bmp file so it doesn't have anything to do with original one:

![Camera Roll representation](https://raw.githubusercontent.com/burczyk/Camouflage/master/assets/camera_roll.png)


###Algorithm
[BMP](http://en.wikipedia.org/wiki/BMP_file_format) is probably the simplest image format. All you need to know is that it consists of a header and then array of pixels. Each single RGB element can have a value from range (0-255) so it can be represented as a byte. If we extract bytes from NSData and divide them into 3-component groups we can store each group as a single pixel!

Each pixel is stored in a bitmap that has a `height=1` and `width=ceil(size/3)` and whole bitmap is saved in Camera Roll. As a result we get an assetURL we can use later to restore saved data.

You can debug your .bmp files if you store text inside them. Consider following snippet:

```objective-c
- (void)testStringWritingAndReading
{
    NSData *data = [@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." dataUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"data length before save: %d", data.length);
    
    [data writeToBMPFileInCameraRollWithCompletion:^(NSURL *assetURL) {
        [NSData dataFromBMPFileInCameraRollForURL:assetURL withCompletion:^(NSData *data) {
            NSLog(@"data length after load from bmp: %d", data.length);
            NSLog(@"STRING: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        }];
    }];
}
```

Images from iOS Simulator are stored in a path:

```
/Users/kamil/Library/Application Support/iPhone Simulator/7.1/Media/DCIM/100APPLE
```

If you run the code above and find the newest file you can open it with hex editor, e.g. [hexfiend](http://ridiculousfish.com/hexfiend/).

My file which graphical representation looks like this:
![Camera roll example](https://raw.githubusercontent.com/burczyk/Camouflage/master/assets/IMG_0071.BMP)

when open in hexfiend looks like this:
![hexfiend](https://raw.githubusercontent.com/burczyk/Camouflage/master/assets/hexfiend.png)

As you see the whole text is stored inside, right after the header.
We can extract it by just slicing `byte[]` array from a certain index to the end and that's how Camouflage is doing it.


###libbmp dependency
Camouflage uses [libbmp](https://code.google.com/p/libbmp/) library to create .bmp file. Readme summary from project page:

> libbmp is a simple, cross-platform, open source (revised LGPL) C library designed for easily reading, writing, and modifying Windows bitmap (BMP) image files. The library is oriented towards the novice programmer with little formal experience, but it is sufficiently capable for anybody who desires to do I/O and pixel operations on uncompressed 1, 4, 8, 16, 24, and 32 bpp (bits per pixel) BMP files.


###License
`Camouflage` is under `MIT license`, but `libbmp` has a `revised LGPL` one.

See `LICENSE` file for more info.
