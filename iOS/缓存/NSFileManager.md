 
```
NSFileManager *mgr = [NSFileManager defaultManager];
        
NSString *path = @"/Users/Desktop/NSFileManager/my.txt";
        
NSError *error = nil;
```

> 1. 创建文件
       

```
BOOL ture = [mgr createFileAtPath:path contents:nil attributes:nil];
ture ? NSLog(@"1.文件创建成功!") : NSLog(@"1.文件创建失败!");
```

        
        
> 2. 创建文件的同时给文件写内容


```
NSString *writeContentString = @"断剑重铸之日，骑士归来之时!";
NSData *writeContentData = [writeContentString dataUsingEncoding:4];
ture = [mgr createFileAtPath:path contents:writeContentData attributes:nil];
ture ? NSLog(@"2.文件创建成功!") : NSLog(@"2.文件创建失败!");
```

        
> 3. 字符串的 简洁写入

```
/*
     这种写入是直接覆盖
 */
writeContentString = @"断剑重铸之日，骑士归来之时!\n 断剑重铸之日，骑士归来之时";

[writeContentString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error]; 

ture ? NSLog(@"3.简洁写入成功!") : NSLog(@"3.简洁写入失败!,%@", error.userInfo);
```

        
> 4. 通过NSFileManager根据文件路径获取NSData 转换成字符串


```
NSData *takeContenData = [mgr contentsAtPath:path];

NSString *takeContenStr = [[NSString alloc] initWithData:takeContenData encoding:NSUTF8StringEncoding];

NSLog(@"takeContenStr:%@", takeContenStr);
```

        
> 5. 直接从文件路径获取NSString
        

```
NSString *contents3 = [NSString stringWithContentsOfFile:path
                                                encoding:4
                                                   error:nil];
NSLog(@"直接从文件路径获取NSString:%@",contents3);
```

        
> 6. 删除文件
       

```
error = nil;
ture = [mgr removeItemAtPath:path error:&error];
ture ? NSLog(@"删除成功!") : NSLog(@"删除失败:%@",error.userInfo);
```

> 新建文件目录(files)


```
NSString *path = @"/Users/Desktop/files";

BOOL res = [mgr fileExistsAtPath:path];
    //如果不存在则创建
    if (!res) {
        NSLog(@"目标目录不存在,创建目录");
        [mgr createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
 NSString *writePath = [[path stringByAppendingString:@"/"]stringByAppendingString:[[NSDate date] description]];
  // NSLog(@"writePath:%@", writePath);
    
[takeContenStr writeToFile:writePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
```
> Copy文件或目录，如果文件或者目录存在则拷贝失败


```
NSString *sourcePath = @"/Users/Desktop/QQ";

NSString *targetPath = @"/Users/Desktop/QQ2";

if (![manager copyItemAtPath:sourcePath toPath:targetPath error:nil])
{
    NSLog(@"拷贝失败!");
}
```

> 使用URL来操作文件或者目录


```
//创建目录
NSURL *url = [NSURL URLWithString:@"file:///Users/tarena4000/Desktop/urlDir"];
if (![mgr createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"使用URL创建目录失败!");
    }
```
> 利用一个path来将一个文件的二进制数据读入到NSData(假设这个文件是图片,或视频等,就不能读成字符串)


```
NSData *data = [NSData dataWithContentsOfFile:@"/Users/tarena4000/Desktop/my3.txt"];
  
NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
  
NSLog(@"%@",str);
```


> 使用URL将一个文件的二进制数据读入内存中(使用NSData对象来封装)
   

```
//NSString *urlStr = @"http://tmooc.cn/web/library/library.html";
    
NSURL *url2 = [NSURL URLWithString:@"http://tmooc.cn/web/library/library.html"];
    
NSData *htmlData = [NSData dataWithContentsOfURL:url2];
    
NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
NSLog(@"%@",htmlStr);
```

    


