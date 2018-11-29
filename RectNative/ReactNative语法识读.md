# ReactNative语法识读


## 2018年11月9日

### 1. 在原生视图中展示JS Bundle中定义的组件（视图）

在js的组件中，`render()`方法返回了这个组件的视图，在OC中要展示一个组件视图，需要使用`RCTRootView`类。

`RCTRootView`继承于`UIView`，作为一个容器，承接js中定义的组件视图。

在使用上，`RCTRootView`与一般的 `UIView` 最大的不同在于初始化的时候是加载 `JS Bundle` 中定义的组件的视图，一旦初始化以后，就可以像使用一般的`UIView` 一样使用它。

#### 初始化 RCTRootView

初始化一个 `RCTRootView`，需要指定所加载的组件的名称以及定义该组件的 `JS Bundle` 文件。

两个实例方法:

- 指定bundleURL+moduleName

```
initWithBundleURL: moduleName: initialProperties: launchOptions:
```

- 指定bridge+moduleName

```
initWithBridge: moduleName: initialProperties:nil
```
这两种方式是有区别的，使用第二种方法可以实现对同一个`RCTBridge`实例的复用，而使用第一种方法，每次都会创建一个新的`RCTBridge`实例。

`RCTBridge`实例越多，意味着`JavaScript`上下文的越多。如果多个`RCTRootView`实例所加载的组件都来自于同一个`js bundle`，通常没有必要创建多个`RCTBridge`实例，这时应该使用第二种方法。


