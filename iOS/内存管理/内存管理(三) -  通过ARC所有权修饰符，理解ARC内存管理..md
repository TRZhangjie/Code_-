 

##  内存管理 ARC 中的所有权修饰符
 
ARC 有效时，id 类型和对象类型与其他类型不同，其类型上必须附加所有权修饰符。

所有权修饰符一共有 4 种：

-  __strong
-  __weak      
-  __unsafe_unretained
-  __autoreleasing 
 
---

### __strong 修饰符修饰变量

__strong 修饰符是 id 类型和对象类型默认的所有权修饰符。也就是说在我们日常开发中定义的对象、id 变量，实际上被附加了所有权修饰符。

```
id __strong obj = [[NSObject alloc] init];
```

定义一个 obj 实例, 在 ARC 和 MRC 中表象上是没有区别的，都是以

```
id obj = [[NSObject alloc] init];
```

这样的方式呈现。

那么我们 C 语言的变量的作用域中定义一个实例 

```
ARC时
{
	id __strong obj = [[NSObject alloc] init];
}
```
那么切换 MRC 的内存管理方式时

```
MRC时
{
	id obj = [[NSObject alloc] init];
	[obj release];
}
```
为了释放生成并持有的对象，MRC 增加了调用 release 的方法。ARC __strong 修饰符的变量 obj 在超出作用域时，会释放被其赋予的对象。一个是手动释放，一个是超出作用域自动释放。

如"strong"这个名称所示， __strong 修饰符表示对对象的强引用。持有强引用的变量在超出作用域时被废弃，随着强引用的失效，变量引用的对象也会随之释放。

前面我们有了解到在 MRC 时，持有对象的方式有两种：

- 自己生成并持有的
- 非自己生成并持有

```
{
	// 自己生成并持有的对象
	id __strong obj = [[NSObject alloc] init];
	
	// 因为变量 obj 为强引用修饰符修饰，所以自己持有对象
}
/// obj 变量超出作用域失效
/// obj 指向的对象，没有任何强引用对象指向它，因此对象废弃
```

此处，对象的所有者和对象的生命周期是明确的。那么，在取得非自己生成并持有对象又如何呢？

```
{
	// 非自己生成并持有的对象
	id __strong obj = [NSMutableArray array];
	
	// 因为变量 obj 为强引用修饰符修饰，所以自己持有对象
}
/// obj 变量超出作用域失效
/// obj 指向的对象，没有任何强引用对象指向它，因此对象废弃
```

在这里，对象的所有者和对象的生命周期也是明确的。

当然，附有 __strong 修饰符的变量之间可以相互赋值。

```
/// 声明
id __strong obj0 = [[NSObject alloc] init]; //对象A
id __strong obj1 = [[NSObject alloc] init]; //对象B
id __strong obj2 = nil;

obj0 = obj1; //obj0变量强引用对象B，对象A即将销毁
obj2 = obj0; //obj0变量强引用对象B

此时对象B强引用变量有：obj0、obj1、obj2

obj1 = nil;  //obj1变量销毁  对象B强引用变量有：obj0、obj2
obj0 = nil;  //obj0变量销毁  对象B强引用变量有：obj2
obj2 = nil;  //obj2变量销毁  对象B即将销毁
```

通过上面这些不难发现，__strong 修饰符的 变量，不仅只在变量作用域中，在赋值上也能够正确地管理其对象的所有者。

当然，即便是 OC 类成员变量，方法参数上，都能使用附有 __strong 修饰符的变量。

```
@interface Test : NSObject
{
	id __strong _obj;
}
- (void)setObject:(id __strong)obj;
@end

@implementatuin Test
- (id)init {
	self = [super init];
	if (self){
	
	};
	return self;
}

- (void)setObject:(id __strong)obj {
	_obj = obj;
}
@end
```

下面试着使用该类。

