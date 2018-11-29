Runloop 是 iOS 中非常重要的机制，iOS 系统底层很多模块都是通过 Runloop 机制实现的。例如界面更新、事件响应等。本质上 Runloop 是一种用于循环处理事件，而又不至于使 CPU 无意义空转的方式。

### 一、 NSRunLoop 对象

在 CoreFoundation 里面关于 RunLoop 有5个类

- ++CFRunLoopRef++
- CFRunLoopModeRef
- ++CFRunLoopSouceRef++
- ++CFRunLoopTimerRef++
- ++CFRunLoopObserverRef++

其中 CFRunLoopModeRef 类并没有对外暴露，只是通过 CFRunLoopRef 的接口进行了封装。

他们的关系如下:

Mode  | Mode 
---|---
<Set>Source | <Set>Source
<Array>Observer | <Array>Observer
<Array>Timer | <Array>Timer



#### (1) CFRunLoopRef

NSRunLoop 对象是OC对象，是对 CFRunLoopRef 的封装，可以通过 getCFRunLoop 方法获取其对应的 CFRunLoopRef 对象。注意，NSRunLoop 不是线程安全的，但 CFRunLoopRef 是线程安全的。

#### (2) RunLoopMode

一个 RunLoop 包含若干个 Mode，每个 Mode 又包含若干个 Source/Timer/Observer。每次调用 RunLoop 的主函数时，只能指定其中一个 Mode，这个Mode被称作 CurrentMode。如果需要切换 Mode，只能退出 Loop，再重新指定一个 Mode 进入。这样做主要是为了分隔开不同组的 Source/Timer/Observer，让其互不影响。


其中系统默认注册的5个 mode 有

- **kCFRunLoopDefaultMode** : App 默认的 mode，一般情况下 App 都是运行在这个 mode 下的。
- **UITrackingRunLoopMode** : 页面跟踪时的 mode，一般用于 ScrolView 滚动的时候追踪的，保证滑动的时候不受其他事件的影响。
- **UIInitializationRunLoopMode** : 在刚起动时进入的第一个 Mode, 启动完成后就不再使用。([ɪ,nɪʃəlɪ'zeʃən])
- **GSEventReceiveRunLoopMode** : 接受系统事件的内部的 Mode, 一般用不到。
- **kCFRunLoopCommonModes** : 占位 mode，可以向其中添加其他 mode用以检测多个 mode 的事件。

#### (3) CFRunLoopSourceRef 

CFRunLoopSourceRef 是事件源产生的地方，主要有两种 : 

- **Source0** : 只包含了一个回调（函数指针），它并不能主动触发事件。使用时，你需要先调用 CFRunLoopSourceSignal(source)，将这个 Source 标记为待处理，然后手动调用 CFRunLoopWakeUp(runloop) 来唤醒 RunLoop，让其处理这个事件。
- **Source1** : 包含了一个 mach_port 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。这种 Source 能主动唤醒 RunLoop 的线程。

#### (4) CFRunLoopTimerRef

CFRunLoopTimerRef 是基于时间的触发器，它和 NSTimer 是toll-free bridged 的，可以混用。其包含一个时间长度和一个回调（函数指针）。当其加入到 RunLoop 时，RunLoop会注册对应的时间点，当时间点到时，RunLoop会被唤醒以执行那个回调。

#### (5) performSEL

performSEL 其实和 NSTimer 一样，是对 CFRunLoopTimerRef 的封装。因此，当调用 performSelecter:afterDelay: 后，实际上内部会转化成 CFRunLoopTimerRef 并添加到当前线程的 RunLoop 中去，因此，如果当前线程中没有启动 RunLoop 的时候，该方法会失效。

#### (6) CFRunLoopObserverRef

CFRunLoopObserverRef 是观察者，每个 Observer 都包含了一个回调（函数指针），当 RunLoop 的状态发生变化时，观察者就能通过回调接受到这个变化。 

可以观察的时间点包括以下几点:

```
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
};
```


#### (7) modelItem
 
上面的 Source/timer/Observer 被统称为 mode item，一个 item 可以被同时加入多个 mode。但一个 item 被重复加入同一个 mode 时是不会有效果的。如果一个 mode 中一个 item 都没有，则 RunLoop 会直接退出，不进入循环。


###  NSRunLoop 的驱动

RunLoop本身就是不能循环的,要通过外部的 while 循环循环驱动。


```
BOOL isRunning = NO;
do {
    isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode 
    beforeDate:[NSDate distantFuture]];
} whitle (isRunning);
```

### RunLoop 内部的基本流程

每次运行RunLoop, 内部都会处理之前没有处理的消息，并且在各个阶段通知相应的观察者。

大致步骤如下:

(1) 通知观察者 RunLoop 启动

(2) 通知观察者即将处理 Timer

(3) 通知观察者即将处理 Source0

(4) 触发 Source0 回调

(5) 如果有 Source1 (基于port) 处于 ready 状态，直接处理该 Source1 然后跳转去处理消息

(6) 如果没有待处理消息，则通知观察者 RunLoop 所在线程即将进入休眠

(7) 休眠前，RunLoop 会添加一个 dispartchPort, 底层调用 mach_msg 接收 mach_port 的消息。线程进入休眠，直到下面某个事件触发唤醒线程。
- 基于 port 的 Source1 事件到达
- Timer 时间到达
- RunLoop 启动时设置的最大超时时间到了
- 手动唤醒

(8) 唤醒后，将休眠前添加的 dispatchPort 移除，并通知观察者 RunLoop 已经被唤醒

(9) 通过 handle_msg 处理消息

(10) 如果消是 Timer 类型，则触发该 Timer 的回调

(11) 如果消息是 dispatch 到 main_queue 的 block，执行block

(12) 如果消息是 Source1 类型，则处理 Source1 回调

(13) 以下条件中满足时候退出循环，否则从 (2) 继续循环

- 事件处理完毕而且启动 RunLoop 的时候参数设置为一次性执行
- 启动 RunLoop 时设置的最大运行时间到期
- RunLoop 被外部调用强行停止
- 启动 RunLoop 的 mode items 为空

(14) 上一步退出循环后退出 RunLoop，通知观察者 RunLoop 退出

