//
//  PYImageBrowserViewControllerAnimatedTransition.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/2.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserViewControllerAnimatedTransition.h"
#import "UIImage+zip.h"
#import "UIColor+GetRGB.h"
@interface PYImageBrowserViewControllerAnimatedTransition()


@end

static NSInteger const animationImageViewTag = 10003245667;

@implementation PYImageBrowserViewControllerAnimatedTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dismissDefaultWidth = 100;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    //0 是present 1是dismiss
    return 2;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController * toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    PYImageBrowserViewController *toVC;
    PYImageBrowserViewController *fromVC;
    if ([toViewController isKindOfClass:PYImageBrowserViewController.class]) {
        toVC = (PYImageBrowserViewController *)toViewController;
    }
    if ([fromViewController isKindOfClass:PYImageBrowserViewController.class]) {
        fromVC = (PYImageBrowserViewController *)fromViewController;
    }
    
    UIView * contentView = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:(UITransitionContextToViewKey)];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    contentView.backgroundColor = [UIColor clearColor];
    
    if(self.isPresent){
        
        [self presentAnimation:contentView
                     andToView:toView
                    andContext:transitionContext
                       andToVC:toVC];
    }else{
        [self dismissAnimationAndFromView:fromView
                               andContext:transitionContext
                               andfromVC:fromVC];
        
    }
}
- (void) presentAnimation: (UIView *)contentView
                andToView: (UIView *)toView
               andContext: (id <UIViewControllerContextTransitioning>)transitionContext
                  andToVC: (PYImageBrowserViewController *)toVC {
    [contentView addSubview:toView];
    UIView *animationView = [self addPresentAnimationView:toView];
    animationView.frame = self.selectedImageViewWindowFrame;
    CGSize size = [self.defaultSelectedImage getSizeWithMaxHeight:toView.frame.size.height andMaxWidth:toView.frame.size.width];
    toVC.previewView.alpha = 0;
   
    BOOL isToVCViewBackColorNotClear = toVC.view.backgroundColor != UIColor.clearColor;
    if (isToVCViewBackColorNotClear) {
        toVC.view.backgroundColor = [toVC.view.backgroundColor alpha:0];
    }else{
        toVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
    [UIView animateWithDuration:self.presentAnimationDefaultDuration animations:^{
        if (isToVCViewBackColorNotClear) {
            toVC.view.backgroundColor = [toVC.view.backgroundColor alpha:1];
        }else{
            toVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        }
        animationView.bounds = CGRectMake(0, 0, size.width, size.height);
        animationView.center = toView.center;
    }completion:^(BOOL finished) {
        if (!isToVCViewBackColorNotClear) {
            toVC.view.backgroundColor = UIColor.clearColor;
        }
        toVC.previewView.alpha = 1;
        
        [self removeAnimationViewWithToView:toView];
        [transitionContext completeTransition:YES];
    }];
}

- (void)dismissAnimationAndFromView:(UIView *)fromView
                         andContext: (id <UIViewControllerContextTransitioning>) transitionContext
                         andfromVC: (PYImageBrowserViewController *)fromVC {
    UIView *animationView = [self addDismissAnimationView:fromView];
    CGFloat w = self.dismissDefaultWidth;
    CGFloat h = self.dismissDefaultWidth;
    CGFloat x = fromView.center.x;
    CGFloat y = fromView.center.y;
    
    if (self.dismissStartView) {
        w = self.dismissStartView.frame.size.width;
        h = self.dismissStartView.frame.size.height;
    }
    CGRect endViewFrame = self.dismissEndViewFrame;
    CGFloat maxX = CGRectGetMaxX(endViewFrame);
    CGFloat minX = CGRectGetMinX(endViewFrame);
    CGFloat maxY = CGRectGetMaxY(endViewFrame);
    CGFloat minY = CGRectGetMinY(endViewFrame);
    if (endViewFrame.size.width
        && maxX > 0
        && minX < fromVC.view.frame.size.width
        && maxY > 0
        && minY < fromVC.view.frame.size.height) {

        w = endViewFrame.size.width;
        h = endViewFrame.size.height;
        x = CGRectGetMidX(endViewFrame);
        y = CGRectGetMidY(endViewFrame);
    }else if (self.dismissDefaultWidth > 0){
        h = h / (w / self.dismissDefaultWidth);
        w = self.dismissDefaultWidth;
    }
    
    fromVC.previewView.alpha = 0;
    BOOL isfromVCViewBackColorNotClear = fromVC.view.backgroundColor != UIColor.clearColor;
//    if (isfromVCViewBackColorNotClear) {
//        fromVC.view.backgroundColor = [fromVC.view.backgroundColor alpha:1];
//    }else{
//        fromVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
//    }
    [UIView animateWithDuration:self.dismissAnimationDefaultDuration + 0.1 animations:^{
        if (isfromVCViewBackColorNotClear) {
            fromVC.view.backgroundColor = [fromVC.view.backgroundColor alpha:0];
        }else{
            fromVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        }
    }];
    [UIView animateWithDuration:self.dismissAnimationDefaultDuration animations:^{
       
        animationView.center = CGPointMake(x, y);
        animationView.bounds = CGRectMake(0, 0, w, h);
    } completion:^(BOOL finished) {
        [self removeAnimationViewWithToView:fromView];
        [transitionContext completeTransition:YES];
    }];
}

- (UIView *) addPresentAnimationView: (UIView*)view {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.tag = animationImageViewTag;
    imageView.image = self.defaultSelectedImage;
    CGRect imageViewFrame = self.selectedImageViewWindowFrame;
    imageView.frame = imageViewFrame;
    [view addSubview:imageView];
    return imageView;
}

- (UIView *) addDismissAnimationView: (UIView*)view {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.tag = animationImageViewTag;
    CGRect imageViewFrame = CGRectZero;
    if (self.dismissStartView) {
        imageView.image = self.dismissStartView.image;
        imageViewFrame = [view convertRect:self.dismissStartView.frame fromView:self.dismissStartView.superview];
    }
    imageView.frame = imageViewFrame;
    [view addSubview:imageView];
    return imageView;
}

- (void)removeAnimationViewWithToView: (UIView *)view {
    UIView *subView = [view viewWithTag:animationImageViewTag];
    [subView removeFromSuperview];
}
- (UIView *)getAnimationPresentView: (UIView *) view {
    UIView *animationView = [view viewWithTag:animationImageViewTag];
    if (!animationView) {
        animationView = [self addPresentAnimationView:view];
    }
    return view;
}
@end
