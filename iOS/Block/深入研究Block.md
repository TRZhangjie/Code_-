## Block 的实质

Block 是"带有自动变量的匿名函数"。


```
clang -rewrite-objc 源代码文件名
```


```
int main()
{
    void (^blk)(void) = ^{
        printf("Block\n");
    };
    blk();
    return 0;
}
```

转换


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

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

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

看起来比较复杂。我们可以逐步理解。


```
^{
        printf("Block\n");
    };
```
转换成


```
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

        printf("Block\n");
    }
```
可以看到，变换后的源代码中也含有相同的表达式。

++如源码所示，通过 Blocks 使用的匿名函数实际上被作为简单的C语言函数来处理。++

另外，==__main_block_func_0== 这个函数名，则根据 Block 语法所属的函数名(此处为main) 和该 Block 出现的顺序值(此处为0) 来给经 clang 变换的函数命名。


```
struct __main_block_impl_0 *__cself
```
++__cself 是  __main_block_impl_0 结构体指针++


```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  <!--__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {-->
  <!--  impl.isa = &_NSConcreteStackBlock;-->
  <!--  impl.Flags = flags;-->
  <!--  impl.FuncPtr = fp;-->
  <!--  Desc = desc;-->
  <!--}-->
};
```

由于转换后的源代码中，也一并写入了其构造函数，所以看起来稍显复杂，如果除去该构造函数，==__main_block_impl_0== 结构体就变的非常简单。两个结构体成员变量结构体指针 ==impl== 和 ==Desc==;

```
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

```
我们可以从其名称可以来联想到某些标志，今后版本升级所需的区域以及函数指针。
```
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
};
```
这些也如同成员名称所示，其结构为今后版本升级所需区域和 Block 的大小。
那么，继续看看== __main_block_impl_0== 的构造函数


```
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
```


