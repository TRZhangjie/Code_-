# Code_浅蓝



[本文CSDN地址](http://blog.csdn.net/blog751196085/article/details/78784529)

[本文有道地址](http://note.youdao.com/noteshare?id=d7cce18438b52a59a26af3b7e763e5b2)

下一篇 [React Native - (二) Props属性和State状态](http://blog.csdn.net/blog751196085/article/details/78784547)


### ReactNative 基础开发
 
- 基础前端开发知识
- Node.js基础
- JSX语法基础
- Flexbox布局


### 了解文件结构

#### App.js

React Native 下面例举了一些已经具备的内置组件：

```
import {
  Platform,
  StyleSheet,
  Text,
  View,
  TabBarIOS
} from 'react-native';
```
通过 `improt` 引入该组件，比如我们页面上需要显示文本，我们则使用 `<Text>Hello world!</Text>`。


常量对象的定义和扩展

```
const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
    'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
```
定义App.js类的组件

```
import React, { Component } from 'react'; //1.

export default class App extends Component<{}> { //2.
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          123{this.props.text}123
        </Text>
        <Text style={styles.instructions}>
          {instructions}
        </Text>
      </View>
    );
  }
```  
1. `Component` 模块则是用来告知当前类具备封装成一个组件的能力。
2.  组件的封装及页面的定制。
3.  `render` 方法中返回一些用于渲染结构的 JSX 语句。
4.  `extends` 扩展


#### index.js

```
import { AppRegistry } from 'react-native';//1
import App from './App';//3

AppRegistry.registerComponent('XXXXX', () => App);//2
```
1. `AppRegistry` 模块则是用来告知 React Native 哪一个组件被注册为整个应用的根容器。
2. 你无需在此深究，因为一般在整个应用里 `AppRegistry.registerComponent 这个方法只会调用一次。
3. 导入名为App的组件，也就上述提到的App.js。


[(二) React Native -  Props属性和State状态]()


