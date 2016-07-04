//
//  NSArray+YLBUtil.m
//  WhiteDragon
//
//  Created by rxj on 16/7/1.
//  Copyright © 2016年 YongLibao. All rights reserved.
//

#import "NSArray+YLBUtil.h"
#import <objc/runtime.h>
@implementation NSArray (YLBUtil)

+(void)load{
    Method otherMethod = class_getClassMethod(self, @selector(objectAtIndexCheck:));
    Method method = class_getClassMethod(self, @selector(objectAtIndex:));
    method_exchangeImplementations(otherMethod, method);
}


- (id)objectAtIndexCheck:(NSUInteger)index {
    if (index < self.count) {
        return self[index];
    }
    return nil;
}

@end
