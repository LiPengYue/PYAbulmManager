//
//  PYAssetList_CollectionViewCell.m
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/8.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAssetList_CollectionViewCell.h"
#import "PYAblum.h"

@interface PYAssetList_CollectionViewCell()
    @property (nonatomic,strong) UIView *maskView;
    @property (nonatomic,assign) NSInteger identifier;
    @property (nonatomic,strong) UIButton *selectedBackgroundButton;
    
    @property (nonatomic,assign) long imageID;
    /// event
    @property (nonatomic,copy) void(^event)(NSString *singla,PYAssetModel *model);
    ///点击了右上角的图片 返回值为是否要 继续处理默认配置 以及 是否通过 event传出事件
    @property (nonatomic,copy) BOOL(^clickRightTopBlock)(PYAssetModel *model);
    ///点击了在default下 imageView 返回值为是否要 继续处理默认配置 以及 是否通过 event传出事件
    @property (nonatomic,copy) BOOL(^clickImageViewBlock)(PYAssetModel *model);
    @end
@implementation PYAssetList_CollectionViewCell
    
- (instancetype)initWithFrame:(CGRect)frame
    {
        self = [super initWithFrame:frame];
        if (self) {
            [self py_setupView];
            self.clickRightTopBlock = ^BOOL(PYAssetModel *model) {
                return true;
            };
            self.clickImageViewBlock = ^BOOL(PYAssetModel *model) {
                return true;
            };
            //            self.type = PYAssetList_CollectionViewCell_Default;
            self.notSelectedAndOverTopMaxSelectedCountMaskViewColor = [UIColor clearColor];
            self.selectedColor = [UIColor clearColor];
            CGFloat buttonW = 40;
            CGFloat y = 8;
            self.buttonW = buttonW;
            self.buttonY = y;
            
        }
        return self;
    }
    
#pragma mark - setup
- (void)py_setupView {
    self.maskView = [[UIView alloc]init];
    [self setValue:[[UIImageView alloc] init] forKey:@"imageView"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = true;
    self.imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImageView:)];
    [self.imageView addGestureRecognizer:tap];
    
    [self.contentView addSubview: self.imageView];
    [self.imageView addSubview: self.maskView];
    [self.contentView addSubview: self.selectedBackgroundButton];
    [self.contentView addSubview:self.selectedButton];
}
    
- (void)layoutSubviews {
    [super layoutSubviews];
    //    switch (self.type) {
    //        case PYAssetList_CollectionViewCell_Default:
    
    self.imageView.frame = self.bounds;
    self.maskView.frame = self.bounds;
    CGFloat selfW = self.frame.size.width;
    CGFloat x = self.bounds.size.width - self.buttonW - self.buttonY;
    self.selectedButton.frame = CGRectMake(x,self.buttonY, self.buttonW, self.buttonW);
    
    CGFloat backButtonX = x - self.effectiveAreaOffset;
    backButtonX = backButtonX <= 0 ? 0 : backButtonX;
    
    CGFloat backButtonY = self.buttonY - self.effectiveAreaOffset;
    backButtonY = backButtonY <= 0 ? 0 : backButtonY;
    
    CGFloat buttonMaxX = backButtonX + self.buttonW + self.effectiveAreaOffset * 2;
    buttonMaxX = buttonMaxX > selfW ? selfW : buttonMaxX;
    CGFloat backButtonW = buttonMaxX - backButtonX;
    
    self.selectedBackgroundButton.frame = CGRectMake(x-self.effectiveAreaOffset, backButtonY, backButtonW, backButtonW);
    //            break;
    //        default:break;
    
    //    }
}
- (void)setDataPrivate: (PYAssetModel *)model {
    [self setValue:model forKey:@"assetModel"];
    __weak typeof(self)weakSelf = self;
    __weak typeof([PYAblum defaultAblum])ablum = [PYAblum defaultAblum];
    if (!model.delicateImage) {
        [ablum getAssetWithImageWidth:weakSelf.imageWidth andModel:model andBlock:^(PYAssetModel *assetFirstModel) {
            if (weakSelf.imageID == assetFirstModel.imageRequestID) {
                [weakSelf setDataWithImage:model];
                [weakSelf setDataWithButton:assetFirstModel];
                [weakSelf setData:assetFirstModel];
            }
        } andBlock:^(PYAssetModel *assetLastModel) {
            if (weakSelf.imageID == assetLastModel.imageRequestID) {
                [weakSelf setDataWithImage:model];
                [weakSelf setDataWithButton:assetLastModel];
                [weakSelf setData:assetLastModel];
            }
        }];
    }
    self.imageID = model.imageRequestID;
    [self setDataWithImage:model];
    [self setDataWithButton:model];
    [self setDataWithMaskColor: model];
    [self setData:model];
}
    
    - (void)setDataWithImage:(PYAssetModel *)model {
        if (model.delicateImage) {
            self.imageView.image = model.delicateImage;
        }else{
            self.imageView.image = model.degradedImage;
        }
    }
    
    - (void)setDataWithMaskColor: (PYAssetModel *)model {
        UIColor *maskColor = [UIColor clearColor];
        if (model.isBeyondTheMaximum && !model.isSelected) {
            maskColor = self.notSelectedAndOverTopMaxSelectedCountMaskViewColor;
        } else if(model.isSelected) {
            maskColor = self.selectedColor;
        }
        self.maskView.backgroundColor = maskColor;
    }
    
