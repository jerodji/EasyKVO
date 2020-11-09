//
//  MRCEasyKVOTools.h
//  AI-Practice
//
//  Created by Jerod on 2020/8/13.
//  Copyright © 2020 JIJIUDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRCEasyKVOTools : NSObject

+ (void)object_copyIndexedIvars:(id)obj toTarget:(id)targetObj size:(size_t)size;

@end
