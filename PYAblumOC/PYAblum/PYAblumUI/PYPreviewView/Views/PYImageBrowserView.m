//
//  PYImageBrowserView.m
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/11.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYImageBrowserView.h"
#import "PYImageBrowserCollectionViewCell.h"
#import "PYImageBrowserCollectionViewFlowLayout.h"

@interface PYImageBrowserView()<PYImageBrowserCollectionViewCellProtocol,UICollectionViewDelegate>
@property (nonatomic,assign) NSInteger defultSelectedIndex;
@property (nonatomic,assign) BOOL isFirstLayoutView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,strong) NSMutableArray <NSIndexPath *>* changeIndexPathArray;
/// 当前显示的offset
@property (nonatomic,assign) NSInteger currentIndex;
/// 当前展示的index
@property (nonatomic,strong) NSIndexPath *currenIndexPath;
@end

@implementation PYImageBrowserView

#pragma mark - init
static NSString * const CELLID = @"CELLID";
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - funcs
// MARK: 设置view
- (void)setup {
    [self setproperty];
}

- (void) setproperty {
    _isFirstLayoutView = true;
    _defultSelectedIndex = -1;
}

- (void) setupView {
    [self setupCollectionView];
}

- (void)addChangeArrayWithIndex: (NSIndexPath *)index {
    if ([self.changeIndexPathArray containsObject:index]) {
        return;
    }
    [self.changeIndexPathArray addObject:index];
}

- (void)removeChangeIndexWithArray: (NSIndexPath *)index {
    if ([self.changeIndexPathArray containsObject:index]) {
        [self.changeIndexPathArray removeObject:index];
        PYImageBrowserCollectionViewCell *cell = (PYImageBrowserCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:index];
        [cell restoreOriginalScale];
    }
}

- (void) removeAllChangeIndex {
    [self.changeIndexPathArray enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PYImageBrowserCollectionViewCell *cell = (PYImageBrowserCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:obj];
        [cell restoreOriginalScale];
    }];
    [self.changeIndexPathArray removeAllObjects];
}
- (void)clickCollectionView {
    if ([self.delegate respondsToSelector:@selector(dismissWithCurrenCell:andIndex:)]) {
        [self.delegate dismissWithCurrenCell:nil andIndex:0];
    }
}

#pragma mark - override
// MARK: system override
- (void) layoutSubviews {
    [super layoutSubviews];
    if (self.isFirstLayoutView) {
        [self setupView];
        [self.collectionView reloadData];
        if (self.defultSelectedIndex > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.defultSelectedIndex inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:false];
        }
    }
}
- (void)dealloc {
    NSLog(@"✅%@",NSStringFromClass([self classForCoder]));
}
#pragma mark - setter
#pragma mark - getter or lazy load
- (void) setupCollectionView {
    if (self.collectionView) {
        [self addSubview:self.collectionView];
        CGFloat w = self.flowLayout.minimumLineSpacing + self.bounds.size.width;
        self.collectionView.frame = CGRectMake(0, 0, w, self.bounds.size.height);
        self.collectionView.contentInset = UIEdgeInsetsMake(0,
                                                            0,
                                                            0,
                                                            self.flowLayout.minimumLineSpacing);
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        Class cellClass = self.cellClass;
        if (!cellClass) {
            cellClass = [PYImageBrowserCollectionViewCell classForCoder];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickCollectionView)];
        [self.collectionView addGestureRecognizer:tap];
        [self.collectionView registerClass: cellClass forCellWithReuseIdentifier: CELLID];
        if ([_delegate respondsToSelector:@selector(setUpCollectionView:)]) {
            [self.delegate setUpCollectionView:_collectionView];
            
        }
    }
}
- (NSMutableArray<NSIndexPath *> *)changeIndexPathArray {
    if (!_changeIndexPathArray) {
        _changeIndexPathArray = [[NSMutableArray alloc] init];
    }
    return _changeIndexPathArray;
}
/**
 collectionView
 @return if self.frame.size.width == 0 则返回nil
 */
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = self.flowLayout;
        if (layout) {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            _collectionView.pagingEnabled = true;
            _collectionView.backgroundColor = UIColor.clearColor;
        }
    }
    return _collectionView;
}

