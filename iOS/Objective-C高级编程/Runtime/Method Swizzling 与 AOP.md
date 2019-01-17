#### AOP(Aspect Oriented Programming)，面向切面编程

---

###### 场景: 要对用户的页面的轨迹进行统计。

1. 在每一个自定义的控制器的viewWillAppear函数添加处理代码
2. 使用派生
3. 使用Aspects来勾取UIViewController类viewWillAppear方法，在勾取的函数添加代码

先说下使用方式1，重复的代码太多，不易维护。方式2由于要所有的类都继承自定义的基类，需要额外的沟通成本，均不可取。

下面我们来看方式3，通过需要勾取的类来调用`aspect_hookSelector:withOptions:usingBlock`
```
[UIViewController aspect_hookSelector:@selector(viewWillAppear:)
                          withOptions:AspectPositionAfter
                           usingBlock:^(id<AspectInfo> aspectInfo)
{//do something} error:NULL];
```
直接在usingBlock回调中，调用处理代码即可。

##### 面向切片编程须知

> 程序要完成一件事情，一定会有一些步骤，1，2，3，4这样。这里分解出来的每一个步骤我们可以认为是一个`切片`。

> 针对每一个切片的间隙，塞一些代码进去，在程序正常进行1，2，3，4步的间隙可以跑到你塞进去的代码，那么你的写的这些代码就是`面向切片编程`。

> 你要想到在每一个步骤中间做你自己的事情，不用AOP也一样可以达到目的，直接在步骤之间塞代码就好了。但是事实情况往往很复杂，直接把代码塞进去，主要问题在于: `塞进去的代码很有可能是跟原业务无关的代码，在同一份代码文件里面掺杂多种业务，这会带来业务间的耦合`。为了降低这种耦合度，我们引用了AOP。


##### AOP的优势：
- 减少切面业务的开发量，“一次开发终生使用”，比如日志
- 减少代码耦合，方便复用。切面业务的代码可以独立出来，方便其他应用使用
- 提高代码review的质量，比如我可以规定某些类的某些方法才用特定的命名规范，这样review的时候就可以发现一些问题


##### AOP的弊端：
- 它破坏了代码的干净整洁。

##### iOS 如何实现AOP

 > 在iOS开发领域，Objective-C的runtime有提供了一些列的方法，能够让我们拦截到某个方法的调用，来实现拦截器的功能，这种手段我们称为Method Swizzling。
 
 
#####  Aspects 
 
Aspects封装了runtime，Method Swizzing。提供了两个api，可以很好的勾取一个类或者一个对象的某个方法。

```
+ (id<AspectToken>)aspect_hookSelector:(SEL)selector
                           withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;
 
- (id<AspectToken>)aspect_hookSelector:(SEL)selector
                       withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;
```

[Demo(一)](https://github.com/steipete/Aspects)
[Demo(二)](https://github.com/okcomp/AspectsDemo)


