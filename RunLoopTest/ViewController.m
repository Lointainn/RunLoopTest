//
//  ViewController.m
//  RunLoopTest
//
//  Created by Tusky on 2017/7/19.
//  Copyright © 2017年 Tusky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) dispatch_queue_t aGlobalQueue;
@property (nonatomic, strong) NSThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self runloopObserver];
    [self openSonThreadRunLoop];
    [self openSecondThreadRunLoop];
}

- (void)openSonThreadRunLoop {
    _aGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(_aGlobalQueue, ^{
        NSLog(@"现在开启子线程RunLoop");
        //开启runloop使线程常驻
        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
        NSLog(@"这句话如果被打印,说明子线程runloop被开启失败");
    });
}

- (void)openSecondThreadRunLoop {
    
    _thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"现在开启第二个子线程RunLoop");
        //开启runloop使线程常驻
        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
        NSLog(@"这句话如果被打印,说明第二个子线程runloop被开启失败");
    }];
    [_thread start];
}

- (void)runloopObserver {
    // Do any additional setup after loading the view, typically from a nib.
    /*
     kCFRunLoopEntry = (1UL << 0),
     kCFRunLoopBeforeTimers = (1UL << 1),
     kCFRunLoopBeforeSources = (1UL << 2),
     kCFRunLoopBeforeWaiting = (1UL << 5),
     kCFRunLoopAfterWaiting = (1UL << 6),
     kCFRunLoopExit = (1UL << 7),
     kCFRunLoopAllActivities = 0x0FFFFFFFU
     */
    NSDictionary *dic = @{@"1":@"kCFRunLoopEntry",
                          @"2":@"kCFRunLoopBeforeTimers",
                          @"4":@"kCFRunLoopBeforeSources",
                          @"32":@"kCFRunLoopBeforeWaiting",
                          @"64":@"kCFRunLoopAfterWaiting",
                          @"128":@"kCFRunLoopExit"
                          };
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, 1, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"%lu %@",activity,dic[@(activity).stringValue]);
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    CFRelease(observer);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"开启了个临时线程");
    }];
    [thread start];
    //没有常驻的线程在运行完其任务以后就不再能执行其他任务
    [self performSelector:@selector(showSomethingOnThread:) onThread:thread withObject:thread waitUntilDone:0];
    //常驻了的线程在运行了刚开始创建的任务以后,后期还可以继续执行其他任务
    [self performSelector:@selector(showSomethingOnThread:) onThread:self.thread withObject:self.thread waitUntilDone:0];

}

- (void)showSomethingOnThread:(NSThread *)thread {
    NSLog(@"showOnThread: %@",thread);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
