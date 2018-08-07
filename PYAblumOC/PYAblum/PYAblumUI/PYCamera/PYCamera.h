//
//  PYCamera.h
//  koalareading
//
//  Created by 李鹏跃 on 2018/3/30.
//  Copyright © 2018年 koalareading. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYCamera : UIImagePickerController
///是否可以访问相册

/**
 是否可以访问相册

 @param openBlock 1. 第一次获取权限，授权按钮点击后会调用block，可以添加图片请求的逻辑。2. 已经授权，再次获取权·限，会调用block
 @return 是否可以访问
 */
+ (BOOL) isOpenPhotoAlbum: (void(^)(BOOL isOpen))openBlock;
///是否可以打开照相机
+ (BOOL) isOpenCamera;

///是否可以打开前摄像头
+ (BOOL) isOpenCameraDevice_Front;
///是否可以打开后摄像头
+ (BOOL) isOpenCameraDevice_Rear;
///是否支持从摄像头采集资源
+ (BOOL) isSourceTypeAvailable;

/// 只能照相的相机
- (void)configuration_Photograph_Control;

///拍照完成的时候调用的方法
- (void) setUp_PhotographImage: (void(^)(UIImage *originImage, NSDictionary *info))setUpImageBlock;

///取消拍照 的时候调用 imageArray 为已经拍过的照片 
- (void) didCancel: (void(^)(NSArray <UIImage *>* imageArray))didCancelBlock;

///编辑图片调用
- (void) editing: (void(^)(UIImage *didFinishPickingImage, NSDictionary<NSString *,id> * editingInfo))editingBlock;

///写入相册 
- (void) imageWriteToSavedPhotosAlbum: (UIImage *)image and:(void * __nullable)contextInfo andBlock: (void(^)(bool isSucceed, NSError *error, void * __nullable contextInfo))block;
@end
