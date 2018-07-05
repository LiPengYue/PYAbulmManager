//
//  PYImageManager.m
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/27.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageManager.h"
@interface PYImageManager()
@property (nonatomic,assign) dispatch_queue_t queue;
@end
@implementation PYImageManager
static PYImageManager *manager;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldFixOrientation = true;
        self.queue = dispatch_get_global_queue(0, 0);
        self.cachingImageManager = [[PHCachingImageManager alloc]init];
    }
    return self;
}

///获取封面照片
- (PHImageRequestID) getPotoWithAlbum: (PHFetchResult<PHAsset *> *)assetfetchResult
                         andPotoWidth: (CGFloat)Width
               andSortAscendingByDate: (BOOL)isSortAscendingByDate
                        andCompletion:(void (^)(UIImage *image))completion {
    PHAsset *asset = assetfetchResult.lastObject;
    if (isSortAscendingByDate) {asset = assetfetchResult.firstObject;}
    return [self getPotoWithAsset:asset andSetPotoWidth:Width  andnetworkAccessAllowed: false andCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo);
        }
    } andProgress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    }];
}


/// 获取原图
- (PHImageRequestID) getOriginPoto:(PHAsset *)asset andCompletion: (void (^)(UIImage *))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    __block PHImageRequestID imageID = 0;
    ///开辟线程
    dispatch_async(self.queue, ^{
        imageID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            
            if (downloadFinined && result && ![info[PHImageResultIsDegradedKey] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion([self fixOrientation:result]);
                });
            }
        }];
    });
    
        return imageID;
}

/**
 缓存图片 以便获取图片的时候可以
 */ 


/**
 获取图片，默认获取的是缩略图，如果networkAccessAllowed 为true，则接着获取原图

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
                          andProgress:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressBlock{
    /// 计算imageSize
    CGSize imageSize = [self getImageSize:asset andSetPotoWidth:width];
    /// http://ju.outofmemory.cn/entry/209200
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        ///缩略图
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            BOOL isDegradedKey = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (completion) completion(result,info,isDegradedKey);
        }
        
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressBlock) {
                        progressBlock(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                ///压缩图片
                resultImage = [self scaleImage:resultImage toSize:imageSize];
                if (resultImage) {
                    resultImage = [self fixOrientation:resultImage];
                    if (completion) {
                        BOOL isDegradedKey = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                        if (completion) completion(result,info,isDegradedKey);
                    }
                }
            }];
        }
    }];
    return imageRequestID;
}

- (CGSize) getImageSize:(PHAsset *)asset
        andSetPotoWidth: (CGFloat)width {
    CGFloat assetW = asset.pixelWidth == 0 ? 1 : asset.pixelWidth;
    CGFloat assetH = asset.pixelHeight == 0 ? 1 : asset.pixelHeight;
    CGFloat aspectRatio = assetW * 1.0 / assetH;
    CGFloat retio_w = width;
    CGFloat retio_h = retio_w / aspectRatio;
    CGSize imageSize = CGSizeMake(retio_w, retio_h);
    return imageSize;
}
/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (!self.shouldFixOrientation) return aImage;

    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}


+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}
/**
 * 图片压缩到指定大小
 * @param targetRect 目标图片的大小
 * @param sourceImage 源图片
 * @return 目标图片
 */
+ (UIImage*)imageByScalingAndCroppingForSize:(CGRect)targetRect withSourceImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGSize targetSize = targetRect.size;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
