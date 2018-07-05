//
//  ViewController.m
//  PYAblumOC
//
//  Created by 李鹏跃 on 2018/7/5.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "ViewController.h"
#import "PYAblumHeader.h"
@interface ViewController ()<PYAssetListViewEventHandle>
@property (nonatomic,strong) PYAssetListView *assetView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview: self.assetView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - getter
- (PYAssetListView *) assetView {
    if (!_assetView) {
        PYAssetListViewConfiguration *configuration = [[PYAssetListViewConfiguration alloc] init];
        configuration.imageWidth = 400;
        configuration.selectedImageWidth = 600;
        configuration.maxAssetSelectedCount = 8;
        
        _assetView = [[PYAssetListView alloc] initWithFrame:self.view.bounds andConfiguration:configuration];
        _assetView.eventHandlerel = self;

    }
    return _assetView;
}


- (void)eventFunc:(PYAssetModel *)model andKey:(NSString *)key andInfo:(id)info {

    if ([key isEqualToString:PYAssetListCell_ClickSelectedButton]) {
        [PYAblum getSelectAssetArrayWithClickedModel:model andMaxCount:6 andOverTopBlock:^(NSArray<PYAssetModel *> *modelArray, BOOL isVoerTop) {
            //...做你想做的事情
        }];
        [_assetView reloadData];
    }
}

@end
