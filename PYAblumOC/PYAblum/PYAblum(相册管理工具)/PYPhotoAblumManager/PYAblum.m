//
//  PYAblum.m
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/29.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAblum.h"
@interface PYAblum()
/// value是 PYAssetModel, key 是PHAsset
@property (nonatomic,strong) NSMutableDictionary <PHAsset*,PYAssetModel* >*cacheAssetModelDic;
///所有相片相册中 转化后的资源model
@property (nonatomic,strong,readonly) NSArray <PYAssetModel *>*allPhotoAblumModelArray_Private;
/// value是 UIImage, key 是PHAsset
@property (nonatomic,strong) NSMutableDictionary <PHAsset*,UIImage*>*cacheImageDic;
@property (nonatomic,assign) NSInteger maxCount;
@end
@implementation PYAblum
static PYAblum *ablum;
///单例
+ (PYAblum *) defaultAblum {
    return [self ablum];
}
/// 单例
+ (PYAblum *) ablum {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ablum = [[self alloc]init];
    });
    return ablum;
}
/// init
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
/// setup
- (void)setup {
    self.selectedImageW = 600;
    self.ablumManager = [[PYAblumManager alloc] init];
    self.assetManager = [[PYAssetManager alloc] init];
    self.imageManager = [[PYImageManager alloc] init];
    
    self.ablumModelClass = PYAblumModel.class;
    self.assetModelClass = PYAssetModel.class;
    
    self.photographImageArray = [[NSMutableArray alloc] init];
    self.selectedAssetModelArray = [[NSMutableArray alloc]init];
    self.cacheAssetModelDic = [[NSMutableDictionary alloc]init];
    self.cacheImageDic = [[NSMutableDictionary alloc]init];
}



/**
 * 获取图片并缓存
 */
- (void)getAssetWithImageWidth: (CGFloat)imageW
                      andModel: (PYAssetModel *)model
                      andBlock: (void(^)(PYAssetModel *assetFirstModel)) assetFirstModelBlock
                      andBlock: (void(^)(PYAssetModel *assetLastModel)) assetLastModelBlock{
    //精致缩略图 从缓存中获取
    if (model.delicateImageW == imageW) {
        if (assetFirstModelBlock) {
            assetFirstModelBlock(model);
        }
        return;
    }
    ///缓存照片
    if (!model.asset) { return; }
    __weak typeof([PYAblum defaultAblum])ablum = [PYAblum defaultAblum];
    CGSize imageSize = [ablum.imageManager getImageSize:model.asset andSetPotoWidth:imageW];
    [ablum.imageManager.cachingImageManager startCachingImagesForAssets:@[model.asset] targetSize:imageSize contentMode:PHImageContentModeAspectFit options:nil];
    
   model.imageRequestID = [ablum.imageManager getPotoWithAsset:model.asset
                                               andSetPotoWidth:imageW
                                       andnetworkAccessAllowed:true
                                                 andCompletion:^(UIImage *photo,
                                                                 NSDictionary *info,
                                                                 BOOL isDegraded) {
        if (isDegraded && assetFirstModelBlock){
            model.degradedImage = photo;
            assetFirstModelBlock(model);
        }
        if (!isDegraded && assetLastModelBlock){
            model.delicateImage = photo;
            assetLastModelBlock(model);
        }
    } andProgress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {}];
    return;
}
#pragma mark - 方法
/**
 获取相册中的图片，其中不包含 视频的内容
 
 @param w image 的大小（assetLastModelBlock 调用中 image的大小）
 @param assetFirstModelBlock 缩略图
 @param assetLastModelBlock 精致些的图片
 */
