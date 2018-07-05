//
//  PYAssetManager.h
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PYAblumManagerCommon.h"
@class PYAssetModel;
@class PHFetchResult;
///资源管理者, 获取 相册中的资源
@interface PYAssetManager : NSObject

//MARK: - 筛选
///最小的 图片的size 默认 为 （0，0）
@property (nonatomic,assign) CGSize minSize;
///最大的 图片的size 默认 为（80，80）
@property (nonatomic,assign) CGSize maxSize;
///最短时长 默认为 0
@property (nonatomic,assign) CGFloat minTime;
///最长时长 默认为 1小时
@property (nonatomic,assign) CGFloat maxTime;
///资源类型 type
@property (nonatomic,assign) Enum_PYAblumManager_AssetType type;

///MARK: - 要继承自 PYAssetModel,
///默认 PYAssetModel
@property (nonatomic,strong) Class assetModelClass;

/**
 管理选中的assetModel
 
 @param clickedModel 被点击的model
 @param beOperatedArray 被操作的数组（请穿一个生命周期适当的数组）
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param block 超出最大数量的回调
 @return 返回被操作后的数组
 */
+ (NSMutableArray <PYAssetModel *>*)getSelectAssetArrayWithClickedModel: (PYAssetModel *)clickedModel andBeOperated: (NSMutableArray <PYAssetModel *>*) beOperatedArray andMaxCount:(NSInteger) maxCount andOverTopBlock: (void(^)(NSArray <PYAssetModel *>*modelArray, BOOL isVoerTop))block;

///解析 asset
- (NSArray <PYAssetModel *>*)getAssetWithFetchResult:(PHFetchResult<PHAsset *>*)fetchResult;
@end
