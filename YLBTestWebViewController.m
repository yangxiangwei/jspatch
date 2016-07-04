//
//  YLBTestWebViewController.m
//  WhiteDragon
//
//  Created by 杨相伟 on 16/6/23.
//  Copyright © 2016年 YongLibao. All rights reserved.
//

#import "YLBTestWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "YLBCSNetAccessor.h"
#import "UIWebView+AFNetworking.h"
#import "YLBJSParamAdapter.h"
#import "YLBResourceAssistant.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "TFHpple.h"
#import "ShareSheet.h"
#import <ShareSDK/ShareSDK.h>
#import "NSString+URLConvert.h"
#import "YLBLoginVC.h"
#import "YLBWebView.h"
@interface YLBTestWebViewController()<YLBWebViewDelegate,UIAlertViewDelegate>
@property(nonatomic ,strong)YLBWebView *evWebView;
@property(nonatomic, strong) NSString *jsPort;

@end

@implementation YLBTestWebViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    _evWebView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //设置导航颜色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_blue"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterLoginReloadData) name:kloginSuccess object:nil];
    
    [self addNaviView];
    
    [self addWebView];
    
    [self addMJhead];
    
    [self loadDataWithScheme:self.evScheme];
}


- (void)addMJhead {
    
    if (self.isRefresh) {
        __weak typeof(self) wself = self;
        [self.evWebView.scrollView addLegendHeaderWithRefreshingBlock:^{
            __strong typeof(self) strongSelf = wself;
            [strongSelf loadDataWithScheme:strongSelf.evScheme];
        }];
    }
    
}



-(void)addWebView{
    self.evWebView = [[YLBWebView alloc] initWithFrame:CGRectMake(0, 0, SWidth, SHeight - 64)];
    self.evWebView.delegate = self;
    [self.view addSubview:self.evWebView];
}

