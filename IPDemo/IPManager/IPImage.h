//
//  IPImage.h
//  IPDemo
//
//  Created by x.wang on 15/5/7.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;
@class ALAsset;

@interface IPImage : NSObject

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) UIImage *fullResolutionImage;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) UIImage *editedImage;
@property (nonatomic, strong) NSURL *url; // maybe nil

- (instancetype)initWithAsset:(ALAsset *)asset;
- (instancetype)initWithInfo:(NSDictionary *)info imageName:(NSString *)name;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) ALAsset *asset;

- (NSData *)data;

@end

@interface IPGroup : NSObject
@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, strong) NSString *groupName;

- (UIImage *)posterImage;
- (NSInteger)numberOfCount;

@end

@interface IPImage (Tools)

+ (UIImage *)previewImageForVideo:(NSURL *)videoURL;
+ (void)referenceURL:(NSURL *)url mediaName:(void (^)(NSString *name))name;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end

#if DEBUG
#define debug(block) block()
#else
#define debug(block)
#endif