```
{
	/// 自己生成并持有对象Test
  id __strong test = [[Test alloc] init]; // Test对象
  /// test变量持有NSObject对象
  [test setObject:[NSObject alloc] init]]; //NSObject对象
}
/// test 变量超出作用域，强引用失效
/// Test对象释放
/// Test对象释放的同时 _obj 成员变量也被废弃
/// NSObject对象强引用失效，对象自动释放
```

正如正如苹果宣称的那样，通过__strong 修饰符，不变再次键入 retain 或者 release，完美地满足了 "引用计数式内存管理的思考方式"。

- 自己生成对象，自己所持有。
- 非自己生成的对象，自己也能持有。
- 不再需要自己持有的对象时释放
- 非自己持有的对象无法释放。

**总结 ======================================================**

前两项"自己生成的对象，自己所持有" 和 "非自己生成的对象，自己也能持有"，只需通过带 __strong 修饰符的变量赋值即可达成要求。 通过废弃带 __strong 修饰符的变量(变量作用域结束、成员变量所属对象废弃)或者对变量赋值，都可以做到 "不再需要自己持有的对象时释放"。最后一项"非自己持有的对象无法释放"，由于不变再键入 release, 所以原本就不会执行，这些都满足引用计数式的内存管理的思考方式。

因为 id 类型和对象类型的所有权修饰符默认为 __strong 修饰符，所以不必要再写上 " __strong "。使 ARC 简单有效的编程遵循Object-C 内存管理的思考方式。

---

### __weak 修饰符修饰变量

看起来好像通过 __strong 修饰符编辑器就能够完美地进行内存管理。但是遗憾的是，仅仅通过 __strong 修饰符是不能解决重大问题的。

前面我们有说过，通过废弃带 __strong 修饰的变量(变量作用域结束、成员变量所属对象销毁)或者对变量赋值，都可以做到"不再需要自己持有的对象时释放",换句话说，也仅仅只有这三种情况才能做"不再需要自己持有的对象时释放"。

那么就存在这么一种情况，而且在 iOS 开发中非常常见的一种情况。

对象 A 的成员变量强引用对象 B ，对象 B 的成员变量强引用对象A。
 B 对象的释放依赖于 A 对象的释放后所属成员变量的强引用失效，而 A 对象的释放依赖于B对象释放后所属成员变量的强引用失效。A 依赖 B ，B 则依赖 A。这就是引用计数式内存管理中必然会发生的"循环引用"的问题。

举个栗子: 还是上面Test类验证，循环引用的场景

```
{
id test0 = [[Test alloc] init]; //对象A
// test0持有对象A的强引用

id test1 = [[Test alloc] init]; //对象B 
//  test1持有对象A的强引用

[test0 setObject:test1];   
// 对象B的强引用变量test1, 被赋值给对象A的成员变量_obj 
// 此时，对象B的强引用变量为: test1变量、对象A的成员变量_obj

[test1 setObject:test2];
// 对象A的强引用对象test0, 被赋值给对象B的成员变量_Obj
// 此时，对象A的强引用变量为: test0变量、对象B的成员变量_obj
}
/*
 * 因为 test0 变量超出作用域，强引用失效
 * 因为 test1 变量超出作用域，强引用失效
 * 将要释放A对象，B对象
 * 此时，A对象的强引用变量为B对象的_obj
 * 此时，B对象的强引用变量为A对象的_obj
 * 发生内存泄漏
 */
```
循环引用容易发送内存泄漏。所谓内存泄漏就是应当废弃的对象在超出其生命周期后继续存在。

怎么样才能避免循环引用呢？看到 __strong 修饰符就会意识到了。既然有  strong 就应该与之对应的 weak。也就是说，使用 __weak 修饰符可以避免循环引用。

__weak 修饰符与 __strong 修饰符相反，提供弱引用。弱引用不能持有对象实例。

看下面这个例子:

```
id __weak obj = [[NSObject alloc] init];
```
变量 obj 附加了 __weak 修饰符。实际上如果编译一下代码，编译器会发出警告。

```
Assigning retained object to weak variable; object will be released after assignment
```
大概意思是：

将一个对象分配给weak修饰的变量；对象在创建后即销毁；

上述的例子我们可以这样写

