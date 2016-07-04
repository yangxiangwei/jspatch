//
//  TestObject.m
//  jspatch
//
//  Created by 杨相伟 on 16/6/22.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject

- (id)init
{
    self = [super init];
    blk_ = ^{NSLog(@"self = %@", self);};
    return self;
}
- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
