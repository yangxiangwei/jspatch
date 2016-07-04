//
//  YLBArray.m
//  jspatch
//
//  Created by 杨相伟 on 16/7/1.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import "YLBArray.h"
#import "NSArray+YLBUtil.h"
@implementation YLBArray
-(id)objectAtIndex:(NSUInteger)index{
    return [self objectAtIndexCheck:index];
}
@end
