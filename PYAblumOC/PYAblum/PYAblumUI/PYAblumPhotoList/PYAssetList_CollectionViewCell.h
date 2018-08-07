//
//  PYAssetList_CollectionViewCell.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAssetModel.h"
///如果自定义这个cell 请用者两个字符串对应的 imageView click事件。 与selected button 事件
///点击了 imageView
static NSString * const PYAssetListCell_clickImageView = @"PYAssetList_CollectionViewCell_clickImageView";
///点击了 右上角的图片
static NSString * const PYAssetListCell_ClickSelectedButton = @"PYAssetListCell_ClickSelectedButton";


@interface PYAssetList_CollectionViewCell : UICollectionViewCell
typedef enum{
    PYAssetList_CollectionViewCell_Default = 0,
    PYAssetList_CollectionViewCell_Custom = 1
}Enum_PYAssetList_CollectionViewCell_Type;
///model
@property (nonatomic,strong,readonly) PYAssetModel *assetModel;
/**
 * 设置数据
 * 如果自定义cell 那么重写这个方法，获取数据
 */
- (void)setData: (PYAssetModel *)model;


/// button 左上角的button
@property (nonatomic,strong) UIButton *selectedButton;
///button 的宽度 （高度与宽度一致）
@property (nonatomic,assign) CGFloat buttonW;
///button 的y坐标 （与距离cell右边距一致）
@property (nonatomic,assign) CGFloat buttonY;
///点击相应区域 偏移量 （边距距离button边距）
@property (nonatomic,assign) CGFloat effectiveAreaOffset;


///imageView
@property (nonatomic,strong,readonly) UIImageView *imageView;
    
/**
 * image w
 */
@property (nonatomic,assign) CGFloat imageWidth;

    
/**
 已经选中的cell的蒙版颜色
 */
@property (nonatomic,strong) UIColor *selectedColor;


/**
 未选中的cell，已经选中cell的个数大于等于最大选中数的时候，显示的蒙版颜色
 */
@property (nonatomic,strong) UIColor *notSelectedAndOverTopMaxSelectedCountMaskViewColor;
    
    
/**
 未选中的cell，已经选中cell的个数大于等于最大选中数的时候，选则button是否接受点击事件 默认为true
 */
@property (nonatomic,assign) BOOL notSelectedAndOverTopMaxSelectedCountButtonUserInteractionEnabled;
    
/// type 如果default 那么默认创建了一个imageView 和一个button,默认为 deflaut
//@property (nonatomic,assign) Enum_PYAssetList_CollectionViewCell_Type type;


/**
 * event 事件的传递
 * 调用这个方法，向PYAssetListView 传递数据，
 * 在PYAssetListView，的event handler 中，实现 ‘- (void)eventFunc:(PYAssetModel *)model andKey: (NSString*) key;’ 方法，获取事件，并且，通过key来区分事件
 */
- (void) eventCallBackFunc: (void(^)(NSString *singla,PYAssetModel *model))eventBlock;


/**
 * 点击了右上角的button
 * block 的返回值为 是否执行event回调
 */

- (void)clickRightTopButtonFunc: (BOOL(^)(PYAssetModel *model)) clickRightTopBlock;

///点击了在default下 imageView
- (void)clickImageViewFunc: (BOOL(^)(PYAssetModel *model)) clickImageViewBlock;
@end