- (void) getAblumAllImageWithWidth: (CGFloat)w andBlock: (void(^)(NSArray <PYAssetModel *>*assetFirstModelArray, NSArray <UIImage*>*degradedArray)) assetFirstModelBlock andBlock: (void(^)(NSArray <PYAssetModel *>*assetLastModelArray, NSArray <UIImage*>*originArray)) assetLastModelBlock {
    //精致缩略图 从缓存中获取
    if (self.allPhotoAblumModelArray.count) {
        if (assetLastModelBlock) {
            assetLastModelBlock(self.allPhotoAblumModelArray,self.allPhotoAblumImageArray);
        }
        return;
    }
    ///请求所有照片相册
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PYAblumModel *ablumModel = [self.ablumManager getFetchResultWithAssetType:Enum_Image andAblumType:Enum_Ablum_AblumAll allBlum:nil];
        NSArray <PYAssetModel *>* assetModelArray = [self.assetManager getAssetWithFetchResult:ablumModel.assetfetchResult];
        __block NSMutableArray <UIImage *>* degradedImageArray = [NSMutableArray new];
        __block NSMutableArray <PYAssetModel *>* degradedModelArray = [NSMutableArray new];
        __block NSMutableArray <PYAssetModel *>* delicateModelArray = [NSMutableArray new];
        __block NSMutableArray <UIImage *>* delicateImageArray = [NSMutableArray new];
        __block BOOL isFirstCallDelicateBlock = true;
        __block BOOL isFirstCallDegradedBlock = true;
        __weak typeof(self) weakSelf = self;
//        for (int i = 0; i < 2 ; i++) {
        [assetModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ///里面才是真正的image
            obj.imageRequestID = [self.imageManager getPotoWithAsset:obj.asset andSetPotoWidth:w andnetworkAccessAllowed:true andCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (weakSelf.allPhotoAblumModelArray.count) {
                    if (assetLastModelBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            assetLastModelBlock(self.allPhotoAblumModelArray,self.allPhotoAblumImageArray);
                        });
                    }
                    if (assetFirstModelBlock) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                        assetFirstModelBlock(self.allPhotoAblumModelArray,self.allPhotoAblumImageArray);
                       });
                    }
                }
                if (isDegraded){
                    obj.degradedImage = photo;
                    [degradedModelArray addObject:obj];
                    [degradedImageArray addObject:photo];
                }else{
                    obj.delicateImage = photo;
                    [delicateModelArray addObject:obj];
                }
                if ((assetModelArray.count <= degradedModelArray.count) && assetFirstModelBlock && isFirstCallDegradedBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isFirstCallDegradedBlock = false;
                        assetFirstModelBlock(degradedModelArray,degradedImageArray);
                    });
                }
                if ((assetModelArray.count <= delicateModelArray.count) && assetLastModelBlock && isFirstCallDelicateBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    isFirstCallDelicateBlock = false;
                    [delicateModelArray removeAllObjects];
                    [assetModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [delicateImageArray addObject:obj.delicateImage];
                        [delicateModelArray addObject:obj];
                    }];
                    ///缓存 所有相册 图片
                    [weakSelf setValue:delicateImageArray.copy forKey:@"allPhotoAblumImageArray"];
                    [weakSelf setValue:delicateModelArray.copy forKey:@"allPhotoAblumModelArray"];
                    assetLastModelBlock(delicateModelArray,delicateImageArray);
                    });
                }
            } andProgress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {}];
        }];
//    }
//    });
    
}


/**
 * 获取所有相册 并获取相册的封面
 @param getAblumblock 获取相册
 @param w image的宽度，高度会自动比例计算
 * ablumModel 默认为 PYAblumModel， 如果，自定义，请给self.ablumModelClass赋值
 */
- (void) getAbulmSetCoverImageWithImageWidth: (CGFloat)w andBlock: (void(^)(NSArray <PYAblumModel*> *ablumModel))getAblumblock {
    __weak typeof(self) weakSelf = self;
    [self.ablumManager getFetchResultWithAssetType:Enum_AssetAll andAblumType:Enum_Ablum_AblumAll allBlum:^(NSArray<PYAblumModel *> *blumArray) {
        [blumArray enumerateObjectsUsingBlock:^(PYAblumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.imageManager getPotoWithAlbum:obj.assetfetchResult andPotoWidth:w andSortAscendingByDate:true andCompletion:^(UIImage *image) {
                obj.coverImageView = image;
            }];
        }];
        if (getAblumblock) {
            getAblumblock(blumArray);
        }
    }];
}



/**
 获取资源数组中的某张图片
 * 默认做了缓存，（index先从缓存中获取，再网络获取）
 @param assetArray 资源集合
 @param index 要获取的资源的下标
 @param width image 的宽度，如果width <= 0 或者 width 大于 image原有宽度，则返回原图
 */
