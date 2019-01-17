##  Objective-C Runtime 运行时之一：类与对象

---

【转载收藏:南峰子-类与对象】(http://www.codeceo.com/article/objective-c-runtime-class.html)

【南峰子博客】(http://southpeak.github.io/2014/10/25/objective-c-runtime-1/)

---

Objective-C 语言是一门动态语言，它将很多静态语言在编译和链接时期做的事放到了运行时来处理。这种动态语言的优势在于：我们写代码时更具灵活性，如我们可以把消息转发给我们想要的对象，或者随意交换一个方法的实现等。

这种特性意味着 Objective-C 不仅需要一个编译器，还需要一个运行时系统来执行编译的代码。对于 Objective-C 来说，这个运行时系统就像一个操作系统一样：它让所有的工作可以正常的运行。这个运行时系统即 Objc Runtime。Objc Runtime 其实是一个 Runtime 库，它基本上是用 C 和汇编写的，这个库使得 C 语言有了面向对象的能力。

Runtime 库主要做下面几件事：

1. 封装：在这个库中，对象可以用 C 语言中的结构体表示，而方法可以用 C 函数来实现，另外再加上了一些额外的特性。这些结构体和函数被 runtime 函数封装后，我们就可以在程序运行时创建，检查，修改类、对象和它们的方法了。

2. 找出方法的最终执行代码：当程序执行[object doSomething]时，会向消息接收者(object)发送一条消息(doSomething)，runtime会根据消息接收者是否能响应该消息而做出不同的反应。这将在后面详细介绍。

Objective-C runtime 目前有两个版本：Modern runtime 和 Legacy runtime。Modern Runtime 覆盖了64位的Mac OS X Apps，还有 iOS Apps，Legacy Runtime 是早期用来给32位 Mac OS X Apps 用的，也就是可以不用管就是了。

在这一系列文章中，我们将介绍runtime的基本工作原理，以及如何利用它让我们的程序变得更加灵活。在本文中，我们先来介绍一下类与对象，这是面向对象的基础，我们看看在Runtime中，类是如何实现的。

### 类与对象基础数据结构

---

#### Class

---

Objective-C 类是由 Class 类型来表示的，它实际上是一个指向 objc_class 结构体的指针。它的定义如下：

```
typedef struct objc_class *Class;
```

查看 objc/runtime.h 中 objc_class 结构体的定义如下：


```
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class super_class                       OBJC2_UNAVAILABLE;  // 父类
    const char *name                        OBJC2_UNAVAILABLE;  // 类名
    long version                            OBJC2_UNAVAILABLE;  // 类的版本信息，默认为0
    long info                               OBJC2_UNAVAILABLE;  // 类信息，供运行期使用的一些位标识
    long instance_size                      OBJC2_UNAVAILABLE;  // 该类的实例变量大小
    struct objc_ivar_list *ivars            OBJC2_UNAVAILABLE;  // 该类的成员变量链表
    struct objc_method_list **methodLists   OBJC2_UNAVAILABLE;  // 方法定义的链表
    struct objc_cache *cache                OBJC2_UNAVAILABLE;  // 方法缓存
    struct objc_protocol_list *protocols    OBJC2_UNAVAILABLE;  // 协议链表
#endif

} OBJC2_UNAVAILABLE;

```

在这个定义中，下面几个字段是我们感兴趣的

1. isa：需要注意的是在 Objective-C 中，所有的类自身也是一个对象，这个对象的 Class 里面也有一个isa指针，它指向 metaClass (元类)，我们会在后面介绍它。

2. super_class：指向该类的父类，如果该类已经是最顶层的根类(如 NSObject 或 NSProxy )，则super_class 为 NULL。

3. cache：用于缓存最近使用的方法。一个接收者对象接收到一个消息时，它会根据 isa 指针去查找能够响应这个消息的对象。在实际使用中，这个对象只有一部分方法是常用的，很多方法其实很少用或者根本用不上。这种情况下，如果每次消息来时，我们都是 methodLists 中遍历一遍，性能势必很差。这时，cache 就派上用场了。在我们每次调用过一个方法后，这个方法就会被缓存到cache列表中，下次调用的时候 runtime 就会优先去 cache 中查找，如果 cache 没有，才去 methodLists 中查找方法。这样，对于那些经常用到的方法的调用，但提高了调用的效率。

4. version：我们可以使用这个字段来提供类的版本信息。这对于对象的序列化非常有用，它可是让我们识别出不同类定义版本中实例变量布局的改变。

针对 cache，我们用下面例子来说明其执行过程：

```
NSArray *array = [[NSArray alloc] init];
```

其流程是:

1.  [NSArray alloc] 先被执行。因为 NSArray 没有 +alloc 方法，于是去父类 NSObject 去查找。
2.  检测 NSObject 是否响应 +alloc 方法，发现响应，于是检测 NSArray 类，并根据其所需的内存空间大小开始分配内存空间，然后把 isa 指针指向 NSArray 类。同时，+alloc也被加进 cache 列表里面。
3.  接着，执行 -init 方法，如果 NSArray 响应该方法，则直接将其加入 cache；如果不响应，则去父类查找。
4.  在后期的操作中，如果再以 [[NSArray alloc] init] 这种方式来创建数组，则会直接从 cache 中取出相应的方法，直接调用。

---

#### objc_object与id

---

objc_object 是表示一个类的实例的结构体，它的定义如下(objc/objc.h)：


```
struct objc_object {
    Class isa  OBJC_ISA_AVAILABILITY;
};

typedef struct objc_object *id;

```

可以看到，这个结构体只有一个字体，即指向其类的isa指针。这样，当我们向一个 Objective-C 对象发送消息时，运行时库会根据实例对象的 isa 指针找到这个实例对象所属的类。Runtime 库会在类的方法列表及父类的方法列表中去寻找与消息对应的 selector 指向的方法。找到后即运行这个方法。

当创建一个特定类的实例对象时，分配的内存包含一个 objc_object 数据结构，然后是类的实例变量的数据。NSObject 类的 alloc 和 allocWithZone: 方法使用函数 class_createInstance 来创建objc_object 数据结构。

另外还有我们常见的id，它是一个 objc_object 结构体类型的指针。它的存在可以让我们实现类似于 C++ 中泛型的一些操作。该类型的对象可以转换为任何一种对象，有点类似于C语言中 void * 指针类型的作用。


---

#### objc_cache

---

上面提到了 objc_class 结构体中的 cache 字段，它用于缓存调用过的方法。这个字段是一个指向objc_cache 结构体的指针，其定义如下：


```
struct objc_cache {
    unsigned int mask /* total = mask + 1 */                 OBJC2_UNAVAILABLE;
    unsigned int occupied                                    OBJC2_UNAVAILABLE;
    Method buckets[1]                                        OBJC2_UNAVAILABLE;
};
```

该结构体的字段描述如下：

1. mask：一个整数，指定分配的缓存 bucket 的总数。在方法查找过程中，Objective-C runtime 使用这个字段来确定开始线性查找数组的索引位置。指向方法 selector 的指针与该字段做一个 AND 位操作(index = (mask & selector))。这可以作为一个简单的 hash 散列算法。

2. occupied：一个整数，指定实际占用的缓存 bucket 的总数。

3. buckets：指向 Method 数据结构指针的数组。这个数组可能包含不超过 mask+1 个元素。需要注意的是，指针可能是 NULL，表示这个缓存 bucket 没有被占用，另外被占用的 bucket 可能是不连续的。这个数组可能会随着时间而增长。

---

#### 元类(Meta Class)

---

在上面我们提到，所有的类自身也是一个对象，我们可以向这个对象发送消息(即调用类方法)。如:

```
NSArray *array = [NSArray array];
```

这个例子中，+array 消息发送给了 NSArray 类，而这个 NSArray 也是一个对象。既然是对象，那么它也是一个 objc_object 指针,它包含一个指向其类的一个 isa 指针。那么这些就有一个问题了，这个 isa 指针指向什么呢？为了调用 +array 方法，这个类的 isa 指针必须指向一个包含这些类方法的一个objc_class 结构体。这就引出了 meta-class 的概念。

```
meta-class 是一个类对象的类。
```

当我们向一个对象发送消息时，runtime 会在这个对象所属的这个类的方法列表中查找方法；而向一个类发送消息时，会在这个类的 meta-class 的方法列表中查找。

**meta-class之所以重要，是因为它存储着一个类的所有类方法。** 每个类都会有一个单独的 meta-class，因为每个类的类方法基本不可能完全相同。

再深入一下，meta-class 也是一个类，也可以向它发送一个消息，那么它的 isa 又是指向什么呢？为了不让这种结构无限延伸下去，Objective-C 的设计者让所有的 meta-class 的 isa 指向基类的meta-class，以此作为它们的所属类。即，任何 NSObject 继承体系下的 meta-class 都使用 NSObject 的meta-class 作为自己的所属类，而基类的 meta-class 的 isa 指针是指向它自己。这样就形成了一个完美的闭环。

通过上面的描述，再加上对 objc_class 结构体中 super_class 指针的分析，我们就可以描绘出类及相应meta-class 类的一个继承体系了，如下图所示：

![](https://wx3.sinaimg.cn/mw690/6c63902cgy1fytki5l7muj20rs0sigs8.jpg)

对于 NSObject 继承体系来说，其实例方法对体系中的所有实例、类和 meta-class 都是有效的；而类方法对于体系内的所有类和 meta-class 都是有效的。

讲了这么多，我们还是来写个例子吧：


```
void TestMetaClass(id self, SEL _cmd) {

    NSLog(@"This objcet is %p", self);
    NSLog(@"Class is %@, super class is %@", [self class], [self superclass]);

    Class currentClass = [self class];
    for (int i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p", i, currentClass);
        currentClass = objc_getClass((__bridge void *)currentClass);
    }

    NSLog(@"NSObject's class is %p", [NSObject class]);
    NSLog(@"NSObject's meta class is %p", objc_getClass((__bridge void *)[NSObject class]));
}

#pragma mark -

@implementation Test

- (void)ex_registerClassPair {

    Class newClass = objc_allocateClassPair([NSError class], "TestClass", 0);
    class_addMethod(newClass, @selector(testMetaClass), (IMP)TestMetaClass, "v@:");
    objc_registerClassPair(newClass);

    id instance = [[newClass alloc] initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}

@end

```

这个例子是在运行时创建了一个NSError的子类TestClass，然后为这个子类添加一个方法testMetaClass，这个方法的实现是TestMetaClass函数。

运行后，打印结果是


```
2014-10-20 22:57:07.352 mountain[1303:41490] This objcet is 0x7a6e22b0
2014-10-20 22:57:07.353 mountain[1303:41490] Class is TestStringClass, super class is NSError
2014-10-20 22:57:07.353 mountain[1303:41490] Following the isa pointer 0 times gives 0x7a6e21b0
2014-10-20 22:57:07.353 mountain[1303:41490] Following the isa pointer 1 times gives 0x0
2014-10-20 22:57:07.353 mountain[1303:41490] Following the isa pointer 2 times gives 0x0
2014-10-20 22:57:07.353 mountain[1303:41490] Following the isa pointer 3 times gives 0x0
2014-10-20 22:57:07.353 mountain[1303:41490] NSObject's class is 0xe10000
2014-10-20 22:57:07.354 mountain[1303:41490] NSObject's meta class is 0x0

```
我们在for循环中，我们通过objc_getClass来获取对象的isa，并将其打印出来，依此一直回溯到NSObject的meta-class。分析打印结果，可以看到最后指针指向的地址是0×0，即NSObject的meta-class的类地址。
这里需要注意的是：我们在一个类对象调用class方法是无法获取meta-class，它只是返回类而已。

**每个实例都有一个 isa 的指针，他指向创建实例的类 Class ，而每一个 Class 类里面也有一个 isa 指针，指向 metaClass 元类。元类（metaClass）也是类，它也是对象。元类也有isa指针, 它的isa指针最终指向的是一个根元类(root metaClass)。根元类的isa指针指向本身，这样形成了一个封闭的内循环。
Class 提供成员变量、实例方法(-方法)等
metaClass 则提供类方法(+方法)**

---

### 类与对象操作函数
---


runtime





