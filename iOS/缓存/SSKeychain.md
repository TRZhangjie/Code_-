
### 概要

> Keychain目前主要功能就是帮助用户安全地记住密码,keychain保存的密码文件都是经过加密的，其他人不能直接通过打开keychain的文件获取保存在keychain中的密码。

> 苹果还提供了使用keychain保存密码的API，如果APP使用了keychain API来保存密码， 保存密码的结果都可以在钥匙串应用中查看到。

> Safari就是用keychain来保存密码的，当用户在一个网页中输入了用户名和密码之后，Safari会询问用户是否需要记住密码。如果用户选择记住Safari则会采用keychain进行密码的保存，在下次用户再次访问同一个网站的时候，系统会自动进行用户名和密码的填充。同时在钥匙串程序中，可以看到Safari保存的针对特定网页的用户名，在输入了系统登录密码之后可以查看到对应的密码明文。

***

### iOS中使用keychain和userdefaults保存数据的对比

> userdefault适合保存一些轻量级的数据，使用userdefault保存的时间加载的时候要快一些，数据以明文的形式保存在.plist文件中，不适合用来保存密码信息。 

> 文件的位置是Library/Application Support/iPhone Simulator/模拟器版本/Applications/应用对应的数字/Library/Preference/.plist文件


> keychain采用的是将数据加密之后再保存到本地的，这样对数据而言更安全。适合保存密码之类的数据，

> 数据目录:  Library/Application Support/iPhone Simulator/模拟器版本/Library/Keychains/

***
### SSkeychain

> SSKeyChains对苹果安全框架API进行了简单封装，支持对存储在钥匙串中密码、账户进行访问，包括读取、删除和设置。 

> 对于只需要保存用户名和密码来说，SSKeychain可能更合适，它对keychain做了相应的封装，接口相对于更加简单。

#### 对SSKeychain中的password，service，account的理解和使用

> 既然说到要用SSKeychain来保存用户名和密码，那么需要使用到的SSKeychain的功能就包括添加用户名和密码，删除用户名和密码、查询用户和密码。


> SSSkeychain的方法中涉及到的变量主要有三个，password，service，account。

> password、account分别保存的是密码和用户名信息。service保存的是服务的类型，就是用户名和密码是为什么应用保存的一个标志。比如一个用户可以再不同的论坛中使用相同的用户名和密码，那么service保存的信息分别标识不同的论坛。由于包名通常具有一定的唯一性，通常在程序中可以用包的名称来作为service的标识。


```
[SSKeychain setPassword: @"password"
             forService: @"service" 
                account: @"account"];
                
[SSKeychain accountsForService:@"service" 
                        error:&error];
 
```

**setPassword的功能是保存account、service、password的**

**accoutsForService是提取对应于特定service的所有accouts,可以才看出它的返回结果是NSArray类型的, 并且Array的每一个元素是以key-value格式保存的数据。 如果需要找出特定的用户名的话，需要使用valueForKey@“acct”来定位用户名。（由于在这之前keychain已经保存了一个数据，所以lastObject对应的下标是2.）**



###本文出处

- [x] [SSKeychain在iOS中的原理和使用说明](http://www.jianshu.com/p/df0f15409e5d)
- [x] [IOS的keychain的三种使用方法](http://www.hudongdong.com/ios/356.html)