//设置页面标题和右上角按钮
-(void)addNaviView{
    NSDictionary *headerDic = [self.evScheme.jsParamDic objectForKey:@"UIHeader"];
    if (headerDic) {
        //标题
        NSString *titleString = [headerDic objectForKey:@"title"];
        if (titleString.length >0) {
            self.title = titleString;
        }
        
        //按钮
        NSDictionary *rightDic = [headerDic objectForKey:@"right"];
        if (rightDic && [rightDic allKeys].count >0) {
            if ([[rightDic objectForKey:@"type"] isEqualToString:@"word"]) {//按钮为文字
                if ([rightDic objectForKey:@"content"]) {
                    [self setupCustomRightWithtitle:[rightDic objectForKey:@"content"] target:self action:@selector(rightAction:)];
                }
            }else if ([[rightDic objectForKey:@"type"] isEqualToString:@"icon"]){//按钮图片需要下载
                if ([rightDic objectForKey:@"content"]) {
                    UIImageView *tmpImageView = [[UIImageView alloc] init];
                    [tmpImageView sd_setImageWithURL:[NSURL URLWithString:[rightDic objectForKey:@"content"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [self setupCustomRightWithImage:image target:self action:@selector(rightAction:)];
                    }];
                }
            }else if ([[rightDic objectForKey:@"type"] isEqualToString:kIcon]){//按钮图片为本地图片
                if ([rightDic objectForKey:@"content"]) {
                    [self setupCustomRightWithImage:[UIImage imageNamed:[rightDic objectForKey:@"content"]] target:self action:@selector(rightAction:)];
                }
            } else if ([[rightDic objectForKey:@"type"] isEqualToString:@"share"]) {
                [self setupCustomRightWithtitle:@"分享" target:self action:@selector(rightAction:)];
            }
        }
    }
}


- (NSURLRequest *)getMrequestWithurl:(NSString *)urlStr {
    // 获取带有head（set-cookie）的request
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    if ([YLBDataManager shareDataManager].headers) {
        NSString *cookie = [YLBDataManager shareDataManager].headers[@"Set-Cookie"];
        [mRequest addValue:cookie forHTTPHeaderField:@"Set-Cookie"];
    }
    return mRequest;
}

-(void)loadDataWithScheme:(YLBJSScheme *)scheme{
    switch (scheme.jsNaviType) {
        case PageNaviTypeToWebViewWithHttp:{
            if (scheme.jsUrl.length >0) {
                YLBUserInfo *userInfo = [[YLBDataManager shareDataManager] getUserInfoFromLocation];
                long uid = 0;
                if (userInfo) {
                    uid = userInfo.uId;
                }
                NSString *UUid = @"";
                if ([OpenUDID value]) {
                    UUid = [OpenUDID value];
                }
                NSDictionary *parameters = @{@"u": UUid,
                                             @"i":@(uid),
                                             };
                parameters = [Tool getParameters:parameters withUrl:nil];
                NSString *parametersStr = parameters[@"i"];
                parametersStr = [parametersStr URLDecodedString];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@%@i=%@&isApp=ios",scheme.jsUrl,[scheme.jsUrl componentsSeparatedByString:@"?"].count > 1?@"&" : @"?",parametersStr];
                NSURLRequest *request = [self getMrequestWithurl:urlStr];
                
                [self.evWebView loadRequest:request];
            }
        }
            
            break;
        case PageNaviTypeToWebViewWithLocal:{
            NSString *resourcePath = RAWebPath_HtmlLocalPath(Location_HTML);
            NSString *filePath  = [resourcePath stringByAppendingPathComponent:scheme.jsUrl];
            
            NSURL *url ;
            if (IsIOS9) { 
                url = [NSURL fileURLWithPath:filePath];
                filePath = [filePath stringByAppendingString:@"?isApp=ios"];
                NSString *partURL = [kServerIP stringByAppendingString:kServerPort];
                YLBUserInfo *userInfo = [[YLBDataManager shareDataManager] getUserInfoFromLocation];
                long uid = 0;
                if (userInfo) {
                    uid = userInfo.uId;
                }
                NSString *UUid = @"";
                if ([OpenUDID value]) {
                    UUid = [OpenUDID value];
                }
                NSDictionary *parameters = @{@"u": UUid,
                                             @"i":@(uid),
                                             };
                parameters = [Tool getParameters:parameters withUrl:nil];
                NSString *parametersStr = parameters[@"i"];
                parametersStr = [parametersStr URLDecodedString];
                
                parametersStr = [parametersStr stringByReplacingOccurrencesOfString:@"/" withString:@"a"];
                filePath = [NSString stringWithFormat:@"%@&origin=%@&i=%@",filePath,partURL,parametersStr];
                
                [self.evWebView loadFileURL:url allowingReadAccessToURL:[NSURL fileURLWithPath:filePath]];
            }else{
                filePath = [filePath stringByAppendingString:@"?isApp=ios"];
                NSString *partURL = [kServerIP stringByAppendingString:kServerPort];
                
                YLBUserInfo *userInfo = [[YLBDataManager shareDataManager] getUserInfoFromLocation];
                long uid = 0;
                if (userInfo) {
                    uid = userInfo.uId;
                }
                NSString *UUid = @"";
                if ([OpenUDID value]) {
                    UUid = [OpenUDID value];
                }
                NSDictionary *parameters = @{@"u": UUid,
                                             @"i":@(uid),
                                             };
                parameters = [Tool getParameters:parameters withUrl:nil];
                NSString *parametersStr = parameters[@"i"];
                parametersStr = [parametersStr URLDecodedString];
                filePath = [NSString stringWithFormat:@"%@&origin=%@&i=%@",filePath,partURL,parametersStr];
                url = [NSURL URLWithString:filePath];
                [self.evWebView loadRequest:[NSURLRequest requestWithURL:url]];
            }
        }
            
            break;
            
        default:
            break;
    }
}


-(void)epWebView:(YLBWebView *)webView didFinishLoadURL:(NSURL *)url{
    [YLBLoadingHUD hide];
    [self.evWebView.scrollView.header endRefreshing];
    
    [self.evWebView.wkWebView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable content, NSError * _Nullable error) {
        // 分享标题
        DLog(@"evaluateJavaScript:%@",content);
    }];
    [self.evWebView.wkWebView evaluateJavaScript:@"document.documentElement.innerText" completionHandler:^(id _Nullable content, NSError * _Nullable error) {
        // 分享标题
        DLog(@"evaluateJavaScript:%@",content);
    }];
}

