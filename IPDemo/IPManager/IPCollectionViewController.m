//
//  IPCollectionViewController.m
//  ImagePickerManager
//
//  Created by x.wang on 15/3/13.
//  Copyright (c) 2015年 x.wang. All rights reserved.
//

#import "IPCollectionViewController.h"
#import "IPCollectionViewCell.h"
#import "IPManager.h"

@interface IPCollectionViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSMutableArray *selectedImage;

@end

static NSString * const CollectionCell = @"IPCollectionViewCell";

@implementation IPCollectionViewController

- (IBAction)doneButtonPressed:(id)sender {
    [[IPManager shareManager] dismissImagePickerAnimated:YES result:[NSArray arrayWithArray:self.selectedImage]];
}

- (void)configDoneButton; {
    self.doneButton.enabled = self.selectedImage.count >= [IPManager shareManager].minNumberForSelected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    // Do any additional setup after loading the view.
    self.selectedImage = [NSMutableArray array];
    [self configDoneButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.groupName) {
        self.navigationItem.title = self.groupName;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    IPCollectionViewCell *cell = (IPCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    IPImage *iImage = [self.dataSource objectAtIndex:indexPath.row];
    if (self.selectedImage.count < [IPManager shareManager].maxNumberForSelected || iImage.isSelected) {
        iImage.isSelected = ! iImage.isSelected;
        [cell configCell:iImage];
        if (iImage.isSelected) {
            [self.selectedImage addObject:iImage];
        } else {
            [self.selectedImage removeObject:iImage];
        }
    } else {
        [self showAlert];
    }
    [self configDoneButton];
}

- (void)showAlert; {
    NSString *msg = [IPManager shareManager].msgForNumberExceeded;
    if (msg) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCell forIndexPath:indexPath];
    // Configure the cell
    [cell configCell:[self.dataSource objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    CGFloat width = 30;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        width = ((collectionView.frame.size.width - 12) / 5); // 5 cell each line
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = ((collectionView.frame.size.width - 20) / 9); // 9 cell each line
    }
    return CGSizeMake(width, width);
}


@end
