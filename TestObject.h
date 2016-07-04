//
//  TestObject.h
//  jspatch
//
//  Created by 杨相伟 on 16/6/22.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^blk_t)(void);
@interface TestObject : NSObject{
     blk_t blk_;
}

@end
