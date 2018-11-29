# App防奔溃策略(三) - Notification

前言：

> NSNotificationCenter 比 Delegate 可以更简便实现更大的跨度的通讯机制，可以为两个无引用关系的对象进行通信。

NSNotification 是iOS中一个调度消息通知的类，通俗来讲就是"通知中心"，采用单例模式设计。 

**iOS 9 之前**

我们向"通知中心"注册观察者后，没有在观察者 delloc 时及时的注销观察者，极有可能"通知中心"会给僵尸对象发送通知而导致 crash。 

**iOS 9 之后**

苹果在 iOS 9 之后专门针对于这种情况做了处理。（具体可以去查看官方文档）

参考：强引用与弱引用、weak 与 unsafe_unretained 

所以针对 iOS 9 之前的用户，我们还是有必要做一下 Notification 的防护。

## Crash 防护方案

在我们日常使用通知中心时，A对象需要收听到通知中心的消息，那么 A 对象可以注册成为"通知中心"的观察者。那么注销呢？我们只需要在 A 对象的 dealloc 函数中调用注销函数即可。


那是不是利用 method swizzling **hook** NSObject的 dealloc 函数，在对象真正 dealloc 之前注销的观察者就可以了？

这样就可以了吗？当然是不行的！事实上并不是所有的对象都需要注销观察，如果一个对象并未注册为观察者，但是又在其 dealloc 时注销观察者，完全属于多此一举，造成不必要开支。

还有两种情况需要注意:

1) 单例里不用 dealloc 方法，应用会统一管理；

2) 分类中不要用 dealloc方法（分类中重写 dealloc 方法，元类dealloc会被覆盖, 就不执行了）

## crash 防护方案一

**hook** NSNotificationCenter 的 `addObserver:selector:name:object:` 函数，在添加 observer 时动态添加标记flag，在 observer dealloc时，通过 flag 来判断是否需要注销。
 

```//NSNotificationCenter+CrashGuard.m
#import "NSNotificationCenter+CrashGuard.h"
#import <objc/runtime.h>
#import <UIKit/UIDevice.h>
#import "NSObject+NotificationCrashGuard.h"


@implementation NSNotificationCenter (CrashGuard)
+ (void)load{
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[self class] swizzedMethod:sel_getUid("addObserver:selector:name:object:") withMethod:@selector(crashGuard_addObserver:selector:name:object:)];
        });
    }
}

+ (void)swizzedMethod:(SEL)originalSelector withMethod:(SEL )swizzledSelector {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)crashGuard_addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    NSObject *obj = (NSObject *)observer;
    obj.notificationCrashGuardTag = notificationObserverTag;
    [self crashGuard_addObserver:observer selector:aSelector name:aName object:anObject];
}

@end

//  NSObject+NotificationCrashGuard.h
#import <Foundation/Foundation.h>
extern  NSInteger notificationObserverTag;

@interface NSObject (NotificationCrashGuard)
@property(nonatomic, assign)NSInteger notificationCrashGuardTag;
@end

//  NSObject+NotificationCrashGuard.m

#import "NSObject+NotificationCrashGuard.h"
#import "NSObject+Swizzle.h"
#import <UIKit/UIDevice.h>
#import <objc/runtime.h>

NSInteger notificationObserverTag = 11118;

@implementation NSObject (NotificationCrashGuard)

#pragma mark Class Method
+ (void)load{
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[self class] swizzedMethod:sel_getUid("dealloc") withMethod:@selector(crashGuard_dealloc)];
        });
    }
}

#pragma Setter & Getter
- (NSInteger)notificationCrashGuardTag {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    return [number integerValue];
}

- (void)setNotificationCrashGuardTag:(NSInteger)notificationCrashGuardTag {
    NSNumber *number = [NSNumber numberWithInteger:notificationCrashGuardTag];
    objc_setAssociatedObject(self, @selector(notificationCrashGuardTag), number, OBJC_ASSOCIATION_RETAIN);
}


- (void)crashGuard_dealloc {
    if(self.notificationCrashGuardTag == notificationObserverTag) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self crashGuard_dealloc];
}

```
此方案有以下缺点：

1. ARC开发下，dealloc作为关键字，编译器是有所限制的。会产生编译错误“ARC forbids use of 'dealloc' in a @selector”。不过我们可以用运行时的方式进行解决。

2. dealloc作为最为基础，调用次数最为频繁的方法之一。如对此方法进行替换，一是代码的引入对工程影响范围太大，二是执行的代价较大。因为大多数dealloc操作是不需要引入自动注销的，为了少数需求而对所有的执行都做修正是不适当的。




### 参考链接

- [从 iOS 9 NSNotificationCenter 无需手动移除观察者说起](https://www.jianshu.com/p/7925a00ec739)
- [crash详解与防护 NSNotification crash](https://www.cnblogs.com/Xylophone/p/6394056.html)


