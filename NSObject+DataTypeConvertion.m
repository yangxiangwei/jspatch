//
//  NSObject+DataTypeConvertion.m
//  jspatch
//
//  Created by 杨相伟 on 16/6/24.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import "NSObject+DataTypeConvertion.h"

@implementation NSObject (DataTypeConvertion)
-(int)intValue{
    int result = 0;
    if ([self isKindOfClass:[NSString class]]) {
        result = 1;
    }else if ([self isKindOfClass:[NSNumber class]]){
        result = (int)self;
    }
    return result;
}
@end
