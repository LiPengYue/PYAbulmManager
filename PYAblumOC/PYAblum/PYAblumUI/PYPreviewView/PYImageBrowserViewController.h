//
//  PYPreViewVC.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/11.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYImageBrowserView.h"
#import "PYImageBrowserViewControllerConfiguration.h"
#import "PYImageBrowserCollectionViewCell.h"
struct PYImageBrowserViewDefaultAnimation {
  
};

@class PYImageBrowserViewController;
@protocol PYImageBrowserViewControllerDataSource <NSObject>


/**
 设置collectionView 懒加载collectionView的时候回调用，可以进行cell的register
 @param collectionView collectionView
 */
- (void) setUpCollectionView: (UICollectionView *) collectionView;

/**
 一共多少个图片需要展示
 @return image的总量
 */
- (NSInteger)numberOfItems;

/**
 数据源方法
 @param collectionView collectionView
 @param cell cell
 @param indexPath index
 @return cell
 */
- (UICollectionViewCell *)collectionView: (UICollectionView *) collectionView
                                 andCell:(PYImageBrowserCollectionViewCell *) cell
                            andIndexPath:(NSIndexPath *)indexPath;
@end


@protocol PYImageBrowserViewControllerDelegate <NSObject>

- (void)singleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap;

- (void)doubleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap;

- (void)pullDowningFunc: (PYImageBrowserCollectionViewCell *) cell
          andScrollView:(UIScrollView *)scrollView;

- (void)scrollViewDidZoom: (PYImageBrowserCollectionViewCell *)cell
                    index: (NSIndexPath *)index
     changeIndexPathArray: (NSArray <NSIndexPath *>*)indexArray;


/**
 当dismiss之前调用，需要返回当前index对应的dismiss动画图片目的地的view
 @param cell 当前执行dismiss动画的cell
 @param index 当前cell的 indexPath 请取 index.row 
 @return 当前index对应的dismiss动画图片的目的地的view
    如果返回nil，将会执行 设置好的默认动画
 */
- (CGRect)dismissWithCurrenCell: (PYImageBrowserCollectionViewCell *)cell andIndex: (NSIndexPath *)index;
@end



@interface PYImageBrowserViewController : UIViewController <PYImageBrowserViewDelegate>
- (void) setUpTriggerModalImage: (UIImage *)triggerModalImage
                   andView: (UIView *) triggerModalView
    andImageViewConentMode: (UIViewContentMode)mode;

@property (nonatomic,readonly) PYImageBrowserView *previewView;
@property (nonatomic,weak) id <PYImageBrowserViewControllerDelegate> delegate;
@property (nonatomic,weak) id <PYImageBrowserViewControllerDataSource> dataSource;
@property (nonatomic,strong) PYImageBrowserViewControllerConfiguration *configuration;

+ (instancetype) createWihtConfig:(PYImageBrowserViewControllerConfiguration *) config;
@end


