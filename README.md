# iOS多线程
1. Pthreads：基本很少用
2. NSThread：基本很少用
    1. 获取当前线程：```[NSThread currentThread]```
    2. 休眠当前线程
        ```
        + (void)sleepForTimeInterval:(NSTimeInterval)time;
        + (void)sleepUntilDate:(NSDate *)date;
        ```
    3. 给线程命名：```[NSThread currentThread].name```
    4. 其他接口
        ```
        @interface NSThread : NSObject  {
        @private
            id _private;
            uint8_t _bytes[44];
        }
        //当前线程
        @property (class, readonly, strong) NSThread *currentThread;

        //创建新线程，前者是block方式（iOS10+），后者是selector方式
        + (void)detachNewThreadWithBlock:(void (^)(void))block API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));
        + (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(nullable id)argument;

        //是否是多线程
        + (BOOL)isMultiThreaded;
        //维护一个字典保存一些信息，在整个线程的执行过程中都不变
        @property (readonly, retain) NSMutableDictionary *threadDictionary;

        //休眠当前线程
        + (void)sleepUntilDate:(NSDate *)date;
        + (void)sleepForTimeInterval:(NSTimeInterval)ti;

        //结束进程
        + (void)exit;

        //线程优先级
        + (double)threadPriority;
        + (BOOL)setThreadPriority:(double)p;

        //设置优先级，iOS8+推荐使用NSQualityOfService
        @property double threadPriority API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0)); // To be deprecated; use qualityOfService below

        @property NSQualityOfService qualityOfService API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0)); // read-only after the thread is started

        //当前线程在栈空间的地址
        @property (class, readonly, copy) NSArray<NSNumber *> *callStackReturnAddresses API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        //栈空间的符号表
        @property (class, readonly, copy) NSArray<NSString *> *callStackSymbols API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

        //线程名称
        @property (nullable, copy) NSString *name API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        //栈大小
        @property NSUInteger stackSize API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        //是否是主线程
        @property (readonly) BOOL isMainThread API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        @property (class, readonly) BOOL isMainThread API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)); // reports whether current thread is main
        //获取主线程
        @property (class, readonly, strong) NSThread *mainThread API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

        //初始化
        - (instancetype)init API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) NS_DESIGNATED_INITIALIZER;
        - (instancetype)initWithTarget:(id)target selector:(SEL)selector object:(nullable id)argument API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        - (instancetype)initWithBlock:(void (^)(void))block API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));

        //是否在执行
        @property (readonly, getter=isExecuting) BOOL executing API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        //是否执行完成
        @property (readonly, getter=isFinished) BOOL finished API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        //是否取消
        @property (readonly, getter=isCancelled) BOOL cancelled API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        //取消线程
        - (void)cancel API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        //开始线程
        - (void)start API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

        - (void)main API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));	// thread body method

        @end
        //一些通知
        FOUNDATION_EXPORT NSNotificationName const NSWillBecomeMultiThreadedNotification;
        FOUNDATION_EXPORT NSNotificationName const NSDidBecomeSingleThreadedNotification;
        FOUNDATION_EXPORT NSNotificationName const NSThreadWillExitNotification;

        @interface NSObject (NSThreadPerformAdditions)

        - (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array;
        - (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
            // equivalent to the first method with kCFRunLoopCommonModes

        - (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
        - (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
            // equivalent to the first method with kCFRunLoopCommonModes
        - (void)performSelectorInBackground:(SEL)aSelector withObject:(nullable id)arg API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

        @end
        ```
