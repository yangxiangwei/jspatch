//
//  YLBWebView.m
//  WhiteDragon
//
//  Created by 杨相伟 on 16/6/23.
//  Copyright © 2016年 YongLibao. All rights reserved.
//

#import "YLBWebView.h"
#define IsIOS8   1
static void *KINWebBrowserContext = &KINWebBrowserContext;

@interface YLBWebView ()
@property (nonatomic, strong) NSTimer *fakeProgressTimer;
@property (nonatomic, assign) BOOL uiWebViewIsLoading;
@property (nonatomic, strong) NSURL *uiWebViewCurrentURL;
@property (nonatomic, strong) NSURL *URLToLaunchWithPermission;
@end

@implementation YLBWebView

#pragma mark - Dealloc

- (void)dealloc {
    [self.webView setDelegate:nil];
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if(IsIOS8) {
            self.wkWebView = [[WKWebView alloc] initWithFrame:frame];
        }else {
            self.webView = [[UIWebView alloc] initWithFrame:frame];
        }
        if(self.wkWebView) {
            [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [self.wkWebView setNavigationDelegate:self];
            [self.wkWebView setUIDelegate:self];
            [self.wkWebView setMultipleTouchEnabled:YES];
            [self.wkWebView setAutoresizesSubviews:YES];
            [self.wkWebView.scrollView setAlwaysBounceVertical:YES];
            self.scrollView = self.wkWebView.scrollView;
            [self addSubview:self.wkWebView];
            [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:KINWebBrowserContext];
        }else {
            [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [self.webView setDelegate:self];
            [self.webView setMultipleTouchEnabled:YES];
            [self.webView setAutoresizesSubviews:YES];
            [self.webView setScalesPageToFit:YES];
            [self.webView.scrollView setAlwaysBounceVertical:YES];
            self.scrollView = self.webView.scrollView;
            [self addSubview:self.webView];
        }
        
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [self.progressView setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.progressView.frame.size.height)];
        [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        
        
        //设置进度条颜色
        [self setTintColor:[UIColor colorWithRed:0.400 green:0.863 blue:0.133 alpha:1.000]];
        [self addSubview:self.progressView];
        
    }
    return self;
}



#pragma mark - Public Interface
- (void)loadRequest:(NSURLRequest *)request {
    if(self.wkWebView) {
        [self.wkWebView loadRequest:request];
    }else  {
        [self.webView loadRequest:request];
    }
    self.request = request;
}

-(void)loadFileURL:(NSURL *)url allowingReadAccessToURL:(NSURL *)readAccessURL{
    self.request = [NSURLRequest requestWithURL:readAccessURL];
    [self.wkWebView loadFileURL:url allowingReadAccessToURL:readAccessURL];
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    if(self.wkWebView) {
        [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
    }else if(self.webView) {
        [self.webView loadHTMLString:HTMLString baseURL:nil];
    }
}



- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self.progressView setTintColor:tintColor];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(webView == self.webView) {
        [self.delegate epWebViewDidStartLoad:self];
    }
}

//监视请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.webView) {
        if(![self externalAppRequiredToOpenURL:request.URL]) {
            self.uiWebViewCurrentURL = request.URL;
            self.uiWebViewIsLoading = YES;
            
            [self fakeProgressViewStartLoading];
            if (self.delegate && [self.delegate respondsToSelector:@selector(epWebView:shouldStartLoadWithURL:)]) {
                [self.delegate epWebView:self shouldStartLoadWithURL:request.URL];
            }
            
            return YES;
        }
    }
    return NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView == self.webView) {
        if(!self.webView.isLoading) {
            self.uiWebViewIsLoading = NO;
            
            [self fakeProgressBarStopLoading];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(epWebView:didFinishLoadURL:)]) {
            [self.delegate epWebView:self didFinishLoadURL:self.webView.request.URL];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(webView == self.webView) {
        if(!self.webView.isLoading) {
            self.uiWebViewIsLoading = NO;
            
            [self fakeProgressBarStopLoading];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(epWebView:didFailLoadURL:error:)]) {
            [self.delegate epWebView:self didFailLoadURL:webView.request.URL error:error];
        }
    }
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(epWebViewDidStartLoad:)]) {
            [self.delegate epWebViewDidStartLoad:self];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(epWebView:didFinishLoadURL:)]) {
            [self.delegate epWebView:self didFinishLoadURL:webView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(epWebView:didFailLoadURL:error:)]) {
            [self.delegate epWebView:self didFailLoadURL:webView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(epWebView:didFailLoadURL:error:)]) {
            [self.delegate epWebView:self didFailLoadURL:webView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(webView == self.wkWebView) {
        
        NSURL *URL = navigationAction.request.URL;
        if(!navigationAction.targetFrame) {
            
            [self loadURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        
        [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];

    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(epWebView:shouldStartLoadWithURL:)]) {
        [self.delegate epWebView:self shouldStartLoadWithURL:request.URL];
    }
    return YES;
}


#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
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


#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Fake Progress Bar Control (UIWebView)

- (void)fakeProgressViewStartLoading {
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!self.fakeProgressTimer) {
        self.fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire:) userInfo:nil repeats:YES];
    }
}

- (void)fakeProgressBarStopLoading {
    if(self.fakeProgressTimer) {
        [self.fakeProgressTimer invalidate];
    }
    
    if(self.progressView) {
        [self.progressView setProgress:1.0f animated:YES];
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressView setProgress:0.0f animated:NO];
        }];
    }
}

- (void)fakeProgressTimerDidFire:(id)sender {
    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
    if([self.webView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.95) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

#pragma mark - External App Support

- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    return YES;
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https",@"file",@"rainbow"]];
    return ![validSchemes containsObject:URL.scheme];
}


@end