```
{
	/// 自己生成并持有对象
	id __strong obj0 = [[NSObject alloc] init];
	
	/// 因为 obj0 变量为强引用，所以自己持有对象
	id __weak obj1 = obj0;
	
	/// obj1 变量持有生成对象的弱引用
}
/*
 * 因为 obj0 变量超出其作用域，强引用失效
 * 所以自动释放自己持有的对象
 * 因为对象的所有者不存在，所以废弃该对象
 */
```
因为带 __weak 修饰符的变量(即弱引用) 不持有对象，所以在超出其变量作用域时，对象即被释放。

```
@interface Test : NSObject
{
	id __weak _obj;
}
- (void)setObject:(id __strong)objl
@end
 
```
这样就能避免上述例子的循环引用了。

__weak 修饰符还有另一优点。在持有某对象的弱引用时，若该对象被废弃，则此弱引用将自动失效且处于nil 被赋值的状态(空弱引用)。如下代码所示:

```
id __weak obj1 = nil;
{
	id __strong obj0 = [[NSObject alloc] init];
	obj1 = obj0;
	NSLog(@"A : %@", obj1);
}
NSLog(@"B : %@", obj1);
```
此源代码执行结果如下:

```
A: <NSObject: 0x753e180>
B: (null)
```
像这样，使用weak修饰符即可避免循环引用。通过检查附有 __weak 修饰符的对象是否nil,即可判断被赋值的对象是否已废弃。

---

### __unsafe_unretained 修饰符

__unsafe_unretained 修饰符正如其名 unsafe 所示，是不安全的所有权修饰符。

尽管 ARC 式的内存管理是编译器的工作，但附有 __unsafe_unretained 修饰符的变量不属于编译器的内存管理范围对象。这一点使用时要注意。

```
id __unsafe_unretained obj = [[NSObject alloc] init];
```
 
该源代码将自己生成并持有的对象赋值给附有 __unsafe_unretained 修饰符的变量中。

虽然用来 unsafe 的变量，但编译器并不会忽略，而是给出适当的警告:

```
Assigning retained object to unsafe_unretained variable; object will be released after assignment
```

附有 __unsafe_unretained 修饰符的变量同附有 __weak 修饰符的变量一样，因为自己生成并持有的对象不能继续为自己所有，所以生成的对象会立即释放。到这里, __unsafe_unretained 修饰符和 __weak 修饰符是一样的。

下面我们来看看源代码的差异:

```
id __unsafe_unretained obj1 = nil;
{
	id __strong obj0 = [[NSObject alloc] init];
	obj1 = obj0;
	NSLog(@"A : %@", obj1);
}
NSLog(@"B : %@", obj1);
```

此源代码执行结果如下:

```
A: <NSObject: 0x753e180>
Thread 1: EXC_BAD_ACCESS (code=1, address=0xa2bb8)
```

当 __unsafe_unretained 变量执行一个废弃的对象时，__unsafe_unretained变量会变成 悬垂指针。访问 悬垂指针会发生crash。而 __weak 修饰符变量会被赋值为nil。这就是与 __weak 修饰符不同的地方。

---

### __autoreleasing 修饰符
 
ARC 有效时 autorelease 会如何呢？ARC 中不能使用 autorelease 方法。另外也不能使用 NSAutoreleasePool 类。虽然 autorelease 无法直接使用，但实际上，ARC 有效时 autorelease 功能是其作用的。

我们来回顾一下 MRC 时, 使用 autorelease

```
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

id obj = [[NSObject alloc] init];

[obj autorelease];

[pool drain];
```

ARC 有效时，该源代码也能写成下面这样:


```
@autoreleasePool {
    id __autoreleasing obj = [[NSObject alloc] init];
}
```

指定 "@autoreleasePool块" 来替代 "NSAutoreleasePool 类对象的生成、持有、以及废弃"这一范围。
另外, 使用 __autoreleasing 修饰符的变量来替代调用 autorelease 方法。对象赋值给有 __autoreleasing 修饰符的变量等价于 MRC 时对象调用 autorelease 方法, 即对象被注册到 autoreleasePool 中。
也就是说可以理解为，在 ARC 有效时，用 @autoreleasePool块代替 NSAutoreleasePool 类，用附有 __autoreleasing 修饰符的变量替代 autorelease 方法。





