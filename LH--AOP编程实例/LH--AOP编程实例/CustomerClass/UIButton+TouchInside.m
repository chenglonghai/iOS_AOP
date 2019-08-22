//
//  UIButton+TouchInside.m
//  LH--AOP编程实例
//
//  Created by chenlonghai on 2019/8/21.
//  Copyright © 2019 chenlonghai. All rights reserved.
//

#import "UIButton+TouchInside.h"
#import "LHHook.h"

@implementation UIButton (TouchInside)
+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(sendAction:to:forEvent:);
        SEL toSelector = @selector(hook_sendAction:to:forEvent:);
        [LHHook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}
-(void)hook_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    [self insertAction:action to:target forEvent:event];
    [self hook_sendAction:action to:target forEvent:event];
    
    
}
//对此方法进行相关埋点操作
-(void)insertAction:(SEL)action to:(id)target forEvent:(UIEvent*)event{
    NSString * actionName = NSStringFromSelector(action);//目标方法
    NSString * targetName = NSStringFromClass([target class]);//目标类
}
@end
