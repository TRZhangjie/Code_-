## Blocks 的实现 （99-184）


---

### Block 的实质

---

Block 是"带有自动变量的匿名函数",但 Block 究竟是什么呢？ 本文通过 Block 的实现进一步加深理解。

在实际编译时无法转换成我们能够理解的源代码，但是 clang(LLVM编译器)具有转换为我们可读源代码的功能。通过 "-rewrite-objc" 选项就能将含有 Block 语法的源代码变换为 C++ 的源代码。说是 C++, 其实也仅是使用了 struct 结构体，其本质是 C 语言代码。

```
clang  -rewrite-objc 源代码文件名
```

下面，我们转换 Block 语法。

```
int main()
{
    void (^blk)(void) = ^{ printf("Block\n");};
    
    blk();
    
    return 0;
}
```

此源代码的 Block 语法最为简单，省略了返回值类型以及参数列表。此源代码通过 clang 可变换为以下形式:


```
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
 	printf("Block\n");
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

int main()
{
    void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}
```
8 行源代码竟然增加到了 43 行。但是如果仔细观察就能发现，这段源代码虽长却不那么复杂。下面我们将源代码分成这个部分逐步理解。首先来看最初的源代码中的 Block 语法。
 
#### '_main_block_func_0'
 
```
^{printf("Block\n");};
```

可以看到，变换后的源代码中也含有相同的表达式。

```
static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
	 printf("Block\n");
}
```

**如转换后的源代码所示，通过 Blocks 使用的匿名函数实际上被作为简单的C语言函数来处理。**

另外，根据 Block 语法所属的函数名 (此处为main) 和该 Block 出现的顺序值(此处为0) 来给经过 clang 转换的函数命名。

**该函数的参数 __cself 相当于 C++ 实例自身的变量 this，或者 Objective-C 实例方法中指向对象自身的变量 self，即参数 __cself 为指向 Block 值的变量。**
 
下面我们继续研究 __main_block_impl_0 这个结构体

```
struct __main_block_impl_0 *__cself
```

与 C++ 的 this 和 Objective-C 的 self 相同，参数 __cself 是  __main_block_impl_0 结构体指针。

该结构体声明如下:

```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
};
```

由于转换后的源代码中，也一并写入了其构造函数，所以看起来稍显复杂，如果除去该构造函数， __main_block_impl_0 结构体就变的非常简单。

第一个成员变量是 impl, 我们先来看一下其 __block_impl 结构体的声明。

```
struct __block_impl {
  	 void *isa;
  	 int Flags;
  	 int Reserved;
 	 void *FuncPtr;
};
```

我们从其名称可以来联想到某些标志、今后版本升级所需的区域以及函数指针。这些会在后面详细说明。第二个成员变量是 Desc 指针，以下为其 __main_block_desc_0 结构体的声明。

```
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
};
```
以及 __main_block_desc_0 结构体的初始化

```
__main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
```

这些也如同成员名称所示，其结构为今后版本升级所需区域和 Block 的大小。

那么，下面我们来看看初始化含有这些结构体的 __main_block_impl_0 结构体的构造函数。


```
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
```
以 上 就 是 初 始 化 __main_block_impl_0 结 构 体 成 员 的 源 代 码。

我们刚刚跳过了 _NSConcreteStackBlock 的说明。_NSConcreteStackBlock 用于初始化 __block_impl 结构体的 isa 成员。

虽然大家很想了解它，但在进行讲解之前，我们来看看该构造函数的调用。

```
void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
```

因为转换较多，看起来不是很清楚，我们去掉转换的部分，具体如下:


```
struct __main_block_impl_0 tmp = __main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA)
struct __main_block_impl_0 *blk = &tmp;
```

声明一个 `__main_block_impl_0` 结构体指针 tmp，通过其 `__main_block_impl_0` 构造函数传入了两个参数，`__main_block_func_0` 和 `&__main_block_desc_0_DATA`。

这样也就容易理解了。该源代码将 __main_block_impl_0 结构体类型的自动变量，即栈上生成的 __main_block_impl_0 结构体实例的指针，赋值给 __main_block_impl_0 结构体指针类型的变量 blk。以下为这部分对应的最初代码。

```
void (^blk)(void) = ^{printf("Block\n");};
```
 
将 Block 语法生成的 Block 赋给 Block 类型变量 blk。它等同于将 __main_block_impl_0 结构体实例的指针赋给变量 blk。该源代码中的 Block 就是 __main_block_impl_0 结构体类型的自动变量，即栈上生成的 __main_block_impl_0 结构体实例。

下面就来看看 __main_block_impl_0 结构体实例构造参数。

```
__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA)
```

第一个参数是由 Block 语法转换的 C 语言函数指针。第二个参数是作为静态全局变量初始化的 __main_block_desc 结构体实例指针。以下为 __mian_block_desc_0 结构体实例的初始化部分代码。

```
static struct __mian_block_desc_0 __main_block_desc_0_DATA = {
	0,
	sizeOf(struct __main_block_impl_0);
}
```
由此可知，该源代码使用 Block,即 __main_block_impl_0 结构体实例的大小，进行初始化。

下面看看栈上的 __main_block_impl_0 结构体实例(即 Block) 是如何根据这些参数进行初始化的。如果展开 __main_block_impl_0 结构体的 __block_impl 结构体，可记述为如下形式:

```
struct __main_block_impl_0 {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
  struct __main_block_desc_0* Desc;
};
```

该结构体根据构造函数会像下面这样进行初始化。

```
isa = &_NSConcreteStackBlock;
Flags = 0;
Reserved = 0;
FunPtr = __mian_block_func_0;
Desc = &__mian_block_desc_0_Data;
```

虽然大家非常迫切地想了解 _NSConcreteStackBlock，不过我们还是先把其他部分讲完再对此进行说明。将 __mian_block_func_0 函数指针赋给成员变量 FunPtr。

我们来确认一下使用该 Block 的部分。

```
blk();
```

这部分可变换为以下源代码:

```
((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
```

去掉转换部分


```
(*blk ->impl.FuncPtr)(blk);
```

这就是简单地使用函数指针调用函数。正如我们刚才所确认的，由 Block 语法转换的 __mian_block_func_0 函数的指针被赋值成员变量 FunPtr 中。另外也说明了， __main_block_func_0 函数的参数 __cself 指向 Block 值。在调用该函数的源代码中可以看出 Block 正是作为参数进行了传递。

到此总算摸清了 Block 的实质。

