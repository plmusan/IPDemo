//
//  IPTableViewController.m
//  ImagePickerManager
//
//  Created by x.wang on 15/3/13.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import "IPTableViewController.h"
#import "IPTableViewCell.h"
#import "IPCollectionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IPManager.h"

@interface IPDataSource : NSObject

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *allImages;
- (void)updateGroup:(void (^)(void))succeed;
- (void)imageWithGroup:(IPGroup *)group succeed:(void (^)(NSArray *result))succeed;

@end

@interface IPTableViewController ()

@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) IPDataSource *datasourceManager;

@end

static NSString * const TableViewCell = @"IPTableViewCell";
static NSString * const CollectionView = @"IPCollectionViewController";

@implementation IPTableViewController

- (IBAction)cancelButtonPressed:(id)sender {
    [[IPManager shareManager] dismissImagePickerAnimated:YES result:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.datasourceManager = [[IPDataSource alloc] init];
    
    __weak typeof(self)weakSelf = self;
    [self.datasourceManager updateGroup:^{
        weakSelf.datasource = weakSelf.datasourceManager.groups;
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([IPManager shareManager].groupTitle) {
        self.navigationItem.title = [IPManager shareManager].groupTitle;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCell forIndexPath:indexPath];
    // Configure the cell...
    [cell configCell:[self.datasource objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)weakSelf = self;
    IPGroup *group = [self.datasource objectAtIndex:indexPath.row];
    [self.datasourceManager imageWithGroup:group succeed:^(NSArray *result) {
        IPCollectionViewController *controller = [weakSelf.storyboard
                                                  instantiateViewControllerWithIdentifier:CollectionView];
        controller.dataSource = result;
        controller.groupName = group.groupName;
        [weakSelf.navigationController pushViewController:controller animated:YES];
    }];
}

@end

@implementation IPDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        self.groups = [NSMutableArray array];
        self.allImages = [NSMutableArray array];
    }
    return self;
}

- (void)updateGroup:(void (^)(void))succeed; {
    [self.groups removeAllObjects];
    __weak typeof(self)weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            IPGroup *iGroup = [[IPGroup alloc] init];
            iGroup.group = group;
            iGroup.groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            [weakSelf.groups addObject:iGroup];
            debug(^{
                NSLog(@"group %@",group);
            });
        } else {
            succeed ();
        }
    } failureBlock:^(NSError *error) {
        debug(^{
            NSLog(@"\nGroup not found!\nerror:%@", error);
        });
    }];
}

- (void)imageWithGroup:(IPGroup *)group succeed:(void (^)(NSArray *result))succeed {
    switch ([IPManager shareManager].pickerType) {
        case IPManagerPickerTypeCustomSelecteImage:
            [group.group setAssetsFilter:[ALAssetsFilter allPhotos]];
            break;
        case IPManagerPickerTypeCustomSelecteMovie:
            [group.group setAssetsFilter:[ALAssetsFilter allVideos]];
            break;
        case IPManagerPickerTypeCustomSelecteAll:
            [group.group setAssetsFilter:[ALAssetsFilter allAssets]];
            break;
        default:
            succeed(nil);
            return;
    }
    NSMutableArray *assetArr = [NSMutableArray array];
    [group.group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            IPImage *image = [[IPImage alloc] initWithAsset:result];
            [assetArr addObject:image];
        } else if (stop) {
            succeed ([NSArray arrayWithArray:assetArr]);
        }
    }];
}

@end



