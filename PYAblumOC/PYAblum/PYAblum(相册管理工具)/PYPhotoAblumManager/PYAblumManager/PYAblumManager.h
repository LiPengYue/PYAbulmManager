//
//  PYAblumManager.h
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <Foundation/Foundation.h>
#import "PYAblumModel.h"
#import "PYAblumManagerCommon.h"
@interface PYAblumManager : NSObject

/**
 管理资源缓存的manager
 */
@property (nonatomic,strong) PHCachingImageManager *cachImageManager;

/// 是否按照时间对资源排序(默认为true)
@property (nonatomic,assign) BOOL isTimeRank;

/// 相册的 model class 一定要继承自（PYAblumManagerModel）
@property (nonatomic,strong) Class ablumModelClass;

/// 返回传入的modelClass对象 主相册， block里面为相册数组 
- (PYAblumModel *)getFetchResultWithAssetType: (Enum_PYAblumManager_AssetType)assetType andAblumType: (Enum_PYAblumManager_AblumType) ablumType allBlum:(void(^)(NSArray <PYAblumModel *>* blumArray))allBlumBlock;
@end
