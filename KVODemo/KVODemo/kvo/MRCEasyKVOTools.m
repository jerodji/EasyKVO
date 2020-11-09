//
//  MRCEasyKVOTools.m
//  AI-Practice
//
//  Created by Jerod on 2020/8/13.
//  Copyright © 2020 vipPelian. All rights reserved.
//

#import "MRCEasyKVOTools.h"
#import <objc/objc.h>

@implementation MRCEasyKVOTools

+ (void)object_copyIndexedIvars:(id)obj toTarget:(id)targetObj size:(size_t)size
{
    uint64_t *s1 = object_getIndexedIvars(obj);
    uint64_t *s2 = object_getIndexedIvars(targetObj);
    memcpy(s2, s1, size);
}

@end
