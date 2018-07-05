//
//  PYAblumManager.m
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//
/*
 作者：Shmily落墨
 链接：https://www.jianshu.com/p/3612365d6494
 
 typedef NS_ENUM(NSInteger, PHAssetCollectionType) {
 PHAssetCollectionTypeAlbum      = 1, // 在 照片 应用中创建的相簿或者通过iTunes同步的在iOS设备上显示的相簿
 PHAssetCollectionTypeSmartAlbum = 2, // 照片 应用中内置的相簿
 PHAssetCollectionTypeMoment     = 3, // 照片 应用中的 时刻
 } PHOTOS_ENUM_AVAILABLE_IOS_TVOS(8_0, 10_0);
 
 
 
 
 typedef NS_ENUM(NSInteger, PHAssetCollectionSubtype) {
 // PHAssetCollectionTypeAlbum regular subtypes
 PHAssetCollectionSubtypeAlbumRegular         = 2, // 在 相册 应用中创建的相簿
 PHAssetCollectionSubtypeAlbumSyncedEvent     = 3, // 从iPhone中同步到设备的 事件
 PHAssetCollectionSubtypeAlbumSyncedFaces     = 4, // 从iPhone中同步到设备的 面孔（人物）
 PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5, // 从iPhone中同步到设备的相簿
 PHAssetCollectionSubtypeAlbumImported        = 6, // 从相机或者外部存储设备中导入的相簿
 // PHAssetCollectionTypeAlbum shared subtypes
 PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100, // 用户自己的iCloud照片流
 PHAssetCollectionSubtypeAlbumCloudShared     = 101, // 一个iCloud共享照片流
 // PHAssetCollectionTypeSmartAlbum subtypes
 PHAssetCollectionSubtypeSmartAlbumGeneric    = 200, // 没有指定子类型的智能相簿
 PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201, // 包含了照片库中所有全景照片的智能相簿——全景照片
 PHAssetCollectionSubtypeSmartAlbumVideos     = 202, // 包含了照片库中所有视频的智能相簿——视频
 PHAssetCollectionSubtypeSmartAlbumFavorites  = 203, // 包含了照片库中所有用户标记为喜欢的资源的智能相簿——个人收藏
 PHAssetCollectionSubtypeSmartAlbumTimelapses = 204, // 包含了照片库中所有延时视频的智能相簿——慢动作
 PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205, // 包含了 照片 应用中所有从 时刻 中隐藏的资源的智能相簿——
 PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206, // 包含了所有最近添加到图片库的资源的智能相簿——
 PHAssetCollectionSubtypeSmartAlbumBursts     = 207, // 包含了所有连拍的智能相簿——连拍快照
 PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208, // 包含了 照片 应用中所有慢动作视频的智能相簿——慢动作
 PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209, // 包含了所有options自己的图库的资源的智能相簿（而不是来自于iCloud共享流的资源）
 PHAssetCollectionSubtypeSmartAlbumSelfPortraits PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 210, // 包含了所有使用前置摄像头拍摄的资源的智能相册——自拍
 PHAssetCollectionSubtypeSmartAlbumScreenshots PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 211, // 包含了所有使用屏幕截图的资源的智能相册——屏幕快照
 PHAssetCollectionSubtypeSmartAlbumDepthEffect PHOTOS_AVAILABLE_IOS_TVOS(10_2, 10_1) = 212, // 包含了所有兼容设备上使用景深效果拍摄的资源的智能相册
 PHAssetCollectionSubtypeSmartAlbumLivePhotos PHOTOS_AVAILABLE_IOS_TVOS(10_3, 10_2) = 213, // 包含了所有Live Photo的智能相册——Live Photo
 // Used for fetching, if you don't care about the exact subtype
 PHAssetCollectionSubtypeAny = NSIntegerMax // 所有可能的子类型
 } PHOTOS_ENUM_AVAILABLE_IOS_TVOS(8_0, 10_0);
 
 */
#import "PYAblumManager.h"

@interface PYAblumManager()
/**
 视频类型
 */
@property (nonatomic,assign) Enum_PYAblumManager_AblumType assetType_Private;
@end


@implementation PYAblumManager


static PYAblumManager *manager;

#pragma mark - 初始化方法
- (instancetype)init {if (self = [super init]) {[self setup];} return self;}
- (void)setup {
    self.cachImageManager = [PHCachingImageManager new];
    self.isTimeRank = true;
}