-(void)epWebViewDidStartLoad:(YLBWebView *)webView{
    [YLBLoadingHUD showInView:self.view];
    [self.evWebView.scrollView.header endRefreshing];
}

-(void)epWebView:(YLBWebView *)webView didFailLoadURL:(NSURL *)url error:(NSError *)error{
    [YLBLoadingHUD hide];
}

-(void)epWebView:(YLBWebView *)webView shouldStartLoadWithURL:(NSURL *)url{
    NSString *urlStr = [url absoluteString];
    urlStr = [urlStr stringByRemovingPercentEncoding];
    DLog(@"%@",urlStr);
    //解析scheme
    YLBJSScheme *scheme = [[YLBJSScheme alloc] initWithUrl:webView.request.URL];
    self.jsPort = scheme.jsPort;
    //处理scheme = rainbow
    if ([kScheme isEqualToString:scheme.jsSchemeName]) {
        
        [self execScheme:scheme];
    }

}

-(void)rightAction:(UIButton *)sender{
    YLBJSScheme *scheme = [[YLBJSScheme alloc] initWithUrl:nil];
    
    //分享
    if ([[self.evScheme.jsParamDic valueForKeyPath:@"UIHeader.right.type"] isEqualToString:@"share"]) {
        NSDictionary *shareDic = [self.evScheme.jsParamDic valueForKeyPath:@"UIHeader.right.shareAction"];
        if ([shareDic isKindOfClass:[NSDictionary class]]) {
            [self shareFromJSWithShareDic:shareDic];
        }
    } else {
        NSDictionary *rightDic = [self.evScheme.jsParamDic valueForKeyPath:@"UIHeader.right.action"];
        scheme.jsParamDic = rightDic;
        scheme.jsMethodType = MethodTypeOfForward;
        if ([rightDic isKindOfClass:[NSDictionary class]] && [rightDic allKeys].count >0) {
            NSString *url = [rightDic objectForKey:kToPage];
            if (url.length >0) {
                scheme.jsUrl = url;
            }
            
            NSString *type = [rightDic objectForKey:kNaviType];
            if (type.length >0) {
                if ([type isEqualToString:kH5Web]) {
                    scheme.jsNaviType = PageNaviTypeToWebViewWithHttp;
                }else if ([type isEqualToString:kNative]){
                    scheme.jsNaviType = PageNaviTypeToNative;
                }else if ([type isEqualToString:kH5Native]){
                    scheme.jsNaviType = PageNaviTypeToWebViewWithLocal;
                }
            }
            
            [self execScheme:scheme];
        }
    }
}



