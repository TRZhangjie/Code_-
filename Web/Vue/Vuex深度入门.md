# Vuex

1. [Vuex概念](#1)
2. [Vuex基本使用](#2)
3. [state状态的获取 store.state](#3)
4. [state状态的修改 store.commit](#4)
5. [actions](#5)
6. [getters](#6)
7. [modules](#7)
8. [mapGetters、mapActions 和 mapState使用](#8)

参考链接:

- [https://segmentfault.com/a/1190000009404727](https://segmentfault.com/a/1190000009404727)
- [https://segmentfault.com/a/1190000015782272](https://segmentfault.com/a/1190000015782272)
- [https://vuex.vuejs.org/zh/guide/mutations.html](https://vuex.vuejs.org/zh/guide/mutations.html) 

<h3 id='1'> 一、Vuex概念 </h3>

> Vuex 应用的核心就是 store(仓库)， store 基本上就是一个容器，它包含着你的应用中大部分的 **状态(state)**。

这 Vuex 官网的说法。

个人理解: 

> Vue 的 vuex 是全局转态管理; 在state中定义数据、在mutation修改数据、然后衍生出了各种便捷操作函数让你可以在当前项目任何一个组件里获取数据、修改数据，并且你的修改可以得到全局的响应式变更。

---

<h3 id='2'> 二、Vuex基本使用  </h3>
 
```
安装 npm install --save vuex
```

安装完成Vuex后，在 main.js 中加入以下代码

```
 
import vuex form 'vuex'

Vue.use(vuex);

const state = {
	show:true
}

var store = new vuex.Store({ 
    state
})

new Vue({
  el: '#app',
  router,
  store, 
  template: '<App/>',
  components: { App }
})

```
`const state`定义的state对象就是store定义状态的地方，我们可以把需要状态定义在里面。然后在store实例中引入。

在Vue实例中，则引入store;

Vue.use(vuex),大家也应该看到这段代码，它是 vuex 通过 store 选项，提供了一种机制将状态从根组件 "注入" 到每一个子组件中，这样所有子组件中都能够直接使用store对象了。

---

<h3 id='3'> 三、state状态的获取 store.state  </h3>

 
上面的栗子我们已经搭建好了基础的 Vuex store 构建。

那么子组件我们子组件就可以通过 

```
this.$store.state.show   
```
获取 state 中的状态了，例如
```
<p v-show="this.$store.state.show"><p>
```
 
我们还可以在 state 中定义更多的数据

```
const state = {
	show:true，
	age:18
	....等等
}
```
为了方便管理，我们在src目录下新建一个store的文件夹且新建index.js的文件。

index.js

```
import Vue from 'vue'
import vuex form 'vuex'

Vue.use(vuex);

const state = {
	show:true，
	age:18，
	changableNum:0
}

export default new vuex.Store({
    state 
})

```
main.js


```
//vuex
import store from './store'

new Vue({
  el: '#app',
  router,
  store,//使用store
  template: '<App/>',
  components: { App }
})
```

这样就把store分离出去了。不影响状态的获取。

---

<h3 id='4'> 四、state状态的修改 store.commit  </h3>
 

store对象使用和全局对象使用是不是很像？

**Vuex 和 单纯的全局对象有一下两点不同**

(1) Vuex 的状态存储是响应式的。

当 Vue 组件从 store 中读取状态的时候，若 store 中的状态发生变化，那么相应的组件也会相应地得到高效更新(触发更新相关联的 DOM)。

(2) 你不能直接改变 store 中的状态。

改变 store 中的状态的唯一途径就是显式地 **提交(commit)mutation**。这样使得我们可以方便的跟踪没一个状态的变化，从而让我们能够实现一些工具帮助我们更好地了解我们的应用。

**那么要如何显示的提交  (commit)mutation 呢？**

在store中，配置mutations对象

```
const mutations = {
    show(state) { 
    	//自定义改变state初始值的方法，这里面的参数除了state之外还可以再传额外的参数(变量或对象);
        state.show = true;
    },
    hide(state) {  //同上
        state.show = false;
    },
    newNum(state,sum){ 
    	//同上，这里面的参数除了state之外还传了需要增加的值sum
       state.changableNum += sum;
    }
};

export default new vuex.Store({
    state, 
    mutations
})
```
这个时候你完全可以通过使用

```
this.$store.commit('show')
this.$store.commit('hide')
this.$store.commit('newNum',6)
```
在子组件里面改变state中的`show` 和 `newNum`的值了。

---

<h3 id='5'> 五、actions  </h3>
 

vuex官方API还提供了一个actions，这个actions也是个对象变量

1. 官方推荐, 将异步操作放在 action 中。
2. 能执行多个mutations方法。
 
**这里面的方法是用来异步触发mutations里面的方法。**

actions里面自定义的函数接收一个context参数和要变化的形参，context与store实例具有相同的方法和属性，

所以它可以执行context.commit(' '),然后也不要忘了把它也扔进Vuex.Store里面：

```
const actions = {
   // 增加ac_ 方便区分(名字随便取，子组件调用即可)
   async ac_newNum(context,sum){ 
		 ///  在这里我们可以做耗时操作、网络请求 
		  
   	 ///  然后mutations中的方法 newNum 修改state中状态的值
    	 context.commit(newNum, sum);
    }
};

export default new vuex.Store({
    state, 
    mutations，
    actions
})
```
执行则可以直接调用

```
this.$store.dispatch('ac_newNum',6)
```
这样就在修改state中的值时，添加一些耗时操作后，通过 commit 到 mutations中 再在修改state中的值。


---

<h3 id='6'> 六、getters  </h3>


还是前面的例子，我们已经知道获取state中的值(`this.$store.state.xx`),同步事务修改state中的值(`this.$.store.commit('函数名','形参')`)，以及异步事务后修改state中的值(`this.$store.dispatch('ac_函数',6`)`)。

还有一个值得一个对象属性:`getters`

`getters` 和 `vue` 中的 `computed` 类似 , 都是用来计算 `state` 然后生成新的数据 ( 状态 ) 的。

```
computed(){
    not_show(){
        return !this.$store.state.show;
    }
}
```
那么 , 如果很多很多个组件中都需要用到这个与 `show` 刚好相反的状态 , 那么我们需要写很多很多个 `not_show` , 使用 `getters` 就可以解决这种问题 :

```
const getters = {
 	not_show(state){//这里的state对应着上面这个state
		 return !state.show;
   }，
   getChangableNum(state){
   	return state.changableNum + 100;	}
};

export default new vuex.Store({
    state, 
    mutations，
    actions，
    getters
})
```
那么我们就可以通过

```
this.$store.getters.getChangableNum
this.$store.getters.not_show
```

**注意 : **$store.getters.not_show 的值是不能直接修改的 , 需要对应的 state 发生变化才能修改。

总而言之，`getters` 是用来生成与state相关联的属性对象，

到现在我们已经基本了解了 Vuex store的 4个基本对象属性

- state
- getters
- mutations
- actions

---

<h3 id='7'> 七、modules 模块化 </h3>

在单个这个modules 

index.js 
 
```
const state = {
	show:true，
	age:18，
	changableNum:0
}

const mutations = {
    show(state) { 
    	//自定义改变state初始值的方法，这里面的参数除了state之外还可以再传额外的参数(变量或对象);
        state.show = true;
    },
    hide(state) {  //同上
        state.show = false;
    },
    newNum(state,sum){ 
    	//同上，这里面的参数除了state之外还传了需要增加的值sum
       state.changableNum += sum;
    }
};

const actions = {
   // 增加ac_ 方便区分(名字随便取，子组件调用即可)
   async ac_newNum(context,sum){ 
		 ///  在这里我们可以做耗时操作、网络请求 
		  
   	 ///  然后mutations中的方法 newNum 修改state中状态的值
    	 context.commit(newNum, sum);
    }
};

const getters = {
 	not_show(state){//这里的state对应着上面这个state
		 return !state.show;
   }，
   getChangableNum(state){
   	return state.changableNum + 100;	}
};

export default new vuex.Store({
    state, 
    mutations，
    actions，
    getters
})
```

main.js

```
//vuex
import store from './store'

new Vue({
  el: '#app',
  router,
  store,//使用store
  template: '<App/>',
  components: { App }
})
```

多个modules时

index.js 变化如下

```
import Vue from 'vue'
import vuex form 'vuex'

Vue.use(vuex);

import a_store from '../components/a_store.js';//引入某个store对象
import b_store from '../components/b_store.js';//引入某个store对象

export default new vuex.Store({
    modules: {
        a_store: a_store,
        b_store: b_store
    }
})
```
在 a_store.js 和  b_store.js中

```
export default {
	 state, 
    mutations，
    actions，
    getters
}

```
通过引入这个两JS， 我们就可以单独写组件的状态了。

---

<h3 id='8'> 八、mapGetters、mapMutation、mapActions 和 mapState 使用 </h3>

我们回顾一下，当我们查询、修改状态的时候都是这么样去操作的？

1. this.$store.state.属性名
2. this.$store.commit('mutation对象中方法名','形参')
2. this.$store.dispath('actions对象中方法名','形参')
3. this.$store.getters('getters对象中方法名','形参')

这种写法非常繁琐,很不方便
我们没使用 vuex的时候, 获取一个状态只需要 this.show，执行一个方法只需要 this.switch_dialog 就行了 , 使用 vuex 使写法变复杂了 ?

使用 `mapState、mapGetters、mapActions、mapMutation` 就不会这么复杂了。

以 mapState 为例：

我们都知道获取 mapState 要么计算属性中获取，要么直接赋值

``` 
computed:{
     ...mapState([
      'show',
      'age'
    ])，
  }
```
这样就和`data()`函数里面的参数使用就没什么区别了。

mapGetters 一般也写在 computed 中 , mapActions、mapMutation 一般写在 methods中。
 
通过mapState、mapGetters赋值给计算属性，mapActions、mapMutation 一般在 methods 触发调用。

当然这是针对单一modules写法。但是如果是多modules写法来说，这些函数也会有相应的变化：

还是用 mapState 举例

```
mapState('a_store',[])
mapState('b_store',[])
```

基本来这里，对于基础的Vuex的用法，应该了解差不多了，后期如果有时间，精力可以再进深一步的研究。
特别是mapState、mapMutation这些函数，当第一次看到这些函数的时候可能会很蒙，当了解原理后，其实也就那么回事，慢慢运用到工作中就越发会觉得的便宜。






 

