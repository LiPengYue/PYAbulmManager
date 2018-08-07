//
//  PYPreviewCollectionViewCell.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/8/1.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserCollectionViewCell.h"
#import "UIImage+zip.h"
#import "UIColor+GetRGB.h"

@interface PYImageBrowserCollectionViewCell()
@property (nonatomic,assign) CGFloat scrollViewOffsetYOld;

@property (nonatomic,assign) BOOL isZooming;
@end

@implementation PYImageBrowserCollectionViewCell
#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - funcs
- (void)setup {
    [self setupProperty];
}

- (void) setupProperty {
    self.minPullDownDistance = 10;
    _scrollView = [[PYImageBrowserScrollView alloc]initWithFrame:CGRectZero];
    _imageBrowserImageView = [[UIImageView alloc]init];
    [self setupScrollView];
    [self setupImageView];
}

- (void)setupImageView {
    _imageBrowserImageView.image = [UIImage imageNamed:@"1."];
    _imageBrowserImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setupScrollView {
    
    [self.contentView addSubview:_scrollView];
    [self.scrollView addSubview:_imageBrowserImageView];
    self.scrollView.backgroundColor = self.backgroundColor;
    self.scrollView.browserScrollViewProtocol = self;
    self.scrollView.delegate = self;
}

- (void)layout {
    self.scrollView.frame = self.bounds;
    [self setupImageFrame:_imageBrowserImageView];
}

- (void) restoreOriginalScale {
    [self.scrollView setZoomScale:1.0 animated:false];
}

//根据不同的比例设置尺寸
-(CGRect) setupImageFrame:(UIImageView *)imageView {
    
    if (!imageView.image) return CGRectZero;
    CGFloat imageW = imageView.image.size.width;
    CGFloat imageH = imageView.image.size.height;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGRect imgframe;
    
    CGFloat height = [imageView.image getHeightWightWidth:w];
    imageW = w;
    imageH = height;
    
    imgframe = CGRectMake((w - imageW) / 2, (h - imageH) / 2, imageW, imageH);
    imageView.frame = imgframe;
    if (imageH < h) {
        self.scrollView.maximumZoomScale = h / imageH;
    }else if (imageW < w) {
        self.scrollView.maximumZoomScale = w / imageW;
    }else {
        self.scrollView.maximumZoomScale = 2;
    }
    return imgframe;
}

#pragma mark - override
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

- (void)didMoveToSuperview {
    UICollectionView *collectionView = (UICollectionView *)self.superview;
    self.backgroundColor = self.superview.backgroundColor;
}
- (void)dealloc {
    NSLog(@"✅%@",NSStringFromClass([self classForCoder]));
}

#pragma mark - setter

#pragma mark - getter or lazy load

#pragma mark - delegate or dataSource

// MARK: Scrollview
// PYImageBrowserScrollViewProtocol
- (void) singleTapEventFonc:(PYImageBrowserScrollView *)scrollView
                     andTap:(UITapGestureRecognizer *)tap {
    
    if ([self.delegate respondsToSelector:@selector(singleTapEventFonc:andTap:)]) {
        [self.delegate singleTapEventFonc:self andTap:tap];
    }
    
    SEL selector = @selector(dismissWithCurrenCell:andIndex:);
    if([self.delegate respondsToSelector:selector]) {
        [self.delegate dismissWithCurrenCell:self andIndex:self.indexPath];
    }
}

- (void) doubleTapEventFonc:(PYImageBrowserScrollView *)scrollView
                     andTap:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale <= 1.0) {
        CGPoint touchPoint = [tap locationInView:_imageBrowserImageView];
        CGFloat scaleX = touchPoint.x;
        CGFloat scaleY = touchPoint.y;
        
        [self.scrollView zoomToRect:CGRectMake(scaleX, scaleY, 10, 10) animated:YES];
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(doubleTapEventFonc:andTap:)]) {
        [self.delegate doubleTapEventFonc:self andTap:tap];
    }
}

// ScrollView delegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageBrowserImageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(pullDowningFunc:)]) {
        [self.delegate pullDowningFunc:self];
    }
    
    UIPanGestureRecognizer *pan = self.scrollView.panGestureRecognizer;

    switch (pan.state) {
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            if (self.scrollView.contentOffset.y <= -_imageBrowserImageView.frame.size.height / 2.0) {
                self.backgroundColor = UIColor.clearColor;
                self.scrollView.backgroundColor = UIColor.clearColor;
                /// 执行动画并销毁
                if (self.isZooming) { return; }
                SEL selector = @selector(dismissWithCurrenCell:andIndex:);
                if([self.delegate respondsToSelector:selector]) {
                    [self.delegate dismissWithCurrenCell:self andIndex:self.indexPath];
                    return;
                }
            }
        default: break;
    }
    
    if (self.scrollViewOffsetYOld > scrollView.contentOffset.y
        && pan.numberOfTouches == 1
        && scrollView.contentOffset.y < -10) {
        if ([self.delegate respondsToSelector:@selector(pullingFuncChangeColor:)]) {
            [self.delegate pullingFuncChangeColor:true];
        }
//        [self backgroundColorDiminishing0_1];
    }else{
        if ([self.delegate respondsToSelector:@selector(pullingFuncChangeColor:)]) {
            [self.delegate pullingFuncChangeColor:false];
        }
//        [self backgroundColorIncrementing0_1];
    }
    
    self.scrollViewOffsetYOld = scrollView.contentOffset.y;
}

- (void)backgroundColorDiminishing0_1 {
    if ([self.delegate respondsToSelector:@selector(pullingFuncChangeColor:)]) {
        [self.delegate pullingFuncChangeColor:true];
    }
//    self.backgroundColor = [self.backgroundColor alphaIncrementing:-self.alphaIncrementingCount];
//    self.scrollView.backgroundColor = [self.scrollView.backgroundColor alphaIncrementing:-self.alphaIncrementingCount];
//    self.superview.backgroundColor = [self.superview.backgroundColor alphaIncrementing:-self.alphaIncrementingCount];
}
- (void)backgroundColorIncrementing0_1 {
    if ([self.delegate respondsToSelector:@selector(pullingFuncChangeColor:)]) {
        [self.delegate pullingFuncChangeColor:false];
    }
//    self.backgroundColor = [self.backgroundColor alphaIncrementing:self.alphaIncrementingCount];
//    self.scrollView.backgroundColor = [self.scrollView.backgroundColor alphaIncrementing:self.alphaIncrementingCount];
//    self.superview.backgroundColor = [self.superview.backgroundColor alphaIncrementing:self.alphaIncrementingCount];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.isZooming = true;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    
}
//控制缩放是在中心
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat boundsH = scrollView.bounds.size.height;
    CGFloat boundsW = scrollView.bounds.size.width;
    CGFloat contentSizeH = scrollView.contentSize.height;
    CGFloat contentSizeW = scrollView.contentSize.width;
    
    CGFloat offsetX = (boundsW > contentSizeW) ?
    (boundsW - contentSizeW) * 0.5 : 0.0;
    CGFloat offsetY = (boundsH > contentSizeH) ? (boundsH - contentSizeH) * 0.5 : 0.0;
    
    _imageBrowserImageView.center = CGPointMake(contentSizeW * 0.5 + offsetX, contentSizeH * 0.5 + offsetY);
    self.scrollView.contentSize = _imageBrowserImageView.frame.size;
    self.scrollView.bounces = true;
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:index:)]) {
        [self.delegate scrollViewDidZoom:self index:self.indexPath];
    }
}

@end
