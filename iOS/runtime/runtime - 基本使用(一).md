#### UIImageView的性能优化

> 交叉 UIImageView 的 setImage, 通过开启上下文对象，重绘Image。


#### 字体的适配

> 交叉 分别交叉UIButton， UILable，UITextView, 等一些有设置文字属性的控件，交叉其设置文字字体大小的方法。


```
+ (void)load{
 
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
    method_exchangeImplementations(imp, myImp);
}

- (id)myInitWithCoder:(NSCoder*)aDecode{
    [self myInitWithCoder:aDecode];
    if (self) {
        
        //部分不像改变字体的 把tag值设置成333跳过
        if(self.titleLabel.tag != 333){
            CGFloat fontSize = self.titleLabel.font.pointSize;
            self.titleLabel.font = [UIFont systemFontOfSize:fontSize * kWidth];
        }
    }
    return self;
}
```


### 动态添加方法
---
> 开发使用场景：如果一个类方法非常多，加载类到内存的时候也比较耗费资源，需要给每个方法生成映射表，可以使用动态给某个类，添加方法解决。

- 经典面试题：有没有使用performSelector，其实主要想问你有没有动态添加过方法。

```
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    Person *p = [[Person alloc] init];

    // 默认person，没有实现eat方法，可以通过performSelector调用，但是会报错。
    // 动态添加方法就不会报错
    [p performSelector:@selector(eat)];
}
@end
@implementation Person
// void(*)()
// 默认方法都有两个隐式参数，
void eat(id self,SEL sel)
{
    NSLog(@"%@ %@",self,NSStringFromSelector(sel));
}
// 当一个对象调用未实现的方法，会调用这个方法处理,并且会把对应的方法列表传过来.
// 刚好可以用来判断，未实现的方法是不是我们想要动态添加的方法
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(eat)) 
    {
        // 动态添加eat方法
        // 第一个参数：给哪个类添加方法
        // 第二个参数：添加方法的方法编号
        // 第三个参数：添加方法的函数实现（函数地址）
        // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, @selector(eat), eat, "v@:");
    }
    return [super resolveInstanceMethod:sel];
}
@end
```
### 动态添加属性
---

```
obj_getAssociatedObject 调用运行时方法前，判断对象是否已经获取，如果已经获取直接返回。

obj_setAssociatedObject  动态创建属性，纪录属性数组
```
**效率**

> 不用每次都调用运行时方法，提高效率。


```
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // 给系统NSObject类动态添加属性name
    NSObject *objc = [[NSObject alloc] init];
    objc.name = @"iOS";
    NSLog(@"%@",objc.name);
}

@end
// 定义关联的key
static const char *key = "name";

@implementation NSObject (Property)

- (NSString *)name
{
    // 根据关联的key，获取关联的值。
    return objc_getAssociatedObject(self, key);
}

- (void)setName:(NSString *)name
{
    // 第一个参数：给哪个对象添加关联
    // 第二个参数：关联的key，通过这个key获取
    // 第三个参数：关联的value
    // 第四个参数: 关联的策略
    objc_setAssociatedObject(self, key, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
```
### 字典转模型
---

- 模型属性，通常需要跟字典中的key一一对应
- 问题：一个一个的生成模型属性，很慢？
- 需求：能不能自动根据一个字典，生成对应的属性。
- 解决：提供一个分类，专门根据字典生成对应的属性字符串。

#### KVC

* 如果不一致，就会调用[<Status 0x7fa74b545d60> setValue:forUndefinedKey:] 报key找不到的错。

* 分析:模型中的属性和字典的key不一一对应，系统就会调用setValue:forUndefinedKey:报错。

* 解决:重写对象的setValue:forUndefinedKey:,把系统的方法覆盖， 就能继续使用KVC，字典转模型了。
```
@implementation Status

+ (instancetype)statusWithDict:(NSDictionary *)dict
{
    Status *status = [[self alloc] init];

    [status setValuesForKeysWithDictionary:dict];

    return status;

}
@end
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

}
```

#### runtime

- 思路：利用运行时，遍历模型中所有属性，根据模型的属性名，去字典中查找key，取出对应的值，给模型的属性赋值。

- 步骤：提供一个NSObject分类，专门字典转模型，以后所有模型都可以通过这个分类转。


