//
//  ViewController.m
//  jspatch
//
//  Created by 杨相伟 on 16/5/30.
//  Copyright © 2016年 yangxiangwei. All rights reserved.
//

#import "ViewController.h"
#import "SecondVC.h"
#import "TestObject.h"
#import <WebKit/WebKit.h>
//#import "NSObject+DataTypeConvertion.h"
#import "Car.h" 
#import <objc/runtime.h>
#import "Person.h"
#import "NSArray+Safe.h"
//#import "NSArray+YLBUtil.h"
#import "YLBArray.h"
#import "Father.h"
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong)WKWebView *webView;
@end

@implementation ViewController
 

- (void)viewDidLoad {
    [super viewDidLoad];
   
//    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
// 
//    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
//    _webView.navigationDelegate = self;
//    _webView.UIDelegate = self;
//    [self.view addSubview:_webView];
//    
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    
//    [self formatNumber];
    
//    [self formatNumber];
    
//    [self testArray];
//    [self tryMember];
    [self tryAddingFunction];
    [self tryMemberFunc];
}
#define kTryCatch(v1,v2) @try{v1;}@catch(NSException *exception){v2;}
- (void)tryMethodExchange
{
    Method method1 = class_getInstanceMethod([NSArray class], @selector(objectAtIndex:));
    Method method2 = class_getInstanceMethod([NSArray class], @selector(objectAtIndexSafe:));
    method_exchangeImplementations(method1, method2);
    NSArray *arr = @[@"a",@"b"];
    @try {
        NSLog(@"%@",[arr objectAtIndex:2]);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
 
}

- (void)tryAddingFunction
{
    class_addMethod([self class], @selector(method::), (IMP)myAddingFunction, "i@:i@");
    
}
//具体的实现，即IMP所指向的方法
int myAddingFunction(id self, SEL _cmd, int var1, NSString *str)
{
    NSLog(@"I am added funciton");
    return 10;
}

- (void)tryMember
{
    Father *father = [[Father alloc] init];
    NSLog(@"before runtime:%@", [father description]);
    
    unsigned int count = 0;
    Ivar *members = class_copyIvarList([Father class], &count);
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        const char *memberName = ivar_getName(var);
        const char *memberType = ivar_getTypeEncoding(var);
        NSLog(@"%s----%s", memberName, memberType);
    }
}

- (void)tryMemberFunc
{
    unsigned int count = 0;
    Method *memberFuncs = class_copyMethodList([self class], &count);//所有在.m文件显式实现的方法都会被找到
    for (int i = 0; i < count; i++) {
        SEL name = method_getName(memberFuncs[i]);
        NSString *methodName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"member method:%@", methodName);
    }
}

-(void)testArray{
    YLBArray *array = (YLBArray *)@[@"a",@"b"];
//    NSLog(@"%@",[array objectAtIndexCheck:2]);
//    [array objectAtIndexSafe:2];
    NSLog(@"%@",[array objectAtIndex:2]);
}


-(void)formatNumber{
    NSArray *p = [NSArray new];
//    [p objectAtIndex:0];
//    [p objectAtIndexSafe:0];
    NSLog(@"**************");
    Method M1 = class_getInstanceMethod([NSArray class], @selector(objectAtIndex:));
    Method M2 = class_getInstanceMethod([NSArray class], @selector(objectAtIndexSafe:));
    method_exchangeImplementations(M1, M2);
    [p objectAtIndex:0];
    [p objectAtIndexSafe:0];
}


-(void)testIntParse{
    NSArray *car = [[NSArray alloc] init];
//    [name intValue]
    [car performSelector:@selector(objectAtIndexSafe:) withObject:nil afterDelay:0];
    
//    NSMutableArray *dd = [[NSMutableArray alloc] init];
    
//    NSString *bb = dd.count;
//    int cc = [[dd objectAtIndex:0] intValue];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(33),33, nil];
//    
//    NSLog(@"%d",[[dic objectForKey:@"aa"] intValue]);
//    if ([aa respondsToSelector:@selector(intValue)]) {
//        
//        NSLog(@"%d",bb);
//    }else{
//        NSLog(@"%d",1);
//    }
  
}



- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
}

/*! @abstract Displays a JavaScript confirm panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the confirm
 panel has been dismissed. Pass YES if the user chose OK, NO if the user
 chose Cancel.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
}

/*! @abstract Displays a JavaScript text input panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param defaultText The initial text to display in the text entry field.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the text
 input panel has been dismissed. Pass the entered text if the user chose
 OK, otherwise nil.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel, and a field in
 which to enter text.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}


@end