- (PYImageBrowserCollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        SEL selector = @selector(getCollectionViewLayout);
        if ([self.delegate respondsToSelector:selector]) {
            _flowLayout = [self.delegate getCollectionViewLayout];
        }
        if (!_flowLayout && self.frame.size.width) {
            _flowLayout = [[PYImageBrowserCollectionViewFlowLayout alloc]init];
            
            _flowLayout.itemSize = self.bounds.size;
            _flowLayout.minimumLineSpacing = 10;
            _flowLayout.minimumInteritemSpacing = 0;
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
    }
    return _flowLayout;
}

#pragma mark - delegate or dataSource
- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfItems)]) {
        return [self.delegate numberOfItems];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELLID forIndexPath:indexPath];
    self.currenIndexPath = indexPath;
   
    if ([cell isKindOfClass: PYImageBrowserCollectionViewCell.class]) {
        PYImageBrowserCollectionViewCell * browserCell = (PYImageBrowserCollectionViewCell*)cell;
        
        SEL selector = @selector(collectionView:andCell:andIndexPath:);
        if ([self.delegate respondsToSelector:selector]) {
            
            cell = [self.delegate collectionView:collectionView
                                         andCell:browserCell
                                    andIndexPath:indexPath];
            
        }
        
        browserCell.delegate = self;
        browserCell.indexPath = indexPath;
        [browserCell restoreOriginalScale];
        [browserCell.scrollView.singleTap requireGestureRecognizerToFail:collectionView.panGestureRecognizer];
    }
    cell.backgroundColor = self.collectionView.backgroundColor;
    return cell;
}

// MARK: PYImageBrowserCollectionViewCellProtocol
- (void)doubleTapEventFonc:(PYImageBrowserCollectionViewCell *)cell
                    andTap:(UITapGestureRecognizer *)tap {
    SEL selector = @selector(doubleTapEventFonc:andTap:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate doubleTapEventFonc:cell andTap:tap];
    }
}

- (void)singleTapEventFonc:(PYImageBrowserCollectionViewCell *)cell
                    andTap:(UITapGestureRecognizer *)tap {
    
    SEL selector = @selector(singleTapEventFonc:andTap:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate singleTapEventFonc:cell andTap:tap];
    }
}

- (void) pullDowningFunc:(PYImageBrowserCollectionViewCell *)cell {
    /// 专场动画开始
    SEL selector = @selector(pullDowningFunc:andPan:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate pullDowningFunc:cell andScrollView:cell.scrollView];
    }
}

- (void)scrollViewDidZoom:(PYImageBrowserCollectionViewCell *)cell index:(NSIndexPath *)index {
    
    [self addChangeArrayWithIndex: index];
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:index:changeIndexPathArray:)]) {
        [self.delegate scrollViewDidZoom:cell
                                   index:index
                    changeIndexPathArray:self.changeIndexPathArray];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        CGFloat offsetIndex = self.collectionView.contentOffset.x / (self.flowLayout.itemSize.width + self.flowLayout.minimumLineSpacing);
        NSInteger index = round(offsetIndex);
        if (index != round(self.currentIndex)) {
            [self removeAllChangeIndex];
            self.currentIndex = index;
        }
    }
}

- (void)dismissWithCurrenCell:(PYImageBrowserCollectionViewCell *)cell andIndex:(NSIndexPath *)index {
    if ([self.delegate respondsToSelector:@selector(dismissWithCurrenCell:andIndex:)]) {
        if (index.row == self.currentIndex) {
            [self.delegate dismissWithCurrenCell:cell andIndex:index];
        }
    }
}
- (void)pullingFuncChangeColor:(BOOL)isDow {
    if ([self.delegate respondsToSelector:@selector(pullingFuncChangeColor:)]) {
        [self.delegate pullingFuncChangeColor: isDow];
    }
}

- (void)setupDefaultSelectedIndex: (NSInteger)index; {
    if ([self.delegate respondsToSelector:@selector(numberOfItems)]) {
        NSInteger itemTotalCount = [self.delegate numberOfItems];
        if (itemTotalCount < index) {
            return;
        }
        self.defultSelectedIndex = index;
        self.currentIndex = index;
    }
}
@end
