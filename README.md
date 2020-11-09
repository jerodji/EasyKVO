# EasyKVO
自定义KVO，支持监听多个属性，支持自动销毁



观察属性示例：

```objc
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) Person *person;
```



```objc
[self observeProperty:@"msg" changedBlock:^(id newValue, id oldValue) {
    NSLog(@" > msg : 旧值 %@, 新值 %@", oldValue, newValue);
}];
```



```objc
[self.person observeProperty:@"name" changedBlock:^(id newValue, id oldValue) {
    NSLog(@" > person.name : 旧值 %@, 新值 %@", oldValue, newValue);
}];
```



暂不支持下面这种方式：

```objc
[self observeProperty:@"person.name" changedBlock:^(id newValue, id oldValue) {
    NSLog(@" > person.name : 旧值 %@, 新值 %@", oldValue, newValue);
}];
```



自动释放，不需要手动移除观察者。

请不要和系统 KVO 一起使用, 由于 isa 指针的关系, 会造成冲突.
