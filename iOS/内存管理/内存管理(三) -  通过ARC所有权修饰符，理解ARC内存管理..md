
[CSDN](http://note.youdao.com/noteshare?id=102c2604763d9f17d4e268e1f83bb307)

[有道云](http://note.youdao.com/noteshare?id=102c2604763d9f17d4e268e1f83bb307)
### ARC 内存管理的思考方式

引用计数式内存管理的思考方式就是思考 ARC 所引起的变化。

- 自己生成的对象，自己所持有
- 非自己生成的对象，自己也能持有
- 自己持有的对象不再需要时释放
- 非自己持有的对象无法释放

这一思考方式在 ARC 有效时也是可行的。只是在源代码的记述方法上稍有不同。

### 所有权修饰符

----------

Objcetive-C 编程中为了处理对象，可将变量类型定义为 id 类型或者各种对象类型。

所谓对象类型就是指向 NSObject 这样的 Objcetive-C 类的指针，例如 "NSObject *"。id 类型用于隐藏对象类型的类名部分，相当于 C 语言中常用的 "void *"。

ARC 有效时，id 类型和对象类型同 C 语言其他类型不同，其类型上必须附加所有权修饰符。

- __strong 修饰符
- __weak 修饰符
- __unsafe_unretained 修饰符
- __autoreleasing 修饰符


####  __strong 修饰符

----------

__strong 修饰符是 id 类型和对象默认类型的所有权修饰符。也就是说，以下源代码中的 id 变量，实际上被附件了所有权修饰符。

```
id obj = [[NSObject alloc] init];
```

id 和 对象类型在没有明确指定所有权修饰符时，默认为 __strong 修饰符。

```
id __strong obj = [[NSObject alloc] init];
```

#####  __strong 修饰符 => 自己生成的对象


ARC 情况下
```
{
    id __strong obj = [[NSObject alloc] init];
}
```

++ 如此源代码所示, 附有 __strong 修饰符的变量 obj在超出其变量作用时，即在该变量被废弃时，NSObject 对象强引用失效，NSObject 对象的所有者不存在，因此废弃该对象。++


MRC 情况下

```
{
    id  obj = [[NSObject alloc] init];
    [obj release];
}
```
++为了释放生成并持有的对象，增加了 release 方法的代码。++


> 我的理解: 在ARC时，__strong修饰的变量，在超出其作用域的时候，会释放赋予给它的对象。而在MRC时，变量要释放赋予给它的对象，需要它调用 release 方法。obj变量其实就是一个指针，指向了对象的内存区域，我们通过它来释放对象。不管是ARC还是MRC，我们都是使用谁持有，谁负责释放。

#####  __strong 修饰符 => 非自己生成的对象
 

 在 NSMutableArray 类的 array 类方法的源代码中取得非自己生成并持有的对象，具体如下:

```
 {
    id __strong obj = [NSMutableArray array];     
 }
```


#### __weak 修饰符

---


为了避免循环引用。既然有 `strong`，就应该有与之对应的 `weak`。也就是说 `__weak` 修饰符可以避免循环引用。

`__weak` 修饰符与 `__strong` 修饰符相反，提供弱引用。弱引用不能持有对象实例。

```
id __weak obj = [[NSObject alloc] init];
```

变量 obj 上附加了 `__weak` 修饰符。实际上如果编译一下代码，编译器会发出警告。

`Assigning retained object to weak variable; object will be released after assignment`

大概意思是：将保留对象分配给弱引用变量;对象赋值后将释放。

`__weak` 修饰符还有另一优点。在持有某对象的弱引用时，若该对象被废弃，则此弱引用将自动失效且处于 nil 被赋值的状态。

通过检查 附有 `__weak` 修饰符的变量是否为nil，可以判断被赋值的对象是否已经废弃。

#### __unsafe_unretained 修饰符

----------

`__unsafe_unretained` 修饰符正如其名 `unsafe` 所示，是不安全的所有权修饰符。尽管 ARC 式的内存管理是编译器的工作，但附有 `__unsafe_unretained` 修饰符的变量不属于编译器的内存管理范围对象。这一点使用时要注意。

```
id __unsafe_unretained obj = [[NSObject alloc] init];
```
 
该源代码将自己生成并持有的对象赋值给附有 `__unsafe_unretained` 修饰符的变量中。

虽然用来 `unsafe` 的变量，但编译器并不会忽略，而是给出适当的警告:

```
Assigning retained object to unsafe_unretained variable; object will be released after assignment
```

附有 `__unsafe_unretained` 修饰符的变量同附有 `__weak` 修饰符的变量一样，因为自己生成并持有的对象不能继续为自己所有，所以生成的对象会立即释放。到这里,`__unsafe_unretained` 修饰符和 `__weak` 修饰符是一样的。

当 `__unsafe_unretained` 变量执行一个废弃的对象时，`__unsafe_unretained` 变量会变成`悬垂指针`。这里就是与`__weak` 不同的地方。

为什么要使用 `__unsafe_unretained` 历史原因。

#### __autoreleasing 修饰符

----------

##### __autoreleasing 说明


ARC 有效时 `autorelease` 会如何呢？ARC 中不能使用 `autorelease` 方法。另外也不能使用 `NSAutoreleasePool` 类。虽然 `autorelease` 无法直接使用，但实际上，ARC 有效时`autorelease`功能是其作用的。

```
@autoreleasePool {
    id __autoreleasing obj = [[NSObject alloc] init];
}
```

指定 `@autoreleasePool块` 来替代 `NSAutoreleasePool`类对象的生成、持有、以及废弃

使用 `__autoreleasing` 修饰符的变量来替代调用 `autorelease` 方法

对象赋值给有 `__autoreleasing` 修饰符的变量等价于 MRC时对象调用 `autorelease`,即对象被注册到 `autoreleasepool`。


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

