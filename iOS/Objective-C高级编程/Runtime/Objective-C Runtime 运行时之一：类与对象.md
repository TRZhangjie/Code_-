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


runtime 提供了大量的函数来操作类与对象。类的操作方法大部分是以 class_ 为前缀的，而对象的操作方法大部分是以 objc_ 或 object_ 为前缀。下面我们将根据这些方法的用途来分类讨论这些方法的使用。


#### 类相关操作函数

我们可以回过头去看看 objc_class 的定义，runtime 提供的操作类的方法主要就是针对这个结构体中的各个字段的。下面我们分别介绍这一些的函数。并在最后以实例来演示这些函数的具体用法。

#### 类名(name)

类名操作的函数主要有:

```
1 // 获取类的类名
2 const char * class_getName ( Class cls );
```

- 对于 class_getName 函数，如果传入的 cls 为 Nil，则返回一个字字符串。

##### 父类(super_class)和元类(meta-class)

父类和元类操作的函数主要有：

```
1 // 获取类的父类
2 Class class_getSuperclass ( Class cls );
3
4 // 判断给定的Class是否是一个元类
5 BOOL class_isMetaClass ( Class cls );
```

- class_getSuperclass 函数，当 cls 为 Nil 或者 cls 为根类时，返回 Nil。不过通常我们可以使用NSObject类的superclass方法来达到同样的目的。 
- class_isMetaClass 函数，如果是 cls 是元类，则返回 YES；如果否或者传入的 cls 为 Nil，则返回 NO。 

##### 实例变量大小(instance_size)

实例变量大小操作的函数有：

```
1 // 获取实例大小
2 size_t class_getInstanceSize ( Class cls );
```

##### 成员变量(ivars)及属性

在 objc_class 中，所有的成员变量、属性的信息是放在链表 ivars 中的。ivars 是一个数组，数组中每个元素是指向 Ivar (变量信息)的指针。runtime 提供了丰富的函数来操作这一字段。大体上可以分为以下几类：

1. 成员变量操作函数，主要包含以下函数：

```
1 // 获取类中指定名称实例成员变量的信息
2 Ivar class_getInstanceVariable ( Class cls, const char *name );
3
4 // 获取类成员变量的信息
5 Ivar class_getClassVariable ( Class cls, const char *name );
6
7 // 添加成员变量
8 BOOL class_addIvar ( Class cls, const char *name, size_t size, uint8_t alignment, const char *types );
9
10 // 获取整个成员变量列表
11 Ivar * class_copyIvarList ( Class cls, unsigned int *outCount );
```

- class_getInstanceVariable 函数，它返回一个指向包含 name 指定的成员信息的 objc_ivar 结构体的指针(Ivar)。

- class_getClassVariable 函数，目前没有找到关于 Objective-C 中类变量的信息，一般认为 Objective-C 不支持类变量。注意: 返回的列表不包含父类的成员变量和属性。

- Objective-C 不支持往已存在的类中添加实例变量，因此不管是系统库提供的类，还是我们自定义的类，都无法动态添加成员变量。但是如果我们运行时来创建一个类的话，又应该如何给它添加成员变量呢？ 这时我们就可以使用 class_addIvar 函数了。不过需要注意的是，这个方法只能在 objc_allocateClassPair 函数与 objc_registerClassPair 之间调用。另外，这个类也不能是元类。成员变量的按字节最小齐量 1<<alignment。这取决于 ivar 的类型和机器的架构。如果变量的类型是指针类型，则传递 log2(sizeof(pointer_type));

- class_copyIvarList 函数，它返回一个指向成员变量信息的数组，数组中每个元素是指向该成员变量信息的 objc_ivar 结构体的指针。这个数组不包含在父类中声明的变量。outCount 指针返回数组的大小。需要注意的是，我们必须使用 free() 来释放这个数组。

2. 属性操作函数，主要包含以下函数:

```
1 // 获取指定的属性
2 objc_property_t class_getProperty ( Class cls, const char *name );
3
4 // 获取属性列表
5 objc_property_t * class_copyPropertyList ( Class cls, unsigned int *outCount );
6
7 // 为类添加属性
8 BOOL class_addProperty ( Class cls, const char *name, const 9 objc_property_attribute_t *attributes, unsigned int attributeCount );
9
10 // 替换类的属性
11 void class_replaceProperty ( Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount );
```

这一种方法也是针对 ivars 来操作，不过只操作那些是属性的值。我们在后面介绍属性时会再遇到这些函数。

3. 在 Mac OSX 系统中，我们可以使用垃圾回收器。runtime 提供了几个函数来确定一个对象的内存区域是否可以被垃圾回收器扫描，以处理 strong/weak 引用。这几个函数定义如下：


```
1 const uint8_t * class_getIvarLayout ( Class cls );
2 void class_setIvarLayout ( Class cls, const uint8_t *layout );
3 const uint8_t * class_getWeakIvarLayout ( Class cls );
4 void class_setWeakIvarLayout ( Class cls, const uint8_t *layout );
```

但通常情况下，我们不需要去主动调用这些方法；在调用 objc_registerClassPair 时，会生成合理的布局。在此不详细介绍这些函数。


