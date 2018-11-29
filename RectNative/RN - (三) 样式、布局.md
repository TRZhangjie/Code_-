
[本文CSDN地址]()

[本文有道地址](http://note.youdao.com/noteshare?id=fcd9d1a4ea8e1f2eab628a7109535c4a)

上一篇 [React Native - (二) Props属性和State状态](http://blog.csdn.net/blog751196085/article/details/78784547)

下一篇 []()

### 样式

---

在`React Native`中，你并不需要学习什么特殊的语法来定义样式。我们仍然是使用 `JavaScript `来写样式。所有的核心组件都接受名为 `style` 的属性。这些样式名基本上是遵循了 web 上的 CSS 的命名，只是按照 JS 的语法要求使用了驼峰命名法，例如将 `background-color` 改为 `backgroundColor`。

`style`属性可以是一个普通的JavaScript对象。 这是最简单的用法，因而在示例代码中很常见。

你还可以传入一个数组一一在数组中位置居后的样式对象比居前的优先级更高，这样你可以间接实现样式的继承。

```
class LotsOfStyles extends Component {
  render() {
    return (
      <View>
        <Text style={styles.red}>just red</Text>
        <Text style={styles.bigblue}>just bigblue</Text>
        <Text style={[styles.bigblue, styles.red]}>bigblue, then red</Text>
        <Text style={[styles.red, styles.bigblue]}>red, then bigblue</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  bigblue: {
    color: 'blue',
    fontWeight: 'bold',
    fontSize: 30,
  },
  red: {
    color: 'red',
  },
});
```

### 高度与宽度

---

#### 指定宽高

最简单的给组件设定尺寸的方式就是在样式中指定固定的 `width` 和 `height`。React Native中的尺寸都是无单位的，表示的是与设备像素密度无关的逻辑像素点。

```
class FixedDimensionsBasics extends Component {
  render() {
    return (
      <View>
        <View style={{width: 50, height: 50, backgroundColor: 'powderblue'}} />
        <View style={{width: 100, height: 100, backgroundColor: 'skyblue'}} />
        <View style={{width: 150, height: 150, backgroundColor: 'steelblue'}} />
      </View>
    );
  }
};
```

#### 弹性（Flex）宽高

[Flex 布局教程：语法篇](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)

在组件样式中使用 `flex` 可以使其在可利用的空间中动态地扩张或收缩。一般而言我们会使用 `flex:1` 来指定某个组件扩张以撑满所有剩余的空间。如果有多个并列的子组件使用了 `flex:1`，则这些子组件会平分父容器中剩余的空间。如果这些并列的子组件的 `flex` 值不一样，则谁的值更大，谁占据剩余空间的比例就更大（即占据剩余空间的比等于并列组件间 `flex` 值的比）。

```
/**
 * 案例 5 弹性（Flex）宽高
 * 设定: flex
 */ 
class FlexDimensionsBasics extends Component {
  render() {
    return (
      // 试试去掉父View中的`flex: 1`。
      // 则父View不再具有尺寸，因此子组件也无法再撑开。
      // 然后再用`height: 300`来代替父View的`flex: 1`试试看？
      <View style={{flex: 1}}>
        <View style={{flex: 1, backgroundColor: 'powderblue'}} />
        <View style={{flex: 2, backgroundColor: 'skyblue'}} />
        <View style={{flex: 3, backgroundColor: 'steelblue'}} />
      </View>
    );
  }
};
```

### 使用Flexbox布局

------

我们在React Native中使用 `flexbox` 规则来指定某个组件的子元素的布局.

`Flexbox` 可以再不同屏幕尺寸上提供一致的布局结构。

一般来说使用 `flexDirection`、`alignItems`、`justifyContent` 三个样式属性就已经能满足大多数布局需求。

> React Native中的Flexbox的工作原理和web上的CSS基本一致，当然也存在少许差异。首先是默认值不同：`flexDirection` 的默认值是 `column` 而不是 `ro`，而`flex`也只能指定一个数字值。

- flexDirection  决定布局的主轴(垂直、水平)
- justifyContent 决定其子元素沿着主轴的排列方式(开始，中间，末尾)
- alignItems     决定其子元素沿着次轴的排列方式(开始，中间，末尾）

#### Flex Direction

flexDirection 取值: `column`(Default) 、`row`

```
/**
 * 案例 6 Flex Direction
 * flexDirection 取值: row、 column
 */ 
class FlexDirectionBasics extends Component {
  render(){
    return(
       <View style={{flex: 1, flexDirection:'column'}}>
         <View style={{width: 50, height: 50, backgroundColor: 'powderblue'}}></View>
         <View style={{width: 50, height: 50, backgroundColor: 'skyblue'}}></View>
         <View style={{width: 50, height: 50, backgroundColor: 'steelblue'}}></View>
       </View>
    );
   }
}
```

#### Justify Content

在组件的style中指定justifyContent可以决定其子元素沿着主轴的排列方式。对应的这些可选项有：`flex-start`、`center`、`flex-end`、`space-around`以及`space-between`。

```
/**
 * 案例 7 Justify Content
 * justifyContent 取值: `flex-start`、`center`、`flex-end`、`space-around` 以及 `space-between`
 */ 
class JustifyContentBasics extends Component {
  render(){
    return(
       <View style={{
         flex: 1, 
         flexDirection:'column',
         justifyContent: 'space-between'
         }}>
         <View style={{width: 50, height: 50, backgroundColor: 'powderblue'}}></View>
         <View style={{width: 50, height: 50, backgroundColor: 'skyblue'}}></View>
         <View style={{width: 50, height: 50, backgroundColor: 'steelblue'}}></View>
       </View>
    );
   }
}
```

#### Align Items

在组件的style中指定alignItems可以决定其子元素沿着次轴（与主轴垂直的轴，比如若主轴方向为row，则次轴方向为column）的排列方式。对应的这些可选项有：flex-start、center、flex-end以及stretch。

> 注意：要使 `stretch` 选项生效的话，子元素在次轴方向上不能有固定的尺寸。以下面的代码为例：只有将子元素样式中的 `width: 50` 去掉之后，`alignItems: 'stretch'` 才能生效。

```
/**
 * 案例 8.1 Align Items
 * alignItems 取值: `flex-start`、`center`、`flex-end`以及 `stretch`
 * 
 */ 
class AlignItemsBasics1 extends Component {
  render(){
    return(
       <View style={{
         flex: 1, 
         flexDirection:'row',
         justifyContent: 'center',
         alignItems: 'center'
         }}>
         <View style={{width: 50, height: 50, backgroundColor: 'powderblue'}}></View>
         <View style={{width: 50, height: 50, backgroundColor: 'skyblue'}}></View>
         <View style={{width: 50, height: 50, backgroundColor: 'steelblue'}}></View>
       </View>
    );
   }
}
```
```
/**
 * 案例 8.2 Align Items
 * alignItems 取值: `stretch`
 * 
 * 注意：要使stretch选项生效的话，子元素在次轴方向上不能有固定的尺寸。
 * 以下面的代码为例：只有将子元素样式中的width: 50去掉之后，alignItems: 'stretch'才能生效。
 */ 
class AlignItemsBasics2 extends Component {
  render(){
    return(
       <View style={{
         flex: 1, 
         flexDirection:'column',
         justifyContent: 'center',
         alignItems: 'stretch'
         }}>
         <View style={{height: 50, backgroundColor: 'powderblue'}}></View>
         <View style={{height: 50, backgroundColor: 'skyblue'}}></View>
         <View style={{height: 50, backgroundColor: 'steelblue'}}></View>
       </View>
    );
   }
}
```

