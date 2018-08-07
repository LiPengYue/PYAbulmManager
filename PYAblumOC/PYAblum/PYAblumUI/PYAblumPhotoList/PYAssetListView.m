
//
//  PYAssetListView.m
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAssetListView.h"
#import "PYAssetList_CollectionViewCell.h"
#import <Photos/Photos.h>
#import "PYCamera.h"
#define WEAKSELF __weak typeof(self)(weakSelf) = self;
//定义一个block
typedef BOOL(^RunloopBlock)(void);
static NSString *const cellID = @"CELLID";
static NSString *const lastCellID = @"lastCellID";
static NSString *const firstCellID = @"firstCellID";
@interface PYAssetListView() <UICollectionViewDataSource>
/// collectionView
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray <PYAssetModel *>*assetModelArray;
//定时器，保证runloop一直处于循环中
@property (nonatomic, weak) NSTimer *timer;

///储存请求图片的block数组
@property (nonatomic,strong) NSMutableArray <RunloopBlock>*tasks;
@property (nonatomic,strong) NSMutableArray <NSString *> *taskKeys;
/// 最后一个位置插入一个cell
@property (nonatomic,copy) UICollectionViewCell *(^insertLastCell)(UICollectionView *collectionView);
/// 第一个位置插入一个cell
@property (nonatomic,copy) UICollectionViewCell *(^insertFirstCell)(UICollectionView *collectionView);
@property (nonatomic,assign) int rowOffset;
@property (nonatomic,assign) NSInteger indexMaxCount;
@property (nonatomic,assign) BOOL isFirstLayoutSubViews;
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
    //    [RunloopManager defaultRunloopManager].delegate = self;
    PYAblum *ablumManager = [PYAblum defaultAblum];
    self.assetModelArray = [ablumManager.allPhotoAblumModelArray mutableCopy];
}


- (void)setup {
    self.isFirstLayoutSubViews = true;
    [self.collectionView removeFromSuperview];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//UIScrollView也适用
    }else {
    }
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout: self.configuration.layout];
    [self addSubview:self.collectionView];
    self.collectionView.delegate = self.configuration.delegate;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:self.configuration.firstCellClass forCellWithReuseIdentifier:firstCellID];
    [self.collectionView registerClass:self.configuration.lastCellClass forCellWithReuseIdentifier:lastCellID];
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
    if (self.isFirstLayoutSubViews) {
        self.collectionView.contentOffset = CGPointMake(0, 0);
        self.collectionView.contentInset = UIEdgeInsetsZero;
        self.isFirstLayoutSubViews = false;
    }
    
}

- (void)eventFunc:(PYAssetModel *)model andKey: (NSString*) key
         andIndex: (NSInteger)index
          andCell: (PYAssetList_CollectionViewCell *)cell {
    if ([key isEqualToString:PYAssetListCell_ClickSelectedButton]) {
        [self clickRightButton:model];
    }
    if ([key isEqualToString:PYAssetListCell_clickImageView]) {
        [self clickImage:model index:index andCell: cell];
    }
    [self reloadData];
}

- (void) clickRightButton: (PYAssetModel*) model {
    NSInteger maxCount = self.configuration.maxAssetSelectedCount;
    if ([self.assetListViewDelegate respondsToSelector:@selector(maxSelectedCount)]) {
        maxCount = [self.assetListViewDelegate maxSelectedCount];
    }
    
    [PYAblum getSelectAssetArrayWithClickedModel:model andMaxCount: maxCount andOverTopBlock:^(NSArray<PYAssetModel *> *modelArray, BOOL isVoerTop) {
        
        SEL selector = @selector(clickRightButtonWithSelectedModel:
                                 andSelectedModelArray:
                                 andIsOverTopMaxSelectedCount:);
        
        if ([self.assetListViewDelegate respondsToSelector:selector]){
            [self.assetListViewDelegate
             clickRightButtonWithSelectedModel:model
             andSelectedModelArray:modelArray
             andIsOverTopMaxSelectedCount:isVoerTop];
        }
    }];
}

- (void) clickImage: (PYAssetModel *)model
              index: (NSInteger)index
            andCell: (PYAssetList_CollectionViewCell *)cell {
    
    SEL selecter = @selector(clickImageViewWithClickModel:
                             andModelArray:
                             andSelectedIndex:
                             andCell:);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if ([self.assetListViewDelegate respondsToSelector:selecter]) {
        [self.assetListViewDelegate
         clickImageViewWithClickModel:model
         andModelArray:self.assetModelArray
         andSelectedIndex:index
         andCell:cell];
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

- (UICollectionView *) assetCollectionView {
    return _collectionView;
}

//MARK: - DataSource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.indexMaxCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /// 判读是否需要插入第一个
    if (indexPath.row == 0 && self.configuration.firstCellClass) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:firstCellID forIndexPath:indexPath];
        if ([self.assetListViewDelegate respondsToSelector:@selector(setupCell:andIndex:andCell:)]) {
            [self.assetListViewDelegate setupCell:collectionView andIndex:indexPath andCell:cell];
        }
        return cell;
    }
    
    if (indexPath.row == self.indexMaxCount - 1 && self.configuration.lastCellClass) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:lastCellID forIndexPath:indexPath];
        if ([self.assetListViewDelegate respondsToSelector:@selector(setupCell:andIndex:andCell:)]) {
            [self.assetListViewDelegate setupCell:collectionView andIndex:indexPath andCell:cell];
        }
        return cell;
    }
    
    
    PYAssetList_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: cellID forIndexPath:indexPath];
    
    PYAssetModel *model = self.assetModelArray[indexPath.row - self.rowOffset];
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
        [weakSelf eventFunc:model
                     andKey:singla
                   andIndex:indexPath.row
                    andCell:cell];
    }];
    if ([self.assetListViewDelegate respondsToSelector:@selector(setupCell:andIndex:andCell:)]) {
        [self.assetListViewDelegate setupCell:collectionView andIndex:indexPath andCell:cell];
    }
    return cell;
}
- (void)reloadData {
    [self loadData];
    //    [self.collectionView reloadData];
}
- (void)dealloc {
    
}
///是否可以打开相册
+ (BOOL) isOpenCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}


+ (BOOL) isOpenPhotoAlbum: (void(^)(BOOL isOpen))openBlock {
    ///https://www.jianshu.com/p/e4a2b83c8069
    BOOL isOpen = [PYCamera isOpenPhotoAlbum:openBlock];
    return isOpen;
}

- (NSInteger) indexMaxCount {
    return self.assetModelArray.count + self.rowOffset;
}
- (int) rowOffset {
    int a = self.configuration.lastCellClass ? 1 : 0;
    int b = self.configuration.firstCellClass ? 1 : 0;
    return a + b;
}
@end
