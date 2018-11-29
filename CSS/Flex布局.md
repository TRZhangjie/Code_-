# Flex布局

1. [阮 Flex 布局教程：语法篇](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)


## 一、 Flex 父容器


### Flex 布局语法

---

#### 一、Flex 基本概念

Flex 是 Flexible Box 的缩写，意为"弹性布局"，用来为盒状模型提供最大的灵活性。

任何一个容器都可以指定为 Flex 布局。

```
.box{
  display: flex;
}
```
Webkit 内核的浏览器，必须加上-webkit前缀。

```
.box{
  display: -webkit-flex; /* Safari */
  display: flex;
}
```
**注意，设为 Flex 布局以后，子元素的float、clear和vertical-align属性将失效。**

采用 Flex 布局的元素，称为 Flex 容器（flex container），简称"**容器**"。它的所有子元素自动成为容器成员，称为 Flex 项目（flex item），简称"**项目**"。
 
```
<div class="container">
	<span class="B1"></span>
	<span class="B2"></span>
	<span class="B3"></span>
</div>
<style>
.container {
	display:flex;
}
</style>
```
container就是父容器，B1,B2,B3就是子容器(项目);

容器默认存在两根轴:
- 水平的主轴（main axis） 
- 垂直的交叉轴（cross axis）

主轴的开始位置（与边框的交叉点）叫做`main start`，结束位置叫做`main end`；交叉轴的开始位置叫做`cross start`，结束位置叫做`cross end`。
项目默认沿主轴排列。单个项目占据的主轴空间叫做`main size`，占据的交叉轴空间叫做`cross size`。


#### 二、容器属性

容器(display:flex)有以下6个常用属性：

- flex-direction
- flex-wrap
- flex-flow
- justify-content
- align-items
- align-content

##### 2.1 flex-direction

flex-direction属性决定主轴的方向（即项目(子容器)的排列方向）。

```
.box {
   flex-direction: column | column-reverse | row | row-reverse;
}
```
![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071005.png)

它可能有4个值。

```
column：主轴为垂直方向，起点在上沿。
column-reverse：主轴为垂直方向，起点在下沿。
row（默认值）：主轴为水平方向，起点在左端。
row-reverse：主轴为水平方向，起点在右端。
```

##### 2.2 flex-wrap

默认情况下，项目都排在一条线上(轴线)。

如果在一条轴线上的项目排不下的情况下，我们想让其换行，我们又该怎么处理呢？

我们可以使用flex-wrap属性。

![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071006.png)

```
.box {
	flex-wrap: nowrap | wrap | wrap-reverse;
}
```
它可能取三个值。

(1) nowrap（默认）：不换行。
![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071007.png)
(2) wrap：换行，第一行在上方。
![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071008.jpg)
(3) wrap-reverse：换行，第一行在下方。
![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071009.jpg)

##### 2.3  flex-flow属性

**flex-flow** 属性是 **flex-direction** 属性和 **flex-wrap** 属性的简写形式，默认值为:**row nowrap**。
 
```
.box {
  flex-flow: <flex-direction> || <flex-wrap>;
}
```
##### 2.4 justify-content属性

**justify-content** 属性定义了项目在主轴上的对齐方式。


```
.box {
  justify-content: flex-start | flex-end | center | space-between | space-around;
}
```

它可能取5个值，具体对齐方式与轴的方向有关。下面假设主轴为从左到右。


```	
-	flex-start（默认值）：左对齐
-	flex-end：右对齐
-	center： 居中
-	space-between：两端对齐，项目之间的间隔都相等。
-	space-around：每个项目两侧的间隔相等。所以，项目之间的间隔比项目与边框的间隔大一倍。 
```

##### 2.5 align-items属性

`align-items` 属性定义项目在交叉轴上如何对齐。

```
.box {
  align-items: flex-start | flex-end | center | baseline | stretch;
}
```
它可能取5个值。具体的对齐方式与交叉轴的方向有关，下面假设交叉轴从上到下。


