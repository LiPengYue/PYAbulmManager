//
//  PYCamera.m
//  koalareading
//
//  Created by 李鹏跃 on 2018/3/30.
//  Copyright © 2018年 koalareading. All rights reserved.
//

#import "PYCamera.h"
#import "PYAblum.h"
///https://blog.csdn.net/wang_gwei/article/details/51882462
@interface PYCamera ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
///拍照完成的时候调用的方法
@property (nonatomic,copy) void(^setupImageBlock)(UIImage *originImage, NSDictionary *info);
///取消拍照 的时候调用
@property (nonatomic,copy) void(^didCancelBlock)(NSArray <UIImage *>* imageArray);
///编辑图片调用
@property (nonatomic,copy) void(^editingBlock)(UIImage *didFinishPickingImage, NSDictionary<NSString *,id> * editingInfo);
@property (nonatomic,copy) void(^writeImage)(bool isSucceed, NSError *error, void * __nullable contextInfo);
@end

@implementation PYCamera

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//MARK: - property


//MARK: - func

///是否可以打开相册
+ (BOOL) isOpenCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isOpenPhotoAlbum: (void(^)(BOOL isOpen))openBlock {
    ///https://www.jianshu.com/p/e4a2b83c8069
    __block BOOL isOpen = true;
    dispatch_group_t group = dispatch_group_create();
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted) {
        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限。
        NSLog(@"因为系统原因, 无法访问相册");
        isOpen = false;
    } else if (status == PHAuthorizationStatusDenied) {
        // 用户拒绝访问相册
        isOpen = false;
    } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许访问相册
        isOpen = true;
        // 放一些使用相册的代码
    } else if (status == PHAuthorizationStatusNotDetermined) {
        // 用户还没有做出选择
        // 弹框请求用户授权
        if (openBlock) {
            dispatch_group_enter(group);
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                // 用户点击了好 : status == PHAuthorizationStatusAuthorized
                isOpen = status == PHAuthorizationStatusAuthorized;
                dispatch_group_leave(group);
            }];
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (openBlock) {
            openBlock(isOpen);
        }
    });
    return isOpen;
}

///是否可以打开前摄像头
+ (BOOL) isOpenCameraDevice_Front {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}


///是否可以打开后摄像头
+ (BOOL) isOpenCameraDevice_Rear {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

///是否支持从摄像头采集资源
+ (BOOL) isSourceTypeAvailable {
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

//MARK: event func
/// 只能照相的相机
- (void)configuration_Photograph_Control {
    // 判断有摄像头，并且支持拍照功能
    if ([PYCamera isOpenCamera] &&
        [PYCamera isSourceTypeAvailable] &&
        ([PYCamera isOpenCameraDevice_Front] ||
        [PYCamera isOpenCameraDevice_Rear])){
        // 初始化图片选择控制器
        
//            if ([PYCamera isOpenCameraDevice_Rear]) {
//                self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
//            }else{
//                self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//            }
            if ([PYCamera isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                self.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            self.delegate = self;
    }else {
        NSLog(@"Camera is not available.");
    }
}


///拍照完成的时候调用的方法
- (void)setUp_PhotographImage:(void (^)(UIImage *, NSDictionary *))setUpImageBlock {
    self.setupImageBlock = setUpImageBlock;
}

///取消拍照 的时候调用
- (void)didCancel:(void (^)(NSArray<UIImage *> *))didCancelBlock {
    self.didCancelBlock = didCancelBlock;
}

///编辑图片调用
- (void)editing:(void (^)(UIImage *, NSDictionary<NSString *,id> *))editingBlock {
    self.editingBlock = editingBlock;
}


//MARK: private func
#pragma mark - UIImagePickerControllerDelegate
/// 拍照完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    if (self.setupImageBlock) {
        self.setupImageBlock(originalImage, info);
    }
    
    [PYAblum.ablum.photographImageArray addObject:originalImage];
    
}

///写入 相册
- (void) imageWriteToSavedPhotosAlbum: (UIImage *)image
                                  and:(void * __nullable)contextInfo
                             andBlock: (void(^)(bool isSucceed,
                                                NSError *error,
                                                void * __nullable contextInfo))block {
    
    self.writeImage = block;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!self.writeImage) {
        NSLog(@"没有实现 write image 函数的 block");
        return;
    }
    
    if(!error){
        self.writeImage(true, error, contextInfo);
    }else{
        self.writeImage(false, error, contextInfo);
    }
}

///编辑 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    if (self.editingBlock) {
        self.editingBlock(image, editingInfo);
    }
}
///取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.didCancelBlock) {
        self.didCancelBlock(PYAblum.ablum.photographImageArray);
    }
}
@end
