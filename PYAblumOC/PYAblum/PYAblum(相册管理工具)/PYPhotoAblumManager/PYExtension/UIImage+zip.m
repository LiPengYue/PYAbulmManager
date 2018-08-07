//
//  UIImage+zip.m
//  KoalaReadingTeacher
//
//  Created by 李鹏跃 on 2018/7/30.
//  Copyright © 2018年 Beijing Enjoy Reading Education&Technology Co,. Ltd. All rights reserved.
//

#import "UIImage+zip.h"

@implementation UIImage (UIImageZip)


/**
 调整新的image尺寸
 @param scale 拉伸比例
 @return 调整新的image尺寸后返回的image
*/
- (UIImage *)resizableImage: (CGFloat)scale {
    CGFloat imageW = self.size.width * scale;
    CGFloat imageH = self.size.height * scale;
    UIEdgeInsets edge = UIEdgeInsetsMake(imageH, imageW, imageH, imageW);
    UIImage *image = [self resizableImageWithCapInsets:edge];
    return image;
}

/**
 压缩图片到指定字节 返回image
 
 @param maxLength 最大字节数
 @param sideLength image最大边长
 @return 返回后指定边长的image data
*/
- (UIImage *) compressImageWidthMaxDataLenght: (int)maxLength
                                andMaxSideLength: (CGFloat)sideLength {
    NSData *data = [self compressImageDataWidthMaxDataLenght:maxLength andMaxSideLength:sideLength];
    return [UIImage imageWithData:data];
}
    
/**
 压缩图片到指定字节 返回data

 @param maxLength 最大字节数
 @param sideLength image最大边长
 @return 返回后指定边长的image data
 */
- (NSData *) compressImageDataWidthMaxDataLenght: (int)maxLength
                            andMaxSideLength: (CGFloat)sideLength{
    
    CGSize newSize = [self getScaleSize:sideLength];
    UIImage *newImage = [self resize:newSize];
    if (!newImage) return nil;
    
    CGFloat compress = 1;
    NSData *data = UIImageJPEGRepresentation(self, compress);
    if (data.length < maxLength) return data;
    
    while (data.length > maxLength && compress > 0.01) {
        compress -= 0.02;
        data = UIImageJPEGRepresentation(newImage, compress);
    }
    
    return data;
}
    
    
/**
     获取等比例图片的size
     
     @param imageMaxLenght 图片的最大长度
     @return 等比例的size
*/
- (CGSize) getScaleSize: (CGFloat)imageMaxLenght {
    CGFloat newW, newH, w, h;
    newW = 0;
    newH = 0;
    w = self.size.width;
    h = self.size.height;
    
    if (w > imageMaxLenght || h > imageMaxLenght) {
        if (w > h) {
            newW = imageMaxLenght;
            newH = newW * h / w;
        }else if (h > w) {
            newH = imageMaxLenght;
            newW = newH * w / h;
        }else {
            newW = imageMaxLenght;
            newH = imageMaxLenght;
        }
    }
    return CGSizeMake(newW, newH);
}
    
- (CGFloat) getWidthWightHeight: (CGFloat)height {
    CGFloat scale = self.size.height / height;
    return self.size.width / scale;
}
- (CGFloat) getHeightWightWidth: (CGFloat)width {
    CGFloat scale = self.size.width / width;
    return self.size.height / scale;
}
/**
     获取新size图片
     
     @return 获取图片的
*/
- (UIImage *) resize: (CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
    [self drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    
    return newImage;
}
    
    
/**
 获取指定最大边长的新图片
 
 @param maxLengh 最大长度
 @return 新图片
 */
- (UIImage *) resizeWithMaxLenghOfSize: (CGFloat)maxLengh {
    CGSize maxSize = [self getScaleSize:maxLengh];
    return [self resize:maxSize];
}

- (CGSize) getSizeWithMaxHeight: (CGFloat)maxHeight andMaxWidth: (CGFloat)maxWidth {
    CGFloat h = 0;
    CGFloat w = 0;
    if (self.size.height / self.size.width < maxHeight / maxWidth) {
        /// 需要按照最大宽度来计算
        h = [self getHeightWightWidth:maxWidth];
        w = maxWidth;
    }else{
        w = [self getWidthWightHeight:maxHeight];
        h = maxHeight;
    }
    return CGSizeMake(w, h);
}

@end