```
flex-start：交叉轴的起点对齐。
flex-end：交叉轴的终点对齐。
center：交叉轴的中点对齐。
baseline: 项目的第一行文字的基线对齐。
stretch（默认值）：如果项目未设置高度或设为auto，将占满整个容器的高度。
```

![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071011.png)

##### 2.6  align-content属性

`align-content` 属性定义了多根轴线的对齐方式。如果项目只有一根轴线，该属性不起作用。


```
flex-start：与交叉轴的起点对齐。
flex-end：与交叉轴的终点对齐。
center：与交叉轴的中点对齐。
space-between：与交叉轴两端对齐，轴线之间的间隔平均分布。
space-around：每根轴线两侧的间隔都相等。所以，轴线之间的间隔比轴线与边框的间隔大一倍。
stretch（默认值）：轴线占满整个交叉轴
```

![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071012.png)


## 二、 Flex 子容器

### 深入理解css3中的flex-grow、flex-basis、flex-shrink

----

转自：http://zhoon.github.io/css3/2014/08/23/flex.html   感谢他的整理 

1. [深入理解css3中的flex-grow、flex-basis、flex-shrink](https://www.cnblogs.com/ghfjj/p/6529733.html)
2. [flex设置成1和auto有什么区别](https://www.cnblogs.com/chris-oil/p/5430137.html)

flex布局发生在父容器和子容器之间。父容器需要有flex环境(display:flex),子容器才能根据自身的属性来布局，简单来说就是瓜分容器的空间。

讲到瓜分父容器来的看，那么首先需要讲到一个很重要的词：**剩余空间**。

```
<div class="container">
	<span class="B1"></span>
	<span class="B2"></span>
	<span class="B3"></span>
</div>
```
container就是父容器，B1,B2,B3就是子容器; 假如container的width是500px,那么剩余空间就是:
500px - B1.width - B2.width - B3.width。 嗯，就是这么简单！

#### flex-grow

知道了剩余空间的概念，首先看一下 flex-grow。
根据上面的例子，我们再假设B1、B2、B3的width是100px, 那么剩余空间就是500-100*3=200。知道了剩余空间有什么用呢？这个时候 flex-grow 就该出场了。


假如我们这个时候对B1设置felx-grow:1，那么我们会发现，B1把B2和B3都挤到右边了，也就是说剩余的200px空间都被B1占据了，所以此时B1的width比实际设置的值要大。

![flex-grow](https://images2015.cnblogs.com/blog/722584/201703/722584-20170310112145422-62458118.png)

是有意这里flex-grow的意思已经很明显了，就是索取父容器的剩余空间，默认值是0，就是个子容器都不索取父容器的剩余空间。但是当B1设置为1的时候，剩余空间就会被分成一份，然后都给了B1。

如果此时B2设置了flex-gorw:2，那么说明B2也参与到瓜分剩余空间中来了，并且他是占据了剩余空间的2份，那么此时父容器就会把剩余空间分成3份，然后1份给到B1，2份给到B2

![](https://images2015.cnblogs.com/blog/722584/201703/722584-20170310112237563-341243798.png)

#### flex-basis(default:auto) 

初次见 flex-basis 这个属性，一脸懵逼，不知道它又是用来干嘛的。后来研究发现，这个 **属性值的作用也就是width的替代品**。

如果子容器设置了flex-basis或者width, 那么在分配空间之前，他们会跟父容器预约这么多空间，然后剩下的才归入到剩余空间，然后父容器再把剩余空间分配给设置了 flex-grow 的容器。**如果同时设置flex-basis和width, 那么width属性会被覆盖**，也就是说flex-basis的优先级比width要高。有一点需要注意，如果felx-basis和width其中有一个是auto,那么另外一个非auto的属性优先级会更高。

![](https://images2015.cnblogs.com/blog/722584/201703/722584-20170310112258313-941109466.png)

tips:flex-basis和width为auto值，那最后的空间就是根据内容多少来定的，内容多占据的水平空间就多。

![](https://images2015.cnblogs.com/blog/722584/201703/722584-20170310112336438-961954812.png)

#### flex-shrink(default:1)

好了，上面讲了这么多，你们应该都没明白了吧。有人会想，不就是这样嘛，很容易啊，不就是剩余的空间的分配吗？

是的，上面讲的是剩余空间的分配。但是，你有没有想过还有其他的情况的呢？ **可以发现，上面讲的例子B1、B2、B3的宽度总和都是没有超过父容器的宽度的。那么三个子容器的的宽度超过父容器的宽度呢？**那还有剩余空间可以分配吗？此时浏览器又是怎么处理呢？

tips:flex环境默认是不换行的，即使父容器宽度不够也不会，除非设置flex-wrap来换行。

![](https://images2015.cnblogs.com/blog/722584/201703/722584-20170310112354641-1167430146.png)

此时我们会发现，B1设置的flex-grow没有作用，不但没有获取到剩余空间，他的空间甚至是比他定义的300px还要小，而且我们发现B2和B3的空间也相应的被压缩了。 那么这里的问题就是：

1. 为什么flex-grow没有作用，反而被压缩呢？
2. 三个容器的压缩比例是这样的呢？

**这就是本文的重点:  flex-shrink**

同样的，三个容器处于flex环境中，所以布局之前，父容器还是会计算剩余空间。

但是这一次计算的结果是这样的: 

```
剩余空间 = 500px - 300px - 160px - 120px = -80px;
```

剩余空间是一个负数所以很容易理解这个问题，即使设置了flex-grow, 但是由于没有剩余空间，所以B1分配到的空间是0。

由于flex环境的父容器的宽度500px是不会变的，所以为了是子容器的宽度最多为父容器的宽度，那么只有两个办法：第一是使子容器换行，第二个是压缩子容器使之刚好撑满父容器的宽度。前面就有说到，flex子容器默认是不换行的。那么根据第二种压缩，实际上就是上面例子表现出的样式。现在就遇到上面第二个问题，这三个的压缩比例是多少呢？各自需要压缩的空间是多少呢？

这个时候就需要谈谈： flex-shrink，这个属性其实就是定义一个子容器的压缩比例。他的默认值是1，所以三个子容器压缩比例：1:1:1。

如果此时我们设置B1的压缩比例是2,那会怎么样呢？

![](https://images2015.cnblogs.com/blog/722584/201703/722584-20170310112410141-256981885.png)

我们可以发现，B1被压缩的更多了。而B2和B3得到了跟多的空间。那我们怎么得出他们各自的压缩率呢？我们假设B2 B3的压缩率是X1，那么B1的压缩率就是X2了，那就有了如下方程：

```
X2 = 2 *X1;
500 = 300 *X2 + 160 * X1 + 120 * X1;
```
这样我们就可以解出X1和X2等于多少了，这样就可以计算出压缩率和被压缩了多少空间了。

#### 总结

1. 剩余空间 = 父容器 - 子容器1.flex-basis/width - 子容器2.flex-basis/width - ...
2. 如果父容器空间不够，就走压缩flex-shrink，否则走扩张flex-grow；
3. 如果你不希望某个容器在任何时候都不被压缩，那设置flex-shrink:0；
4. 如果子容器的的flex-basis设置为0(width也可以，不过flex-basis更符合语义)，那么计算剩余空间的时候将不会为子容器预留空间。
5. 如果子容器的的flex-basis设置为auto(width也可以，不过flex-basis更符合语义)，那么计算剩余空间的时候将会根据子容器内容的多少来预留空间。
6. flex-basis/width设置具体的值优先级高于auto

#### 补充属性: flex

flex 属性是flex-grow, flex-shrink 和 flex-basis的简写;

我们已知:
 
 - flex-grow默认值为0 
 - flex-shrink默认值为1 
 - flex-basis默认值为auto

那么 flex 的默认值是 0 1 auto;

#### 补充属性: align-self属性

align-self 属性允许单个项目有与其他项目不一样的对齐方式，可覆盖 align-items 属性。默认值为auto，表示继承父元素的 align-items 属性，如果没有父元素，则等同于 stretch。

```
.item {
  align-self: auto | flex-start | flex-end | center | baseline | stretch;
}
```
![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015071016.png)


