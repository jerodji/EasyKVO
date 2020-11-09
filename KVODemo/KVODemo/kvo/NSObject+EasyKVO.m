//
//  NSObject+EasyKVO.m
//  AI-Practice
//
//  Created by Jerod on 2020/8/13.
//  Copyright © 2020 vipPelian. All rights reserved.
//

#import "NSObject+EasyKVO.h"
#import <objc/message.h>

@implementation NSObject (EasyKVO)

typedef void(^EasyKVOChangedBlock)(id newValue, id oldValue);

static NSString * const EASY_KVO_PREFIX = @"EasyKVONotifying_";
static NSString * const EASY_KVO_MAP = @"EasyKVOTipsMap";
static NSString * const EASY_KVO_OBSERVED_OBJECTS = @"EasyKVOObservedObjects";

void __easy_dealloc(id self);
//void __observed_dealloc(void);

void easy_setter(id self, SEL _cmd, id newValue);
Class easy_class(id self, SEL _cmd);
void easy_dealloc(id self, SEL _cmd);
//void observed_dealloc(id self, SEL _cmd);

BOOL _containSelector(NSObject *objc, NSString *selector);
NSString* _setterForProperty(NSString *keyPath);

NSMutableDictionary *_globalTipsMap(void);
NSMutableArray *_globalObservedObjects(void);




//- (void)observe:(NSObject*)observedObjc forKeyPath:(NSString*)keyPath changedBlock:(void(^)(id newValue, id oldValue))block {
//
//    if (!observedObjc || ![observedObjc isKindOfClass:[NSObject class]]) {
//        NSLog(@"KVO 无效的被观察者");
//        return;
//    }
//    if (keyPath.length < 1) {
//        NSLog(@"KVO 无效的观察属性");
//        return;
//    }
//
//    NSMutableArray * observedList = _globalObservedObjects();
//    if (self != observedObjc && ![observedList containsObject:self]) {
//        /* 观察者销毁 */
//        if (_containSelector(self, @"dealloc")) {
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
//                Method m1 = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
//                Method m2 = class_getInstanceMethod([self class], @selector(selObservedDealloc));
//                method_exchangeImplementations(m1, m2);
//            });
//        } else {
//            SEL deallocSEL = NSSelectorFromString(@"dealloc");
//            Method deallocMethod = class_getInstanceMethod([self class], deallocSEL);
//            const char * deallocType = method_getTypeEncoding(deallocMethod);
//            class_addMethod([self class], deallocSEL, (IMP)observed_dealloc, deallocType);
//        }
//
//
//        if (![observedList containsObject:observedObjc]) {
//            [observedList addObject:observedObjc];
//        }
//    }
//
//    [observedObjc watchKeyPath:keyPath changedBlock:block];
//}

- (void)watchKeyPath:(NSString*)keyPath changedBlock:(void(^)(id newValue, id oldValue))block
{
    if (keyPath.length < 1) {
        return;
    }

    if ([keyPath containsString:@"."]) {
        NSString *errmsg = [NSString stringWithFormat:@"KVO 暂不支持路径模式 %@", keyPath];
        NSLog(@"%@", errmsg);
        return;
    }
    
    NSString *oldClassName = NSStringFromClass([self class]);
    NSString *pairClassName = [EASY_KVO_PREFIX stringByAppendingString:oldClassName];
    Class pairClass = NSClassFromString(pairClassName);
    
    if (!pairClass) {
        /* 创建派生类 */
        pairClass = objc_allocateClassPair([self class], pairClassName.UTF8String, 0x68);
        objc_registerClassPair(pairClass);
        
        /* 添加 class 方法, 重写 class */
        SEL classSEL = NSSelectorFromString(@"class");
        Method classMethod = class_getInstanceMethod([self class], @selector(class));
        const char *classType = method_getTypeEncoding(classMethod);
        class_addMethod(pairClass, classSEL, (IMP)easy_class, classType);
        
        /* 被观察者自动销毁 */
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
        
    }
    
    /* setter */
    SEL setSel = NSSelectorFromString(_setterForProperty(keyPath));
    Method setMethod = class_getInstanceMethod([self class], setSel);
    const char * setType = method_getTypeEncoding(setMethod);
    class_addMethod(pairClass, setSel, (IMP)easy_setter, setType);
    
    /* 修改 isa 指针指向 */
    object_setClass(self, pairClass);
    
    /* 保存 block 信息, 用于执行回调 */
    NSString * KEY = [NSString stringWithFormat:@"_%@_%@_block", NSStringFromClass(pairClass), keyPath];
    NSMutableDictionary *tips = _globalTipsMap();
    if (block) {
        [tips setObject:[block copy] forKey:KEY];
    } else {
        [tips setObject:[^{} copy] forKey:KEY];
    }
    
}


