//
//  NSString+kvo.h
//  KVODemo
//
//  Created by Jerod on 2020/11/6.
//

#import <Foundation/Foundation.h>


@interface NSString (kvo)

- (void)addObserver:(NSObject*)observer changedBlock:(void(^)(id newValue, id oldValue))block;

@end
