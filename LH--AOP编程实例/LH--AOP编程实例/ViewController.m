//
//  ViewController.m
//  LH--AOP编程实例
//
//  Created by chenlonghai on 2019/8/20.
//  Copyright © 2019 chenlonghai. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "Aspects.h"

@interface ViewController ()

@end

@implementation ViewController



- (IBAction)pushAction:(id)sender {
    
    [self.navigationController pushViewController:SecondViewController.new animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{

    NSLog(@"xxxxxxxxx%s", __func__);
    [super viewWillAppear:animated];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hello:@"AOP实例编程"];
}

- (void)hello:(NSString *)str{
    NSLog(@"——————hello__%@",str);
}
+(void)load{
//    AspectPositionAfter   = 0,            /// Called after the original implementation (default)
//    AspectPositionInstead = 1,            /// Will replace the original implementation.
//    AspectPositionBefore  = 2,            /// Called before the original implementation.
//
//    AspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
 //   AspectInfo 被勾的对象
    [self aspect_hookSelector:@selector(hello:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info,NSString *str) {
        
  
        //调用的实例对象
        id instance = info.instance;
        NSString *className = NSStringFromClass([instance class]);
        NSLog(@"aspect-->%@--hello1",className);
        //原始的方法
        id invocation = info.originalInvocation;
           NSLog(@"原始的方法：%@",invocation);
        //参数
        id arguments = info.arguments;
          NSLog(@"参数：%@",arguments);
        //原始的方法，再次调用
        [invocation invoke];
        
        //监控方法的参数值
        NSLog(@"方法参数值：%@",str);
    } error:NULL];
}
@end
