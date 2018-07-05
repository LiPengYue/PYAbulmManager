//
//  PYAssetManager.m
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAssetManager.h"
#import "PYAssetModel.h"
@implementation PYAssetManager {
    BOOL _limitMinSize;
    BOOL _limitMaxSize;
    BOOL _limitMinTime;
    BOOL _limitMaxTime;
    BOOL _limitType;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _limitMinSize = false;
        _limitMaxSize = false;
        _limitMinTime = false;
        _limitMaxTime = false;
        _limitType = false;
    }
    return self;
}

/**
 管理选中的assetModel
 
 @param clickedModel 被点击的model
 @param beOperatedArray 被操作的数组（请穿一个生命周期适当的数组）
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param block 超出最大数量的回调
 @return 返回被操作后的数组
 */
+ (NSMutableArray <PYAssetModel *>*)   getSelectAssetArrayWithClickedModel: (PYAssetModel *)clickedModel andBeOperated: (NSMutableArray <PYAssetModel *>*) beOperatedArray andMaxCount:(NSInteger) maxCount andOverTopBlock: (void(^)(NSArray <PYAssetModel *>*modelArray, BOOL isVoerTop))block {
    
    clickedModel.isSelected = !clickedModel.isSelected;
    BOOL isContainsModel = [beOperatedArray containsObject:clickedModel];
    if (!clickedModel.isSelected && isContainsModel) {
        [beOperatedArray removeObject:clickedModel];
        clickedModel.orderNumber = -1;
    }else if (clickedModel.isSelected && !isContainsModel) {
        [beOperatedArray addObject:clickedModel];
    }
    [beOperatedArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.orderNumber = idx + 1;
    }];
    BOOL isOverTop = beOperatedArray.count > maxCount && maxCount > 0;
    if (isOverTop) {
        beOperatedArray.lastObject.isSelected = false;
        beOperatedArray.lastObject.orderNumber = -1;
        [beOperatedArray removeLastObject];
    }
     block(beOperatedArray,isOverTop);
    return beOperatedArray;
}


///解析 asset
- (NSArray <PYAssetModel *>*)getAssetWithFetchResult:(PHFetchResult<PHAsset *>*)fetchResult {
    NSMutableArray <PYAssetModel *>*assetArrayM = [[NSMutableArray alloc]init];
    for (PHAsset *asset in fetchResult) {
        //尺寸是否合格
        BOOL isQualified_MinSize =[self isQualified_MinSize:asset];
        BOOL isQualified_MaxSize = [self isQualified_MaxSize:asset];
        //类型是否合格
        BOOL isQualified_Type = [self isQualifiedType:asset];
        //过滤
        if (!isQualified_MinSize || !isQualified_MaxSize || !isQualified_Type) {NSLog(@"🌶，内容不匹配");continue;}
        //转化
        if (!self.assetModelClass) {
            self.assetModelClass = PYAssetModel.class;
            NSLog(@"🐖:没有self.assetModel 没有值，已经自动赋值为PYAssetModel.class");
        }
        PYAssetModel *assetModel = (PYAssetModel *)[self.assetModelClass new];
        assetModel.asset = asset;
        //这里的 0 已经被排除
        NSInteger assetType = asset.mediaType;
        assetModel.assetType = assetType;
        assetModel.isSelected = false;
        [assetArrayM addObject:assetModel];
    }
    return assetArrayM.copy;
}

- (BOOL) isQualified_MinSize: (PHAsset *)asset {
    BOOL isMinH = (asset.pixelHeight >= self.minSize.height);
    BOOL isMinW = asset.pixelWidth >= self.minSize.width;
    BOOL isMin = (isMinW && isMinH) || !_limitMinSize;
    if (!isMin) {
        
        NSLog(@"size小于 %@，%@",[NSValue valueWithCGSize:self.minSize],asset);
    }
    return isMin;
}
- (BOOL) isQualified_MaxSize: (PHAsset *)asset {
    BOOL isMaxH = (asset.pixelHeight <= self.maxSize.height);
    BOOL isMaxW = asset.pixelWidth <= self.maxSize.width;
    BOOL isMax = (isMaxW && isMaxH) || !_limitMinSize;
    if (!isMax) {
        NSLog(@"size大于 %@，%@",[NSValue valueWithCGSize:self.maxSize],asset);
    }
    return isMax;
}

- (BOOL) isQualifiedType: (PHAsset *)asset {
    NSInteger type = self.type;
    NSInteger mediaType = asset.mediaType;
    BOOL isType = (type == mediaType) || !_limitType;
    if (!isType) {
        NSLog(@"typy 不符合默认设置，%@",asset);
    }
    return isType;
}
- (void)setMaxSize:(CGSize)maxSize {
    _maxSize = maxSize;
    _limitMaxSize = true;
}

- (void)setMinSize:(CGSize)minSize {
    _minSize = minSize;
    _limitMinSize = true;
}
- (void)setType:(Enum_PYAblumManager_AssetType)type {
    _type = type;
    _limitType = true;
}
@end
