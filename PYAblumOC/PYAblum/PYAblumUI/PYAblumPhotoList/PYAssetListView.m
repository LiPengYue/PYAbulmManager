
//
//  PYAssetListView.m
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAssetListView.h"
#import "PYAssetList_CollectionViewCell.h"
#define WEAKSELF __weak typeof(self)(weakSelf) = self;
//定义一个block
typedef BOOL(^RunloopBlock)(void);
static NSString *const cellID = @"CELLID";
@interface PYAssetListView() <UICollectionViewDataSource,RunLoopManagerDelegate>
/// collectionView
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray <PYAssetModel *>*assetModelArray;
//定时器，保证runloop一直处于循环中
@property (nonatomic, weak) NSTimer *timer;

///储存请求图片的block数组
@property (nonatomic,strong) NSMutableArray <RunloopBlock>*tasks;
@property (nonatomic,strong) NSMutableArray <NSString *> *taskKeys;
@end

@implementation PYAssetListView
@synthesize assetModelArray = _assetModelArray;
+ (instancetype) AssetListView: (PYAssetListViewConfiguration *)configuration {
    return [[self alloc] initWithFrame:CGRectZero andConfiguration:configuration];
}
- (instancetype) initWithFrame:(CGRect)frame andConfiguration: (PYAssetListViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        self.configuration = configuration;
    }
    return self;
}
- (void)runCompletionCallBackFunc {
    //    [self.collectionView reloadData];
}
- (void)loadData {
    [RunloopManager defaultRunloopManager].delegate = self;
    PYAblum *ablumManager = [PYAblum defaultAblum];
    self.assetModelArray = [ablumManager.allPhotoAblumModelArray mutableCopy];
}


- (void)setup {
    [self.collectionView removeFromSuperview];
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout: self.configuration.layout];
    [self addSubview:self.collectionView];
    self.collectionView.delegate = self.configuration.delegate;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:self.configuration.cellClass forCellWithReuseIdentifier:cellID];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.configuration) {
        self.configuration = [[PYAssetListViewConfiguration alloc]init];
    }
    if (!self.configuration.collectionViewColor) {
        self.collectionView.backgroundColor = self.superview.backgroundColor;
    }else{
        self.collectionView.backgroundColor = self.configuration.collectionViewColor;
    }
    self.collectionView.frame = self.bounds;
}

- (void)eventFunc:(PYAssetModel *)model andKey: (NSString*) key andInfo:(id)info {
    
    if ([self.eventHandlerel respondsToSelector:@selector(eventFunc:andKey:andInfo:)]){
        [self.eventHandlerel eventFunc:model andKey:key andInfo:info];
    }else{
        NSLog(@"🐖 你没有实现代理方法，应该是没有设置eventHandlerel");
        if ([key isEqualToString:PYAssetListCell_ClickSelectedButton]) {
            [PYAblum getSelectAssetArrayWithClickedModel:model andMaxCount:self.configuration.maxAssetSelectedCount andOverTopBlock:^(NSArray<PYAssetModel *> *modelArray, BOOL isVoerTop) {
                
            }];
            [self reloadData];
        }
    }
}

//MARK: - property
- (void)setConfiguration:(PYAssetListViewConfiguration *)configuration {
    _configuration = configuration;
    [PYAblum ablum].assetModelClass = configuration.pyAssetModelClass;
    [self setup];
    [self loadData];
}
- (NSMutableArray<PYAssetModel *> *)assetModelArray {
    if(!_assetModelArray) {
        _assetModelArray = [[NSMutableArray alloc]init];
    }
    return _assetModelArray;
}
- (void)setAssetModelArray:(NSMutableArray<PYAssetModel *> *)assetModelArray {
    _assetModelArray = assetModelArray;
    [self.collectionView reloadData];
}
//MARK: - DataSource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetModelArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
   
    PYAssetList_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: cellID forIndexPath:indexPath];
    
    PYAssetModel *model = self.assetModelArray[indexPath.row];
    cell.imageWidth = self.configuration.imageWidth;
    
    SEL setCellDataSEL = NSSelectorFromString(@"setDataPrivate:");
    IMP imp = [cell methodForSelector:setCellDataSEL];
    void(*func)(id,SEL,id) = (void*)imp;
    
    
    __weak typeof(self)weakSelf = self;
    //    __weak typeof([PYAblum defaultAblum])ablum = [PYAblum defaultAblum];
    //    NSInteger count = 1;
    //    if (self.assetModelArray.count - indexPath.row < count) {
    //        count = self.assetModelArray.count - indexPath.row;
    //    }
    //    if (indexPath.row + count < self.assetModelArray.count) {
    //        for (long i = indexPath.row; i <= indexPath.row + count; i ++) {
    //            PYAssetModel *assetmodelTemp = self.assetModelArray[i];
    //            if (!(assetmodelTemp.delicateImage || assetmodelTemp.isLoadedImage)) {
    //                [ablum getAssetWithImageWidth:weakSelf.configuration.imageWidth andModel:assetmodelTemp andBlock:^(PYAssetModel *assetFirstModel) {
    //                } andBlock:^(PYAssetModel *assetLastModel) {
    //                    assetmodelTemp.isLoadedImage = true;
    //                }];
    //            }
    //        }
    //    }
    //    if (!(model.delicateImage || model.isLoadedImage)) {
    //        [ablum getAssetWithImageWidth:weakSelf.configuration.imageWidth andModel:model andBlock:^(PYAssetModel *assetFirstModel) {
    //            PYAssetList_CollectionViewCell *cell =  (PYAssetList_CollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    //            func(cell,setCellDataSEL,model);
    //        } andBlock:^(PYAssetModel *assetLastModel) {
    //            PYAssetList_CollectionViewCell *cell =  (PYAssetList_CollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    //            model.isLoadedImage = true;
    //            func(cell,setCellDataSEL,model);
    //        }];
    //    }
    func(cell,setCellDataSEL,model);
    [cell eventCallBackFunc:^(NSString *singla, PYAssetModel *model) {
        [weakSelf eventFunc:model andKey:singla andInfo:@(indexPath.row)];
    }];
    return cell;
}
- (void)reloadData {
    [self.collectionView reloadData];
}
- (void)dealloc {
    
}
///是否可以打开相册
+ (BOOL) isOpenCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
///是否可以打开照相机
+ (BOOL) isOpenPhotoAlbum {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}
@end
