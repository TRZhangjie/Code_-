## App间的跳转

	- https://www.jianshu.com/p/0811ccd6a65d
	- http://www.cocoachina.com/ios/20140522/8514.html
	- https://www.jianshu.com/p/0ead88409212

### 目标

平常我们做iOS开发，会经常遇到打开其他的APP的功能。本篇文章讲的就是打开别人的APP的一些知识。我们的目标是：

	•	打开别人的APP
	•	让别人打开我们的APP
	•	版本大于等于iOS9的适配问题
	•	使用URL Schemes传递数据

----

### 让别人打开我们的APP

想要打开别人的APP或者让别人打开我们的APP，那就需要通过URL Schemes了。

#### 什么是URL Schemes？

URL Schemes 是苹果给出的用来跳转到系统应用或者跳转到别人的应用的一种机制。同时还可以在应用之间传数据。
 
 	URL Schemes 有两个单词：

	URL，我们都很清楚，http://www.apple.com 就是个 URL，我们也叫它链接或网址；
	
	Schemes，表示的是一个 URL 中的一个位置——最初始的位置，即 :// 之前的那段字符。比如 http://www.apple.com 这个网址的 Schemes是 http。 根据我们上面对 URL Schemes 的使用，我们可以很轻易地理解，在以本地应用为主的 iOS 上，我们可以像定位一个网页一样，用一种特殊的 URL 来定位一个应用甚至应用里某个具体的功能。而定位这个应用的，就应该是这个应用的 URL 的 Schemes 部分，也就是开头儿那部分。


 

