//
//  UIViewController+Points.m
//  LH--AOP编程实例
//
//  Created by chenlonghai on 2019/8/21.
//  Copyright © 2019 chenlonghai. All rights reserved.
//

#import "UIViewController+Points.h"
#import "LHHook.h"
#import "Aspects.h"
@implementation UIViewController (Points)
+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        SEL fromWillAppearSelector = @selector(viewWillAppear:);
//        SEL toWillAppearSelector = @selector(hook_viewWillAppear:);
//        [LHHook hookClass:self fromSelector:fromWillAppearSelector toSelector:toWillAppearSelector];
//
//        SEL fromillDisappear = @selector(viewWillDisappear:);
//        SEL toillDisappear= @selector(hook_viewWillDisAppear:);
//        [LHHook hookClass:self fromSelector:fromillDisappear toSelector:toillDisappear];
        
        [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info) {
            NSString *className = NSStringFromClass([[info instance] class]);
            NSLog(@"aspect-->%@",className);
        }  error:NULL];

        [UIViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
            NSString *className = NSStringFromClass([[info instance] class]);
            NSLog(@"aspect-->%@",className);
        }  error:NULL];
 });
}
-(void)hook_viewWillAppear:(BOOL)animated{
    // 进来的时间 根据具体的业务去加时间的统计
         [self comeIn];
        NSLog(@"__%@___%s",NSStringFromClass(self.class),  __func__);
    
       [self hook_viewWillAppear:animated];
}

-(void)hook_viewWillDisAppear:(BOOL)animated{
    // 出去的时间 统计方法根据具体的业务加
     [self comeOut];
//    NSLog(@"_____%s",__func__);
    [self hook_viewWillDisAppear:animated];
}

- (void)comeIn{
    NSLog(@"进来前");
}
- (void)comeOut{
    NSLog(@"出去后");
}


@end
