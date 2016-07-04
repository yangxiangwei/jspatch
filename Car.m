//
//  Car.m
//  jspatch
//
//  Created by 杨相伟 on 16/6/24.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import "Car.h"

@implementation Car

-(instancetype)init{
    self = [super init];
    if (self) {
 
    }
    return self;
}

/*
 + (BOOL)resolveClassMethod:(SEL)sel {
 return NO;
 }
 */

// 如果上面返回 NO，就会进入这一步，用于指定备选响应此 SEL 的对象
// 如果返回 self 就会死循环
/*
 + (id)forwardingTargetForSelector:(SEL)aSelector {
 return nil;
 }
 */

// 指定方法签名，若返回 nil，则不会进入下一步，而是无法处理消息
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"intValue"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }else if ([NSStringFromSelector(aSelector) isEqualToString:@"floatValue"]){
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }else if ([NSStringFromSelector(aSelector) isEqualToString:@"doubleValue"]){
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }else if ([NSStringFromSelector(aSelector) isEqualToString:@"integerValue"]){
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }else if ([NSStringFromSelector(aSelector) isEqualToString:@"boolValue"]){
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

// 当实现了此方法后，-doesNotRecognizeSelector: 将不会被调用
// 如果要测试找不到方法，可以注释掉这一个方法
// 在这里进行消息转发
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"invocation + %@",anInvocation);
    // 我们还可以改变方法选择器
    [anInvocation setSelector:@selector(noMethod)]; 
    // 改变方法选择器后，还需要指定是哪个对象的方法
    [anInvocation invokeWithTarget:self];
}

/*
 + (void)doesNotRecognizeSelector:(SEL)aSelector {
 NSLog(@"无法处理消息：%@", NSStringFromSelector(aSelector));
 }
 */

- (void)noMethod{
    NSLog(@"noMethod");
}

@end
