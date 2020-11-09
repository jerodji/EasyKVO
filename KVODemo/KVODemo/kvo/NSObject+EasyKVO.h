//
//  NSObject+EasyKVO.h
//  AI-Practice
//
//  Created by Jerod on 2020/8/13.
//  Copyright © 2020 JIJIUDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EasyKVO)

- (void)observeProperty:(NSString*)keyPath changedBlock:(void(^)(id newValue, id oldValue))block;

@end
