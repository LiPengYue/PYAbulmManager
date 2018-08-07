//
//  UIColor+GetRGB.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/2.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "UIColor+GetRGB.h"

@implementation UIColor (GetRGB)
- (ColorRGB)getRGBA {
    UIColor *color = self;
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    // iOS 5
    if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    } else {
        // < iOS 5
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }
    // This is a non-RGB color
    CGFloat hue;
    CGFloat saturation = 0.0;
    CGFloat brightness;
    
    if(CGColorGetNumberOfComponents(self.CGColor) == 2) {
        [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    }
    
    ColorRGB colorRGB;
    colorRGB.red = red;
    colorRGB.green = green;
    colorRGB.blue = blue;
    colorRGB.alpha = alpha;
    colorRGB.hue = hue;
    colorRGB.saturation = saturation;
    return colorRGB;
}

/**
 设置color 的透明度并返回新的UIColor

 @param alpha 透明度
 @return 透明度为alpha的新的 UIColor
 */
- (UIColor *)alpha: (CGFloat)alpha {
    return [self colorWithAlphaComponent:alpha];
}

/**
  color.alpha = alpha + count

 @param count alpha增加多少
 @return 新的UIColor，alpha最小为0 最大为1；
 */
- (UIColor *)alphaIncrementing: (CGFloat)count {
    ColorRGB rgba = [self getRGBA];
    CGFloat alpha = rgba.alpha + count;
    alpha = alpha < 0 ? 0 : alpha;
    alpha = alpha > 1 ? 1 : alpha;
    NSLog(@"✅alpha: - %lf",alpha);
    return [self colorWithAlphaComponent:alpha];
}
@end
