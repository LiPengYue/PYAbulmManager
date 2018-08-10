//
//  PYImageBrowserView.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/11.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAblum.h"
@class PYImageBrowserCollectionViewFlowLayout;
@class PYImageBrowserCollectionViewCell;

@protocol PYImageBrowserViewDelegate <NSObject>
/**
 collectionView 的flowLayout
 */
- (PYImageBrowserCollectionViewFlowLayout *) getCollectionViewLayout;

- (NSInteger) numberOfItems;

/**
 数据源方法，获取了默认的cell，如果自定义可以返回需要的cell，这样将会覆盖默认的cell

 @param collectionView collectionView
 @param cell 默认dequeue的cell
 @param indexPath indexPath
 @return cell
 */
- (UICollectionViewCell *)collectionView: (UICollectionView *) collectionView
                                 andCell:(PYImageBrowserCollectionViewCell *) cell
                            andIndexPath:(NSIndexPath *)indexPath;


/**
 设置collectionView 创建collectionView的时候回调用一次
 @param collectionView collectionView
 */
- (void) setUpCollectionView: (UICollectionView *) collectionView;

- (void)singleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap;

- (void)doubleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap;

- (void)pullDowningFunc: (PYImageBrowserCollectionViewCell *) cell andScrollView:(UIScrollView *)scrollView;

- (void)pullingFuncChangeColor: (BOOL) isDow;

- (void)scrollViewDidZoom: (PYImageBrowserCollectionViewCell *)cell
                    index: (NSIndexPath *)index
     changeIndexPathArray: (NSArray <NSIndexPath *>*)indexArray;

- (void)dismissWithCurrenCell: (PYImageBrowserCollectionViewCell *)cell andIndex: (NSIndexPath *)index;
@end


///预览 （点击图片后，会跳到预览图片界面）
@interface PYImageBrowserView : UIView <UICollectionViewDataSource>

///数据源
@property (nonatomic,strong) NSArray <PYAssetModel *> *assetModelArray;

///cell class 需要继承自 PYImageBrowserCollectionViewCell
@property (nonatomic,strong) Class cellClass;

@property (nonatomic,weak) id <PYImageBrowserViewDelegate> delegate;

- (void)removeChangeIndexWithArray: (NSIndexPath *)index;
- (void)addChangeArrayWithIndex: (NSIndexPath *)index;
- (void)removeAllChangeIndex;
- (void)setupDefaultSelectedIndex: (NSInteger)index;
@end

