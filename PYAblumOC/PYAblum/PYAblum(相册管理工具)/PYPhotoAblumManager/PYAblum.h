//
//  PYAblum.h
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/29.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunloopManager.h"
#import "PYAblumManagerCommon.h"
#import "PYAblumManager.h"
#import "PYAssetManager.h"
#import "PYImageManager.h"

#import "PYAblumModel.h"
#import "PYAssetModel.h"
#import "UITableView+PYAblumScroll.h"
#define WEAKSELF __weak typeof(self)(weakSelf) = self;
///提供了一些常用方法，可以用单例中的manager 来做一些其他操作
@interface PYAblum : NSObject

#pragma mark - 单例
///swift 请调用这方法，获取
+ (PYAblum *) defaultAblum;
+ (PYAblum *) ablum;
/// “所有照片” 相册中，预先加载的个数
@property (nonatomic,assign) NSInteger allPhotoAbulmPreloadingCount;



#pragma mark -  关于相册

///相册管理类
@property (nonatomic,strong) PYAblumManager *ablumManager;

///自定义返回的model ： 一定要继承自（PYAblumManagerModel）
@property (nonatomic,strong) Class ablumModelClass;





#pragma mark - 关于资源的
///资源管理者
@property (nonatomic,strong) PYAssetManager *assetManager;
///缓存的所有资源
@property (nonatomic,strong,readonly) NSArray <PYAssetModel *>*cacheAssetModelArray;
///所有相片相册中 转化后的资源model
@property (nonatomic,strong,readonly) NSArray <PYAssetModel *>*allPhotoAblumModelArray;

///缓存的所有照片
@property (nonatomic,strong,readonly) NSArray <UIImage *>* allPhotoAblumImageArray;
///自定义返回的model ： 默认 PYAssetModel, 一定要继承自（assetModel）
@property (nonatomic,strong) Class assetModelClass;
///拍照的图片
@property (nonatomic,strong) NSMutableArray <UIImage *>* photographImageArray;



//MARK: 关于选择资源的方法
/**
 管理选中的assetModel
 *
 @param clickedModel 被点击的model
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param block 超出最大数量的回调
 @return 返回被操作后的数组
 */
+ (NSMutableArray <PYAssetModel *>*)getSelectAssetArrayWithClickedModel: (PYAssetModel *)clickedModel andMaxCount:(NSInteger) maxCount andOverTopBlock: (void(^)(NSArray <PYAssetModel *>*modelArray, BOOL isVoerTop))block;
/// 选被中的assetModel
@property (nonatomic,strong) NSMutableArray <PYAssetModel*>*selectedAssetModelArray;
///选中后的图片 请求的宽度
@property (nonatomic,assign) CGFloat selectedImageW;

/// 消除选中其中的某个asset
- (void)removeSelectedAssetWith:(PYAssetModel *)asset;
/// 清理 selectedAssetModelArray
- (void)removeSelectedAssetModelArray;






#pragma mark - image 管理类
@property (nonatomic,strong) PYImageManager *imageManager;
/// 压缩 image
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;
/**
 * 图片切片到指定大小
 * @param targetSize 目标图片的大小
 * @param sourceImage 源图片
 * @return 目标图片
 */
+ (UIImage*)imageByScalingAndCroppingForSize:(CGRect)targetRect withSourceImage:(UIImage *)sourceImage;




#pragma mark - 常用 方法
/**
 * 获取图片并缓存
 */
- (void)getAssetWithImageWidth: (CGFloat)imageW andModel: (PYAssetModel *)model andBlock: (void(^)(PYAssetModel *assetFirstModel)) assetFirstModelBlock andBlock: (void(^)(PYAssetModel *assetLastModel)) assetLastModelBlock;

/**
 获取相册中的图片，其中不包含 视频的内容
 
 @param w image 的大小（assetLastModelBlock 调用中 image的大小）
 @param assetFirstModelBlock 缩略图
 @param assetLastModelBlock 精致些的图片
 */
- (void) getAblumAllImageWithWidth: (CGFloat)w andBlock: (void(^)(NSArray <PYAssetModel *>*assetFirstModelArray, NSArray <UIImage*>*degradedArray)) assetFirstModelBlock andBlock: (void(^)(NSArray <PYAssetModel *>*assetLastModelArray, NSArray <UIImage*>*originArray)) assetLastModelBlock;


/**
 * 获取所有相册 并获取相册的封面
 @param getAblumblock 获取相册
 @param w image的宽度，高度会自动比例计算
 * ablumModel 默认为 PYAblumModel， 如果，自定义，请给self.ablumModelClass赋值
 */
- (void) getAbulmSetCoverImageWithImageWidth: (CGFloat)w andBlock: (void(^)(NSArray <PYAblumModel*> *ablumModel))getAblumblock;


/**
 获取资源数组中的某张图片
 * 默认做了缓存，（index先从缓存中获取，再网络获取）
 @param assetArray 资源集合
 @param index 要获取的资源的下标
 @param width image 的宽度，如果width <= 0 或者 width 大于 image原有宽度，则返回原图
 */
- (void) getPhotoWithAssetArray: (NSArray <PHAsset *>*)assetArray andIndex: (NSInteger) index andImageSize: (CGFloat)width andCallBack: (void(^)(UIImage *))callBack;

/**
 获取资源数组中的某张图片
 * 默认做了缓存，（index先从缓存中获取，再网络获取）
 @param assetArray 资源集合
 @param index 要获取的资源的下标
 @param width image 的宽度，如果width <= 0 或者 width 大于 image原有宽度，则返回原图
 */
- (void) getPhotoWithAssetModelArray: (NSArray <PYAssetModel *>*)assetArray andIndex: (NSInteger) index andImageSize: (CGFloat)width andCallBack: (void(^)(PYAssetModel *))callBack;


/**
 时间排序
 
 @param modelArray model array
 @param isASC 是否升序，（最近期 照片 在后面）
 */
- (NSArray <PYAssetModel *>*) sortWithModelArray: (NSArray <PYAssetModel *>*)modelArray andIsASC: (BOOL)isASC ;

///删除 缓存的缩略图 及预览图
- (void)removeCache;
    
/// 插入一个 model，
- (void) insertAllPhotoAblumModelArray: (NSInteger) index andModel: (PYAssetModel *)model;
@end

