//
//  PYAssetListView.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//
#import "PYAblum.h"
#import <UIKit/UIKit.h>
#import "PYAssetListViewConfiguration.h"
#import "PYAssetList_CollectionViewCell.h"

@protocol PYAssetListViewProtocol <NSObject>


/**
 设置 cell会在数据源中调用此方法

 @param collectionView collectionView
 @param cell 当前index的cell
 @param index index
 */
- (void) setupCell: (UICollectionView *)collectionView
          andIndex: (NSIndexPath *) index
           andCell: (UICollectionViewCell *)cell;



/**
 选中了button
 */
@required
- (void)clickRightButtonWithSelectedModel: (PYAssetModel *)model
                    andSelectedModelArray: (NSArray <PYAssetModel *>*)modelArray
             andIsOverTopMaxSelectedCount: (BOOL) isOverTop;


/**
 最多能选中多少个model 默认为
 */
@required
- (NSInteger)maxSelectedCount;


/**
 * 点击了imageView
 */
@required
- (void)clickImageViewWithClickModel: (PYAssetModel *)model andModelArray: (NSArray<PYAssetModel*>*) modelArray andSelectedIndex: (NSInteger)index andCell: (PYAssetList_CollectionViewCell *)cell;

@end




/**
 * 资源列表视图
 * 里面包含一个collectionView
 */
@interface PYAssetListView : UIView

/**
 * 配置 管理，set方法中，对布局等做了操作
 */
@property (nonatomic,strong) PYAssetListViewConfiguration *configuration;

/**
 * assetListViewDelegate
 */
@property (nonatomic,weak) id <PYAssetListViewProtocol> assetListViewDelegate;
@property (nonatomic,readonly) UICollectionView *assetCollectionView;

/**
 * reloadData
 */
- (void) reloadData;

//MARK: - init 
- (instancetype) initWithFrame:(CGRect)frame andConfiguration: (PYAssetListViewConfiguration *)configuration;
+ (instancetype) AssetListView: (PYAssetListViewConfiguration *)configuration;

///是否可以打开相册
+ (BOOL) isOpenPhotoAlbum: (void(^)(BOOL isOpen))openBlock;
///是否可以打开照相机
+ (BOOL) isOpenCamera;
@end
