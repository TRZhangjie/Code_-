> 问题:我们知道，在使用 block 的时候，为了避免产生循环引用，通常需要使用 weakSelf 与 strongSelf，写下面这样的代码：

```
__weak typeof(self) weakSelf = self;
[self doSomeBlockJob:^{
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (strongSelf) {
        ...
    }
}];
```

### 什么时候在 block里面用self，不需要使用weakself?

---

当 block 本身不被 self 持有，而被别的对象持有, 同时不产生循环引用的时候，就不需要使用 weakSelf 了。最常见的代码就是 UIView 的动画代码，我们在使用 UIView anmateWithDuration: 方法做动画的时候，并不需要使用 weakSelf，因为引用持有关系：

> UIView 的某个负责动画的对象持有 block， block 持有了 self 因为 self 并不持有 block，所以就没有循环引用产生，因此就不需要使用 weakSelf 了。

```
[UIView animateWithDuration:0.2 animations:^{
    self.alpha = 1;
}];

```
> 当动画结束时，UIView会结束持有这个 block，如果没有别的的对象持有block的话，block 对象就会释放掉，从而 block 会释放掉对 self 的持有。整个内存引用关系解除。


### 为什么 block 里面还需要写一个 strongSelf, 如果不写会怎么样？
---

在 block 中先写一个 strongSelf，其实是为避免在 block 的执行过程中，突然出现 self 被释放的尴尬情况。通常情况下，如果不这么做的话，还是会出现一写奇怪的逻辑，甚至闪退。

我们以 AFNetworking 中的 AFNetworkReachabilityManager.m 的一段代码举例:

```
__weak __typeof(self)weakSelf = self;
AFNetworkReachabilityStatusBlock callback = ^(AFNetworkReachabilityStatus status) {
    __strong __typeof(weakSelf)strongSelf = weakSelf;
    strongSelf.networkReachabilityStatus = status;
    if (strongSelf.networkReachabilityStatusBlock) {strongSelf.networkReachabilityStatusBlock(status);
    }
};
```

如果没有 strongSelf 的那行代码，那么后面的每一行代码执行时，self都可能被释放掉了，这样很可能造成逻辑异常。

### block什么时候需要构造成循环引用

---

问题: 有没有这样一个场景，block 会产生循环引用，但是业务又需要你不能使用 weakSelf，如果有，请举例解释如和解决循环引用的问题。

答案: 需要不使用 weakSelf 场景是：你需要构造一个循环引用，以保证引用双方都在。比如你有一个后台的任务，希望任务执行完后，通知另一个实例。


在 YTKNetwork 库中，我们的每一个网络请求 API 会持有回调的 block， 回调的 block 会持有 self，而如果 self 也持有网络请求 API 的话，我们就构造了一个循环引用，但是网络请求结束的时候，网络请求 API 会主动释放对 block 的持有。因此，整个循环链条被解开，循环引用就被打破了，所以不会有内存泄漏的问题。

```
//  YTKBaseRequest.m
- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}
```

总结来说，解决循环引用问题主要有两个方法：

第一个办法是 [事前避免]，我们在会产生循环引用的地方使用 weak 弱引用，以避免产生循环引用。
第二个办法是 [事后补救], 我们明确知道会存在循环引用，但是我们在合理的位置主动断开环中的一个引用，使得对象得以回收。


