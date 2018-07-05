//
//  PYAssetListViewConfiguration.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAblum.h"
/// 配置资源列表页 相关数据 ，如果不传，那么会有默认配置
@interface PYAssetListViewConfiguration : NSObject


/**
 * 默认为 PYAssetModel
 * 这个属性关系到你的collectionViewCell中 接受到哪种Model
 */
@property (nonatomic,strong) Class pyAssetModelClass;

/**
 * layout collectionView 的layout
 */
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

/**
 * 自定的 cllectionViewCell 的class
 * (一定要继承自 PYAssetList_CollectionViewCell)
 */
@property (nonatomic,strong) Class cellClass;

/**
 * collectionView 的delegate
 */
@property (nonatomic,weak) id <UICollectionViewDelegate> delegate;


//获取的数据类型
@property (nonatomic,assign) Enum_PYAblumManager_AssetType assetType;

/**
 * 获取的图片的大小 (缩略图)
 */
@property (nonatomic,assign) CGFloat imageWidth;

/**
 * 选中的图片的大小
 */
@property (nonatomic,assign) CGFloat selectedImageWidth;
/**
 * collectionView 的背景色
 */
@property (nonatomic,assign) UIColor *collectionViewColor;

/**
 * 最多选择 asset 数量
 * 默认8张
 */
@property (nonatomic,assign) NSInteger maxAssetSelectedCount;
@end

