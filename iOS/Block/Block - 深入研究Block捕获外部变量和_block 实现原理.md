
- block怎样捕获外部变量；

- block的种类以及有什么区别；

- 为什么使用了__block之后就可以在block中更新变量的值；

作者：一缕殇流化隐半边冰霜

链接：https://www.jianshu.com/p/ee9756f3d5f6#

Block在OC中的实现如下:

```
struct Block_layout {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *,...);
    struct Block_descriptor *descriptor;
    /* Imported variables. */
};

struct Block_desriptor {
    unsigned long int reserved;
    unsigned long int size;
    void (*copy)(void *dst, void *src);
    void (*dispose)(void *);
}
```
![image](https://upload-images.jianshu.io/upload_images/1194012-1739b7e85e46b4db.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/510)

从结构图中很容易看到isa，所以OC处理Block是按照对象来处理的。在iOS中，isa常见的就是_NSConcreteStackBlock，_NSConcreteMallocBlock，_NSConcreteGlobalBlock这3种(另外只在GC环境下还有3种使用的_NSConcreteFinalizingBlock，_NSConcreteAutoBlock，_NSConcreteWeakBlockVariable，本文暂不谈论这3种，有兴趣的看看官方文档)

 
#### 目录
 
1. Block捕获外部变量实质
2. Block的copy和release
3. Block中__block实现原理


##### 一.Block捕获外部变量实质

说到外部变量，我们要先说一下C语言中变量有哪几种。一般可以分为一下5种：

- 自动变量
- 函数参数
- 静态变量
- 静态全局变量
- 全局变量

研究Block的捕获外部变量就要除去函数参数这一项，下面一一根据这4种变量类型的捕获情况进行分析。

![image](https://upload-images.jianshu.io/upload_images/1194012-cba895ef7fe45179.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

这里很快就出现了一个错误，提示说自动变量没有加__block，由于__block有点复杂，我们先实验静态变量，静态全局变量，全局变量这3类。测试代码如下：

```
#import <Foundation/Foundation.h>

/// 全局变量
int global_i = 1;

/// 静态全局变量
static int static_global_j = 2;

int main(int argc, const char * argv[]) {
    
        /// 静态变量
        static int static_k = 3;

        /// 自动变量
        int val = 4;
        
        void (^myBlock)(void) = ^{
            global_i ++;
            static_global_j ++;
            static_k ++;
            //val ++;
            NSLog(@"中: global_i = %zi,static_global_j = %zi,static_k = %zi, val = %zi", global_i, static_global_j, static_k, val);
        };
      
        global_i ++;
        static_global_j ++;
        static_k ++;
        NSLog(@"外: global_i = %zi,static_global_j = %zi,static_k = %zi, val = %zi", global_i, static_global_j, static_k, val);
        myBlock();
    
    return 0;
}
```
运行结果

```
外: global_i = 2,static_global_j = 3,static_k = 4,val = 5
中: global_i = 3,static_global_j = 4,static_k = 5,,val = 4
```

那么这里就有两个问题需要弄清楚了

1. 为什么在Block里面不加__Block不允许修改变量?
2. 为什么Block里面自动变量的值没有增加，而其他几个变量的值是增加的?自动变量是什么状态下被block捕获进去的?

为了弄清楚这两点，我们用`clang`转换一下源码出来分析分析。

```
/// 全局变量
int global_i = 1;

/// 静态全局变量
static int static_global_j = 2;

struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    int *static_k;
    int val;
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_k, int _val, int flags=0) : static_k(_statick_k), val(_val) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
    }
};

static void __main_block_fun_0(struct __main_block_impl_0 *__cself){
    int *static_k = __cself->static_k; // bound by copy
    int val = __celf->val; // bound by copy
    global_i ++;
    static_global_j ++;
    (*static_k) ++;
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_45_k1d9q7c52vz50wz1683_hk9r0000gn_T_main_6fe658_mi_0,global_i,static_global_j,(*static_k),val);
 
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
 
int main(int argc, const char * argv[]) {

    static int static_k = 3;
    int val = 4;

    void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &static_k, val));

    global_i ++;
    static_global_j ++;
    static_k ++;
    val ++;
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_45_k1d9q7c52vz50wz1683_hk9r0000gn_T_main_6fe658_mi_1,global_i,static_global_j,static_k,val);

    ((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

    return 0;
}

```

首先全局变量global_i和静态全局变量static_global_j的值增加，以及它们被Block捕获进去，这一点很好理解，因为是全局的，作用域很广，所以Block捕获了它们进去之后，在Block里面进行++操作，Block结束之后，它们的值依旧可以得以保存下来。

接下来仔细看看自动变量和静态变量的问题。
在__main_block_impl_0中，可以看到静态变量static_k和自动变量val，被Block从外面捕获进来，成为__main_block_impl_0这个结构体的成员变量了。

接着看构造函数，

```
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_k, int _val, int flags=0) : static_k(_static_k), val(_val)
```

这个构造函数中，自动变量和静态变量被捕获为成员变量追加到了构造函数中。

main里面的myBlock闭包中的__main_block_impl_0结构体，初始化如下

```
void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &static_k, val));


impl.isa = &_NSConcreteStackBlock;
impl.Flags = 0;
impl.FuncPtr = __main_block_impl_0; 
Desc = &__main_block_desc_0_DATA;
*_static_k = 4；
val = 4;
```
到此，__main_block_impl_0结构体就是这样把自动变量捕获进来的。也就是说，在执行Block语法的时候，Block语法表达式所使用的自动变量的值是被保存进了Block的结构体实例中，也就是Block自身中。

这里值得说明的一点是，如果Block外面还有很多自动变量，静态变量，等等，这些变量在Block里面并不会被使用到。那么这些变量并不会被Block捕获进来，也就是说并不会在构造函数里面传入它们的值。

Block捕获外部变量仅仅只捕获Block闭包里面会用到的值，其他用不到的值，它并不会去捕获。

再研究一下源码，我们注意到__main_block_func_0这个函数的实现

```
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int *static_k = __cself->static_k; // bound by copy
  int val = __cself->val; // bound by copy
  global_i ++;
  static_global_j ++;
  (*static_k) ++;
  NSLog((NSString *)&__NSConstantStringImpl__var_folders_45_k1d9q7c52vz50wz1683_hk9r0000gn_T_main_6fe658_mi_0,global_i,static_global_j,(*static_k),val);
}
```
 我们可以发现，系统自动给我们加上的注释，bound by copy，自动变量val虽然被捕获进来了，但是是用 __cself->val来访问的。Block仅仅捕获了val的值，并没有捕获val的内存地址。所以在__main_block_func_0这个函数中 即使我们重写这个自动变量val的值，依旧没法去改变Block外面自动变量val的值。

 OC可能是基于这一点，在编译的层面就防止开发者可能犯的错误，因为自动变量没法在Block中改变外部变量的值，所以编译过程中就报编译错误。错误就是最开始的那张截图。
 
##### 小结一下：

到此为止，上面提出的第二个问题就解开答案了。自动变量是以值传递方式传递到Block的构造函数里面去的。Block只捕获Block中会用到的变量。由于只捕获了自动变量的值，并非内存地址，所以Block内部不能改变自动变量的值。Block捕获的外部变量可以改变值的是静态变量，静态全局变量，全局变量。

 

