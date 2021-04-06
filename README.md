iOS自定义 KVO，支持多属性监听，支持自动释放。

## 使用系统 KVO 监听属性
先来回顾下系统 KVO 是如何使用的：
```objc
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) Person *person;
```
1、添加观察者
```objc
[self addObserver:self forKeyPath:@"msg" options:NSKeyValueObservingOptionNew context:nil];
[self addObserver:self forKeyPath:@"person.name" options:NSKeyValueObservingOptionNew context:nil];
```
2、处理回调

```objc
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"msg"]) {
        NSLog(@"msg 新值 : %@", self.msg);
    }
    if ([keyPath isEqualToString:@"person.name"]) {
        NSLog(@"person.name 新值 : %@", self.person.name);
    }
}
```
3、手动移除观察者
```objc
[self removeObserver:self forKeyPath:@"msg"];
[self removeObserver:self forKeyPath:@"person.name"];
```
系统 KVO 需要写一大堆代码，需要手动释放，需要我们自己判断监听是哪个属性，我们通过自定义 KVO 自动处理这些流程。

## 使用自定义 EasyKVO 监听属性
如果 KVO 能够以下面这种方式调用，使用起来无疑会方便很多：

监听 msg 属性
```objc
[self observeProperty:@"msg" changedBlock:^(id newValue, id oldValue) {
    NSLog(@" > msg : 旧值 %@, 新值 %@", oldValue, newValue);
}];
```

监听 person.name 属性
```objc
[self.person observeProperty:@"name" changedBlock:^(id newValue, id oldValue) {
    NSLog(@" > person.name : 旧值 %@, 新值 %@", oldValue, newValue);
}];
```
所以，我们希望自定义 kvo 不需要手动释放，不需要再回调函数中添加很多 if 判断来区别不同属性，使用简单。


## 自定义 KVO 主要原理简介
#### 1、创建自定义派生类
创建中间类，挂载 setter 方法和 dealloc 方法：
```objc
NSString *oldClassName = NSStringFromClass([self class]);
NSString *pairClassName = [EASY_KVO_PREFIX stringByAppendingString:oldClassName];
Class pairClass = NSClassFromString(pairClassName);
pairClass = objc_allocateClassPair([self class], pairClassName.UTF8String, 0x68);
objc_registerClassPair(pairClass);
```

#### 2、添加自动释放的方法
如果没有dealloc，添加 dealloc 方法；如果有则交换 dealloc 实现。
```objc
if (!_containSelector(self, @"dealloc")) {
    SEL deallocSEL = NSSelectorFromString(@"dealloc");
    Method deallocMethod = class_getInstanceMethod([self class], deallocSEL);
    const char * deallocType = method_getTypeEncoding(deallocMethod);
    class_addMethod(pairClass, deallocSEL, (IMP)easy_dealloc, deallocType);
} else {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method m1 = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
        Method m2 = class_getInstanceMethod([self class], @selector(selEasyDealloc));
        method_exchangeImplementations(m1, m2);
    });
}
```
dealloc实现，这里我采用了遍历所有属性变量并置空的方法来避免多属性监听导致属性无法全部释放的问题。
```objc
- (void)selEasyDealloc {
    __easy_dealloc(self);
    [self selEasyDealloc];
}

void easy_dealloc(id self, SEL _cmd) {
    __easy_dealloc(self);
}

void __easy_dealloc(id self) {
    NSLog(@"-- easy_dealloc %@", self);
    NSMutableDictionary *tips = _globalTipsMap();
    [tips removeAllObjects];
    Class oldClass = [self class];
    object_setClass(self, oldClass); /* 改回 isa 指针 */
    
    /* 释放所有属性和变量 */
    unsigned int count = 0;
    Ivar * ivarList = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        const char * name = ivar_getName(ivar);
        NSString * KEY = [NSString stringWithUTF8String:name];
        [self setValue:nil forKey:KEY];
        //NSLog(@"prop %@ released", KEY);
    }   
}
```

#### 3、重写 setter 方法
```objc
SEL setSel = NSSelectorFromString(_setterForProperty(keyPath));
Method setMethod = class_getInstanceMethod([self class], setSel);
const char * setType = method_getTypeEncoding(setMethod);
class_addMethod(pairClass, setSel, (IMP)easy_setter, setType);
```
setter 实现，重写 setter 方法，在此不仅要实现本来的 setter，也要调用 block 回调出去。
```objc
void easy_setter(id self, SEL _cmd, id newValue) {
    NSString *setterName = NSStringFromSelector(_cmd);
    if (setterName.length < 4) return;
    
    NSString *format = [setterName substringWithRange:NSMakeRange(3, setterName.length - 4)];
    NSString *keyPath = [format stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[format substringToIndex:1] lowercaseString]];
    if (keyPath.length < 1) return;
    
    id oldValue = [self valueForKeyPath:keyPath];
    if (![oldValue isEqual:newValue]) {
        //调用父类setter
        struct objc_super superClass = {
            .receiver = self,
            .super_class = class_getSuperclass(object_getClass(self))
        };
        void (* msgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;
        msgSendSuper(&superClass, _cmd, newValue);
    }
    
    // 回调 block
    NSString *KEY = [NSString stringWithFormat:@"_%@_%@_block", NSStringFromClass(object_getClass(self)), keyPath];
    NSMutableDictionary * tipMap = _globalTipsMap();
    EasyKVOChangedBlock block = (EasyKVOChangedBlock)[tipMap objectForKey:KEY];
    if (block) {
        block(newValue, oldValue);
    }
}
```

#### 4、修改 isa 指针
将 isa 指镇指向自定义派生类
```objc
object_setClass(self, pairClass);
```

#### 5、保存 block 回调信息
保存 block 信息，以遍 setter 时回调
```objc
NSString * KEY = [NSString stringWithFormat:@"_%@_%@_block", NSStringFromClass(pairClass), keyPath];
NSMutableDictionary *tips = _globalTipsMap();
if (block) {
    [tips setObject:[block copy] forKey:KEY];
} else {
    [tips setObject:[^{} copy] forKey:KEY];
}
```


## 注意事项
1. 暂不支持下面的监听方式：
```objc
[self observeProperty:@"person.name" changedBlock:^(id newValue, id oldValue) {
   NSLog(@" > person.name : 旧值 %@, 新值 %@", oldValue, newValue);
}];
```

2. 请不要和系统 KVO 一起使用, 由于 isa 指针的关系, 会造成冲突. 


## Demo
demo地址：
[https://github.com/jerodji/EasyKVO](https://github.com/jerodji/EasyKVO)
