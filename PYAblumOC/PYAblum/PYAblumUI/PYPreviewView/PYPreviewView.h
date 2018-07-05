//
//  PYPreviewView.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/11.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAblum.h"
///预览 （点击图片后，会跳到预览图片界面）
@interface PYPreviewView : UIView
///数据源
@property (nonatomic,strong) NSArray <PYAssetModel *> *assetModelArray;
///cell class
@property (nonatomic,strong) Class cellClass;
@property (nonatomic,weak) id delegate;
@end

@protocol PYPreviewViewDelegate <NSObject>
//- (void) 
@end
