//
//  ViewController.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/7/5.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//


#import "ViewController.h"
#import "UIColor+GetRGB.h"
#import "PYAblumHeader.h"
#import "PYImageBrowserViewController.h"
#import "PYImageBrowserViewControllerConfiguration.h"
@interface ViewController ()<PYAssetListViewProtocol,PYImageBrowserViewControllerDelegate,PYImageBrowserViewControllerDataSource>
@property (nonatomic,strong) PYAssetListView *assetView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation ViewController
typedef enum {
    
    aa,
    bb
} PUHSSETUPURL;
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.imageView = [UIImageView new];
//    self.imageView.image = [UIImage imageNamed:@"1."];
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.button = [UIButton new];
//    [self.view addSubview:self.imageView];
//    [self.view addSubview:self.button];
//    self.button.frame = CGRectMake(100, 100, 100, 100);
//    self.imageView.frame = self.button.frame;
//    [self.button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.assetView];
}

- (void)clickButton {
    PYImageBrowserViewController *VC = [PYImageBrowserViewController new];
    VC.delegate = self;
    VC.dataSource = self;
    [VC setUpTriggerModalImage:[UIImage imageNamed:@"1."] andView:self.imageView
   andImageViewConentMode:UIViewContentModeScaleAspectFit];
    [self presentViewController:VC animated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// MARK: - getter
- (PYAssetListView *) assetView {
    if (!_assetView) {
        PYAssetListViewConfiguration *configuration = [[PYAssetListViewConfiguration alloc] init];
        configuration.imageWidth = 400;
        configuration.selectedImageWidth = 600;
        configuration.maxAssetSelectedCount = 8;
        
        _assetView = [[PYAssetListView alloc] initWithFrame:self.view.bounds andConfiguration:configuration];
        _assetView.assetListViewDelegate = self;

    }
    return _assetView;
}

- (void) clickImageViewWithClickModel:(PYAssetModel *)model
                        andModelArray:(NSArray<PYAssetModel *> *)modelArray
                     andSelectedIndex:(NSInteger)index
                              andCell:(PYAssetList_CollectionViewCell *)cell{
    NSLog(@"%ld",index);
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
     PYImageBrowserViewControllerConfiguration *configuration = [PYImageBrowserViewControllerConfiguration new];
    configuration.selectedImageViewWindowFrame = [window convertRect:cell.imageView.frame fromView:cell];
    configuration.defaultSelectedImage = cell.imageView.image;
    configuration.defaultSelectedIndex = index;
    configuration.selectedImageViewContentMode = cell.imageView.contentMode;
    PYImageBrowserViewController *VC = [PYImageBrowserViewController createWihtConfig:configuration];
    VC.delegate = self;
    VC.dataSource = self;
    [self presentViewController:VC animated:true completion:nil];
}

- (void) clickRightButtonWithSelectedModel:(PYAssetModel *)model
                     andSelectedModelArray:(NSArray<PYAssetModel *> *)modelArray
              andIsOverTopMaxSelectedCount:(BOOL)isOverTop {
    if (isOverTop) { NSLog(@"🌶 ：超出了"); return; }
    NSLog(@"%lu",(unsigned long)modelArray.count);
}

- (NSInteger) maxSelectedCount {
    return 10;
}


//MARK: - delegate  PYImageBrowser
- (CGRect)dismissWithCurrenCell:(PYImageBrowserCollectionViewCell *)cell andIndex:(NSIndexPath *)index {
     UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSIndexPath *indexPath = index;
    PYAssetList_CollectionViewCell *collectionViewCell = [self.assetView.assetCollectionView
     cellForItemAtIndexPath:indexPath];
    
    return [window convertRect:collectionViewCell.imageView.frame fromView:collectionViewCell];
}
- (NSInteger)numberOfItems {
    return [PYAblum defaultAblum].allPhotoAblumModelArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                                 andCell:(PYImageBrowserCollectionViewCell *)cell
                            andIndexPath:(NSIndexPath *)indexPath {
    NSArray<PYAssetModel *>* assetModelArray = [PYAblum defaultAblum].allPhotoAblumModelArray;
    if (assetModelArray.count > indexPath.row) {
        PYAssetModel *assetModel = assetModelArray[indexPath.row];
        UIImage *image = assetModel.delicateImage;
        [self.assetView.assetCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:false];
        image = image == nil ? assetModel.degradedImage : image;
        image = image == nil ? assetModel.originImage : image;
        if (!assetModel.delicateImage) {
            [assetModel getDelicateImageWidth:300 andBlock:^(UIImage *image) {
                cell.imageBrowserImageView.image = image;
            }]; 
        }
        cell.imageBrowserImageView.image = image;
    }
    return cell;
}
@end
