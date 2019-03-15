## Flutter 学习

---

### 一、创建第一个 Flutter App
   
---


> 说明: 本文来自 Flutter 官网摘抄和学习过程中的笔者的一些笔记与心得。

  
```
$ flutter create '项目名称'
```

通过 flutter create '项目名称' 创建 Flutter App, 项目名称可以使用下划线，但是不能使用大写字母。

否则抛出以下异常

```
"xxx" is not a valid Dart package name.
```

贴出项目创建成功后，大致日志信息

```
All done!
[✓] Flutter is fully installed. (Channel stable, v1.0.0, on Mac OS X 10.13.6
    17G65, locale zh-Hans-CN)
[✓] Android toolchain - develop for Android devices is fully installed. (Android
    SDK 26.0.1)
[✓] iOS toolchain - develop for iOS devices is fully installed. (Xcode 10.1)
[✓] Android Studio is fully installed. (version 3.0)
[✓] VS Code is fully installed. (version 1.30.2)
[✓] Connected device is fully installed. (1 available)

In order to run your application, type:

  $ cd 项目名称
  $ flutter run

Your application code is in '项目名称'/lib/main.dart.
```

那么接下里在终端中键入 cd jz_boxedlove、 flutter run 即可。

-----

那么接下来，我们就可以开始编写我们的第一个 Flutter 项目了！

前面日志中也有看到 Your application code is in '项目名称'/lib/main.dart。

我们打开 main.dart 文件。（因为笔者已经是删除 main.dart 之前里面自带的代码了）。


```
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title:'Welcome to Flutter',
      home: new Scaffold(
        appBar: new AppBar (
          title: new Text ('Welcome to Flutter')
        ),
        body: new Center (
          child: new Text('Hello Flutter'),
        ),
      ),
    );
  }
}
```

效果如下

