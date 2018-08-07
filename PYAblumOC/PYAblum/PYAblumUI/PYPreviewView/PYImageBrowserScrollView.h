//
//  PYImageBrowserScrollView.h
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/1.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PYImageBrowserScrollView;
@protocol PYImageBrowserScrollViewProtocol <NSObject>
- (void)singleTapEventFonc: (PYImageBrowserScrollView *) scrollView andTap: (UITapGestureRecognizer *)tap;

- (void)doubleTapEventFonc: (PYImageBrowserScrollView *) scrollView andTap: (UITapGestureRecognizer *)tap;

- (void)pullDowningFunc: (PYImageBrowserScrollView *) scrollView andPan:(UIPanGestureRecognizer *)pan;
@end

@interface PYImageBrowserScrollView : UIScrollView
@property (nonatomic,weak) id <PYImageBrowserScrollViewProtocol> browserScrollViewProtocol;
/// 双击
@property (nonatomic,readonly,strong) UITapGestureRecognizer *doubleTap;
///单击
@property (nonatomic,readonly,strong) UITapGestureRecognizer *singleTap;
@end
