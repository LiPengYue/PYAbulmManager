//
//  PYAssetModel.h
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "PYAblumManagerCommon.h"
@interface PYAssetModel : NSObject

///资源
@property (nonatomic,strong) PHAsset *asset;
///创建的时间
@property (nonatomic,strong) NSDate *creationDate;
///创建时间
@property (nonatomic,assign) NSInteger createTimeInteger;
///资源的类型
@property (nonatomic,assign) Enum_PYAblumManager_AssetType assetType;
/// 是否选中状态
@property (nonatomic,assign) BOOL isSelected;
/// 选中状态下 第几个被选中的 (没有选中状态下默认为 小于0)
@property (nonatomic,assign) NSInteger orderNumber;
/// 当前选中的model 是否超出最大值了;
@property (nonatomic,assign) BOOL isBeyondTheMaximum;

///image ID
@property (nonatomic,assign) PHImageRequestID imageRequestID;

///缩略图
@property (nonatomic,strong) UIImage *degradedImage;
///精致的缩略图
@property (nonatomic,strong) UIImage *delicateImage;
///精致缩略图的宽度
@property (nonatomic,assign) CGFloat delicateImageW;
///原图
@property (nonatomic,strong) UIImage *originImage;

/// 是否在加载图片
@property (nonatomic,assign) BOOL isLoadedImage;
///是否显示遮罩 （表示已经到达上线）
@property (nonatomic,assign) BOOL isShowMask;

- (void)getOriginImage:(void(^)(UIImage *image)) block;

- (void)getDelicateImageWidth: (CGFloat)imageW andBlock:(void(^)(UIImage *image))block;
@end
