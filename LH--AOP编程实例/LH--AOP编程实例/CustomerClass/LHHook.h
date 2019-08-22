//
//  LHHook.h
//  LH--AOP编程实例
//
//  Created by chenlonghai on 2019/8/21.
//  Copyright © 2019 chenlonghai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHHook : NSObject
+(void)hookClass:(Class)classObject fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
@end

NS_ASSUME_NONNULL_END
