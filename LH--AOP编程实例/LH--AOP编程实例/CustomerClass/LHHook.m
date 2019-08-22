//
//  LHHook.m
//  LH--AOP编程实例
//
//  Created by chenlonghai on 2019/8/21.
//  Copyright © 2019 chenlonghai. All rights reserved.
//

#import "LHHook.h"
#import <objc/runtime.h>

@implementation LHHook


+(void)hookClass:(Class)classObject fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector{
    Class class = classObject;
    // 得到被替换类的实例方法
    Method fromMethod = class_getInstanceMethod(class, fromSelector);
    // 得到替换类的实例方法
    Method toMethod = class_getInstanceMethod(class, toSelector);
    
    //返回失败，表示交换方法已经存在
    if (class_addMethod(class, fromSelector, method_getImplementation(toMethod), method_getTypeEncoding(fromMethod))) {
        
        class_replaceMethod(class, toSelector, method_getImplementation(fromMethod), method_getTypeEncoding(toMethod));
    }else{
        //函数直接进行IMP指针交换以实现方法交换
         method_exchangeImplementations(fromMethod, toMethod);
    }  
}
@end