//- (void)removeObserverForProperty:(NSString*)keyPath
//{
//    NSString *oldClassName = NSStringFromClass([self class]);
//    NSString *pairClassName = [EASY_KVO_PREFIX stringByAppendingString:oldClassName];
//    Class pairClass = NSClassFromString(pairClassName);
//    NSString * KEY = [NSString stringWithFormat:@"_%@_%@_block", NSStringFromClass(pairClass), keyPath];
//
//    NSMutableDictionary *tips = _globalTipsMap();
//    if ([tips.allKeys containsObject:KEY]) {
//        [tips removeObjectForKey:KEY];
//    }
//    NSLog(@"%@", tips);
//}
//
//- (void)removeObserverForAllPropertys {
//    NSMutableDictionary *tips = _globalTipsMap();
//    [tips removeAllObjects];
//    NSLog(@"%@", tips);
//}


#pragma mark -
#pragma mark Easy IMP

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

Class easy_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

void easy_dealloc(id self, SEL _cmd) {
    __easy_dealloc(self);
}

//void observed_dealloc(id self, SEL _cmd) {
//    __observed_dealloc();
//}

#pragma mark- Functions

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
//        NSLog(@"prop %@ released", KEY);
    }
    
}

//void __observed_dealloc() {
//    NSLog(@"*** observed_dealloc ");
//    NSMutableDictionary *tips = _globalTipsMap();
//    [tips removeAllObjects];
//    NSMutableArray * observedList = _globalObservedObjects();
//    for (NSObject *obj in observedList) {
//        Class oldClass = [obj class];
//        object_setClass(obj, oldClass); /* 改回 isa 指针 */
//        [observedList removeObject:obj];
//    }
//}

- (void)selEasyDealloc {
    __easy_dealloc(self);
    [self selEasyDealloc];
}

//- (void)selObservedDealloc {
//    __observed_dealloc();
//    [self selObservedDealloc];
//}

NSMutableDictionary *_globalTipsMap() {
    NSMutableDictionary * _tipsDic = objc_getAssociatedObject(EASY_KVO_MAP, &EASY_KVO_MAP);
    if (!_tipsDic) {
        _tipsDic = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(EASY_KVO_MAP, &EASY_KVO_MAP, _tipsDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _tipsDic;
}

NSMutableArray *_globalObservedObjects() {
    NSMutableArray * list = objc_getAssociatedObject(EASY_KVO_OBSERVED_OBJECTS, &EASY_KVO_OBSERVED_OBJECTS);
    if (!list) {
        list = [NSMutableArray array];
        objc_setAssociatedObject(EASY_KVO_OBSERVED_OBJECTS, &EASY_KVO_OBSERVED_OBJECTS, list, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return list;
}

BOOL _containSelector(NSObject *objc, NSString *selector) {
    Class cls = object_getClass(objc);
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    for (int i=0; i<count; i++) {
        SEL sel = method_getName(methods[i]);
        NSString * str = NSStringFromSelector(sel);
        if ([selector isEqualToString:str]) {
            free(methods);
            return YES;
        }
    }
    free(methods);
    return NO;
}

NSString* _setterForProperty(NSString *keyPath) {
    NSString *format = [keyPath stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[keyPath substringToIndex:1] uppercaseString]];
    NSString *setterName = [NSString stringWithFormat:@"set%@:", format];
    return setterName;
}

@end
