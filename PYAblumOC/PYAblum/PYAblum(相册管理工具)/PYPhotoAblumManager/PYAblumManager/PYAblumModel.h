//
//  PYAblumManagerModel.h
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <Foundation/Foundation.h>
#import "PYAblumManagerCommon.h"
@interface PYAblumModel : NSObject
/// 封面
@property (nonatomic,strong) UIImage *coverImageView;

@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) PHFetchResult<PHAsset *> *assetfetchResult;
@end
