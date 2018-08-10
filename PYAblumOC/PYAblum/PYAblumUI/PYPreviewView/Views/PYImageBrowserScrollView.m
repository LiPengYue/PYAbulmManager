//
//  PYImageBrowserScrollView.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/1.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserScrollView.h"

@interface PYImageBrowserScrollView()


///正在拖拽 一个手指拖拽
@property (nonatomic,assign) BOOL paning;
@end


@implementation PYImageBrowserScrollView


#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - funcs
- (void)setup {
    //打开多指触控
    self.multipleTouchEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self createSingleTap];
    [self createDoubleTap];
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
    [self addGestureRecognizer:_doubleTap];
    [self addGestureRecognizer:_singleTap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)dealloc {
    NSLog(@"✅%@",NSStringFromClass([self classForCoder]));
}
// MARK: event
- (void)doDoubleTap:(UITapGestureRecognizer *)recognizer {
    if ([self.browserScrollViewProtocol respondsToSelector: @selector(doubleTapEventFonc:andTap:)]) {
        [self.browserScrollViewProtocol doubleTapEventFonc:self andTap:recognizer];
    }
}

- (void)doSingleTap:(UITapGestureRecognizer *)recognizer {
    if ([self.browserScrollViewProtocol respondsToSelector: @selector(singleTapEventFonc:andTap:)]) {
        [self.browserScrollViewProtocol singleTapEventFonc:self andTap:recognizer];
    }
}


#pragma mark - override

#pragma mark - setter

#pragma mark - getter or lazy load
- (void)createDoubleTap
{
    if (!_doubleTap)
    {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired  =1;
    }
}

- (void)createSingleTap
{
    if (!_singleTap)
    {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSingleTap:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
    }
}

@end
