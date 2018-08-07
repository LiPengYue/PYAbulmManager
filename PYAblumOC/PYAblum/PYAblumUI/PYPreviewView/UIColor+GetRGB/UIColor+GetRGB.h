//
//  UIColor+GetRGB.h
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/2.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef struct {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    /// 色调（hue）
    CGFloat hue;
    /// 饱和度（saturation）
    CGFloat saturation;
    /// 亮度（brightness）
    CGFloat brightness;
}ColorRGB;

@interface UIColor (GetRGB)

- (ColorRGB) getRGBA;

/**
 设置color 的透明度并返回新的UIColor
 
 @param alpha 透明度
 @return 透明度为alpha的新的 UIColor
 */
- (UIColor *)alpha: (CGFloat)alpha;

/**
 color.alpha = alpha - count
 
 @param count alpha减少多少
 @return 新的UIColor，alpha最小为0；
 */
- (UIColor *)alphaIncrementing: (CGFloat)count;
@end
