//
//  PYPreviewCollectionViewCell.h
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/1.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYImageBrowserScrollView.h"

@class PYImageBrowserCollectionViewCellProtocol;
@class PYImageBrowserCollectionViewCell;
@protocol PYImageBrowserCollectionViewCellProtocol <NSObject>
- (void)singleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap;

- (void)doubleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap;

- (void)pullDowningFunc: (PYImageBrowserCollectionViewCell *) cell;

///
- (void)pullingFuncChangeColor: (BOOL) isDow;

- (void)scrollViewDidZoom: (PYImageBrowserCollectionViewCell *)cell index: (NSIndexPath *)index;

- (void)dismissWithCurrenCell: (PYImageBrowserCollectionViewCell *)cell andIndex: (NSIndexPath *)index;
@end


@interface PYImageBrowserCollectionViewCell : UICollectionViewCell <PYImageBrowserScrollViewProtocol,UIScrollViewDelegate>

@property (nonatomic,strong,readonly) UIImageView *imageBrowserImageView;
@property (nonatomic,strong,readonly) PYImageBrowserScrollView *scrollView;


@property (nonatomic,weak) id <PYImageBrowserCollectionViewCellProtocol> delegate;

/// 向下拉多少，触发dismiss 默认为 10tp
@property (nonatomic,assign) CGFloat minPullDownDistance;

/// indexPath
@property (nonatomic,strong) NSIndexPath *indexPath;
/// 恢复原始大小
- (void) restoreOriginalScale;
/// 自动控制伸缩比例
- (void) isAutoControlScale;
@end
