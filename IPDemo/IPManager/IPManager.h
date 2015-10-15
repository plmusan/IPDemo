//
//  IPManager.h
//  IPDemo
//
//  Created by x.wang on 15/5/7.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPImage.h"

typedef NS_ENUM(NSInteger, IPManagerPickerType) {
    IPManagerPickerTypeNon = 0,
    
    /*  */
    IPManagerPickerTypeCustomSelecteImage,
    IPManagerPickerTypeCustomSelecteMovie,
    IPManagerPickerTypeCustomSelecteAll,
    
    /*  */
    IPManagerPickerTypeSystemShootingImage,
    IPManagerPickerTypeSystemShootingMovie,
    IPManagerPickerTypeSystemShootingAll,
    
    /*  */
    IPManagerPickerTypeSystemSelecteImage,
    IPManagerPickerTypeSystemSelecteMovie,
    IPManagerPickerTypeSystemSelecteAll,
};
UIKIT_EXTERN NSString *IPManagerPickerTypeString(IPManagerPickerType type);

typedef void (^IPManagerPickerResult)(NSArray *result/* IPImage objects */);

@protocol IPManagerDelegate <NSObject>
- (void)didFinishedSelecteWithImages:(NSArray *)images/* IPImage objects */;
@end

@interface IPManager : NSObject

@property (nonatomic, weak) id<IPManagerDelegate> delegate;
@property (nonatomic, strong) IPManagerPickerResult managerPickerResultBlock; // if delegate not set, use this property

@property (nonatomic, readonly) BOOL isShowImagePicker;
@property (nonatomic, readonly) IPManagerPickerType pickerType;

/* Only used with `IPManagerPickerTypeCustomSelecteImage', 
    `IPManagerPickerTypeCustomSelecteMovie' and `IPManagerPickerTypeCustomSelecteAll' */
@property (nonatomic) NSUInteger minNumberForSelected; // default is `1'
@property (nonatomic) NSUInteger maxNumberForSelected; // default is `10'
@property (nonatomic) NSString *msgForNumberExceeded; // default is nil, if nil, there is no alert show
@property (nonatomic) NSString *groupTitle; // default is nil. if nil, the title is `Select an Album'

+ (instancetype)shareManager;
- (void)showImagePickerWithViewContriller:(UIViewController *)viewController
                               pickerType:(IPManagerPickerType)pickerType
                                 animated:(BOOL)animated  __attribute__ ((nonnull(1)));

/* Only called if you want dismiss image picker without tap `Cancel' or `Down' button */
- (void)dismissImagePickerAnimated:(BOOL)animated;
/* At first, call the callback method, such as delegate and block, then dismiss image picker */
- (void)dismissImagePickerAnimated:(BOOL)animated result:(NSArray *)result;

@end

@interface IPManager (Tools)

/// get images contents and write it to file
+ (void)contentsFrom:(NSArray *)iImages progress:(NSProgress **)progress result:(void (^)(NSString *basePath, NSArray *fileName))result  __attribute__ ((nonnull(1,2,3)));

@end