- (void) getPhotoWithAssetArray: (NSArray <PHAsset *>*)assetArray andIndex: (NSInteger) index andImageSize: (CGFloat)width andCallBack: (void(^)(UIImage *))callBack {
    if (!callBack) return;
    if (index >= assetArray.count |index < 0) {
        NSLog(@"🌶，‘getPhotoWithAssetArray’方法中，数组越界");
        return;
    }
    //获取原图
    PHAsset *asset = assetArray[index];
    UIImage *image = self.cacheImageDic[asset];
    if (image) {
        callBack(image);
        return;
    }
    //获取 原图片
    if (width <= 0) {
        __weak typeof(self) weakSelf = self;
        [self.imageManager getOriginPoto:asset andCompletion:^(UIImage *image) {
            weakSelf.cacheImageDic[asset] = image;
            callBack(image);
        }];
    }else{
    //获取 比例图
        [self.imageManager getPotoWithAsset:asset andSetPotoWidth:width andnetworkAccessAllowed:true andCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if(!isDegraded) {
                callBack(photo);
            }
        } andProgress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        }];
    }
}

/**
 获取资源数组中的某张图片
 * 默认做了缓存，（index先从缓存中获取，再网络获取）
 @param assetArray assetModel集合
 @param index 要获取的资源的下标
 @param width image 的宽度，如果width <= 0 或者 width 大于 image原有宽度，则返回原图
 */
- (void) getPhotoWithAssetModelArray: (NSArray <PYAssetModel *>*)assetArray andIndex: (NSInteger) index andImageSize: (CGFloat)width andCallBack: (void(^)(PYAssetModel *))callBack {
    if (!callBack) return;
    if (index >= assetArray.count |index < 0) {
        NSLog(@"🌶，‘getPhotoWithAssetArray’方法中，数组越界");
        return;
    }
    //获取原图
    PYAssetModel *assetModel = assetArray[index];
    PYAssetModel *assetModelTemp = self.cacheAssetModelDic[assetModel.asset];
    if (assetModelTemp) {
        assetModel.originImage = assetModelTemp.originImage;
        callBack(assetModel);
        return;
    }
    //获取 原图片
    if (width <= 0) {
        __weak typeof(self) weakSelf = self;
        [self.imageManager getOriginPoto:assetModel.asset andCompletion:^(UIImage *image) {
            assetModel.originImage = image;
            weakSelf.cacheAssetModelDic[assetModel.asset] = assetModel;
            callBack(assetModel);
        }];
    }else{
        //获取 比例图
       assetModel.imageRequestID = [self.imageManager getPotoWithAsset:assetModel.asset andSetPotoWidth:width andnetworkAccessAllowed:true andCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if(!isDegraded) {
                assetModel.originImage = photo;
                callBack(assetModel);
            }
        } andProgress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        }];
    }
}




/**
 时间排序
 
 @param modelArray model array
 @param isASC 是否升序，（最近期 照片 在后面）
 */
- (NSArray <PYAssetModel *>*) sortWithModelArray: (NSArray <PYAssetModel *>*)modelArray andIsASC: (BOOL)isASC {
    NSSortDescriptor *des = [[NSSortDescriptor alloc]initWithKey:@"createTimeInteger" ascending:isASC];
    [modelArray sortedArrayUsingDescriptors:@[des]];
    return modelArray;
}

///删除 缓存的缩略图 及预览图
- (void)removeCache {
    [self.selectedAssetModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.imageManager.cachingImageManager stopCachingImagesForAllAssets];
        [[PHImageManager defaultManager] cancelImageRequest:obj.imageRequestID];
    }];
    [self setValue:@[] forKey:@"allPhotoAblumImageArray"];
    [self setValue:@[] forKey:@"allPhotoAblumModelArray_Private"];
    [self.photographImageArray removeAllObjects];
    [self.selectedAssetModelArray removeAllObjects];
    [self.cacheAssetModelDic removeAllObjects];
    [self.cacheImageDic removeAllObjects];
}
/// 消除选中其中的某个asset
- (void)removeSelectedAssetWith:(PYAssetModel *)asset {
    asset.isSelected = false;
    asset.orderNumber = -1;
    [self.selectedAssetModelArray removeObject:asset];
    [PYAblum handleIsBeyondTheMaximumArray];
    [self.selectedAssetModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.orderNumber = idx + 1;
    }];
}
- (void)removeSelectedAssetModelArray {
    [self.selectedAssetModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = false;
        obj.orderNumber = -1;
    }];
    [self.selectedAssetModelArray removeAllObjects];
    [PYAblum handleIsBeyondTheMaximumArray];
}
/**
 管理选中的assetModel
 
 @param clickedModel 被点击的model
 @param maxCount 最大可选中数量 （小于0 则为无最大选中限制）
 @param block 判断 是否 超出最大数量的回调
 @return 返回被操作后的数组
 */
