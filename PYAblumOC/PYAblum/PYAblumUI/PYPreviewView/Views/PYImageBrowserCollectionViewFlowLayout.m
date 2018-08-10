//
//  PYImageBrowserCollectionViewFlowLayout.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/1.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserCollectionViewFlowLayout.h"

@implementation PYImageBrowserCollectionViewFlowLayout

-(instancetype)init
{
    if(self=[super init]){
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
}

#pragma mark - 重写父类的方法
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    return array;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    //1. 获取UICollectionView停止的时候的可视范围
    CGRect rangeFrame;
    rangeFrame.size = self.collectionView.frame.size;
    rangeFrame.origin = proposedContentOffset;
    
    NSArray *array = [self layoutAttributesForElementsInRect:rangeFrame];
    
    //2. 计算在可视范围的距离中心线最近的Item
    CGFloat minCenterX = CGFLOAT_MAX;
    CGFloat collectionCenterX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if(ABS(attrs.center.x - collectionCenterX) < ABS(minCenterX)){
            minCenterX = attrs.center.x - collectionCenterX;
        }
    }
    //3. 补回ContentOffset，则正好将Item居中显示
    return CGPointMake(proposedContentOffset.x + minCenterX, proposedContentOffset.y);
}

@end
