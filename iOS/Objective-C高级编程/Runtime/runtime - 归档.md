### runtime实现NSCopying

> 首先当我们要为自定义的类，实现深拷贝，添加NSCopying协议。

> 会在代理方法中copyWithZone中实现如下代码。


```
- (id)copyWithZone:(NSZone *)zone {

    CopyClass *cpyClass = [[CopyClass allocWithZone:zone] init];

    cpyClass.property1 = self.property1;
    cpyClass.property2 = self.property2;
    cpyClass.property3 = self.property3;
    cpyClass.property4 = self.property4;
        ……
        ……
    return cpyPerson;
}
```
如果当前这个Class中的property很多怎么办呢?一个个写下来非常麻烦，还容易出错。

**使用runtime就非常简便了，还可以复用代码，是代码更加的灵活。**


```
- (id)copyWithZone:(NSZone *)zone {

    ///1.
    CopyClass *cpyClass = [[CopyClass allocWithZone:zone] init];

    ///2.
    NSDictionary *dict = [self getClassInfoWithClass:self];

    ///3.
    for (NSString * key in dict[@"keys"])
    {
        [cpyPerson setValue:[self valueForKey:key] forKey:key];
    }
    
    return cpyPerson;
}
/*
    这个method能够获取类的所有property
*/
- (NSDictionary *)getClassInfoWithClass:(id)class {
    
    NSMutableArray * keys = [NSMutableArray array];
    NSMutableArray * attributes = [NSMutableArray array];
   
    unsigned int outCount;
    
    objc_property_t * properties = class_copyPropertyList([class class], &outCount);
    for (int i = 0; i < outCount; i ++) {
      
        objc_property_t property = properties[i];
      
        //通过property_getName函数获得属性的名字
        NSString * propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
      
        [keys addObject:propertyName];
      
        //通过property_getAttributes函数可以获得属性的名字和@encode编码
        NSString * propertyAttribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        [attributes addObject:propertyAttribute];
    }
    //立即释放properties指向的内存
    free(properties);
    
    
    return @{@"keys":keys, @"attributes":attributes};
    
}
```