#pragma mark - 处理 type
- (Enum_PYAblumManager_AblumType)ablumType:(Enum_PYAblumManager_AblumType)ablumType {
    if ((ablumType & Enum_Ablum_AblumAll) == Enum_Ablum_AblumAll) {
        return Enum_Ablum_smartAlbums
        | Enum_Ablum_sharedAlbums
        | Enum_Ablum_myPhotoStreamAlbum
        | Enum_Ablum_topLevelUserCollections
        | Enum_Ablum_syncedAlbums;
    }
    return ablumType;
}

- (PHFetchOptions *)setOptions: (PHFetchOptions *)option WithAssetType: (Enum_PYAblumManager_AssetType)assetType {
    
    switch (assetType) {
        case Enum_Video:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            break;
        case Enum_Image:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            break;
        case Enum_Audio:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeAudio];
            break;
        case Enum_AssetAll:break;
    }
    return option;
}
- ( NSArray <PHFetchResult<PHAssetCollection *>*>*)getFetchResultAblumType: (Enum_PYAblumManager_AblumType)ablumType {
    NSMutableArray <PHFetchResult *>* fetchResultArrayM = [[NSMutableArray alloc]init];
    ablumType = [self ablumType:ablumType];
    // 用户自己的iCloud照片流
    if ((ablumType & Enum_Ablum_myPhotoStreamAlbum) == Enum_Ablum_myPhotoStreamAlbum) {
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        [fetchResultArrayM addObject:myPhotoStreamAlbum];
    }
    
    // 在 相册 应用中创建的相簿
    if((ablumType & Enum_Ablum_smartAlbums) == Enum_Ablum_smartAlbums) {
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [fetchResultArrayM addObject:smartAlbums];
    }
    
    // 获取所有用户创建的相册
    if((ablumType & Enum_Ablum_topLevelUserCollections) == Enum_Ablum_topLevelUserCollections) {
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [fetchResultArrayM addObject:topLevelUserCollections];
    }

    /// 从iPhone中同步到设备的相簿
    if ((ablumType & Enum_Ablum_syncedAlbums) == Enum_Ablum_syncedAlbums) {
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        [fetchResultArrayM addObject:syncedAlbums];
    }
    ///
    if ((ablumType & Enum_Ablum_sharedAlbums) == Enum_Ablum_syncedAlbums) {
        PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        [fetchResultArrayM addObject:sharedAlbums];
    }
    return fetchResultArrayM.copy;
}
#pragma mark - 获取相册 数据

/// 返回相册
- (PYAblumModel *)getFetchResultWithAssetType: (Enum_PYAblumManager_AssetType)assetType andAblumType: (Enum_PYAblumManager_AblumType) ablumType allBlum:(void(^)(NSArray <PYAblumModel *>* blumArray))allBlumBlock {

    NSSortDescriptor *sortDescriptor = nil;
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    ///是否按时间排序
    if (self.isTimeRank) {
        sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:false];
        options.sortDescriptors = @[sortDescriptor];
    }
    /// handle assetType
    options = [self setOptions:options WithAssetType:assetType];
    ///获取 fetchResult
    NSArray <PHFetchResult *>* fetchResultArray = [self getFetchResultAblumType:ablumType];
    
    NSMutableArray <PYAblumModel *>* fetchResultArrayM = [NSMutableArray new];
    for (PHFetchResult *fetchResult in fetchResultArray) {
        for (PHAssetCollection *collection in fetchResult) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if (fetchResult.count < 1) continue;
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
           
            if (!self.ablumModelClass) {
                self.ablumModelClass = PYAblumModel.class;
                NSLog(@"🐷self.ablumClass, 没有设置值，自动设置为 PYAblumModel");
            }
            PYAblumModel *model = (PYAblumModel *)[self.ablumModelClass new];
            model.name = collection.localizedTitle;
            model.assetfetchResult = fetchResult;
            
            //设置封面
            
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                [fetchResultArrayM insertObject:model atIndex:0];
            } else {
                [fetchResultArrayM addObject:model];
            }
        }
    }
    NSArray *bulmArray = fetchResultArrayM.copy;
    if (allBlumBlock) allBlumBlock(bulmArray);
    return bulmArray.firstObject;
}
///是否为相机照片
- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"]
        || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"]
        || [albumName isEqualToString:@"相机胶卷"]
        || [albumName isEqualToString:@"所有照片"]
        || [albumName isEqualToString:@"All Photos"];
    }
}
@end
