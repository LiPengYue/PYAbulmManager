//
//  PYImageManager.h
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/27.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface PYImageManager : NSObject

///是否需自动调整图片方向 默认为true
@property (nonatomic,assign) BOOL shouldFixOrientation;
///imageManager
@property (nonatomic,strong) PHCachingImageManager *cachingImageManager;


///获取封面照片
- (PHImageRequestID) getPotoWithAlbum: (PHFetchResult<PHAsset *> *)assetfetchResult
                         andPotoWidth: (CGFloat)Width
               andSortAscendingByDate: (BOOL)isSortAscendingByDate
                        andCompletion:(void (^)(UIImage *))completion;


/// 获取原图
- (PHImageRequestID) getOriginPoto:(PHAsset *)asset andCompletion: (void (^)(UIImage *))completion;


/**
 获取图片，默认获取的是缩略图，如果networkAccessAllowed 为true，则第二次调用block为获取到的原图
 
 @param asset 资源
 @param width 照片 期望宽度
 @param completion 图片加载完成的block 如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。
 @param progressBlock 进度相关
 @param networkAccessAllowed  参数控制是否允许 icloud 网络请求，默认为 NO，
 @return 返回了 PHImageRequestID
 */
- (PHImageRequestID) getPotoWithAsset: (PHAsset *)asset
                      andSetPotoWidth: (CGFloat)width
              andnetworkAccessAllowed: (BOOL) networkAccessAllowed
                        andCompletion: (void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion
                          andProgress:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressBlock;

///获取 image 比例
- (CGSize) getImageSize:(PHAsset *)asset
        andSetPotoWidth: (CGFloat)width;

/// 压缩图片
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;

/**
 * 图片切片到指定大小
 * @param targetSize 目标图片的大小
 * @param sourceImage 源图片
 * @return 目标图片
 */
+ (UIImage*)imageByScalingAndCroppingForSize:(CGRect)targetSize withSourceImage:(UIImage *)sourceImage;
@end
