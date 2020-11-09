//
//  EasyKVO.m
//  KVODemo
//
//  Created by Jerod on 2020/11/5.
//

#import "EasyKVO.h"
#import <objc/message.h>

@implementation EasyKVO
/*
typedef void(^_EasyKVOChangedBlock)(id newValue, id oldValue);

/// NSKVONotifying_
static NSString * const EASY_KVO_PREFIX = @"_EasyKVO_";

static NSString * const EASY_KVO_MAP = @"_EasyKVOTipsDic";



- (void)observe:(NSObject*)observer keyPath:(NSString*)keyPath changedBlock:(void(^)(id newValue, id oldValue))block
{
    
}


#pragma mark - easy private

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
    _EasyKVOChangedBlock block = (_EasyKVOChangedBlock)[easy_tipsMap(self, _cmd) objectForKey:KEY];
    if (block) {
        block(newValue, oldValue);
    }
}

void easy_dealloc(id self, SEL _cmd) {
    NSLog(@"--- easy_dealloc");
    
    // 调用父类 dealloc
//    struct objc_super superClass = {
//        .receiver = self,
//        .super_class = class_getSuperclass(object_getClass(self))
//    };
//    void (* msgSendSuper)(void *, SEL) = (void *)objc_msgSendSuper;
//    msgSendSuper(&superClass, _cmd);
    
    
    NSMutableDictionary *tips = easy_tipsMap(self, _cmd);
    [tips removeAllObjects];
    

    //改回 isa 指针
    Class oldClass = [self class];
    object_setClass(self, oldClass);
    
//    void (* msgSend)(void *, SEL) = (void *)objc_msgSend;
//    msgSend(self, _cmd);
    
    NSLog(@"--- end");
    return;
}

Class easy_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

NSMutableDictionary *easy_tipsMap(id self, SEL _cmd) {
    NSMutableDictionary * _tipsDic = objc_getAssociatedObject(self, &EASY_KVO_MAP);
    if (!_tipsDic) {
        _tipsDic = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &EASY_KVO_MAP, _tipsDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _tipsDic;
}

// MARK: -

- (BOOL)_containSelector:(SEL)selector {
    Class cls = object_getClass(self);
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    for (int i=0; i<count; i++) {
        SEL sel = method_getName(methods[i]);
        if (selector == sel) {
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
*/

@end
