//
//  PYImageBrowserViewControllerConfiguration.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/6.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserViewControllerConfiguration.h"

@implementation PYImageBrowserViewControllerConfiguration
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pullDownDismissDefaultDistance = 100;
        self.dismissDefaultWidth = 200;
        self.presentAnimationDefaultDuration = 0.5;
        self.dismissAnimationDefaultDuration = 0.4;
        self.alphaIncrementingCount = 0.025;
    }
    return self;
}
@end
