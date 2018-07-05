//
//  PYAblumManagerCommon.h
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <Foundation/Foundation.h>
///选取资源类型
typedef NS_ENUM(NSUInteger, Enum_PYAblumManager_AssetType){
    /// 所有
    Enum_AssetAll = 0,
    /// 图片
    Enum_Image = 1,
    /// 视频
    Enum_Video = 2,
    /// 音频
    Enum_Audio = 3,
};


///选取相册类型
typedef NS_ENUM(NSUInteger, Enum_PYAblumManager_AblumType){
    ///所有相册
    Enum_Ablum_AblumAll = 1 << 0,
    
    ///PHAssetCollectionSubtypeAlbumRegular         = 2, // 在 相册 应用中创建的相簿
    Enum_Ablum_smartAlbums = 1 << 2,
    
    ///获取所有用户创建的相册 PHAssetCollectionSubtypeAlbumRegular
    Enum_Ablum_topLevelUserCollections = 1 << 3,
    
    /// PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5, // 从iPhone中同步到设备的相簿
    Enum_Ablum_syncedAlbums = 1 << 4,
    
    ///PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100, // 用户自己的iCloud照片流
    Enum_Ablum_myPhotoStreamAlbum = 1 << 5,
    
    ///PHAssetCollectionSubtypeAlbumCloudShared     = 101, // 一个iCloud共享照片流
    Enum_Ablum_sharedAlbums = 1 << 6,
};

@interface PYAblumManagerCommon : NSObject

@end
