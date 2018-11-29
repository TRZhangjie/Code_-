
## iOS9新特性之常见关键字

### nonnull

---

新出的关键字:修饰属性,方法的参数，方法返回值,规范开发。
 
好处：

1.提高程序员规范，减少交流成本，程序员一看，就知道怎么赋值。

注意:只能用于声明对象，不能声明基本数据类型，因为只有对象才能为nil。
 
nonnull:表示属性不能为空,non：非，null：空


```
方式一:
@property (nonatomic, strong, nonnull) NSString *name;
 
方式二:
@property (nonatomic, strong) NSString * _Nonnull name;
    
方式三:
@property (nonatomic, strong) NSString * __nonnull name;
```

 
在 `NS_ASSUME_NONNULL_BEGIN` 与 `NS_ASSUME_NONNULL_END` 之间所有的对象属性，方法参数，方法返回值，默认都是nonnull。（++不包括结构体++）
 

```
NS_ASSUME_NONNULL_BEGIN
     
@property (nonatomic, strong) NSString *name;
     
NS_ASSUME_NONNULL_END
```
### nullable
---
nullable：可以为nil
     

```
方式一:
@property (nonatomic, strong, nullable) NSString *name;
     
方式二:
@property (nonatomic, strong) NSString * _Nullable name;
     
方式三:
@property (nonatomic, strong) NSString * __nullable name;
```

### null_resettable 
---
当属性策略中使用了null_resettable修饰，就必须保证该属性的get方法返回不为空，否则编译器会如上图那样报警告⚠️。可以在set方法或get方法中做非空处理，以下是在get方法中做处理： 

`self setText:<#(NSString * _Nullable)#>`


```
- (NSNumber *)number{

    if (_number == nil) {
        _number = @11;
    }
    return _number;
}
```


```
方式一:
@property (nonatomic, strong, null_resettable) NSString *name;
```

注意：用null_resettable属性，必须重写set,或者get方法，处理传值为nil的情况，可以模仿控制器view的get方法，当view为nil，就自己创建一个.


### _Null_unspecified

---

_Null_unspecified：不确定是否为空.

 
```
方式一:
@property (nonatomic, strong) NSString * _Null_unspecified name;
```


## iOS9新特性之泛型

泛型使用场景:

```
1.在集合(数组,字典,NSSet)中使用泛型比较常见. 

2.当声明一个类,类里面的某些属性的类型不确定,这时候我们才使用泛型.
```

泛型书写规范


```
在类型后面定义泛型,NSMutableArray<UITouch *> *datas
```

 
泛型修饰:


```
只能修饰方法的调用.
```

 
泛型好处:   

```
1.提高开发规范,减少程序员之间交流

2.通过集合取出来对象,直接当做泛型对象使用,可以直接使用点语法
```

###  类的泛型 

---

```
@interface Person<__contravariant ObjectType> : NSObject

@end

@interface Language : NSObject

@end

@interface iOS : Language

@end
```

####  __covariant 协变

Person类泛型 声明协变 __covariant。

1. 以父类为泛型的类 不能转换成 以子类泛型的类(父 !-> 子);

2. 以子类为泛型的类 可以转换成 以父类泛型的类(子 -> 父);
        
```
Person<Language *> *lP = [[Person alloc] init];
 
Person<iOS *> *iosP = [[Person alloc] init];
 
lP = iosP;
```

#### __contravariant 逆变

1. 以父类为泛型的类 可以转换成 以子类泛型的类(父 -> 子);
        
2. 以子类为泛型的类 不能转换成 以父类泛型的类(子 !-> 父);
        
```
Person<Language *> *lP = [[Person alloc] init];
    
Person<iOS *> *iosP = lP;
```

## iOS9新特性之__kindof

在我们创建类并给类创建类方法时，id, instancetype, 类名都可以作为返回值，创建类对象。

1. id : 不知道具体返回类型。
2. instancetype ：自动识别当前对象的类型。
3. Person : 仅仅表示只能是Person类。
4. iOS9引入新的关键字，__kindof 配合类作为返回值，可以表示Person类或者它的子类。

```
//1.
@interface Person : NSObject
 
+ (__kindof Person *)personOfKindof;

+ (Person *)personOfPerson;

+ (id)personOfId;

+ (instancetype)psersonOfInstancetype;

@end

//2.
@implementation Person

+ (__kindof Person *)personOfKindof {
    return [[self alloc] init];
}

+ (Person *)personOfPerson {
    return [[self alloc] init];
}

+ (id)personOfId {
    return [[self alloc] init];
}

+ (instancetype)psersonOfInstancetype {
    return [[self alloc] init];
}

@end

//3.
@interface SonPerson : Person

@end!
 
```

