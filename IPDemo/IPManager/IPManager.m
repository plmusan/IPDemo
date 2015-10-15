//
//  IPManager.m
//  IPDemo
//
//  Created by x.wang on 15/5/7.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import "IPManager.h"
#import "IPTableViewController.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error "This project uses features only available in iOS SDK 7.0 and later."
#endif

static NSString *const NavigationController = @"ImagePickerNavigation";

NSString *IPManagerPickerTypeString(IPManagerPickerType type) {
    switch (type) {
        case IPManagerPickerTypeCustomSelecteImage:
            return @"IPManagerPickerTypeCustomSelecteImage";
        case IPManagerPickerTypeCustomSelecteMovie:
            return @"IPManagerPickerTypeCustomSelecteMovie";
        case IPManagerPickerTypeCustomSelecteAll:
            return @"IPManagerPickerTypeCustomSelecteAll";
        case IPManagerPickerTypeSystemShootingImage:
            return @"IPManagerPickerTypeSystemShootingImage";
        case IPManagerPickerTypeSystemShootingMovie:
            return @"IPManagerPickerTypeSystemShootingMovie";
        case IPManagerPickerTypeSystemShootingAll:
            return @"IPManagerPickerTypeSystemShootingAll";
        case IPManagerPickerTypeSystemSelecteImage:
            return @"IPManagerPickerTypeSystemSelecteImage";
        case IPManagerPickerTypeSystemSelecteMovie:
            return @"IPManagerPickerTypeSystemSelecteMovie";
        case IPManagerPickerTypeSystemSelecteAll:
            return @"IPManagerPickerTypeSystemSelecteAll";
        default:
            return @"IPManagerPickerTypeNon";
    }
}

@interface IPManager () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIStoryboard *storyboard;
@property (nonatomic) UINavigationController *customNavigation;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) UIImagePickerControllerSourceType sourceType;
@property (nonatomic) NSArray *mediaTypes;
@property (nonatomic) BOOL isShowImagePicker;
@property (nonatomic) IPManagerPickerType pickerType;
@property (nonatomic) UIViewController *presentViewController;

@end


@implementation IPManager

+ (instancetype)shareManager {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)defaultManager {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.minNumberForSelected = 1;
        self.maxNumberForSelected = 10;
        [self instanceImagePickerController];
        [self instanceStoryboard];
    }
    return self;
}

- (void)instanceImagePickerController; {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
}

- (void)instanceStoryboard; {
    NSString *storyboardName = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboardName = @"ImagePicker_iPhone";
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboardName = @"ImagePicker_iPad";
    }
    self.storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
}

- (void)showImagePickerWithViewContriller:(UIViewController *)viewController pickerType:(IPManagerPickerType)pickerType animated:(BOOL)animated; {
    if (self.isShowImagePicker || pickerType == IPManagerPickerTypeNon) return;
    self.presentViewController = viewController;
    self.pickerType = pickerType;
    self.isShowImagePicker = YES;
    if ([self isShowSystemImagePickerWithType:pickerType]) {
        [self showSystemImagePickerAnimated:animated];
    } else {
        [self showCustomImagePickerAnimated:animated];
    }
}

- (BOOL)isShowSystemImagePickerWithType:(IPManagerPickerType)pickerType {
    switch (pickerType) {
        case IPManagerPickerTypeSystemShootingImage:
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.mediaTypes = @[@"public.image"];
            break;
        case IPManagerPickerTypeSystemShootingMovie:
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.mediaTypes = @[@"public.movie"];
            break;
        case IPManagerPickerTypeSystemShootingAll:
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case IPManagerPickerTypeSystemSelecteImage:
            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.mediaTypes = @[@"public.image"];
            break;
        case IPManagerPickerTypeSystemSelecteMovie:
            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.mediaTypes = @[@"public.movie"];
            break;
        case IPManagerPickerTypeSystemSelecteAll:
            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default:
            return NO;
    }
    return YES;
}

