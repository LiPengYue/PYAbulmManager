//
//  PYImageBrowserViewViewControllerAnimater.h
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/2.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PYImageBrowserViewViewControllerAnimater : NSObject <UIViewControllerTransitioningDelegate>
/// 默认选中的图片
@property (nonatomic,strong) UIImage *defaultSelectedImage;
/// 默认选中的imageView相对与window 的frame
@property (nonatomic,assign) CGRect selectedImageViewWindowFrame;
@property (nonatomic,assign) UIViewContentMode selectedImageViewContentMode;

/// dismiss 默认动画时长
@property (nonatomic,assign) CGFloat dismissAnimationDefaultDuration;
/// present 默认动画时长
@property (nonatomic,assign) CGFloat presentAnimationDefaultDuration;
/// dismiss 默认 动画目的地 width到达这个大小后将会dismiss
@property (nonatomic,assign) CGFloat dismissDefaultWidth;

/**
 dismiss的目的地位置，如果滑动的位置超出了屏幕，那么就填写nil 填写nil，则会缩放到默认位置后dismiss
 @param dismissViewRect dismissViewRect 相对与window的rect
 */
- (void) dismissEndView: (CGRect) dismissViewRect;

/**
 dismiss 执行动画的 imageView 的起始位置
 @param dismissView 起始位置的imageView
 */
- (void) dismissStartView: (UIImageView *) dismissView;

@end