![https://flutterchina.club/get-started/codelab/images/hello-world-screenshot.png](https://flutterchina.club/get-started/codelab/images/hello-world-screenshot.png)
 
 
  **分析**
 
- 本示例创建一个Material APP。Material是一种标准的移动端和web端的视觉设计语言。 Flutter提供了一套丰富的Material widgets。
- main函数使用了(=>)符号, 这是Dart中单行函数或方法的简写。 
- 该应用程序继承了 StatelessWidget，这将会使应用本身也成为一个widget(小部件)。 在Flutter中，大多数东西都是widget，包括对齐(alignment)、填充(padding)和布局(layout) 
 - Scaffold 是 Material library 中提供的一个widget, 它提供了默认的导航栏、标题和包含主屏幕widget树的body属性。widget树可以很复杂。
 - widget的主要工作是提供一个build()方法来描述如何根据其他较低级别的widget来显示自己。
 - 本示例中的body的widget树中包含了一个Center widget, Center widget又包含一个 Text 子widget。 Center widget可以将其子widget树对其到屏幕中心。

 ----
 
### 二、使用外部包(package)
 
 ---- 
 
 **english_words** 软件包的使用。**pub.dartlang.org** 上找到 **english_words** 软件包以及其他许多开源软件包。

 1. pubspec 文件管理 Flutter 应用程序的 assets(资源，如图片、package等)。 在 pubspec.yaml 中，将 english_words（3.1.0或更高版本）添加到依赖项列表，如下面高亮显示的行：

	
```
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  english_words: ^3.1.0
```

2. 在 **lib/main.dart** 中, 引入 **english_words,** 如高亮显示的行所示:

```
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
```

代码修改如下:


	```
	import 'package:flutter/material.dart';
	import 'package:english_words/english_words.dart';
	
	void main() => runApp(new MyApp());
	
	class MyApp extends StatelessWidget {
	  @override
	  Widget build(BuildContext context) {
	    final wordPair = new WordPair.random();
	    return new MaterialApp(
	      title: 'Welcome to Flutter',
	      home: new Scaffold(
	        appBar: new AppBar(
	          title: new Text('Welcome to Flutter'),
	        ),
	        body: new Center(
	          //child: new Text('Hello World'),
	          child: new Text(wordPair.asPascalCase),
	        ),
	      ),
	    );
	  }
	}
	```
新增如下代码:

	```
	1 final wordPair = new WordPair.random();
	2 child: new Text(wordPair.asPascalCase),
	```

- **final** 字面上面翻译过来是最后的意思，应该是类似于 C 语言中的 const 修饰符修饰常量不可变。

- **WordPair** 类似于一个类库，**random()** 通过其方法/函数来获取一个随机的字符串。

- **asPascalCase** 字符串调用，返回一个根据驼峰命名法的字符串。比如："uppercamelcase" 变成 "UpperCamelCase"

----
  
### 三、添加一个 **有状态的部件** (Stateful widget)
  
----

**Stateless widgets** 是不可变的, 这意味着它们的属性不能改变 - 所有的值都是最终的.

**Stateful widgets** 持有的状态可能在 **widget** 生命周期中发生变化. 实现一个 stateful widget 至少需要两个类:

1. 一个 StatefulWidget类。
2. 一个 State类。 StatefulWidget类本身是不变的，但是 State 类在 widget 生命周期中始终存在.

下面我们来添加一个有状态的 **widget-RandomWords**，它创建其 State 类RandomWordsState。State 类将最终为 widget 维护建议的和喜欢的单词对。

1. 添加有状态的 RandomWords widget 到 main.dart。 它也可以在MyApp之外的文件的任何位置使用，但是本示例将它放到了文件的底部。RandomWords widget除了创建State类之外几乎没有其他任何东西。

	```
	class RandomWords extends StatefulWidget {
		@override
		createState() => new RandomWordsState();
	}
	```
2. 添加 **RandomWordsState** 类 继承自State。该应用程序的大部分代码都在该类中， 该类持有 RandomWords widget 的状态。这个类将保存随着用户滚动而无限增长的生成的单词对，以及喜欢的单词对，用户通过重复点击心形 ❤️ 图标来将它们从列表中添加或删除。

  一步一步地建立这个类。首先，通过添加高亮显示的代码创建一个最小类。
  
	```
	class RandomWordsState extends State<RandomWords> {
	}
	```

3. 在添加状态类后，IDE会提示该类缺少 build 方法。接下来，您将添加一个基本的 build 方法，该方法通过将生成单词对的代码从 MyApp 移动到 RandomWordsState 来生成单词对。

	将 build 方法添加到 RandomWordState 中，如下面高亮代码所示


	```
	class RandomWordsState extends State<RandomWords> {
	  @override
	  Widget build(BuildContext context) {
	    final wordPair = new WordPair.random();
	    return new Text(wordPair.asPascalCase);
	  }
	}
	```

4. 通过下面高亮显示的代码，将生成单词对代的码从MyApp移动到RandomWordsState中

	
	```
	class MyApp extends StatelessWidget {
	  @override
	  Widget build(BuildContext context) {
	    //final wordPair = new WordPair.random();  // 删除此行
	
	    return new MaterialApp(
	      title: 'Welcome to Flutter',
	      home: new Scaffold(
	        appBar: new AppBar(
	          title: new Text('Welcome to Flutter'),
	        ),
	        body: new Center(
	          //child: new Text(wordPair.asPascalCase),
	          child: new RandomWords(),
	        ),
	      ),
	    );
	  }
	}
	```

**RandomWords()** 通过这个函数创建一个 **StatefulWidget** 有状态的组件。

然后我们就可以接着运行了看效果了。


----
  
### 4. 路由的简单使用
  
----

#### 通过 Navigator.pushNamed 函数
 
1. 在 MaterialApp 构造函数中注册routes

```
return new MaterialApp(
  theme: new ThemeData(primarySwatch: Colors.blue),
  home: new MyHomePage(),
  routes: {
    "new_page":(context) => new DynamicDetail(),
  }
);
```
2. 在需要触发的点击事件中触发
```
onTap: (){
  Navigator.pushNamed(context, 'new_page'); 
},
```
#### 通过 Navigator.push 函数

```
Navigator.push(context, new MaterialPageRoute(builder: (_){
  return new DynamicDetail();
}));
```
DynamicDetail 指的是需要跳转的页面

均衡场景利弊合理使用即可。

3.flutter 跳转后禁止返回到上一个页面

```
Navigator.of(context).pushAndRemoveUntil(
    new MaterialPageRoute(builder: (context) => new LoginPage()), (route) => route == null);
```



### 5. 对话框的使用


```
_generateAlertDialog() {
  return AlertDialog(
    title: Text('这是标题'),
    content: Text('这是内容'),
    actions: <Widget>[
      FlatButton(
        child: Text('取消'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      FlatButton(
        child: Text('确认'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
showGeneralDialog(
  context: context,
  pageBuilder: (context, a, b) => _generateAlertDialog(),
  barrierDismissible: false,
  barrierLabel: 'barrierLabel',
  transitionDuration: Duration(milliseconds: 400),
);
```