> 但是显式地附加 `__autoreleasing` 修饰符和显式地附加 `__strong` 修饰符一样罕见。

我们通过实例来看看为什么非显式地使用 `__autoreleasing` 修饰符也可以。

##### 1. 可非显示地使用`__autoreleasing` 修饰符 案例1

> `@autoreleasePool` 块中的`__strong` 修饰符对象

思考: 取得 `非自己生成并持有的对象` 时, 我们来思考下 MRC 中，是如何取得 `非自己生成并持有的对象`，是在类方法中 `自己生成并持有的对象` 调用了 `autorelease` 方法，加入到缓存池中。

```
@autoreleasePool {
    // 取得非自己生成的对象并持有对象
    id __strong obj = [NSMutableArray array];
    
    /**
    因为变量obj为强引用，所以自己持有对象。
    
    并且该对象，有编译器判断其方法名后自动注册到 autoreleasepool中
    */
}
/**
    obj变量超出其作用域，强引用失效，
    
    所以自动释放自己持有的对象。
    
    同时，随着@autoreleasePool块的结束，
    注册到 autoreleasepool 中的
    所有对象被自动释放。
    
    因为对象所有者不存在，所以废弃对象。
*/
```
使用 `alloc/new/copy/mutableCopy` `以外`的方法来取得对象，但是该对象已经被注册到了 `autoreleasepool`。

命名规则: `init` 方法返回值的对象不注册到`autoreleasepool` 中。

像这样，不使用 `__autoreleasing` 修饰符也能使对象注册到 `autoreleasepool`。


我们再来看 `取得非自己生成并持有对象` 的源码

``` 
+ (id) array {
    id obj = [[NSMutableArray alloc] init];
    return obj;
}
```
由于 `return` 使得对象变量超出其作用域, 所以该强引用对象的自己持有的对象会被自动释放，但该对象作为函数返回值，编译器会自动将这个对象注册到 `autoreleasepool`中。

#####  可非显示地使用`__autoreleasing` 修饰符 案例2

> `__weak` 修饰符对象的例子

虽然 `__weak` 修饰符是为了避免循环引用而使用的，但在访问附有 `__weak` 修饰符变量时，实际上必定要访问注册到 `autoreleasePool` 中的对象。

```
id __weak obj1 = obj0;

```
与一下源码相同

```
id __weak obj1 = obj0;

id __autoreleasing obj2 = obj1;

```

为什么在访问附有 `__weak` 修饰符的变量时必须访问注册到 `autoreleasePool` 的对象呢？这是因为 `__weak` 修饰符只持有对象的弱引用，而在访问引用对象的过程中，该对象有可能被废弃。

如果把要访问的对象注册到 `autoreleasePool` 中，那么在 `@autoreleasePool` 块结束之前都能确保该对象存在。因此，在使用附有 `__weak` 修饰符的变量时就必定要使用注册到 `autoreleasePool` 中的对象。


##### 案例3 : id *obj

思考: 

前面讲述的 `id obj` 和 `id __string obj` 完全一样。那么 `id` 的指针 `id *obj` 又如何呢? 可以由 `id __string obj` 的例子类推出 `id __string *obj`吗？ 
其实，推出来的是 `id __autoreleasing *obj`, 同样，对象的指针 `NSObject **obj` 便成为了 `NSObject* __autoreleasing *obj`。

像这样，id的指针或对象的指针在没有显式指定时会被附加上 `__autoreleasing` 修饰符。

比如，为了得到详细的错误信息，经常会在方法的参数中传递 `NSError` 对象的指针，而不是函数返回值。Cocoa框架中，大多数方法也是用这种方式，如 NSString 的 string 的 `stringWithContentsOfFile: encoding: error:`类方法等。

使用该方式的源代码如下所示:

