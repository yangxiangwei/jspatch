//
//  YLBTestWebViewController.h
//  WhiteDragon
//
//  Created by 杨相伟 on 16/6/23.
//  Copyright © 2016年 YongLibao. All rights reserved.
//

 
@interface YLBTestWebViewController : UIViewController
/**
 必须设置 jsMethodType, jsNaviType(从本地取文件还是取网络链接) ,jsUrl(文件名或http链接)
 */
@property(nonatomic,strong)YLBJSScheme *evScheme;
@property(nonatomic, assign) BOOL isRefresh;
@end
