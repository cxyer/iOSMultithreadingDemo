# iOS多线程（GCD和NSOperation的选择主要看个人爱好吧，我就喜欢用GCD）
1. Pthreads：基本很少用
2. NSThread：感觉用到最多的就是[NSThread currentThread]
3. GCD：目前苹果官方推荐的多线程开发方式
    1. GCD的两个重要概念：队列和执行方式
    2. 队列：串行队列、并行队列、主队列、全局队列
    3. 执行方式：同步、异步
    4. 线程死锁
        ```
        NSLog(@"1========%@",[NSThread currentThread]);
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"2========%@",[NSThread currentThread]);
        });
        NSLog(@"3========%@",[NSThread currentThread]);
        ```
        dispatch_sync在主线程，主线程需要等待dispatch_sync执行完才能继续执行，而dispatch_sync是同步执行需要等待主线程执行完才能继续执行，这样双方互相等待造成线程死锁
        #### 解决：dispatch_sync换成异步执行dispatch_async，或者dispatch_sync加入并行队列
    5. 创建队列
        ```
        self.serialQueue = dispatch_queue_create("com.cxy.serialQueue", DISPATCH_QUEUE_SERIAL);
        self.concurrentQueue = dispatch_queue_create("com.cxy.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        ```
        #### 四种组合方式
        1. 串行队列 + 同步执行：不会开辟新线程，顺序执行
        2. 串行队列 + 异步执行：会开辟新线程，但是由于是串行队列，所以子线程会按顺序执行
        3. 并行队列 + 同步执行：不会开辟新线程，顺序执行
        4. 并行队列 + 异步执行：会开辟新线程，随机顺序
    6. dispatch_after
        ```
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0*NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            NSLog(@"1========%@",[NSThread currentThread]);
        });
        ```
    7. dispatch_once：整个生命周期内只会执行一次，用来配合单例模式
        ```
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"1========%@",[NSThread currentThread]);
        });
        ```
    8. 队列组：先执行dispatch_group_async，全部完成后才会执行dispatch_group_notify
        ```
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
        ```
        NSLog(@"4========%@",[NSThread currentThread]);都是最后一个执行的

    9. dispatch_barrier_async：类似栅栏的作用，保证该函数前的任务先执行
        ```
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
        ```
        1、2和3、4的中间一定是dispatch_barrier_async

    10. dispatch_apply：重复执行，如果放在串行队列，则顺序执行，如果放在并行队列，则随机执行
        ```
        dispatch_apply(4, self.serialQueue, ^(size_t i) {
            NSLog(@"%zu========%@",i,[NSThread currentThread]);
        });

        dispatch_apply(4, self.concurrentQueue, ^(size_t i) {
            NSLog(@"%zu========%@",i+4,[NSThread currentThread]);
        });
        ```
        #### 注意：该函数是同步执行，避免放在主线程，否则会造成线程死锁
    11. 信号量
        ```
        dispatch_semaphore_create 
        dispatch_semaphore_signal +1
        dispatch_semaphore_wait -1
        ```
        ```
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        dispatch_apply(4, self.concurrentQueue, ^(size_t i) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_async(self.concurrentQueue, ^{
                NSLog(@"%zu========%@",i,[NSThread currentThread]);
                dispatch_semaphore_signal(semaphore);
            });

        });
        ```
        结果按顺序执行
4. NSOperation/NSOperationQueue：苹果对于GCD的封装
    1. NSOperation：抽象类，需要自定义子类，很少用
    2. NSBlockOperation/NSInvocationOperation：系统提供的NSOperation子类，一个是用block，一个是用selector
        ```
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
        ```
        可以看出是异步执行

    3. NSOperationQueue：管理NSOperation，不需要调用start
        1. 任务优先级：queuePriority
        2. 添加依赖关系：[A addDependency:B] B先执行完才能执行A
        3. 最大并发数：maxConcurrentOperationCount 不要开太多，建议2~3为宜
        4. 取消所有操作：cancelAllOperations；暂停所有操作：setSuspended 比如用户在操作UI的时候可以暂停队列
        5. 操作完成的监听：setCompletionBlock 
# 线程锁
1. NSLock
    ```
    //解决了多次访问同一资源
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
    ```
2. @synchronized
    ```
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
    ```

    
