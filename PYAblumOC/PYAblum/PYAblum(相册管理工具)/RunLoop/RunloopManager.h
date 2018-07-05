//
//  RunloopManager.h
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/24.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RunLoopManagerDelegate <NSObject>

/**
 执行task 的回调

 @param task 任务
 @param taskKey 任务key
 @return 是否执行当前任务
 */
- (BOOL) runTaskCallbackFunc: (BOOL(^)(void))task andTaskKey: (NSString *)taskKey;

- (void) runCompletionCallBackFunc;

@end

@interface RunloopManager : NSObject

+ (instancetype) defaultRunloopManager;

///最大任务执行数 （每次 loop进入kCFRunLoopBeforeWaiting模式后 同时运行多少个任务）默认为20
@property (nonatomic,assign) NSInteger maxTaskCount;

///最少几秒调用一次循环 默认为0.1秒
@property (nonatomic,assign) CGFloat minSecondDuration;


/**
 添加任务

 @param task 任务 返回值为是否继续执行以下任务
 @param key 任务标识
 */
-(void)addTask:(BOOL(^)(void))task withKey:(NSString *)key;

//MARK: - delegate
@property (nonatomic,weak) id <RunLoopManagerDelegate> delegate;
@end
