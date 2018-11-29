#### Method Swizzling

---

讲到runtime，值得一提的当然还是 `Method Swizzling`, 俗称黑魔法。

黑魔法主要用于运行时将两个方法实现`IMP`交换, 可以将`Method Swizzling`代码写到任何地方，但是这段 `Method Swizzling` 代码执行完毕后互换才起作用。


> 为什么会用到 `Method Swizzling`

需求：页面统计，我们需要统计每个控制器的页面的使用频率

1. 手动VC中添加
2. 继承
3. Category
4. Category/Method Swizzling
 
减少代码量，沟通成本，维护，适用。


#### Method Swizzling 了解使用场景有哪些？

---

1. UIImageView的性能优化

> 交叉 UIImageView 的 setImage, 通过开启上下文对象，重绘Image。

2. 字体适配

> 交叉 分别交叉UIButton， UILable，UITextView, 等一些有设置文字属性的控件，交叉其设置文字字体大小的方法。

3. AFNetworking

> 交叉了 NSURLSession 的 resume/suspend 两个系统方法。当网络请求开始或者挂起的时候，能够发送通知.监听网络状态变化。

4. AOP

> 面向切面编程

