//
//  PYPreViewVC.m
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/11.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserViewController.h"
#import "PYImageBrowserView.h"
#import "PYImageBrowserViewControllerAnimatedTransition.h"
#import "PYImageBrowserViewViewControllerAnimater.h"
#import "PYImageBrowserCollectionViewCell.h"
#import "UIColor+GetRGB.h"

@interface PYImageBrowserViewController ()
@property (nonatomic,strong) PYImageBrowserView *previewView_private;
@property (nonatomic,strong) PYImageBrowserViewViewControllerAnimater *animater;
@property (nonatomic,weak) UIView *dismissDestinationView;
@end

@implementation PYImageBrowserViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.animater;
    }
    return self;
}
+ (instancetype) createWihtConfig:(PYImageBrowserViewControllerConfiguration *) config {
    PYImageBrowserViewController *vc = [PYImageBrowserViewController new];
    vc.configuration = config;
    vc.animater.dismissAnimationDefaultDuration = config.dismissAnimationDefaultDuration;
    vc.animater.presentAnimationDefaultDuration = config.presentAnimationDefaultDuration;
    vc.animater.dismissDefaultWidth = config.dismissDefaultWidth;
    vc.animater.defaultSelectedImage = config.defaultSelectedImage;
    vc.animater.selectedImageViewWindowFrame = config.selectedImageViewWindowFrame;
    vc.animater.selectedImageViewContentMode = config.selectedImageViewContentMode;
//    [vc.previewView_private setupDefaultSelectedIndex:config.defaultSelectedIndex];
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview: self.previewView_private];
    self.view.backgroundColor = UIColor.blackColor;
    self.previewView_private.frame = self.view.bounds;
    [self.previewView_private setupDefaultSelectedIndex:self.configuration.defaultSelectedIndex];
}
#pragma mark - init

#pragma mark - funcs

#pragma mark - override
- (void)dealloc {
    NSLog(@"✅%@",NSStringFromClass([self classForCoder]));
}
#pragma mark - setter

#pragma mark - getter or lazy load
- (PYImageBrowserView *)previewView {
    return _previewView_private;
}
- (PYImageBrowserView *) previewView_private {
    if (!_previewView_private) {
        _previewView_private = [[PYImageBrowserView alloc]init];
        _previewView_private.delegate = self;
    }
    return _previewView_private;
}



#pragma mark -  <UIViewControllerTransitioningDelegate>

- (PYImageBrowserViewViewControllerAnimater *)animater {
    if (!_animater) {
        _animater = [[PYImageBrowserViewViewControllerAnimater alloc]init];
    }
    return _animater;
}


// MARK: - dataSource
- (NSInteger)numberOfItems {
    if ([self.dataSource respondsToSelector:@selector(numberOfItems)]) {
        return [self.dataSource numberOfItems];
    }
    return 0;
}



- (UICollectionViewCell *)collectionView: (UICollectionView *) collectionView
                                 andCell:(PYImageBrowserCollectionViewCell *) cell
                            andIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionView:andCell:andIndexPath:)]) {
        return [self.dataSource collectionView:collectionView
                                       andCell:cell
                                  andIndexPath:indexPath];
    }
    return cell;
}



- (void) setUpCollectionView: (UICollectionView *) collectionView {
    
}


// MARK: - delegate
- (void)singleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)doubleTapEventFonc: (PYImageBrowserCollectionViewCell *) cell andTap: (UITapGestureRecognizer *)tap {
    
}

- (void)pullDowningFunc: (PYImageBrowserCollectionViewCell *) cell
          andScrollView:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidZoom: (PYImageBrowserCollectionViewCell *)cell
                    index: (NSIndexPath *)index
     changeIndexPathArray: (NSArray <NSIndexPath *>*)indexArray {
    
}

- (void)dismissWithCurrenCell: (PYImageBrowserCollectionViewCell *)cell andIndex: (NSIndexPath *)index {
    SEL selector = @selector(dismissWithCurrenCell:andIndex:);
    if ([self.delegate respondsToSelector:selector]) {
        if ([self.dataSource respondsToSelector:@selector(numberOfItems)]) {
            NSInteger itemTotalCount = [self.dataSource numberOfItems];
            if (itemTotalCount >= index.row) {
                CGRect endRect = [self.delegate dismissWithCurrenCell:cell andIndex:index];
                [self.animater dismissEndView:endRect];
            }
        }
    }
    [self.animater dismissStartView: cell.imageBrowserImageView];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)pullingFuncChangeColor:(BOOL)isDow {
    if (isDow) {
        self.view.backgroundColor = [self.view.backgroundColor alphaIncrementing:-self.configuration.alphaIncrementingCount];
    }else{
        self.view.backgroundColor = [self.view.backgroundColor alphaIncrementing:self.configuration.alphaIncrementingCount];
    }
}
@end
