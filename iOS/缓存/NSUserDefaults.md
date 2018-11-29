# NSUserDefaults
==NSUserDefaults== 很适用于快速读取小规模的数据


```
NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
```

写入数据


```
NSString *string = @"hahaha";
[standardDefaults setObject:string forKey:@"myKey"];
[standardDefaults synchronize];//写完别忘了同步
```

读取数据


```
NSString *value = [standardDefaults objectForKey:@"myKey"];
```

**==NSUserDefaults== 可以很好地理解成键值对存储数据**

其实大可不必这么麻烦，还可以通过使用 ==registerDefaults:==

 

```
NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
[standardDefaults registerDefaults:@{@"favoriteColor": @"Green"}];
[standardDefaults synchronize];
```

每次程序启动的时候调用 ==registerDefaults:==  方法都是安全的。完全可以将这个方法的调用放到 ==applicationDidFinishLaunching:== 方法中. 这个方法永远都不会覆盖用户设置的值。
但是并不是所有类型的对象都能够直接放入NSUserDefaults，NSUserDefaults只支持： NSString, NSNumber, NSDate, NSArray, NSDictionary

解决方法：让这个自定义的类实现协议，举个例子：


```
//SNShops.h

@interface SNShops : NSObject<NSCoding>

@property (nonatomic,strong) NSString* sid;
@property (nonatomic,strong) NSString* name;

- (id) initWithCoder: (NSCoder *)coder;
- (void) encodeWithCoder: (NSCoder *)coder;

//SNShops.m
@implementation SNShops
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.sid = [coder decodeObjectForKey:@"sid"];
        self.name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.sid forKey:@"sid"];
    [coder encodeObject:self.name forKey:@"name"];
}
```

然后再存取时通过 ==NSData== 做载体：

存入

```
NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

SNShops *shop = [[SNShops alloc]init];
NSData *shopData = [NSKeyedArchiver archivedDataWithRootObject:shop];

[standardDefaults setObject:shopData forKey:@"myshop"];
[standardDefaults synchronize];
```
读取


```
NSData *newshopData = [standardDefaults objectForKey:"myshop"];
SNShops *newshop = [NSKeyedUnarchiver unarchiveObjectWithData:newshopData];
```

[NSUserDefaults](http://yulingtianxia.com/blog/2014/04/07/iosdan-li-mo-shi-ornsuserdefaults/)

