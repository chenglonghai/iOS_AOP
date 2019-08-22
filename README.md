# iOS_AOP
AOP （面向切面编程）
1. AOP简介
AOP为Aspect Oriented Programming的缩写：面向切面编程，通过预编译方式和运行期动态代理实现程序功能的统一维护的一种技术。利用AOP可以对业务逻辑的各个部分进行隔离，从而使得业务逻辑各部分之间的耦合度降低，提高程序的可重用性，同时提高了开发的效率。

2. iOS中的AOP
在iOS中实现AOP的核心技术是Runtime,使用Runtime的Method Swizzling黑魔法，我们可以移花接木，在运行时将方法的具体实现添油加醋、偷梁换柱。也就是说，AOP做一些与主业务无关的事，不影响主业务逻辑。
例如埋点，常见的三种埋点，页面进入次数、页面停留时间、点击事件，都可以通过运行时方法替换技术来插入埋点方法，具体实现方法，先写一个运行时替换方法。例如以下分类实现埋点操作
替换的方法如下
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
------页面进入次数、页面停留时间
@implementation UIViewController (Points)
+(void)initialize{
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
SEL fromWillAppearSelector = @selector(viewWillAppear:);
SEL toWillAppearSelector = @selector(hook_viewWillAppear:);
[LHHook hookClass:self fromSelector:fromWillAppearSelector toSelector:toWillAppearSelector];

SEL fromillDisappear = @selector(viewWillDisappear:);
SEL toillDisappear= @selector(hook_viewWillDisAppear:);
[LHHook hookClass:self fromSelector:fromillDisappear toSelector:toillDisappear];
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
-------点击事件
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
3. iOS中的AOP开发，直接使用Runtime方法交换开发的风险有哪些？
Runtime不仅能够进行方法的交换，还能够在运行时Objective-C特性（比如类、成员函数、继承）的增删改查操作。
（1）需要在+load方法进行交换，  其他时候交换，难以保证另一个线程中不会同时调用被交换的方法，从而导致程序的崩溃。
（2）被交换必须是当前类的方法，不能是父类的方法，直接把父类的实现拷贝过来不会起作用。父类的方法必须是在调用的时候使用，而不是方法交换的时候使用。
（3）方法交换命名冲突，可能导致方法交换失败。
4.Aspects-安全的方法交换库（Runtime的消息转发机制来实现方法交换）
将所有的方法调用都指到_objc_msgForward函数调用上，也就利用了forwardInvocation进行转发，最后通过NSInvocation调用来实现方法交换。
// 核心方法 1.Hook forwardInvocation 到自己的方法
// 2.交换原方法的实现为_objc_msgForward 使其直接进入消息转发模式
核心代码
static void aspect_prepareClassAndHookSelector(NSObject *self, SEL selector, NSError **error) {
NSCParameterAssert(selector);
// 1  swizzling forwardInvocation
Class klass = aspect_hookClass(self, error);

// // 被 hook 的 selector
Method targetMethod = class_getInstanceMethod(klass, selector);
IMP targetMethodIMP = method_getImplementation(targetMethod);
// 判断需要被Hook的方法是否应指向 _objc_msgForward 进入消息转发模式
if (!aspect_isMsgForwardIMP(targetMethodIMP)) {
// Make a method alias for the existing method implementation, it not already copied.
// 让一个新的子类方法名指向原先方法的实现，处理回调
const char *typeEncoding = method_getTypeEncoding(targetMethod);
SEL aliasSelector = aspect_aliasForSelector(selector);
if (![klass instancesRespondToSelector:aliasSelector]) {
__unused BOOL addedAlias = class_addMethod(klass, aliasSelector, method_getImplementation(targetMethod), typeEncoding);
NSCAssert(addedAlias, @"Original implementation for %@ is already copied to %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);
}

// We use forwardInvocation to hook in.
// 把 selector 指向 _objc_msgForward 函数
// 用 _objc_msgForward 函数指针代替 selector 的 imp,然后执行这个 imp  进入消息转发模式
class_replaceMethod(klass, selector, aspect_getMsgForwardIMP(self, selector), typeEncoding);
AspectLog(@"Aspects: Installed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
}
}
如何使用：
+ (id<AspectToken>)aspect_hookSelector:(SEL)selector
withOptions:(AspectOptions)options
usingBlock:(id)block
error:(NSError **)error;
/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<AspectToken>)aspect_hookSelector:(SEL)selector
withOptions:(AspectOptions)options
usingBlock:(id)block
error:(NSError **)error;
举例说明下：
例子一：所有的UIViewController进行AOP操作，替换刚刚的方法
[UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info) {
NSString *className = NSStringFromClass([[info instance] class]);
NSLog(@"aspect-->%@",className);
}  error:NULL];
[UIViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
NSString *className = NSStringFromClass([[info instance] class]);
NSLog(@"aspect-->%@",className);
}  error:NULL];
例子二：对于实例方法
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

