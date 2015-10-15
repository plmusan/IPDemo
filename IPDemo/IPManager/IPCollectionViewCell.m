//
//  IPCollectionViewCell.m
//  ImagePickerManager
//
//  Created by x.wang on 15/3/13.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import "IPCollectionViewCell.h"
#import "IPImage.h"

@implementation IPCollectionViewCell

- (void)configCell:(IPImage *)image; {
    self.thumbnail.image = image.thumbnail;
    self.selecteImage.hidden = ! image.isSelected;
}

@end
