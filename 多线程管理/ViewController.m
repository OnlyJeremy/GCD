//
//  ViewController.m
//  多线程管理
//
//  Created by Jeremy on 16/8/4.
//  Copyright © 2016年 Jeremy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
#pragma mark iOS多线程GCD的基本用法
    /*
     比较多的用于更新UI操作
     比如从数据库获取数据需要花较长的时间，又不希望卡主线程，就把获取数据库操作放在异步操作代码块中，等获取结束，回到主线程更新UI，在主线程操作代码块中进行操作。
     
     下面我们来解析一下这代码块中的每个方法：
     
     dispatch_async(<#dispatch_queue_t queue#>, <#^(void)block#>)
     表示异步操作，与之对应的是
     dispatch_sync(<#dispatch_queue_t queue#>,<#^(void)block#>),同步操作，block中的代码执行完了才能执行后面的操作
     方法中第一个参数  dispatch_queue_t queue 表示队列，无非是两种：串行和并行，另外可自建串行或并行队列
    获取系统串行队列，也就是主线程串行队列：dispatch_get_main_queue()
    获取系统并行队列：dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

     其中第一个参数，是队列优先级，有四种：

     #define DISPATCH_QUEUE_PRIORITY_HIGH 2

     #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0

     #define DISPATCH_QUEUE_PRIORITY_LOW (-2)
     
     #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN 

     会根据优先级高低，进行处理
     
     dispatch_queue_create("com.example.serial", NULL);
     第一个参数，文档规范说A string label to attach to the queue.这个字符串需要唯一性，一般是以上形式呈现
     第二个参数传 NULL 或者 DISPATCH_QUEUE_SERIAL表示串行 传DISPATCH_QUEUE_CONCURRENT 表示并行当执行结束，必须要有 dispatch_release() ，将队列释放
     
 
     
     */
     // 异步操作代码快
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        dispatch_async(dispatch_get_main_queue(), ^{
          // 回到主线程操作代码块
        });
    
        
    });
    
    
    
    //=====================================================
    //iOS常见的延时执行有2种方式调用NSObject的方法
    
    [self performSelector:@selector(run) withObject:nil afterDelay:2.0];
    // 2秒后再调用self 的run方法使用GCD函数

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2.0 * NSEC_PER_SEC)),
                   
                   dispatch_get_main_queue(), ^{ 

                       // 2秒后异步执行这里的代码...
 
                   }); 
    
    //============================================= ========
    
    
    //使用dispatch_once函数能保证某段代码在程序运行过程中只被执行1次。
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       //只执行1次的代码（这里边默认是线程安全的）
    });
    
    
    
    /*
     有这么1中需求
     首先：分别执行2个耗时的操作
     其次：等2个异步操作都执行完毕后，再回到主线程执行操作
     
     */
    //如果想要快速高效地实现上述需求，可以考虑用队列组
    dispatch_group_t group = dispatch_group_create(); //创建一个队列组
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //执行1个耗时的异步操作
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //执行1个耗时的异步操作
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
     //等前边的异步操作都执行完毕后，回到主线程
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