```
NSError *error = nil;

BOOL result = [obj performOperationWhitError:&error];
```
该方法的声明为:

```
- (BOOL) performOperationWhtiError:(NSError **)error;
```

和前面讲述的一样，id的指针或者对象的指针会默认附加上 `__autoreleasing` 修饰符。所以等同于下列源代码:

```
- (BOOL) performOperationWhtiError:(NSError * __autoreleasing *)error;
```

参数中持有 `NSError` 对象指针的方法，虽然为响应其执行结果，需要生成 `NSError` 类对象，但也必须符合内存管理的思考方式。

作为 alloc/new/copy/mutableCopy 方法返回值`取得的对象是自己生成并持有的对象`，其他情况下便是`取得非自己生成并持有的对象`。

比如 `performOperationWhtiError` 方法的源代码就应该是下面这样:

```
- (BOOL) performOperationWhtiError:(NSError * __autoreleasing *)error {
    /* 错误发生 */
    *error  = [[NSError alloc] initWithDomain:MyAppDomain code:errorCode userInfo:nil];
    retrun NO;
}
```

因为声明为 `NSError * __autoreleasing *` 类型的 `error` 作为 `*error` 被赋值，所以能够返回注册到 `autoreleasePool` 中的对象。

然而，下面的源代码会产生编译器错误:

```
NSError *error = nil;       //NSError * 代表 NSError 类型。
NSError **pError = &error;  //NSError ** 代码 NSError 类型的指针。
/*编译错误*/
```
赋值给对象指针时，所有权修饰符必须一致。
 
```
NSError *error = nil;     
NSError * __strong * pError = &error;
/*编译正常*/


NSError __weak *error = nil;     
NSError * __weak * pError = &error;
/*编译正常*/


NSError __unsafe_unretained *error = nil;     
NSError * __unsafe_unretained * pError = &error;
/*编译正常*/
```

前面的方法参数中使用了附有 `__autoreleasing` 修饰符的对象指针类型。

```
- (BOOL) performOperationWhtiError:(NSError * __autoreleasing *)error;
```

然而调用方法确使用了附有 `__strong` 修饰符的对象指针类型

```
NSError __strong *error = nil;

BOOL result = [obj performOperationWhitError:&error];
```
上面说到，对象指针类型赋值时，其所有权修饰符必须一致，但为什么该源代码没有警告就顺利通过编译了呢？ 实际上，编译器自动的将该源代码转化成了下面形式。

```
NSError __strong *error = nil;

NSError __autoreleasing *tmp = error;

BOOL result = [obj performOperationWhitError:&tmp];

error = tep;
```
当然也可以显式地指定方法参数中对象指针类型的所有权修饰符。


```
- (BOOL) performOperationWhtiError:(NSError * __strong *)error;
```

像该源代码的声明一样，对象不注册到 `autoreleasePool` 也能够传递。但是前面也说过，只有作为 `alloc/new/copy/mutableCopy` 方法的返回值而取得对象时，能够直接生成并持有对象。其他情况即为 `取得非自己生成并持有的对象`，这些务必牢记。为了在使用参数取得对象时，贯彻内存管理的思考方式，我们要将参数声明为附有 `__autoreleasing` 修饰符的对象指针类型。

另外，虽然可以非显式地指定 `__autoreleasing` 修饰符，但在显式地指定 `__autoreleasing` 修饰符时，必须注意对象要为自动变量(包括局部变量、函数以及方法)。


#### @autoreleasePool 块嵌套使用

MRC时

```
NSAutoreleasePool *p0 = [[NSAutoreleasePool alloc] init];
NSAutoreleasePool *p1 = [[NSAutoreleasePool alloc] init];
NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init];

ib obj = [[NSObject alloc] init];
[obj autorelease]

[p2 drain];
[p1 drain];
[p0 drain];
```

同样时，`@autoreleasePool` 块能嵌套使用:

```
@autoreleasePool {
    @autoreleasePool {
        @autoreleasePool {
            id __autoreleasing obj = [[NSObject alloc] init];
        }
    }
}
```

