//
//  ViewController.m
//  iOSMultithreadingDemo
//
//  Created by 蔡晓阳 on 2018/7/14.
//  Copyright © 2018 cxy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArr;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@end

@implementation ViewController

- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[@"线程死锁",@"串行队列 + 同步执行",@"串行队列 + 异步执行",@"并行队列 + 同步执行",@"并行队列 + 异步执行",@"延时",@"dispatch_once",@"队列组",@"dispatch_barrier_async",@"dispatch_apply",@"信号量",@"NSBlockOperation",@"NSLock",@"@synchronized"];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.serialQueue = dispatch_queue_create("com.cxy.serialQueue", DISPATCH_QUEUE_SERIAL);
    self.concurrentQueue = dispatch_queue_create("com.cxy.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.row == 0) {
        [self test1];
    } else if (indexPath.row == 1) {
        [self test2];
    } else if (indexPath.row == 2) {
        [self test3];
    } else if (indexPath.row == 3) {
        [self test4];
    } else if (indexPath.row == 4) {
        [self test5];
    } else if (indexPath.row == 5) {
        [self test6];
    } else if (indexPath.row == 6) {
        [self test7];
    } else if (indexPath.row == 7) {
        [self test8];
    } else if (indexPath.row == 8) {
        [self test9];
    } else if (indexPath.row == 9) {
        [self test10];
    } else if (indexPath.row == 10) {
        [self test11];
    } else if (indexPath.row == 11) {
        [self test12];
    } else if (indexPath.row == 12) {
        [self test13];
    } else if (indexPath.row == 13) {
        [self test14];
    }
}

//线程死锁
- (void)test1 {
    NSLog(@"1========%@",[NSThread currentThread]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"2========%@",[NSThread currentThread]);
    });
    NSLog(@"3========%@",[NSThread currentThread]);
}

//串行队列 + 同步执行
- (void)test2 {
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"2========%@",[NSThread currentThread]);
    });
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"3========%@",[NSThread currentThread]);
    });
    NSLog(@"4========%@",[NSThread currentThread]);
}
//串行队列 + 异步执行
- (void)test3 {
    dispatch_async(self.serialQueue, ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
    dispatch_async(self.serialQueue, ^{
        NSLog(@"2========%@",[NSThread currentThread]);
    });
    dispatch_async(self.serialQueue, ^{
        NSLog(@"3========%@",[NSThread currentThread]);
    });
    NSLog(@"4========%@",[NSThread currentThread]);
}
//并行队列 + 同步执行
- (void)test4 {
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"2========%@",[NSThread currentThread]);
    });
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"3========%@",[NSThread currentThread]);
    });
    NSLog(@"4========%@",[NSThread currentThread]);
}

//并行队列 + 异步执行
- (void)test5 {
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"2========%@",[NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"3========%@",[NSThread currentThread]);
    });
    NSLog(@"4========%@",[NSThread currentThread]);
}

//延时
- (void)test6 {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0*NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
}

//dispatch_once
- (void)test7 {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
}

//队列组
- (void)test8 {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"2========%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"3========%@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"4========%@",[NSThread currentThread]);
    });
}
//dispatch_barrier_async
- (void)test9 {
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"1========%@",[NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"2========%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(self.concurrentQueue, ^{
        NSLog(@"dispatch_barrier_async");
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"3========%@",[NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"4========%@",[NSThread currentThread]);
    });
}

//dispatch_apply
- (void)test10 {
    dispatch_apply(4, self.serialQueue, ^(size_t i) {
        NSLog(@"%zu========%@",i,[NSThread currentThread]);
    });
    
    dispatch_apply(4, self.concurrentQueue, ^(size_t i) {
        NSLog(@"%zu========%@",i+4,[NSThread currentThread]);
    });
}

//信号量
- (void)test11 {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(4, self.concurrentQueue, ^(size_t i) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(self.concurrentQueue, ^{
            NSLog(@"%zu========%@",i,[NSThread currentThread]);
            dispatch_semaphore_signal(semaphore);
        });
        
    });
}

//NSBlockOperation
- (void)test12 {
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1========%@",[NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"2========%@",[NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"3========%@",[NSThread currentThread]);
    }];
    [blockOperation start];
}
//NSLock
- (void)test13 {
    NSMutableArray *arr = [NSMutableArray new];
    [arr addObjectsFromArray:@[@"1",@"2",@"3",@"4"]];
    NSLock *lock = [NSLock new];
    for (int i = 0; i < 6; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [lock lock];
            if (arr.count > 0) {
                NSLog(@"%@",arr.lastObject);
                [arr removeLastObject];
            } else {
                NSLog(@"xx");
            }
            [lock unlock];
        });
    }
    
}

//@synchronized
- (void)test14 {
    NSMutableArray *arr = [NSMutableArray new];
    [arr addObjectsFromArray:@[@"1",@"2",@"3",@"4"]];
    for (int i = 0; i < 6; i++) {
        dispatch_async(self.concurrentQueue, ^{
            @synchronized (self) {
                if (arr.count > 0) {
                    NSLog(@"%@",arr.lastObject);
                    [arr removeLastObject];
                } else {
                    NSLog(@"xx");
                }
            }
        });
    }
}


@end
