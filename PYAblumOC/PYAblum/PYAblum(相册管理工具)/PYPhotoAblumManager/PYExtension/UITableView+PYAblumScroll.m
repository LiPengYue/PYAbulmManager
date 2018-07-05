//
//  UITableView+PYAblumScroll.m
//  PYPhotoAblumManager_SwiftDemo
//
//  Created by 李鹏跃 on 2018/1/31.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "UITableView+PYAblumScroll.h"
#import <objc/runtime.h>
#import "PYAblum.h"

@implementation UIScrollView (PYAblumScroll)
static NSString const*k_selectedCellArrayKey = @"selectedCellArrayKey";
- (void)setSelectedCellArray:(NSMutableArray *)selectedCellArray {
    
    objc_setAssociatedObject(self, &k_selectedCellArrayKey, selectedCellArray, OBJC_ASSOCIATION_RETAIN);
}
- (NSMutableArray *)selectedCellArray {
    NSMutableArray *array = objc_getAssociatedObject(self, &k_selectedCellArrayKey);
    if (!array) {
        objc_setAssociatedObject(self, &k_selectedCellArrayKey, [NSMutableArray new], OBJC_ASSOCIATION_RETAIN);
    }
    return objc_getAssociatedObject(self, &k_selectedCellArrayKey);
}

///清除所有选中model
- (void)removeAllSelectedModel {
    [self.selectedCellArray removeAllObjects];
}
@end




@implementation UITableView (PYAblumTableView)

/**
 管理选中的assetModel
 
 @param clickedCellModel 被点击的cell 的 model
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param clickCallBack 超出最大数量的回调
 */
- (void)clickedCellWithModel:(PYAssetModel *)clickedCellModel andMaxCount:(NSInteger)maxCount andCallBack:(void (^)(NSArray<PYAssetModel *> *, BOOL))clickCallBack {
    
    [PYAblum getSelectAssetArrayWithClickedModel:clickedCellModel andMaxCount:maxCount andOverTopBlock:clickCallBack];
}
@end


@implementation UICollectionView (PYAblumCollectionView)

/**
 管理选中的assetModel
 
 @param clickedCellModel 被点击的cell 的 model
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param clickCallBack 超出最大数量的回调
 */
- (NSArray <PYAssetModel *>*)clickedCellWithModel:(PYAssetModel *)clickedCellModel andMaxCount:(NSInteger)maxCount andCallBack:(void (^)(NSArray<PYAssetModel *> *, BOOL))clickCallBack {
    return [PYAblum getSelectAssetArrayWithClickedModel:clickedCellModel andMaxCount:maxCount andOverTopBlock:clickCallBack];
}
- (void) dealloc {
    [self.selectedCellArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.orderNumber = -1;
        obj.isSelected = false;
    }];
}
@end
