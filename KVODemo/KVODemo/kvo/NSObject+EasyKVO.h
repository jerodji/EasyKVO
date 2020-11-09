//
//  NSObject+EasyKVO.h
//  AI-Practice
//
//  Created by Jerod on 2020/8/13.
//  Copyright © 2020 vipPelian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EasyKVO)

//- (void)observe:(NSObject*)object forKeyPath:(NSString*)keyPath changedBlock:(void(^)(id newValue, id oldValue))block;

- (void)watchKeyPath:(NSString*)keyPath changedBlock:(void(^)(id newValue, id oldValue))block;

@end
