### 1. React Native获取当前屏幕宽高及分辨率


```
//首先要导入Dimensions包
var Dimensions = require('Dimensions');
 
class MyProject1 extends Component {
    render() {
        return (
            <View style={styles1.container}>
               {/*React Native中获取宽高及分辨率方法*/}
                <Text>当前屏幕的宽度:{Dimensions.get('window').width}</Text>
                <Text>当前屏幕的高度:{Dimensions.get('window').height}</Text>
                <Text>当前屏幕的分辨率:{Dimensions.get('window').scale }</Text>
            </View>
        );
    }
}
```

### 2. TabBarIOS 组件使用

> 这是一款 iOS 平台的组件, 凡事以 IOS 或者 Android 后缀的组件，都不能跨平台运行。


### 属性

1. 设置 Tabbar 背景颜色
```
barTintColor string 
```
2、

