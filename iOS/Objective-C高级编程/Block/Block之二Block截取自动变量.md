## Blocks 的实现 （99-184）


---

### Block 截获自动变量值

---

本文主要讲解如何截获自动变量值。与之前一样，将截获自动变量值的源代码通过 clang 进行转换。


```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  const char *fmt;
  int val;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself){
	const char *fmt = _cself->fmt;
	int val = __cself->val;
	printf(fmt,val);
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


int main()
{
 	int dmy = 256;
 	int val = 10;
 	const char *fmt = "val = %d\n";
 	void (^blk)(void) = &__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA, fmt, val);
 	return 0;
}
```
这与前面转换的源代码稍有差异

 

