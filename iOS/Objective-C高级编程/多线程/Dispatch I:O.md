### 多线程之 Dispatch I/O

 ---

来自与《Objective-C 高级编程》一书。

大家可能想过，在读取较大文件时，如果将文件分成合适的大小并使用 Global Dispatch Queue  并列读取的话，应该会比一般的读取速度快不少。

现今的 输入/输入 硬件已经可以做到一次使用多个线程更快地并列读取了。能实现这一功能的就是 Dispatch I/O 和 Dispath Data。

通过 Dispatch I/O 读写文件时，使用  Global Dispatch Queue 将 1 个文件按某个大小 read/write。

 
```
dispatch_async(queue, ^{ /* 读取  0     ～ 8080  字节*/ });
dispatch_async(queue, ^{ /* 读取  8081  ～ 16383 字节*/ });
dispatch_async(queue, ^{ /* 读取  16384 ～ 24575 字节*/ });
dispatch_async(queue, ^{ /* 读取  24576 ～ 32767 字节*/ });
dispatch_async(queue, ^{ /* 读取  32768 ～ 40959 字节*/ });
dispatch_async(queue, ^{ /* 读取  40960 ～ 49191 字节*/ });
dispatch_async(queue, ^{ /* 读取  49192 ～ 57343 字节*/ });
dispatch_async(queue, ^{ /* 读取  57344 ～ 65535 字节*/ });
```

可以像上面这样，将文件分割为一块一块地进行读取处理。分割读取的数据通过使用 Dispatch Data 可更为简单地进行结合和分割。


```
pipe_q = dispatch_queue_create("PipeQ",NULL);
pipe_channel = dispatch_io_create(DISPATCH_IO_STREAM,fd,pipe_q,^(int err){
   close(fd);
});

*out_fd = fdpair[i];

dispatch_io_set_low_water(pipe_channel,SIZE_MAX);

dispatch_io_read(pipe_channel,0,SIZE_MAX,pipe_q, ^(bool done,dispatch_data_t pipe data,int err){
   if(err == 0)
     {
       size_t len = dispatch_data_get_size(pipe data);
       if(len > 0)
       {
          const char *bytes = NULL;
          char *encoded;

          dispatch_data_t md = dispatch_data_create_map(pipe data,(const void **)&bytes,&len);
          asl_set((aslmsg)merged_msg,ASL_KEY_AUX_DATA,encoded);
          free(encoded);
          _asl_send_message(NULL,merged_msg,-1,NULL);
          asl_msg_release(merged_msg);
          dispatch_release(md);
       }
      }

      if(done)
      {
         dispatch_semaphore_signal(sem);
         dispatch_release(pipe_channel);
         dispatch_release(pipe_q);
      }
});
```

---

### dispatch_io_create 函数

---
 
上面代码中，通过 dispatch_io_create 函数创建一个 I/O 通道。我们找到 /user/include/dispatch/io.h  中的 dispatch_io_create 。

```
dispatch_io_create(
	dispatch_io_type_t type, 
	dispatch_fd_t fd,
	dispatch_queue_t queue,
	void (^cleanup_handler)(int error));
```

我们来看第一个参数 dispatch_io_type_t，点击进去

```
#define DISPATCH_IO_STREAM 0
#define DISPATCH_IO_RANDOM 1

typedef unsigned long dispatch_io_type_t;
```

DISPATCH_IO_STREAM  stream 流; 代表的是读写操作按顺序依次顺序进行。在读或写开始时，操作总是在文件指针位置读或写数据。读和写操作可以在同一个信道上同时进行。

DISPATCH_IO_RANDOM random 随机; 代表的是随机访问文件。读和写操作可以同时执行这种类型的通道,文件描述符必须是可寻址的。


```
/*!
 * @typedef dispatch_fd_t
 * Native file descriptor type for the platform.
 */
typedef int dispatch_fd_t;
```
文件描述类型


```
dispatch_queue_t 
```

这个应该就非常熟悉了，需要传入一个操作队列。

```
void (^cleanup_handler)(int error));
```

异常回调的一个 Block。

io.h 文件中还有其他的 API ,大家有兴趣也可以去看看。比如: dispatch_io_create_with_path 函数 和 dispatch_io_create_with_io 函数。 

---

### 设置一次读取的大小以及时间间隔

---

通过函数设定一次读取的大小(分割大小)

设置读取大小 io.h 文件分别暴露了两个函数

1. dispatch_io_set_low_water 设置一次读取的最小字节

```
void
dispatch_io_set_low_water(dispatch_io_t channel, size_t low_water);
```

2. dispatch_io_set_high_water 设置一次读取的最大字节

```
void
dispatch_io_set_high_water(dispatch_io_t channel, size_t high_water);
```

3. dispatch_io_set_interval 设置调用通道的I / O处理程序的间隔（以纳秒为单位） 

```
void
dispatch_io_set_interval(dispatch_io_t channel,
	uint64_t interval,
	dispatch_io_interval_flags_t flags);
```

----

### 读写操作

---

#### 指定信道调度异步 读 操作


```
void
dispatch_io_read(dispatch_io_t channel,
	off_t offset,
	size_t length,
	dispatch_queue_t queue,
	dispatch_io_handler_t io_handler);
```

dispatch_io_read 函数使用 Global Dispatch Queue 开始并列读取,每当各个分割的文件块读取结束时,将含有 Dispatch Data 传递给 dispatch 函数指定的读取结束时回调用的 Block。

里面的几个 channel 代入创建的 dispatch_io_t 即可，size_t 从通道读取的字节数。像上述苹果实例代码中指定的 SIZE_MAX 继续读取数据直达到一个EOF。还有一个值得注意的是 offset 这个参数，对于DISPATCH_IO_RANDOM 类型的通道, 此参数指定要读取的信道的偏移量。 对于DISPATCH_IO_STREAM 类型的通道, 此参数将被忽略，数据从当前位置读取。
 
#### 指定的信道调度异步 写 操作

```
void
dispatch_io_write(dispatch_io_t channel,
	off_t offset,
	dispatch_data_t data,
	dispatch_queue_t queue,
	dispatch_io_handler_t io_handler);
```