3. GCD：目前苹果官方推荐的多线程开发方式
    1. GCD的两个重要概念：队列和执行方式
    2. 队列：串行队列、并行队列、主队列（特殊的串行队列）、全局队列（特殊的并行队列）
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
    6. dispatch_after：注意，并不是3秒后执行任务，而是3秒后把任务追加到queue上，而且由于runloop的原因，可能会延迟
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
        //此处也可使用dispatch_group_wait 返回0为执行完毕
        //不过还是推荐使用dispatch_group_notify
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
    12. GCD定时器：注意timer一定要强引用
        ```
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
        dispatch_source_set_timer(self.timer, start, 2 * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(self.timer, ^{
            NSLog(@"dispatch_source_t");
        });
        dispatch_resume(self.timer);
        ```
    13. dispatch_set_target_queue
        1. 改变queue的优先级，因为自定义创建的线程优先级都为default
        2. 比如存在多个串行队列，它们是并行执行的，如果使用```dispatch_set_target_queue```把第二个参数设置为串行队列，它们就会同步执行
            ```
            dispatch_queue_t serialQueue1 = dispatch_queue_create("com.cxy.serialQueue1", DISPATCH_QUEUE_SERIAL);
            dispatch_queue_t serialQueue2 = dispatch_queue_create("com.cxy.serialQueue2", DISPATCH_QUEUE_SERIAL);
            dispatch_queue_t serialQueue3 = dispatch_queue_create("com.cxy.serialQueue3", DISPATCH_QUEUE_SERIAL);
            
            dispatch_set_target_queue(serialQueue1, self.serialQueue);
            dispatch_set_target_queue(serialQueue2, self.serialQueue);
            dispatch_set_target_queue(serialQueue3, self.serialQueue);
            dispatch_async(serialQueue1, ^{
                NSLog(@"dispatch_set_target_queue 1");
            });
            dispatch_async(serialQueue2, ^{
                NSLog(@"dispatch_set_target_queue 2");
            });
            dispatch_async(serialQueue3, ^{
                NSLog(@"dispatch_set_target_queue 3");
            });
            ```
    14. 暂停与恢复
        ```
        dispatch_suspend(queue);
        dispatch_resume(queue);
        ```
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
        //可以看出是异步执行
        ```

        1. 任务优先级：queuePriority
        2. 添加依赖关系：[A addDependency:B] B先执行完才能执行A（注意添加依赖必须在添加操作前完成）
        3. 阻塞线程：- (void)waitUntilFinished; 阻塞当前线程，直到该操作完成
        4. 操作完成的监听：setCompletionBlock 
    3. NSOperationQueue：管理NSOperation，不需要调用start
        1. 添加操作：addOperation
        2. 最大并发数：maxConcurrentOperationCount 不要开太多，建议2~3为宜
        3. 取消所有操作：cancelAllOperations；暂停所有操作：setSuspended 比如用户在操作UI的时候可以暂停队列
    4. 接口API
        ```
        @interface NSOperation : NSObject {
        @private
            id _private;
            int32_t _private1;
        #if __LP64__
            int32_t _private1b;
        #endif
        }
        //开始
        - (void)start;
        //入口，一般用于自定义子类
        - (void)main;
        //是否取消
        @property (readonly, getter=isCancelled) BOOL cancelled;
        //取消
        - (void)cancel;
        //是否在执行
        @property (readonly, getter=isExecuting) BOOL executing;
        //是否完成
        @property (readonly, getter=isFinished) BOOL finished;
        //是否异步执行，iOS7+被asynchronous代替
        @property (readonly, getter=isConcurrent) BOOL concurrent; // To be deprecated; use and override 'asynchronous' below
        @property (readonly, getter=isAsynchronous) BOOL asynchronous API_AVAILABLE(macos(10.8), ios(7.0), watchos(2.0), tvos(9.0));
        //是否准备好，在start之前
        @property (readonly, getter=isReady) BOOL ready;
        //添加依赖
        - (void)addDependency:(NSOperation *)op;
        //移除依赖，不能在执行时移除
        - (void)removeDependency:(NSOperation *)op;
        //依赖数组
        @property (readonly, copy) NSArray<NSOperation *> *dependencies;
        //优先级枚举
        typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
            NSOperationQueuePriorityVeryLow = -8L,
            NSOperationQueuePriorityLow = -4L,
            NSOperationQueuePriorityNormal = 0,
            NSOperationQueuePriorityHigh = 4,
            NSOperationQueuePriorityVeryHigh = 8
        };
        //优先级
        @property NSOperationQueuePriority queuePriority;
        //完成后的回调
        @property (nullable, copy) void (^completionBlock)(void) API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
        //是否阻塞线程
        - (void)waitUntilFinished API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

        @property double threadPriority API_DEPRECATED("Not supported", macos(10.6,10.10), ios(4.0,8.0), watchos(2.0,2.0), tvos(9.0,9.0));

        @property NSQualityOfService qualityOfService API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));

        @property (nullable, copy) NSString *name API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));

        @end
        ```

        ```
        @interface NSOperationQueue : NSObject {
        @private
            id _private;
            void *_reserved;
        }
        //添加操作
        - (void)addOperation:(NSOperation *)op;
        - (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

        - (void)addOperationWithBlock:(void (^)(void))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
        //操作数组
        @property (readonly, copy) NSArray<__kindof NSOperation *> *operations;
        //操作总数
        @property (readonly) NSUInteger operationCount API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
        //最大并发数
        @property NSInteger maxConcurrentOperationCount;
        //是否暂停
        @property (getter=isSuspended) BOOL suspended;
        //队列名字
        @property (nullable, copy) NSString *name API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

        @property NSQualityOfService qualityOfService API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));
        //主线程的队列
        @property (nullable, assign /* actually retain */) dispatch_queue_t underlyingQueue API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));
        //取消所有操作
        - (void)cancelAllOperations;
        //阻塞线程
        - (void)waitUntilAllOperationsAreFinished;
        //获取当前队列
        @property (class, readonly, strong, nullable) NSOperationQueue *currentQueue API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
        //获取主队列
        @property (class, readonly, strong) NSOperationQueue *mainQueue API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

        @end
        ```
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

    