- (void)setDataWithButton:(PYAssetModel *)model {
    NSString *title = [NSString stringWithFormat:@"%ld",(long)model.orderNumber];
    if (model.orderNumber <= 0) {
        title = @"";
    }
    [self.selectedButton setTitle:title forState:UIControlStateNormal];
    self.selectedButton.transform = CGAffineTransformInvert(self.selectedButton.transform);
    self.selectedButton.selected = model.isSelected;
    [self changeButtonStatus:self.selectedButton];
    
}
#pragma mark: - 设置数据
- (void)setData: (PYAssetModel *)model {
    
    //    switch (self.type) {
    //        case PYAssetList_CollectionViewCell_Custom:return;
    //        default:break;
    //    }
}
    
#pragma mark: - event
- (void)clickImageView: (UITapGestureRecognizer *)tap {
    if (!self.clickImageViewBlock(self.assetModel)) {
        return;
    }
    if (self.event) {
        self.event(PYAssetListCell_clickImageView, self.assetModel);
    }
}
- (void)eventCallBackFunc:(void (^)(NSString *, PYAssetModel *))eventBlock {
    self.event = eventBlock;
}
    
#pragma mark - property
- (UIButton *)selectedBackgroundButton {
    if (!_selectedBackgroundButton) {
        _selectedBackgroundButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_selectedBackgroundButton addTarget:self action:@selector(clickSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedBackgroundButton;
}
- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _selectedButton.layer.cornerRadius = self.buttonW / 2.0;
        _selectedButton.layer.masksToBounds = true;
        _selectedButton.layer.borderWidth = 1.0;
        _selectedButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _selectedButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _selectedButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_selectedButton addTarget:self action:@selector(clickSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}
- (void)clickSelectedButton: (UIButton *)button {
    if (!self.notSelectedAndOverTopMaxSelectedCountButtonUserInteractionEnabled) {
        if (self.assetModel.isBeyondTheMaximum && !self.assetModel.isSelected) {
            return;
        }
    }
    if (!self.clickRightTopBlock(self.assetModel)) {
        return;
    }
    self.selectedButton.selected = !self.selectedButton.selected;
    [self changeButtonStatus:self.selectedButton];
    
    [UIView animateWithDuration:0.1 animations:^{
        CGFloat x = self.bounds.size.width - self.buttonW - self.buttonY;
        self.selectedButton.frame = CGRectMake(x - 2,self.buttonY - 2, self.buttonW + 4, self.buttonW + 4);
    } completion:^(BOOL finished) {
        CGFloat x = self.bounds.size.width - self.buttonW - self.buttonY;
        self.selectedButton.frame = CGRectMake(x,self.buttonY, self.buttonW, self.buttonW);
        if (self.event) {
            self.event(PYAssetListCell_ClickSelectedButton, self.assetModel);
        }
    }];
}
- (void)changeButtonStatus: (UIButton *)button {
    
    if (button.selected) {
        button.backgroundColor = [UIColor colorWithRed: 68.0 / 255.0 green: 179.0 / 255.0 blue:60.0 / 255.0 alpha:1];
        button.layer.borderWidth = 0;
    }else{
        button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        button.layer.borderWidth = [UIScreen mainScreen].scale / 2.0;
        
    }
}
//- (BOOL) isCustomClass {
//    NSString *selfClassString = NSStringFromClass(self.class);
//    return ![selfClassString  isEqualToString:@"PYAssetList_CollectionViewCell"];
//}
- (void)setButtonW:(CGFloat)buttonW {
    _buttonW = buttonW;
    self.selectedButton.layer.cornerRadius = self.buttonW / 2.0;
}
    
- (void)clickImageViewFunc:(BOOL (^)(PYAssetModel *))clickImageViewBlock {
    _clickImageViewBlock = clickImageViewBlock;
}
- (void)clickRightTopButtonFunc:(BOOL (^)(PYAssetModel *))clickRightTopBlock {
    _clickRightTopBlock = clickRightTopBlock;
}
@end

