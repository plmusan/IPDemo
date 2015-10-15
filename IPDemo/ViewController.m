//
//  ViewController.m
//  IPDemo
//
//  Created by x.wang on 15/5/7.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import "ViewController.h"
#import "IPManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@property (nonatomic) IPManager *manager;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (IBAction)buttonPressed:(id)sender {
    __weak typeof(self)weakSelf = self;
    self.manager.managerPickerResultBlock = ^(NSArray *result) {
        IPImage *image = result.firstObject;
        weakSelf.imageView.image = image.fullResolutionImage;
        NSProgress *p = nil;
        [IPManager contentsFrom:result progress:&p result:^(NSString *basePath, NSArray *fileName) {
            NSLog(@"%s BasePaht:\n%@", __FUNCTION__, basePath);
        }];
    };
    [self.manager showImagePickerWithViewContriller:self pickerType:IPManagerPickerTypeCustomSelecteAll animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.manager = [IPManager shareManager];
    self.manager.maxNumberForSelected = 2;
    self.manager.msgForNumberExceeded = @"You couldn't do it !";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
