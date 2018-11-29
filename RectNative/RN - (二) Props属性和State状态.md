[本文CSDN地址](http://blog.csdn.net/blog751196085/article/details/78784547)

[本文有道地址](http://note.youdao.com/noteshare?id=8822272e6b6f34c86672d3e051d94ab7)

上一篇 [React Native - (一) 了解文件结构](http://blog.csdn.net/blog751196085/article/details/78784529)

下一篇 [React Native - (三) 样式]()


### Props(属性)

---

Props官方解释: **大多数组件在创建的时候可以使用各种参数来进行定制，用于定制的这些参数就是 `Props`(Properties属性)**

以常见的组件 `image` 为例，在创建一个图片时，可以传入一个名为 `source` 的 prop 来指定要显示的图片的地址，以及使用名为 `style` 的prop来控制尺寸。

也就是说，组件 `image` 有两个属性 `source` 和 `style`:

- source: 指定要显示图片的地址
- style: 来控制组件的尺寸


```
//定义一个名为 `Bananas` 组件
class Bananas extends Component {
  render() {
    let pic = {
      uri: 'https://upload.wikimedia.org/wikipedia/commons/d/de/Bananavarieties.jpg'
    };
    return (
      <Image source={pic} style={{width: 193, height: 110}} />
    );
  }
}
```
译注：图片可能不会显示:iOS9引入了新特性App Transport Security (ATS)。参见[这篇说明修改](https://segmentfault.com/a/1190000002933776)。

请注意 `{pic}` 外围有一层括号，我们需要用括号来把 `pic` 这个变量嵌入 JSX 语句中。

`{}` 的意思是 `{}` 内部为一个 js 变量或者表达式，需要执行后取值。

因此 我们可以把任意合法的 JavaScript 表达式通过 `{}`嵌入到 JSX语句中。

###### 自定义的组件也可以使用 `props`。

通过在不同的场景使用不同的属性定制，可以尽量提高自定义组件的复用范畴。

```
class Greeting extends Component {
  render(){
    return (
      <Text>Hello {this.props.name}!</Text>
    );
  }
}
```
`Greeting` 相当于 `Text` 的进一步封装。

```
export default class App extends Component<{}> {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          123123
        </Text>
        <Text style={styles.instructions}>
          {instructions}
        </Text>
        //1//2
        <Greeting name="jerry" />
      </View>
    );
  }
}
```
1. 创建 `Greeting` 组件
2. 添加属性 `name` 并制定值为 `jerry`

了解基础 `Component` 和文件结构，使用 `props` 和基础的 `Text`、`Image` 以及 `View`，你就已经足以编写各式各样的 UI 组件了。是不是很简单？哈哈~


### State(状态)

---

我们使用两种数据来控制一个组件: `props` 和 `state`。

`props` 是在父组件中指出，而且一经指定，在被指定的组件的生命周期中则不再改变。对于需要改变的数据，我们需要使用 `state`。

一般来说, 你需要在 constructor 中初始化 `state`，然后在需要修改时调用 `setState`方法。

假如我们需要制作一段不停闪烁的文字。文字内容本身在组件创建时就已经制定好了，所以文字内容应该是一个 `prop`。而文字的显示或隐藏的状态(快速的显隐切换就产生了闪烁的效果)则是随着时间变化的，因此这一状态应该写到 `state`中。

```
export default class App extends Component<{}> {
  render() {
    return (
      /* 4. 实例代码(四) */
      <View>
         <Blink text='I love to blink'/>      
         <Blink text='Yes blinking is so great' />  
         <Blink text='Why did they ever take this out of HTML' />  
         <Blink text='Look at me look at me look at me'/>  
      </View>
    );
  }
}

class Blink extends Component {
    // 构造函数
    constructor(props){
      super(props);
      this.state = {showText: true};
      
      setInterval(() => {

        this.setState( previousState => {
            return {showText : !previousState.showText};
          });
      }, 1000);
    }
    render(){
      let disdlay = this.state.showText ? this.props.text : '';
      return (
        <Text>{disdlay}</Text>
      );
    }
}

```
上述代码是对 `state` 的初步使用，值得注意的是

[React ES6 class constructor super()](https://segmentfault.com/a/1190000008165717)

1. 在 `constructor` 里面调用 `super` 是否是必要的？
2. `super` 与 `super(props)` 的区别？

其实前面就有说到 

> 一般来说, 你需要在 constructor 中初始化 `state`，然后在需要修改时调用 `setState`方法。

##### 解答一:

仅当存在 `constructor` 的时候必须调用 `super`，如果没有，则不用

如果在你声明的组件中存在 `constructor`，则必须要加`super`。

```
class MyClass extends React.component {
    constructor(){
        console.log(this) //Error: 'this' is not allowed before super()
    }
}
```
如果在你的代码中存在 `consturctor`，那你必须调用：之所以会报错，是因为若不执行`supe`，则 `this` 无法初始化。

小结：

`Blink` 组件扩展自 `Component`， 我们可以理解为 `Blink` 继承自 `Component`。`Component` 默认是提供了它的 构造函数的，在 `Blink` 中我们重写父类的构造函数，而像 `this` 这些是在 `Component` 或者更高一个层次中被初始化的，那么我们需要在 `Blink` 中，调用父类的构造函数，从而对 `this` 初始化或者定义。


##### 解答二:

仅当你想在 `constructor` 内使用 `props` 才将 `props` 传入 `super` 。`React` 会自行 `props` 设置在组件的其他地方（以供访问）。
将 `props` 传入 `super` 的作用是可以使你在 `constructor` 内访问它.


如果你只是想在别处访问它，是不必传入props的，因为 `React` 会自动为你设置好：


[(一) React Native - 了解文件结构]()

[(三) React Native - 样式]()

