//
//  RunloopManager.m
//  OC_AblumMaster
//
//  Created by 李鹏跃 on 2018/2/24.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "RunloopManager.h"
//定义一个block
typedef BOOL(^RunloopBlock)(void);

@interface RunloopManager()
///定时器， runloop至少有一个source
@property (nonatomic,strong) NSTimer *timer;

///储存请求图片的block数组
@property (nonatomic,strong) NSMutableArray <RunloopBlock>*tasks;
///对key进行储存
@property (nonatomic,strong) NSMutableArray <NSString *> *taskKeys;
///是否唤醒runloop 执行任务
@property (nonatomic,assign) BOOL isRunLoop;
@end

@implementation RunloopManager
static RunloopManager *manager;
+ (instancetype) defaultRunloopManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RunloopManager alloc]init];
        [manager addRunloopObserver];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minSecondDuration = 0.01;
        self.maxTaskCount = 200;
        self.tasks = [[NSMutableArray alloc]init];
        self.taskKeys = [[NSMutableArray alloc]init];
    }
    return self;
}



//MARK: 添加任务
-(void)addTask:(RunloopBlock)task withKey:(NSString *)key {
    [self.tasks addObject:task];
    [self.taskKeys addObject:key];
    if (self.tasks.count >= self.maxTaskCount) {
        [self.tasks removeObjectAtIndex:0];
        [self.taskKeys removeObjectAtIndex:0];
    }
    if (!self.isRunLoop) self.isRunLoop = true;
}

-(void)addTasks:(NSArray <BOOL(^)(void)> *)tasks {
    if (!self.tasks.count) {
        NSLog(@"队列中 还有未完成的任务，无法添加");
    }
}


//MARK: 回调函数
//定义一个回调函数  一次RunLoop来一次
static void Callback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    RunloopManager * manager = (__bridge RunloopManager *)(info);
    if (manager.tasks.count == 0) {
        manager.isRunLoop = false;
        if ([manager.delegate respondsToSelector:@selector(runCompletionCallBackFunc)]) {
            [manager.delegate runCompletionCallBackFunc];
        }
        return;
    }
    BOOL result = NO;
    NSInteger runTaskCount = 0;
    while (result == NO && manager.tasks.count && runTaskCount <= manager.maxTaskCount) {
        runTaskCount ++;
        //取出任务
        RunloopBlock task = manager.tasks.firstObject;
        BOOL isRunTask = true;
        if ([manager.delegate respondsToSelector:@selector(runTaskCallbackFunc:andTaskKey:)]) {
            isRunTask = [manager.delegate runTaskCallbackFunc:task andTaskKey: manager.taskKeys.firstObject];
        }
        //执行任务
        if (isRunTask) {result = task();}
        //干掉第一个任务
        [manager.tasks removeObjectAtIndex:0];
        //干掉标示
        [manager.taskKeys removeObjectAtIndex:0];
    }
}


- (NSTimer *) timer {
    if(!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.minSecondDuration
                                                  target:self
                                                selector:@selector(setRunLoop)
                                                userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer
                                     forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

//此方法主要是利用计时器事件保持runloop处于循环中，不用做任何处理
-(void)setRunLoop{
}


- (void)setIsRunLoop:(BOOL)isRunLoop {
    _isRunLoop = isRunLoop;
    if (isRunLoop) {
        [self.timer fire];
    }else{
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)addRunloopObserver {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    //定义一个centext
    CFRunLoopObserverContext context = {
        0,
        ( __bridge void *)(self),
        &CFRetain,
        &CFRelease,
        NULL
    };
    //定义一个观察者
    static CFRunLoopObserverRef defaultModeObsever;
    //创建观察者
    defaultModeObsever = CFRunLoopObserverCreate(NULL,
                                                 kCFRunLoopBeforeWaiting,
                                                 YES,
                                                 NSIntegerMax - 999,
                                                 &Callback,
                                                 &context
                                                 );
    
    //添加当前RunLoop的观察者
    CFRunLoopAddObserver(runloop, defaultModeObsever, kCFRunLoopDefaultMode);
    //c语言有creat 就需要release
    CFRelease(defaultModeObsever);
}

@end
