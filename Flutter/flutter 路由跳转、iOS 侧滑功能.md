## flutter 路由跳转、页面侧滑返回 
 
---

想实现一个这样的功能，在 MaterialApp 已经注册 主 Widget MyHomePage 时，需要根据某种业务条件(登录，协议) push 出相应的页面。

---

### Flutter 路由

---

说到路由跳转，Flutter 里面的路由可以分成两种:

- 提前注册，类似 Vue 中的路由配置。

- 手动配置实例。


#### 提前注册路由

我们在 MaterialApp 中的 routes 属性提前注册我们的路由

```
return new MaterialApp(
  theme: new ThemeData(primarySwatch: Colors.blue),
  home: new MyHomePage(),
  routes: {
    "new_page"  :(context) => new NewPage(),
    "login_page":(context) => new LoginPage(),
  }
);
```
示例代码中注册了两个路由 new_page、login_page 名称以及其对应的实例 NewPage()、LoginPage()。

接下来我们就可以直接通过 pushNamed 调用。


```
Navigator.pushNamed(context, 'new_page');

Navigator.pushNamed(context, 'login_page').then((value){
  
});
```
当我们的 MyHomePage 通过 pushNamed 跳转至 LoginPage, 我们还可以在当 LoginPage 
返回至 MyHomePage 时传递参数。

```
Navigator.pop(context,'反馈给MyHomePage页面的数据');
```
 

#### 在需要的时候 动态配置路由
  
所谓的动态路配置，其实就在 将要使用 Navigator push 到下一个新的页面的时候，再去构建我们新页面的实例

```
Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new LoginPage(title: '登录');
                  }));

```

这样做又有什么样的好处呢？ 在实际业务开发过程中，A 页面传递给 B 页面的数据一般都是实时的, 有数据模型、配置参数等等。

比如 A push B页面，是发生在一个 Button 点击后触发，我们需要获取这个 Button 相应数据传递给 B 页面。那么我们的提前注册还行的通吗？可以但是需要多次很多不必要的代码。

---

### 页面侧滑返回

---

有这样的一个需求: 在我们的 MaterialApp 已经注册了 MyHomePage 实例, 需要判断 App 是否已经登录，如果未登录则跳转至 LoginPage 页面，未登录不能 pop页面。

跳转至 LoginPage 页面 很简单，我们完全可以选择一种路由跳转方式即可。

那么怎么实现未登录情况不能 pop 页面呢？ 

1. 导航栏没有返回按钮(这个UI层面的东西就不说了)
2. 不能侧滑返回

但是实际上在 Flutter 的页面跳转中, Flutter 已经实现了iOS的右滑退出手势。

如果我想要这个右滑功能失效，需要怎么做呢？

带这个问题研究了一下源码

**页面跳转会用到 MaterialPageRoute 或 CupertinoPageRoute 这两个类,MaterialPageRoute 是 Android 风格的,CupertinoPageRoute 是 iOS 风格的.**

如果用 MaterialPageRoute 跳转页面. iOS 端有返回手势, Android 端没有返回手势.

看源码, flutter/src/material/page.dart

```
 /// A delegate PageRoute to which iOS themed page operations are delegated to.
  /// It's lazily created on first use.
  CupertinoPageRoute<T> get _cupertinoPageRoute {
    assert(_useCupertinoTransitions);
    _internalCupertinoPageRoute ??= new CupertinoPageRoute<T>(
      builder: builder, // Not used.
      fullscreenDialog: fullscreenDialog,
      hostRoute: this,
    );
    return _internalCupertinoPageRoute;
  }
  CupertinoPageRoute<T> _internalCupertinoPageRoute;

  /// Whether we should currently be using Cupertino transitions. This is true
  /// if the theme says we're on iOS, or if we're in an active gesture.
  bool get _useCupertinoTransitions {
    return _internalCupertinoPageRoute?.popGestureInProgress == true
        || Theme.of(navigator.context).platform == TargetPlatform.iOS;
  }

...

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (_useCupertinoTransitions) {
      return _cupertinoPageRoute.buildTransitions(context, animation, secondaryAnimation, child);
    } else {
      return new _MountainViewPageTransition(
        routeAnimation: animation,
        child: child,
        fade: true,
      );
    }
  }
```

关键函数 _useCupertinoTransitions 和 _cupertinoPageRoute.
通过 _useCupertinoTransitions 判断当前设备是否是 iOS , 如果是 iOS, 就调用 CupertinoPageRoute 类的对象函数.

通过 iOS 端有返回手势, Android 端没有返回手势 现象,和源码分析出 flutter 中的右滑返回的代码是通过 CupertinoPageRoute 的对象函数 buildTransitions 返回的 Widget 实现的.
让我们来看一下源码, flutter/src/cupertino/route.dart
 


```
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (fullscreenDialog) {
      return new CupertinoFullscreenDialogTransition(
        animation: animation,
        child: child,
      );
    } else {
      return new CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        // In the middle of a back gesture drag, let the transition be linear to
        // match finger motions.
        linearTransition: popGestureInProgress,
        child: new _CupertinoBackGestureDetector<T>(
          enabledCallback: () => popGestureEnabled,
          onStartPopGesture: _startPopGesture,
          child: child,
        ),
      );
    }
  }

```

其中 popGestureEnabled 引起了注意


```
  bool get popGestureEnabled {
    final PageRoute<T> route = hostRoute ?? this;
    // If there's nothing to go back to, then obviously we don't support
    // the back gesture.
    if (route.isFirst)
      return false;
    // If the route wouldn't actually pop if we popped it, then the gesture
    // would be really confusing (or would skip internal routes), so disallow it.
    if (route.willHandlePopInternally)
      return false;
    // If attempts to dismiss this route might be vetoed such as in a page
    // with forms, then do not allow the user to dismiss the route with a swipe.
    if (route.hasScopedWillPopCallback)
      return false;
    // Fullscreen dialogs aren't dismissable by back swipe.
    if (fullscreenDialog)
      return false;
    // If we're in an animation already, we cannot be manually swiped.
    if (route.controller.status != AnimationStatus.completed)
      return false;
    // If we're in a gesture already, we cannot start another.
    if (popGestureInProgress)
      return false;
    // Looks like a back gesture would be welcome!
    return true;
  }

```

有几个条件是禁止 pop 手势的.

- route.isFirst : 当前页面是首屏

- route.willHandlePopInternally : 当前页面有 通过 addLocalHistoryEntry 修改页面的

- route.hasScopedWillPopCallback : 实现 WillPop 回调函数的.就是有可能回退页面被拒绝的情况

- fullscreenDialog : 全屏的对话框

- route.controller.status != AnimationStatus.completed : 当前页面动画未完成

- popGestureInProgress : 当前页面已经有一个手势在运行

第一个条件不用说了,都是第一屏了,没有可返回的.

后两个条件也不需要说,都是某一时间段内禁用返回手势.

咱说说 fullscreenDialog, route.hasScopedWillPopCallback, route.willHandlePopInternally 这三个条件.
 
#### fullscreenDialog

什么情况下 fullscreenDialog 为 true.

fullscreenDialog 是 MaterialPageRoute 和 CupertinoPageRoute 的一个属性.
 
```
 Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new LoginPage(), fullscreenDialog: true));
});

```
在最后一行代码将 fullscreenDialog 属性设置为 true.当点击按钮后弹出的对话框左上角的按钮是 " X ".
这种情况下返回手势失效。


 
### 修改主题颜色

primarySwatch 颜色有限

如果要把顶部导航栏和状态栏的颜色修改成黑色或者白色，需要用到这个属性：

primaryColor:Colors.white


