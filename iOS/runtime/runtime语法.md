
- [link](https://blog.csdn.net/fishmai/article/details/73468952)
- [link](https://www.jianshu.com/p/46dd81402f63)


#### 获取类的实例方法
```
Method class_getInstanceMethod(Class cls, SEL  name)
```


#### 获取类的类方法

```
Method class_getClassMethod ( Class cls, SEL name );
```

#### 返回指定类的元类

```
Class objc_getMetaClass ( const char *name );
```


#### 动态给类添加一个新的方法

```
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)
```

参数 | 说明
---|---
Class cls | 添加新方法的那个类
SEL name | 要添加的方法
IMP imp | 指向实现方法的指针, 就是要添加的方法的实现部分
const char *types | 函数编码
 

#### 获取函数编码
 
```
const char *  method_getTypeEncoding(Method _Nonnull m)
```

