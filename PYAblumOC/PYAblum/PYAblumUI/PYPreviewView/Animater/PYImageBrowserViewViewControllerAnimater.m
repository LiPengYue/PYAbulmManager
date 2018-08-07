//
//  PYImageBrowserViewViewControllerAnimater.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/2.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserViewViewControllerAnimater.h"
#import "PYImageBrowserViewControllerAnimatedTransition.h"

@interface PYImageBrowserViewViewControllerAnimater ()
@property (nonatomic,strong) PYImageBrowserViewControllerAnimatedTransition *animater;
@property (nonatomic,weak) UIImageView *dismissStartView;
@end
@implementation PYImageBrowserViewViewControllerAnimater
- (PYImageBrowserViewControllerAnimatedTransition *)animater {
    if (!_animater) {
        _animater = [[PYImageBrowserViewControllerAnimatedTransition alloc]init];
    }
    _animater.dismissAnimationDefaultDuration = _dismissAnimationDefaultDuration;
    _animater.presentAnimationDefaultDuration = _presentAnimationDefaultDuration;
    _animater.defaultSelectedImage = self.defaultSelectedImage;
    _animater.selectedImageViewWindowFrame = self.selectedImageViewWindowFrame;
    [self setupAnimater];
    return _animater;
}

- (void)setDismissDefaultWidth:(CGFloat)dismissDefaultWidth {
    _dismissDefaultWidth = dismissDefaultWidth;
    self.animater.dismissDefaultWidth = dismissDefaultWidth;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animater.isPresent = false;
    
    return _animater;
}



- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.animater.isPresent = true;
    return _animater;
}

- (void) dismissEndView:(CGRect)dismissViewRect {
    self.animater.dismissEndViewFrame = dismissViewRect;
}
- (void) dismissStartView:(UIImageView *)dismissView {
    self.animater.dismissStartView = dismissView;
}
- (void)setupAnimater {
    _animater.dismissAnimationDefaultDuration = self.dismissAnimationDefaultDuration;
    _animater.presentAnimationDefaultDuration = self.presentAnimationDefaultDuration;
    _animater.dismissAnimationDefaultDuration = _dismissAnimationDefaultDuration;
    _animater.presentAnimationDefaultDuration = _presentAnimationDefaultDuration;
    _animater.defaultSelectedImage = self.defaultSelectedImage;
    _animater.selectedImageViewWindowFrame = self.selectedImageViewWindowFrame;
}
@end
