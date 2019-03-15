## Flutter | 状态管理之 Redux


我们先抛开 Flutter 这个平台来说，如果让你实现数据共享，你能想到的基础方案有哪些。

- 全局静态变量
- 单例
- 持久化(SharePreference)

以上方案真的是简单粗暴，然而，设计到数据数据变更之后及时通知到各个关注方就显得有点捉襟见肘了。
 
---

### Redux 使用

---


#### 一、配置依赖

```
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  dio: ^2.0.3
  redux: ^3.0.0
  flutter_redux: ^0.5.2
```
想要使用Redux、当然需要先配置依赖了。我们这里还使用 flutter_redux 库。其中flutter_redux是用来简化 redux 的使用的。

```
https://github.com/johnpryan/redux.dart
https://github.com/brianegan/flutter_redux
```

#### 二、使用 Redux

```
void main() {
  final store =
  Store<CountState>(reducer, initialState: CountState.initState());
  runApp(new MyApp(store));
}
```

我们在 main 函数入口使用 Store 的构造函数。我们点击查看 Store 源码

下面是他的构造函数。

```
Store(
    this.reducer, {
    State initialState,
    List<Middleware<State>> middleware = const [],
    bool syncStream: false,

    /// If set to true, the Store will not emit onChange events if the new State
    /// that is returned from your [reducer] in response to an Action is equal
    /// to the previous state.
    ///
    /// Under the hood, it will use the `==` method from your State class to
    /// determine whether or not the two States are equal.
    bool distinct: false,
  })
```

Store 可以简单的理解为一个容纳各种数据以及对数据处理的 action 的一个仓库，可以看到可以给它配置一个泛型，这个泛型代表的就是下面的 State，好，我们接着看 State。

##### State

State 实际上并不是 Dart 的基础类型，是一个泛型，他可以是dart基础类型String，int，double，也可以是你定义的class，都ok。总之一句话，他就是Store要守护的和维护的那一份数据。

我们继续分析代码
 
```
void main() {
  final store =
  Store<CountState>(reducer, initialState: CountState.initState());
  runApp(new MyApp(store));
}
```
我们已经得知 State 他就是Store要守护和维护的那一份数据。而上述代码中的 CountState
就是我们名为 CountState 的 State。

---
### State : CountState
---

新增一个 count_state.dart 文件,提供以下函数、属性、方法;

1. 属性 _count
2. 构造函数 CountState
3. 初始化方法  CountState.initState() : _count = 0;
4. Action枚举
5. reducer

完整代码如下:

```
import 'package:meta/meta.dart';
@immutable
class CountState {
  final int _count;
  get count => _count;
  CountState(this._count);
  CountState.initState() : _count = 0;
}

enum Action { increment }

CountState reducer(CountState state, action) {
  if (action == Action.increment) {
    return CountState(state.count + 1);
  }
  return state;
}
```

那么接下来我们逐一拆分

```
import 'package:meta/meta.dart';
@immutable
class CountState {
  final int _count;
  get count => _count;
  CountState(this._count);
  CountState.initState() : _count = 0;
}
```
在这里配置了 CountState类的构造函数 CountState()、成员变量 _count、get方法以及初始化实例方法 CountState.initState(): _count = 0;

```
enum Action{ increment }
```

姑且当做 enum 枚举类型 Action 定义了几个名称，一个对状态进行操作的代号。

```
CountState reducer(CountState state, action) {
  if (action == Action.increment) {
    return CountState(state.count + 1);
  }
  return state;
}
```

reducer是我们的状态生成器(其实就是一个函数，生成新的State)，有两个参数：一个是我们原来的状态 State, 另一个则是我们的代号名称。

然后根据而这个 action 名称做对应的处理。上述代码中当代号为 increment 时，新生成一个 State。 

 
接下来我们回到 main 函数入库

```
class MyApp extends StatelessWidget {
  final Store<CountState> store;
  MyApp(store);
  @override
  Widget build(BuildContext context) {
    return StoreProvider<CountState>(
      store: store,
      child: new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}
```
flutter_redux 提供了一个很棒的 Widget: StoreProvider，它的用法也很简单，接收一个store，和 child Widget。

---

### 子页面中获取

---

接下里我们就在子页面中使用了

```
body: Center(
  child: StoreConnector<CountState,int>(
    converter: (store) => store.state.count,
    builder: (context, count) {
      return Text(
        count.toString(),
        style: Theme.of(context).textTheme.display1,
      );
    },
  ),
),
```

```
class StoreConnector<S, ViewModel> extends StatelessWidget {
```

- 	首先这里需要强制声明类型，S 代表我们需要从 store 中获取什么类型的 state，ViewModel 指的是我们使用这个 State 时的实际类型。

- 	然后我们需要声明一个 converter<S,ViewModel>，它的作用是将 Store 转化成实际ViewModel 将要使用的信息，比如我们这里实际上要使用的是 count，所以这里将 count提取出来。

- builder 是我们实际根据 state 创建 Widget 的地方，它接收一个上下文 context，以及刚才我们转化出来的 ViewModel，所以我们就只需要把拿到的 count 放进 Text Widget中进行渲染就好了

---

### 子页面中修改: action

---

通过点击floatingActionButton发出了action，并通知reducer生成了新的状态。

```
floatingActionButton: StoreConnector<CountState,VoidCallback>(
  converter: (store) {
    return () => store.dispatch(Action.increment);
  },
  builder: (context, callback) {
    return FloatingActionButton(
      onPressed: callback,
      child: Icon(Icons.add),
    );
  },
),
```
- 同样，我们还是使用StoreConnector<S,ViewModel>。这里由于是发出了一个动作，所以是VoidCallback。

-  store.dispatch发起一个action，任何中间件都会拦截该操作,在运行中间件后，操作将被发送到给定的reducer生成新的状态，并更新状态树。

---
### Q&A
---

### ViewModel性能优化

我们的StoreConnector能够将store提取出信息并转化成ViewModel，这里其实是有一个性能优化的点的。我们这里的例子非常简单，它的ViewModel就只是一个int的值，当我们ViewModel很复杂的时候，我们可以使用StoreConnector的distinct属性进行性能优化。使用方法很简单：需要我们在ViewModel中重写[==] and [hashCode] 方法，然后把distinct属性设为true。

 


