## 解决NSTimer循环引用

### NSTimer常见用法

```
@interface TimerClass : NSObject
- (void)start;
- (void)stop;
@end
@implementation TimerClass {
    NSTimer *_timer;
}
- (id)init {
    return [super init];
}
- (void)dealloc {
    NSLog(@"%s",__func__);
}
- (void)stop {
    [_timer invalidate];
    _timer = nil;
}
- (void)start {
    _timer = [NSTimerscheduledTimerWithTimeInterval:5.0 
                                            target:self  
                                          selector:selector(doSomething) 
                                          userInfo:nil 
                                           repeats:YES];
}
- (void)doSomething {//doSomething}
@end
```
 
上面代码很容易理解成

>  self 持有成员变量 NSTimer，`成员变量` NSTimer 又强引用了 TimerClass 实例，才导致循环引用。

### NSTimer思考

##### 思考示例1

self 持有成员变量 NSTimer, 我们试着如果`NSTimer`不是成员变量,self没有持有成员变量，delloc方法会调用吗？

```
- (void)test {
    [NSTimer scheduledTimerWithTimeInterval:1
                                  target:self
                                selector:@selector(doSomething)
                                userInfo:nil
                                 repeats:YES];
}
- (void)doSomething {}
- (void)dealloc { NSLog(@"%s",__func__);}
```

##### 思考示例2

成员变量` NSTimer` 又强引用了 TimerClass 实例 self ，那么如果向NSTimer中传入 __weak 修饰符修饰的self实例呢，delloc方法会调用吗？？

```
__weak typeof(self) weakSelf = self;
self.mytimer = [NSTimer scheduledTimerWithTimeInterval:1 
                                                target:weakSelf 
                                              selector:@selector(doSomeThing) 
                                              userInfo:nil 
                                              repeats:YES];
```

在一个Controller加入该代码，我们就会发现`dealloc`都没有调用了。


那么很明显

~~TimerClass实例持有了，成员变量 NSTimer，成员变量 NSTimer 又强引用了 TimerClass 实例，才导致循环引用。~~

 
>  定时器加在 `runloop` 上才会起作用，到达时间点后就会执行 `action` 方法，并且可以肯定这是一个`对象方法`。 定时器运行在主线程的 `runloop` 上，然后又回调方法，这个方法属于你当前这个`VC的对象方法`。既然是对象方法且能被调用，那么肯定所属的对象一定的要持有，因此这个对象被持有了。
>  
>  而我们通过 `__weak` 修饰 `self`，依然不能打破这个循环引用，说明这个对象依然是被强引用。
>  
> 定时器加在 runloop 上, runloop 是持有定时器的，当不移除定时器且 runloop 一直存在的话那么每隔一段时间就会调用 action 这个方法，既然要调用这个对象方法，就需要占有这个对象。所以导致当前控制器VC不被释放，也证明了 局部变量的 NSTimer 造成循环引用的原因。

 
其实我们可以开启子线程的`runloop`, 添加定时器，通过终止子线程 `runloop`，就能验证这个问题。
从`runloop` 中把 `NSTimer`移除 /终止 `runloop`
 
 
### 解决NSTimer循环引用的方法有三种

- 使用类方法
- 使用weakProxy
- 使用GCD timer

#### weakProxy 解决循环引用

==NSProxy== 本身是一个抽象类，它遵循NSObject协议，提供了消息转发的通用接口。==NSProxy== 通常用来实现消息转发机制和惰性初始化资源。


```
@interface JZWeakProxy()
@property (nonatomic, weak, readonly) id target;
@end
@implementation JZWeakProxy
- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}
+ (instancetype)proxyWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = [invocation selector];
    if([self.target respondsToSelector:sel]){
        [invocation invokeWithTarget:self.target];
    }
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSAssert(self.target, @"目前对象失效, NSTimer必须注销");
    return [self.target methodSignatureForSelector:sel];
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.target respondsToSelector:aSelector];
}
@end

//VC
- (void)viewDidLoad{
    [super viewDidLoad];
    _timer = [NSTimer timerWithTimeInterval:1
                                         target:[JZWeakProxy proxyWithTarget:self]
                                       selector:@selector(doSomeThing)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)doSomeThing{
    NSLog(@"=====================");
}
- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
    NSLog(@"%s",__func__);
}
```

通过使用`NSProxy类`，消息转发的接口，改变实例方法`doSomeThing`的调用者.

综合上述所说，`NSTime` 势必持有 `JZWeakProx` 实例对象, 然后结合`消息转发`，改变实例方法的`调用`者，从而实现 `Controller` 调用实例方法，`JZWeakProxy` 实例对象又不强引用 `Controller实例`，那么 `Controller实例` 能够正常释放。

**注意**

当 控制器实例 释放后，我们必须去是注销 NSTimer，即调用 invalidate 方法，否则抛出以下异常

```
Trapped uncaught exception 'NSInvalidArgumentException', reason: '*** -[NSProxy doesNotRecognizeSelector:doSomeThing] called!'
```
原因很简单，因为调用者已经被释放，`doSomeThing` 事件没有调用实例。

#### Block解决循环引用


```
@interface NSTimer (JZBlocksSupport)
+ (NSTimer *)jz_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats;
@end

@implementation NSTimer (JZBlocksSupport)

+ (NSTimer *)jz_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                          target:self
                                        selector:@selector(jz_blockInvoke:)
                                        userInfo:[block copy]
                                         repeats:repeats];
}
+ (void)jz_blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userinfo;
    if(block) {
        block();
    }
}
@end
//调用
- (void)start {
    __weak JZClass *weakSelf = self;
    _timer = [NSTimer xx_scheduledTimerWithTimeInterval:.5
                                                 block:^{
                                                 JZClass *strongSelf = weakSelf;
                                                 [strongSelf doSomething];
                                                        }
                                               repeats:YES];
}
```


