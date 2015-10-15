//
//  IPCollectionViewCell.h
//  ImagePickerManager
//
//  Created by x.wang on 15/3/13.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPImage;

@interface IPCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnail;
@property (strong, nonatomic) IBOutlet UIImageView *selecteImage;

- (void)configCell:(IPImage *)image;

@end
