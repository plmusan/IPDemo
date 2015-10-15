//
//  IPTableViewCell.m
//  ImagePickerManager
//
//  Created by x.wang on 15/3/13.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import "IPTableViewCell.h"
#import "IPImage.h"

@implementation IPTableViewCell

- (void)configCell:(IPGroup *)group; {
    self.posterImage.image = [group posterImage];
    self.groupName.text = [NSString stringWithFormat:@"%@(%ld)",group.groupName, (long)[group numberOfCount]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
