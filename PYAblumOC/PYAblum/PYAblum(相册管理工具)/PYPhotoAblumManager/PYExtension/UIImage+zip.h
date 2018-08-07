//
//  UIImage+zip.h
//  KoalaReadingTeacher
//
//  Created by 李鹏跃 on 2018/7/30.
//  Copyright © 2018年 Beijing Enjoy Reading Education&Technology Co,. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageZip)
    

/**
 调整新的image尺寸
 @param scale 拉伸比例
 @return 调整新的image尺寸后返回的image
 */
- (UIImage *)resizableImage: (CGFloat)scale;
    
/**
 压缩图片到指定字节 返回image
 
 @param maxLength 最大字节数
 @param sideLength image最大边长
 @return 返回后指定边长的image data
*/
- (UIImage *) compressImageWidthMaxDataLenght: (int)maxLength
                             andMaxSideLength: (CGFloat)sideLength;
/**
 压缩图片到指定字节
 
 @param maxLength 最大字节数
 @param sideLength image最大边长
 @return 返回后指定边长的image data
*/
    
- (NSData *) compressImageDataWidthMaxDataLenght: (int)maxLength
                            andMaxSideLength: (CGFloat)sideLength;
 
    
/**
 获取等比例图片的size

 @param imageMaxLenght 图片的最大长度
 @return 等比例的size
 */
- (CGSize) getScaleSize: (CGFloat)imageMaxLenght;

    
/**
 获取新size图片

 @return 获取图片的
 */
- (UIImage *) resize: (CGSize)newSize;


/**
 获取指定最大边长的新图片

 @param maxLengh 最大长度
 @return 新图片
 */
- (UIImage *) resizeWithMaxLenghOfSize: (CGFloat)maxLengh;

- (CGFloat) getWidthWightHeight: (CGFloat)height;
- (CGFloat) getHeightWightWidth: (CGFloat)width;
- (CGSize) getSizeWithMaxHeight: (CGFloat)maxHeight
                    andMaxWidth: (CGFloat)maxWidth;
@end