![image](http://wx4.sinaimg.cn/mw690/6c63902cgy1fhj89mwg90j212n054403.jpg)

__kindof修饰后，子类调用不会给警告，也能调用。


#  宏、const、static、extern

编译时刻: 宏是预编译，const是编译。

编译检查: 宏不会报编译错误，const会报编译错误。

宏的好处: 可以定义函数和方法，const不行。

宏的坏处: 大量使用宏，会造成编译时间太久，每次都需要替换。


#### const的作用

1. const只用于修饰右边的变量(基本数据变量p,指针变量*p)
2. 被const修饰的变量只读


#### const开发者的使用场景
 
1. 定义个全局只读变量:

```
NSString * const name = @"const";

const int *p1; // *p1：常量 p1:变量

int const *p1; // *p1：常量 p1:变量

int const * const p1;  // *p1：常量 p1：常量
    
```
2. 在方法中定义只读参数:


#### static

1. static修饰局部变量

    * 会延长这个局部变量的声明周期，只要程序一运行，局部变量就会一直存在。
    * 局部变量只会分配一次内存。static修饰的代码，只会在程序一启动就会执行，以后就不会执行。
    
    ```
    - (void)btnClick:(UIButton *)btn {
        static int i = 0;
        i++;
        NSLog(@"%d", i);
    }
    
    ```
> 这个方法的局部变量i，如果未用static修饰，每次方法执行完毕都会释放，每次click都重新创建i，打印结果也一直未1；那么如果我们想记录btn的点击次数，那么只能提升局部变量i的生命周期。通过static修饰后，i只会被创建一次，分配一次内存，且一直不被释放。
 
> 这里我们只做解释static修饰局部变量，实际工作并不采用。(提示至类的生命周期即可)。 

2. 修饰全局变量

    * 只有修改全部变量的作用域，标识只能在当前文件夹用。
      
    > 有时候在我们类里我们会声明一些全局变量，当我们使用static修饰这个全部变量后，这个全局变量只能在当前文件夹使用。
    
    
# super, superClass, class

* super：是编译器指示符，仅仅是一个标志,并不是指针，仅仅是标志的当前对象去调用父类的方法，本质还是当前对象调用

* super: 并不是让父类对象调用方法，调用者还是本身

* class：获取方法调用者的类

* superclass: 获取方法调用者的父类

 
```
 
@interface Father:NSObject 
{
    NSString*  name;
}
- (void) setName:(NSString*) yourName;
@end

@interface Son:Father 
{
    NSUInteger age;
}
- (void) setAge:(NSUInteger) age;
- (void) setName:(NSString*) yourName andAge:(NSUInteger) age;
@end

@implementation Son
- (void) setName:(NSString*) yourName andAge:(NSUInteger) age
{

    NSLog(@"self ' class is %@", [self class]);
    NSLog(@"super' class is %@", [super class]);

    [self setAge:age];
    [super setName:yourName];
}
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    Son *son = [[Son alloc] init];
    [son setName:@"阿尔法" andAge:18];
}

```

```
self ' s class is Son
super ' s class is Son
```

> 上面我们就说到了，super关键字，它只是个"编译器指示符"；他和self指向的是相同的消息接收者。

> 拿上面代码为例，不论是用 ==[self setName]== 还是  ==[super setName]== ，接收这个"setName"消息的接收者都是 Son *son 这个类对象。

++**那么self和super同时调用setName时，具体有什么不同呢？**++

 
1. **super** 告诉编译器，当调用 setName 的方法时，要去调用父类的方法，而不是本类里的。

2. 当使用 self 调用方法时，会从当前类的方法列表中开始找，如果没有，就从父类中再找。

3. 而当使用 super 时，则从父类的方法列表中开始找。然后调用父类的这个方法。

下面会个大家做详细的解释.

___

大家都应该知道OC是运行时机制，其实它们底层调用的是一些C函数；

[self setName] 调用时，会使用 objc_msgSendSuper 函数

```
id objc_msgSend(id theReceiver, SEL theSelector, ...)
```


[super setName] 调用时，会使用 objc_msgSendSuper 函数
 
```
id objc_msgSendSuper(struct objc_super *super, SEL op, ...)
```

#### objc_super结构体

```
struct objc_super {
    id receiver; //接收者
   Class superClass; //父类
};
```
1. 结构体第一个成员变量receiver;

2. 结构体第一个成员变量superClass；


 
---

#### 【super setName:】底层就是【objc_msgSendSuper()】实际步骤是这样的


1. 构建objc_super结构体; 其中receiver就是son对象。superClass就是son的父类，也就是Father;

2. 构建@selector;

3. 将 objc_super结构体 和 @selector方法 传入 objc_msgSendSuper中;

4. 在 objc_super结构体中的成员变量superClass(类) 的方法列表中开始查找@selector;

5. 通过 objc_super结构体中的 receiver成员变量 去调用这个@selector；



```
[super text];
    
等价于    
    
struct objc_super objc_super;

objc_super.receiver = self;

objc_super.super_class = [Person class];

objc_msgSendSuper(&objc_super, @selector(text));
```



>  结论:  super调用方法，从父类方法列表中开始查找，然后调用父类的这个方法。


#### [self class] 和 [super class]时，又是怎么样的一个过程

1. [self class] 实际上就是objc_msgSend需要传入两个参数;第一个参数receiver就是self,也就是son这个实例对象。第二个参数就是需要执行的方法class。

2. 需要找到这个需要执行的方法class，开始先从son对象这个类开始查找，也就是Son类，如果没查找这个方法，就一层一层往上找，都没找到，最终找到NSObject类中的class方法，而NSObject这个class方法就是返回self的类别，所以输出Son。


> 结论1: self调用方法时，首先从当前类的方法列表中查找，如果没有就查找父类。

> 结论2: super调用方法时，首先从父类查找，若没找，就从父类的父类中查找，以此类推和self返回结果一致。

 







