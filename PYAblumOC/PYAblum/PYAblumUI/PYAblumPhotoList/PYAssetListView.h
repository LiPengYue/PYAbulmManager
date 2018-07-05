//
//  PYAssetListView.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//
#import "PYAblum.h"
#import <UIKit/UIKit.h>
#import "PYAssetListViewConfiguration.h"

@protocol PYAssetListViewEventHandle <NSObject>

/**
 * 事件的传递方法
 * 获取cell中 回调回来的数据，用key来区分具体是哪个event
 * 如果实现了这个方法，要手动对 选择的asset进行处理
 * 直接赋值这段代码，到你重写的方法中
 ```
 if ([key isEqualToString:PYAssetListCell_ClickSelectedButton]) {
 [PYAblum getSelectAssetArrayWithClickedModel:model andMaxCount:最大可选数 andOverTopBlock:^(NSArray<PYAssetModel *> *modelArray, BOOL isVoerTop) {
    //...做你想做的事情
 }];
 [(PYAssetListView实例) reloadData];
 }
 ```
 */
@required
- (void)eventFunc:(PYAssetModel *)model andKey: (NSString*) key andInfo:(id)info;
@end




/**
 * 资源列表视图
 * 里面包含一个collectionView
 */
@interface PYAssetListView : UIView

/**
 * 配置 管理，set方法中，对布局等做了操作
 */
@property (nonatomic,strong) PYAssetListViewConfiguration *configuration;

/**
 * 事件处理者
 */
@property (nonatomic,weak) id <PYAssetListViewEventHandle> eventHandlerel;

/**
 * reloadData
 */
- (void) reloadData;

//MARK: - init 
- (instancetype) initWithFrame:(CGRect)frame andConfiguration: (PYAssetListViewConfiguration *)configuration;
+ (instancetype) AssetListView: (PYAssetListViewConfiguration *)configuration;

///是否可以打开相册
+ (BOOL) isOpenPhotoAlbum;

///是否可以打开照相机
+ (BOOL) isOpenCamera;
@end
