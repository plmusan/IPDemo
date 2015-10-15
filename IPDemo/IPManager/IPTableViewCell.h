//
//  IPTableViewCell.h
//  ImagePickerManager
//
//  Created by x.wang on 15/3/13.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPGroup;

@interface IPTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *posterImage;
@property (strong, nonatomic) IBOutlet UILabel *groupName;

- (void)configCell:(IPGroup *)group;

@end
