//
//  SDDispatchTimer.m
//
//  Created by Sheldon on 2018/10/19.
//  Copyright © 2018年 Sheldon. All rights reserved.
//

#import "SDDispatchTimer.h"

@implementation SDDispatchTimer

static NSMutableDictionary * timerContainer;


+ (void)initialize
{
    timerContainer = [NSMutableDictionary dictionary];
}


+ (void)scheduleDispatchTimerWithName:(NSString *)timerName timeInterval:(double)interval queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)action
{
    if (nil == timerName) {
        return;
    }
    
    if (nil == queue) {//默认为全局并发队列
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    dispatch_source_t timer = [timerContainer objectForKey:timerName];
    if (timer == nil) {//创建
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        [timerContainer setObject:timer forKey:timerName];
        //执行timer 一定放在这里 放下面会造成野指针
        dispatch_resume(timer);
    }
    
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, start, interval * NSEC_PER_SEC, 0);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        action();
        if (!repeats) {
            [weakSelf cancelTimerWithName:timerName];
        }
    });
}

+ (void)scheduleDispatchCountdownTimerWithName:(NSString *)timerName
                                 countdownTime:(NSTimeInterval)timeValue
                                  timeInterval:(double)interval
                                         queue:(dispatch_queue_t)queue
                                        action:(void(^)(NSTimeInterval time))action {
    __block NSTimeInterval time = timeValue;
    if (nil == timerName) {
        return;
    }
    
    if (nil == queue) {//默认为全局并发队列
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    dispatch_source_t timer = [timerContainer objectForKey:timerName];
    if (timer == nil) {//创建
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        [timerContainer setObject:timer forKey:timerName];
        //执行timer 一定放在这里 放下面会造成野指针
        dispatch_resume(timer);
    }
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, start, interval * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        time -= interval;
        action(time);
        if (time <= 0) {
            [weakSelf cancelTimerWithName:timerName];
        }
    });
}

+ (void)cancelTimerWithName:(NSString *)timerName
{
    dispatch_source_t timer = [timerContainer objectForKey:timerName];
    
    if (timer == nil) {
        return;
    }
    
    [timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
}


+ (void)cancelAllTimer
{
    [timerContainer enumerateKeysAndObjectsUsingBlock:^(NSString * timerName, dispatch_source_t timer, BOOL * _Nonnull stop) {
        [timerContainer removeObjectForKey:timerName];
        dispatch_source_cancel(timer);
    }];
}

@end