```
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // 解析Plist文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"status.plist" ofType:nil];

    NSDictionary *statusDict = [NSDictionary dictionaryWithContentsOfFile:filePath];

    // 获取字典数组
    NSArray *dictArr = statusDict[@"statuses"];

    // 自动生成模型的属性字符串
    //[NSObject resolveDict:dictArr[0][@"user"]];

    _statuses = [NSMutableArray array];

    // 遍历字典数组
    for (NSDictionary *dict in dictArr) {

        Status *status = [Status modelWithDict:dict];

        [_statuses addObject:status];
    }
    // 测试数据
    NSLog(@"%@ %@",_statuses,[_statuses[0] user]);
}

@end

@implementation NSObject (Model)

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    // 思路：遍历模型中所有属性-》使用运行时

    // 0.创建对应的对象
    id objc = [[self alloc] init];

    // 1.利用runtime给对象中的成员属性赋值

    // class_copyIvarList:获取类中的所有成员属性
    // Ivar：成员属性的意思
    // 第一个参数：表示获取哪个类中的成员属性
    // 第二个参数：表示这个类有多少成员属性，传入一个Int变量地址，会自动给这个变量赋值
    // 返回值Ivar *：指的是一个ivar数组，会把所有成员属性放在一个数组中，通过返回的数组就能全部获取到。
    /* 类似下面这种写法

     Ivar ivar;
     Ivar ivar1;
     Ivar ivar2;
     // 定义一个ivar的数组a
     Ivar a[] = {ivar,ivar1,ivar2};

     // 用一个Ivar *指针指向数组第一个元素
     Ivar *ivarList = a;

     // 根据指针访问数组第一个元素
     ivarList[0];

     */
    unsigned int count;

    // 获取类中的所有成员属性
    Ivar *ivarList = class_copyIvarList(self, &count);

    for (int i = 0; i < count; i++) {
        // 根据角标，从数组取出对应的成员属性
        Ivar ivar = ivarList[i];

        // 获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];

        // 处理成员属性名->字典中的key
        // 从第一个角标开始截取
        NSString *key = [name substringFromIndex:1];

        // 根据成员属性名去字典中查找对应的value
        id value = dict[key];

        // 二级转换:如果字典中还有字典，也需要把对应的字典转换成模型
        // 判断下value是否是字典
        if ([value isKindOfClass:[NSDictionary class]]) {
            // 字典转模型
            // 获取模型的类对象，调用modelWithDict
            // 模型的类名已知，就是成员属性的类型

            // 获取成员属性类型
           NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
          // 生成的是这种@"@\"User\"" 类型 -》 @"User"  在OC字符串中 \" -> "，\是转义的意思，不占用字符
            // 裁剪类型字符串
            NSRange range = [type rangeOfString:@"\""];

           type = [type substringFromIndex:range.location + range.length];

            range = [type rangeOfString:@"\""];

            // 裁剪到哪个角标，不包括当前角标
          type = [type substringToIndex:range.location];

            // 根据字符串类名生成类对象
            Class modelClass = NSClassFromString(type);

            if (modelClass) { // 有对应的模型才需要转

                // 把字典转模型
                value  =  [modelClass modelWithDict:value];
            }
        }
        // 三级转换：NSArray中也是字典，把数组中的字典转换成模型.
        // 判断值是否是数组
        if ([value isKindOfClass:[NSArray class]]) {
            // 判断对应类有没有实现字典数组转模型数组的协议
            if ([self respondsToSelector:@selector(arrayContainModelClass)]) {

                // 转换成id类型，就能调用任何对象的方法
                id idSelf = self;

                // 获取数组中字典对应的模型
                NSString *type =  [idSelf arrayContainModelClass][key];
                
                // 生成模型
               Class classModel = NSClassFromString(type);
                NSMutableArray *arrM = [NSMutableArray array];
                // 遍历字典数组，生成模型数组
                for (NSDictionary *dict in value) {
                    // 字典转模型
                  id model =  [classModel modelWithDict:dict];
                    [arrM addObject:model];
                }
                // 把模型数组赋值给value
                value = arrM;
            }
        }
        if (value) { // 有值，才需要给模型的属性赋值
            // 利用KVC给模型中的属性赋值
            [objc setValue:value forKey:key];
        }
    }
    return objc;
}
@end
```


