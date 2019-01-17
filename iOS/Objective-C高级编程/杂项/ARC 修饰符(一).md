 
<h2>ARC 属性修饰符解读</h2>

###### 背景

ARC苹果新引用了`strong` 与 `weak`对象变量属性。

 ARC引入了新的对象的新生命周期限定，即零弱引用。如果零弱引用指向的对象被deallocated的话，零弱引用的对象会被自动设置为nil。

#### strong 与 weak 强应用与弱引用

 强引用也就是我们通常所讲的引用，其存亡直接决定了所指对象的存亡。如果不存在指向一个对象的引用，并且此对象不再显示列表中，则此对象会被从内存中释放。 

弱引用除了不决定对象的存亡外，其它与强引用相同。即使一个对象被持有无数个若引用，只要没有强引用指向他，那么其还是会被清除。 

使用强引用指向的对象，引用计数器会+1

使用弱引用指向的对象，引用计数器不变化
	
#### strong 与 retain

在ARC下，用strong代替了retain，strong等同于retain。

声明Block，使用retain，Block会在++栈++中。必须使用copy关键字，才能使Block在堆中。

声明Block, 使用strong，Block会在++堆++中。


#### weak 与assign

assign: 简单赋值，不更改索引计数

weak比assign多了一个功能，当对象消失后自动把指针变成nil


#### 一个简单例子
	
```
@interface ViewController ()
@property (nonatomic, weak)   NSDate *weakDate;
@property (nonatomic, assign) NSDate *assignDate;
@property (nonatomic, strong) NSDate *strongDate;
@end
```

```
_strongDate = [NSDate date];
_weakDate = _strongDate;
_assignDate = _strongDate;
    
NSLog(@"_strongDate %p, %p, %@", _strongDate, &_strongDate, _strongDate);
NSLog(@"_weakDate %p, %p, %@", _weakDate, &_weakDate, _weakDate);
NSLog(@"_assignDate %p, %p, %@", _assignDate, &_assignDate, _assignDate);

_strongDate = nil;
NSLog(@"\n");   
NSLog(@"_strongDate : %@", _strongDate);
NSLog(@"_weakDate : %@", _weakDate);
NSLog(@"_assignDate : %@", _assignDate);
```

```
_strongDate 0x60400000c160, 0x7f997ec38608, Wed Nov 15 10:38:24 2015
_weakDate 0x60400000c160, 0x7f997ec385f0, Wed Nov 15 10:38:24 2015
_assignDate 0x60400000c160, 0x7f997ec385f8, Wed Nov 15 10:38:24 2015

_strongDate : (null)
_weakDate : (null)
(lldb) 
```

#### 小结:

* weak 修饰对象时候,当对象被释放掉后,指针会指向 nil 
* strong 修饰对象时候,当对象被释掉后,指针会指向 nil
* assgin 修饰对象时候,当对象被释掉后,会产生悬空指针，再次调用会导致程序崩溃。
* assgin 一般用在修饰基础数据类型

#### 后期新增 [++unsafe_unretained++](http://www.jianshu.com/p/0ca31b3e3ac0)(等价assgin) 

__unsafe_unretained 主要跟 C 代码交互。另外 __weak 是有代价的，需要检查对象是否已经消亡，而为了知道是否已经消亡，自然也需要一些信息去跟踪对象的使用情况。__unsafe_unretained 比 __weak 快。当明确知道对象的生命期时，选择 __unsafe_unretained 会有一些性能提升。当 A 拥有 B 对象，当 A 消亡时 B 也消亡。这样当 B 存在，A 就一定会存在。而 B 又要调用 A 的接口时，B 就可以存储 A 的 __unsafe_unretained 指针。

在细微不同的方式下，__unsafe_unretained和__weak都防止了参数的持有。对于__weak，指针的对象在它指向的对象释放的时候回转换为nil，这是一种特别安全的行为。就像他的名字表达那样，__unsafe_unretained会继续指向对象存在的那个内存，即使是在它已经销毁之后。这会导致因为访问那个已释放对象引起的崩溃。
 
 __weak只支持iOS 5.0和OS X Mountain Lion作为部署版本。如果你想部署回iOS 4.0和OS X Snow Leopark，你就不得不用__unsafe_unretained标识符。(了解即可)
 