+ (NSMutableArray <PYAssetModel *>*)getSelectAssetArrayWithClickedModel: (PYAssetModel *)clickedModel andMaxCount:(NSInteger) maxCount andOverTopBlock: (void(^)(NSArray <PYAssetModel *>*modelArray, BOOL isVoerTop))block{
    
    PYAblum *ablum = [PYAblum ablum];
      NSMutableArray <PYAssetModel *>* beOperatedArray = ablum.selectedAssetModelArray;
    [ablum getAssetWithImageWidth:ablum.selectedImageW andModel:clickedModel andBlock:^(PYAssetModel *assetFirstModel) {
    } andBlock:^(PYAssetModel *assetLastModel) {
    }];
    ablum.maxCount = maxCount;
    return [PYAssetManager getSelectAssetArrayWithClickedModel:clickedModel andBeOperated:beOperatedArray andMaxCount:maxCount andOverTopBlock:^(NSArray<PYAssetModel *> *modelArray, BOOL isVoerTop) {
        [PYAblum handleIsBeyondTheMaximumArray];
        if (block) {
            block(modelArray,isVoerTop);
        }
    }];
}

+ (void) handleIsBeyondTheMaximumArray {
    if([PYAblum ablum].selectedAssetModelArray.count >= [PYAblum ablum].maxCount) {
        [[PYAblum ablum].allPhotoAblumModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isBeyondTheMaximum = true;
        }];
    }else{
        [[PYAblum ablum].allPhotoAblumModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isBeyondTheMaximum = false;
        }];
    }
}

/// 压缩 image
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    return [PYImageManager compressImage:image toByte:maxLength];
}


/**
 * 图片压缩到指定大小
 * @param targetSize 目标图片的大小 （非等比压缩的话，去最大比例压缩）
 * @param isPerceptual 是否等比压缩
 * @param sourceImage 源图片
 * @return 目标图片
 */
+ (UIImage*)imageByScalingAndCroppingForSize:(CGRect)targetRect withSourceImage:(UIImage *)sourceImage {
    return [PYImageManager imageByScalingAndCroppingForSize:targetRect withSourceImage:sourceImage];
}


//MARK: - set && get
- (void) setAblumModelClass:(Class)ablumModelClass {
    _ablumModelClass = ablumModelClass;
    self.ablumManager.ablumModelClass = ablumModelClass;
}
- (void) setAssetModelClass:(Class)assetModelClass {
    _assetModelClass = assetModelClass;
    self.assetManager.assetModelClass = assetModelClass;
}

- (NSArray<PYAssetModel *> *)allPhotoAblumModelArray {
    if (!_allPhotoAblumModelArray_Private || !_allPhotoAblumModelArray_Private.count) {
        ///请求所有照片相册
        PYAblumModel *ablumModel = [self.ablumManager getFetchResultWithAssetType:Enum_Image andAblumType:Enum_Ablum_AblumAll allBlum:nil];
        NSArray <PYAssetModel *>* assetModelArray = [self.assetManager getAssetWithFetchResult:ablumModel.assetfetchResult];
        for (PYAssetModel *model in assetModelArray) {
            model.isShowMask = false;
        }
        _allPhotoAblumModelArray_Private = assetModelArray.mutableCopy;
    }
    return _allPhotoAblumModelArray_Private;
}

- (void) insertAllPhotoAblumModelArray: (NSInteger) index andModel: (PYAssetModel *)model {
    //传入的参数必须大于或者等于0，否则会返回Null
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    //wait = 0，则表示不需要等待，直接执行后续代码；wait != 0，则表示需要等待信号或者超时，才能继续执行后续代码。lock信号量减一，判断是否大于0，如果大于0则继续执行后续代码；lock信号量减一少于或者等于0，则等待信号量或者超时。
    long wait = dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    
    NSMutableArray *array = _allPhotoAblumModelArray_Private.mutableCopy;
    [array insertObject:model atIndex:index];
    _allPhotoAblumModelArray_Private = array;
    //需要执行的代码
    //signal = 0，则表示没有线程需要其处理的信号量，换句话说，没有需要唤醒的线程；signal != 0，则表示有一个或者多个线程需要唤醒，则唤醒一个线程。（如果线程有优先级，则唤醒优先级最高的线程，否则，随机唤醒一个线程。）
    long signal = dispatch_semaphore_signal(lock);
}




@end
