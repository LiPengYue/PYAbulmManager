//
//  PYImageBrowserViewControllerConfiguration.h
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/6.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PYImageBrowserViewControllerConfiguration : NSObject
@property (nonatomic,assign) UIViewContentMode selectedImageViewContentMode;
/// 默认选中的图片
@property (nonatomic,strong) UIImage *defaultSelectedImage;
/// 默认选中的imageView相对与window 的frame
@property (nonatomic,assign) CGRect selectedImageViewWindowFrame;
/// 默认选中的index
@property (nonatomic,assign) NSInteger defaultSelectedIndex;
/// dismiss 默认动画时长
@property (nonatomic,assign) CGFloat dismissAnimationDefaultDuration;
/// present 默认动画时长
@property (nonatomic,assign) CGFloat presentAnimationDefaultDuration;
/// dismiss 默认 动画目的地 width到达这个大小后将会dismiss
@property (nonatomic,assign) CGFloat dismissDefaultWidth;
/// 向下拉 触发dismiss的距离
@property (nonatomic,assign) CGFloat pullDownDismissDefaultDistance;

@property (nonatomic,assign) CGFloat alphaIncrementingCount;
@end
