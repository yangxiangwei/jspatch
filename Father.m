//
//  Father.m
//  jspatch
//
//  Created by 杨相伟 on 16/7/1.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import "Father.h"

@interface Father ()
{
    NSString *_name;
}

- (void)sayHello;

@end

@implementation Father

- (id)init
{
    if (self = [super init]) {
        _name = @"wengzilin";
        [_name copy];
        self.age = 27;
    }
    return self;
}
- (void)dealloc
{
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@, age:%d", _name, self.age];
}
- (void)sayHello
{
    NSLog(@"%@ says hello to you!", _name);
}
- (void)sayGoodbay
{
    NSLog(@"%@ says goodbya to you!", _name);
}
@end