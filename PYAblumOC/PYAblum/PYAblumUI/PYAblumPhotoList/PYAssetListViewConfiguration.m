//
//  PYAssetListViewConfiguration.m
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAssetListViewConfiguration.h"
#import "PYAssetList_CollectionViewCell.h"
#import "PYAssetModel.h"
CGFloat lineSpacing = 2;
@implementation PYAssetListViewConfiguration

- (UICollectionViewFlowLayout *)layout {
    if(!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        _layout.minimumLineSpacing = lineSpacing;
        _layout.minimumInteritemSpacing = lineSpacing;
        ///默认
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat itemW = (w - lineSpacing * 3.0) / 4.0;
        ///
        _layout.itemSize = CGSizeMake(itemW, itemW);
    }
    return _layout;
}
- (Class) cellClass {
    if (!_cellClass) {
        _cellClass = PYAssetList_CollectionViewCell.class;
    }
    return _cellClass;
}
- (Class) pyAssetModelClass {
    if (!_pyAssetModelClass) {
        _pyAssetModelClass = PYAssetModel.class;
    }
    return _pyAssetModelClass;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageWidth = 300;
        self.maxAssetSelectedCount = 8;
    }
    return self;
}
@end
