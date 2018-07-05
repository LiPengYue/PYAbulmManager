//
//  UITableView+PYAblumScroll.h
//  PYPhotoAblumManager_SwiftDemo
//
//  Created by 李鹏跃 on 2018/1/31.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PYAssetModel;
@interface UIScrollView (PYAblumScroll)
- (void)baseSelectedModelArray: (NSArray <PYAssetModel *>*)modelArray;
///储存选中 asset 的model数组
@property (nonatomic,copy) NSMutableArray <PYAssetModel *>*selectedCellArray;
///清除所有选中model
- (void)removeAllSelectedModel;
@end



@interface UITableView (PYAblumTableView)
/**
 管理选中的assetModel
 * (tableView 与collectionView都写了分类，请调用 对象方法 ‘clickedCellWithModel’)
 
 @param clickedCellModel 被点击的model
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param clickCallBack 超出最大数量的回调
 */
- (void)clickedCellWithModel:(PYAssetModel*)clickedCellModel
                 andMaxCount: (NSInteger) maxCount
                 andCallBack: (void(^)(NSArray <PYAssetModel *>*selecetmodelArray,BOOL isOverTop)) clickCallBack;

@end

@interface UICollectionView (PYAblumCollectionView)
/**
 管理选中的assetModel
 * (tableView 与collectionView都写了分类，请调用 对象方法 ‘clickedCellWithModel’)
 
 @param clickedCellModel 被点击的model
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param clickCallBack 超出最大数量的回调
 */
- (NSArray <PYAssetModel *>*)clickedCellWithModel:(PYAssetModel*)clickedCellModel
                 andMaxCount: (NSInteger) maxCount
                 andCallBack: (void(^)(NSArray <PYAssetModel *>*selecetmodelArray,BOOL isOverTop)) clickCallBack;

@end
