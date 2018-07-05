//
//  PYAssetModel.m
//  PYPhotoAblumManager
//
//  Created by 李鹏跃 on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAssetModel.h"
#import "PYAblum.h"
@implementation PYAssetModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isShowMask = false;
    }
    return self;
}
- (void)setIsBeyondTheMaximum:(BOOL)isBeyondTheMaximum {
    _isBeyondTheMaximum = isBeyondTheMaximum;
    self.isShowMask = isBeyondTheMaximum && !self.isSelected;
}
@end