- (void)showSystemImagePickerAnimated:(BOOL)animated {
    if ([UIImagePickerController isSourceTypeAvailable:self.sourceType]) {
        self.imagePicker.sourceType = self.sourceType;
        self.imagePicker.mediaTypes = self.mediaTypes;
        [self.presentViewController presentViewController:self.imagePicker animated:animated completion:nil];
    } else {
        self.presentViewController = nil;
        self.pickerType = IPManagerPickerTypeNon;
        self.isShowImagePicker = NO;
        [self showErrorWhenDEBUG];
    }
}

- (void)showErrorWhenDEBUG {
    debug((^{
        NSString *type = IPManagerPickerTypeString(self.pickerType);
        NSString *msg = [NSString stringWithFormat:@"This device does not support type: %@.\n\nThis message is only show in DEBUG", type];
        NSLog(msg,nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ImagePickerTypeError" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }));
}

- (void)showCustomImagePickerAnimated:(BOOL)animated {
    self.customNavigation = [self.storyboard instantiateViewControllerWithIdentifier:NavigationController];
    [self.presentViewController presentViewController:self.customNavigation animated:animated completion:nil];
}

- (void)dismissImagePickerAnimated:(BOOL)animated; {
    UIViewController *controller = self.customNavigation ? self.customNavigation : self.imagePicker;
    __weak typeof(self)weakSelf = self;
    [controller dismissViewControllerAnimated:animated completion:^{
        weakSelf.presentViewController = nil;
        weakSelf.pickerType = IPManagerPickerTypeNon;
        weakSelf.isShowImagePicker = NO;
        weakSelf.customNavigation = nil;
    }];
}

- (void)dismissImagePickerAnimated:(BOOL)animated result:(NSArray *)result {
    debug(^{
        NSLog(@"%s\n", __FUNCTION__);
        for (IPImage *image in result) {
            if (image.asset) {
                printf("asset:\t%s\n",[[NSString stringWithFormat:@"%@", image.asset] UTF8String]);
            } else {
                printf("info:\t%s\n",[[NSString stringWithFormat:@"%@", image.info] UTF8String]);
            }
        }
        printf("======================== The End ======================\n\n");
    });
    if (self.managerPickerResultBlock) self.managerPickerResultBlock(result);
    [self.delegate didFinishedSelecteWithImages:result];
    [self dismissImagePickerAnimated:animated];
}

#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info; {
    __weak typeof(self)weakSelf = self;
    [IPImage referenceURL:[info objectForKey:UIImagePickerControllerReferenceURL] mediaName:^(NSString *name) {
        IPImage *image = [[IPImage alloc] initWithInfo:info imageName:name];
        [weakSelf dismissImagePickerAnimated:YES result:@[image]];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    [self dismissImagePickerAnimated:YES result:nil];
}

@end


@implementation IPManager (Tools)

+ (void)contentsFrom:(NSArray *)iImages progress:(NSProgress **)progress result:(void (^)(NSString *basePath, NSArray *fileName))result; {
    if (iImages.count == 0) {
        result(nil,nil);
        return;
    }
    NSProgress *p = [NSProgress progressWithTotalUnitCount:iImages.count];
    *progress  =p;
    NSMutableArray *arr = [NSMutableArray array];
    NSString *basePath = (NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyMMddHHmmss"];
    basePath = [basePath stringByAppendingPathComponent:[f stringFromDate:[NSDate date]]];
    [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < iImages.count; i++) {
            IPImage *image = [iImages objectAtIndex:i];
            NSString *name = [NSString stringWithFormat:@"%d.%@", i+1, image.imageName.pathExtension];
            NSString *path = [basePath stringByAppendingPathComponent:name];
            NSError *error = nil;
            [[image data] writeToFile:path options:NSDataWritingAtomic error:&error];
            if ( ! error) {
                [arr addObject:name];
            } else {
                debug(^{
                    NSLog(@"\n%@ write to file error %@", name, error);
                });
            }
            p.completedUnitCount ++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            result(basePath, [NSArray arrayWithArray:arr]);
        });
    });
}

@end