-(void)execScheme:(YLBJSScheme *)scheme{
    switch (scheme.jsMethodType) {
        case MethodTypeOfHttpRequest:{
            __weak typeof(self) wself = self;
            //拼接发起Http请求相关参数
            [YLBJSParamAdapter efExecHttpByScheme:scheme httpParam:^(NSDictionary *paramDic) {
                
                //执行请求
                [YLBCSNetAccessor sendAsyncForJSFormUrl:[NSString stringWithFormat:@"%@",scheme.jsMethodName] parameters:paramDic finished:^(EnumServerStatus status, NSObject *object) {
                    @try {
                        //回调h5
                        NSString *callBackString = [NSString stringWithFormat:@"RainbowBridge.onComplete('%@','%@')",scheme.jsPort,object];
                        DLog(@"%@",callBackString);
                        __strong typeof(self) strongSelf = wself;
                        if (self.evWebView.webView) {
                            NSString *context=[strongSelf.evWebView.webView stringByEvaluatingJavaScriptFromString:callBackString];
                            //                            JSValue *value = [context evaluateScript:callBackString];
                            DLog(@"-------%@",context);
                        }else{
                            [self.evWebView.wkWebView evaluateJavaScript:callBackString completionHandler:^(id _Nullable content, NSError * _Nullable error) {
                                
                            }];
                        }
                        
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                }];
            }];
        }
            break;
        case MethodTypeOfForward:{
            switch (scheme.jsNaviType) {
                case PageNaviTypeToNative:{
                    
                    __weak __typeof(self)weakSelf = self;
                    //跳转到Native页面
                    [YLBJSParamAdapter efPushViewControllerByScheme:scheme pushController:^(UIViewController *pushedController) {
                        __strong typeof(self) strongSelf = weakSelf;
                        
                        if ([pushedController isKindOfClass:[YLBLoginVC class]]) {
                            [strongSelf gotoLogin];
                        }else if ([pushedController isKindOfClass:[YLBBaseViewController class]]){
                            [strongSelf pushViewController:pushedController];
                        }
                    }];
                }
                    
                    break;
                case PageNaviTypeToWebViewWithHttp:
                case PageNaviTypeToWebViewWithLocal:{
                    //            scheme.jsUrl = @"template/mobile/IntegralSeven/IntegralSeven/index_m.html";
                    //跳转到WebView页面
                    [self efPushWebViewControllerWithScheme:scheme];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        case MethodTypeOfShare:{
            //分享
            if ([scheme.jsParamDic[@"useDefault"] boolValue]) {
                [self shareFromhtml];
            } else {
                [self shareFromJSWithShareDic:scheme.jsParamDic];
            }
        }
            break;
            
        case MethodTypeOfShowAlert:{
            //弹窗
            [self showAlertWithDic:scheme.jsParamDic];
        }
            break;
            
        default:
            break;
    }
}


-(void)afterLoginReloadData{
    [self loadDataWithScheme:self.evScheme];
}

#pragma mark - 分享相关
- (void)showAlertWithDic:(NSDictionary *)dic {
    NSString *title = dic[@"title"];
    NSString *message = dic[@"content"];
    NSString *cancelButtonTitle = dic[@"btn1"];
    NSString *otherButtonTitles = dic[@"btn2"];
    if (!title) {
        title = @"";
    }
    if (!message) {
        message = @"";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    [alert show];
    
}


- (void)shareClickTitle:(NSString *)title connent:(NSString *)connent url:(NSString *)url imgUrl:(id)imgUrl {
    
    // 图片为空，引用icon图标
    if (imgUrl == nil) {
        imgUrl = [NSString stringWithFormat:@"%@%@%@",kServerIP,kServerPort,@"/dist/mobile/images/modules/global/appicon114.png"];
    }
    // 内容为空，引用标题
    if (connent == nil) {
        connent = title;
    }
    NSLog(@"\n分享时数据：url = %@,\n title = %@,\n imageurl = %@,\n text = %@", url, title, imgUrl, connent);
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *titles = @[@"微信", @"朋友圈", @"QQ"];
    for (int i = 0; i< 3; i++) {
        NSDictionary *dic = @{@"image": [NSString stringWithFormat:@"shareicon%d",i + 1], @"title": titles[i]};
        [array addObject:dic];
    }
    ShareSheet *shareSheet = [[[NSBundle mainBundle] loadNibNamed:@"ShareSheet" owner:nil options:nil] firstObject];
    shareSheet.shareClick = ^(NSInteger index){
        SSDKPlatformType platformType = SSDKPlatformSubTypeWechatSession;
        switch (index) {
            case 1:
            {
                // 微信
                platformType = SSDKPlatformSubTypeWechatSession;
            }
                break;
            case 2:
            {
                // 朋友圈
                platformType = SSDKPlatformSubTypeWechatTimeline;
            }
                break;
            case 3:
            {
                // QQ
                platformType = SSDKPlatformTypeQQ;
            }
                break;
                
            default:
                break;
        }
        
        // 创建分享参数
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:connent
                                         images:imgUrl
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeAuto];
        
        //进行分享
        [ShareSDK share:platformType
             parameters:shareParams
         onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
             
             switch (state) {
                     // 分享成功
                 case SSDKResponseStateSuccess:
                 {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                         message:nil
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                 }
                     // 分享失败
                 case SSDKResponseStateFail:
                 {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                         message:[NSString stringWithFormat:@"%@", error]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                 }
                     // 分享取消
                 case SSDKResponseStateCancel:
                 {
                     //                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                     //                                                                     message:nil
                     //                                                                    delegate:nil
                     //                                                           cancelButtonTitle:@"确定"
                     //                                                           otherButtonTitles:nil];
                     //                 [alertView show];
                     break;
                 }
                 default:
                     break;
             }
             
         }];
    };
    shareSheet.shareContents = array;
    shareSheet.frame = CGRectMake(0, 0, SWidth, SHeight);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:shareSheet];
    [shareSheet show];
}

//分享内容从js获取
- (void)shareFromJSWithShareDic:(NSDictionary *)shareDic {
    NSString *shareTitle = shareDic[@"title"];
    NSString *imgUrl = shareDic[@"imgUrl"];
    NSString *shareConnent = shareDic[@"content"];
    NSString *shareUrl = shareDic[@"shareUrl"];
    [self shareClickTitle:shareTitle connent:shareConnent url:shareUrl imgUrl:imgUrl];
}

//分享内容从html获取
- (void)shareFromhtml {
    
    // 加载url获取图片数组分享图片
    NSString *shareImg =  [self getImgWithUrl:self.evScheme.jsUrl];
    __block NSString *shareTitle = @"";
    __block NSString *shareText = @"";
    if (self.evWebView.webView) {
        // 分享标题
        shareTitle = [self.evWebView.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        // 分享文本
        shareText = [self.evWebView.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText"];
       
    }else{
        [self.evWebView.wkWebView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable content, NSError * _Nullable error) {
            // 分享标题
            shareTitle = (NSString *)content;
        }];
        [self.evWebView.wkWebView evaluateJavaScript:@"document.documentElement.innerText" completionHandler:^(id _Nullable content, NSError * _Nullable error) {
      
            // 分享文本
            shareText = (NSString *)content;
            
        }];
    }
    
    [self shareClickTitle:shareTitle connent:shareText url:self.evScheme.jsUrl imgUrl:shareImg];
}

- (NSString *)getImgWithUrl:(NSString *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (response == nil){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告！" message:@"无法连接到该网站！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alertView show];
        return nil;
    }
    
    NSArray *imagesData =  [self parseData:response];
    NSMutableArray *images = [self downLoadPicture:imagesData];
    return images.firstObject;
}

- (NSArray*)parseData:(NSData*) data
{
    //解析html数据
    {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
        
        //在页面中查找img标签
        NSArray *images = [doc searchWithXPathQuery:@"//img"];
        return images;
    }
}

- (NSMutableArray*)downLoadPicture:(NSArray *)images
{
    //下载图片的方法
    {
        //创建存放UIImage的数组
        NSMutableArray *downloadImages = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [images count]; i++){
            NSString *prefix = [[[images objectAtIndex:i] objectForKey:@"src"] substringToIndex:4];
            NSString *url = [[images objectAtIndex:i] objectForKey:@"src"];
            
            //判断图片的下载地址是相对路径还是绝对路径，如果是以http开头，则是绝对地址，否则是相对地址
            if ([prefix isEqualToString:@"http"] == NO){
                url = [self.evScheme.jsUrl stringByAppendingPathComponent:url];
            }
            
            NSURL *downImageURL = [NSURL URLWithString:url];
            
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:downImageURL]];
            
            if(image != nil){
                [downloadImages addObject:url];
            }
        }
        return downloadImages;
    }
}

#pragma mark- Login
- (void)gotoLogin {
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Register" bundle:nil];
    YLBLoginVC *loginVC = [loginStoryboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    loginVC.loginUpdateDataBlock = ^{
        [self loadDataWithScheme:self.evScheme];
    };
    YLBNavController *nav = [[YLBNavController alloc] initWithRootViewController:loginVC];
    [((AppDelegate *)YLBApp).tabbar presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //回调h5
    NSString *callBackString = [NSString stringWithFormat:@"RainbowBridge.onComplete('%@','%ld')",self.jsPort,buttonIndex + 1];
    DLog(@"%@",callBackString);
    if (self.evWebView.webView) {
        NSString *context=[self.evWebView.webView stringByEvaluatingJavaScriptFromString:callBackString];
        //                            JSValue *value = [context evaluateScript:callBackString];
        DLog(@"-------%@",context);
    }else{
        [self.evWebView.wkWebView evaluateJavaScript:callBackString completionHandler:^(id _Nullable content, NSError * _Nullable error) {
            
        }];
    }

}

@end
