//
//  IPImage.m
//  IPDemo
//
//  Created by x.wang on 15/5/7.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import "IPImage.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation IPImage

- (instancetype)initWithAsset:(ALAsset *)asset; {
    if (self = [super init]) {
        self.asset = asset;
        self.thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        self.fullResolutionImage = [UIImage imageWithCGImage:[representation fullResolutionImage]];
        self.imageName = [representation filename];
        self.url = [representation url];
    }
    return self;
}

- (instancetype)initWithInfo:(NSDictionary *)info imageName:(NSString *)name; {
    if (self = [super init]) {
        self.info = info;
        self.url = [info objectForKey:UIImagePickerControllerMediaURL];
        if (self.url) {
            self.fullResolutionImage = [IPImage previewImageForVideo:self.url];
        } else {
            self.url = [info objectForKey:UIImagePickerControllerReferenceURL];
            self.fullResolutionImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            self.editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        }
        self.thumbnail = self.fullResolutionImage;
        self.imageName = name;
    }
    return self;
}

- (NSString *)imageName {
    if (! _imageName || [@"" isEqualToString:_imageName]) {
        _imageName = [self createImageNameWithType:_url.path.pathExtension];
    }
    return _imageName;
}

- (NSData *)data; {
    NSMutableData *data = [NSMutableData data];
    if (self.asset) {
        NSUInteger bufferSize = 1024;
        uint8_t buffer[bufferSize];
        NSUInteger read = 0,length = 0;
        NSError *error = nil;
        ALAssetRepresentation* representation = [self.asset defaultRepresentation];
        while (read < representation.size) {
            length = [representation getBytes:buffer fromOffset:read length:bufferSize error:&error];
            NSData *tempData = [NSData dataWithBytes:(const void *)buffer length:(NSUInteger)length];
            [data appendData:tempData];
            read += length;
        }
    } else if (self.info) {
        if (self.url) {
            data = [NSMutableData dataWithContentsOfFile:self.url.path];
        } else {
            data = [NSMutableData dataWithData:UIImageJPEGRepresentation(self.fullResolutionImage, 1.0)];
        }
    }
    return [NSData dataWithData:data];
}

- (NSString *)createImageNameWithType:(NSString *)type {
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyyMMddHHmmssss"];
    NSString *s = [f stringFromDate:[NSDate date]];
    return [s stringByAppendingFormat:@".%@",type];
}

@end


@implementation IPGroup

- (UIImage *)posterImage; {
    UIImage *image = [UIImage imageWithCGImage:[self.group posterImage]];
    return image;
}

- (NSInteger)numberOfCount; {
    return [self.group numberOfAssets];
}

@end

@implementation IPImage (Tools)

+ (UIImage *)previewImageForVideo:(NSURL *)videoURL; {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (error) {
        debug(^{
            NSLog(@"Get video preview error: %@", error);
        });
        return nil;
    }
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

+ (void)referenceURL:(NSURL *)url mediaName:(void (^)(NSString *name))name; {
    if (url) {
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            ALAssetRepresentation *representation = [myasset defaultRepresentation];
            NSString *fileName = [representation filename];
            name(fileName);
        };
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:url
                       resultBlock:resultblock
                      failureBlock:nil];
    } else {
        name(nil);
    }
}

+ (UIImage *)fixOrientation:(UIImage *)aImage; {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

