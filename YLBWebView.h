//
//  YLBWebView.h
//  WhiteDragon
//
//  Created by 杨相伟 on 16/6/23.
//  Copyright © 2016年 YongLibao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class YLBWebView;
@protocol YLBWebViewDelegate <NSObject>

@optional

-(void)epWebView:(YLBWebView *)webView shouldStartLoadWithURL:(NSURL *)url;

-(void)epWebView:(YLBWebView *)webView didFinishLoadURL:(NSURL *)url;

-(void)epWebView:(YLBWebView *)webView didFailLoadURL:(NSURL *)url error:(NSError *)error;

-(void)epWebViewDidStartLoad:(YLBWebView *)webView;

@end

@interface YLBWebView : UIView<WKNavigationDelegate,WKUIDelegate,UIWebViewDelegate>


@property(nonatomic,weak)id <YLBWebViewDelegate> delegate;

@property(nonatomic,strong)UIProgressView *progressView;

@property(nonatomic,strong)UIWebView *webView;

@property(nonatomic,strong)WKWebView *wkWebView;

@property(nonatomic,strong)UIScrollView *scrollView;

@property(nonatomic,strong)NSURLRequest *request;
/**
 *  进度条颜色
 */
@property (nonatomic, strong) UIColor *tintColor;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)loadFileURL:(NSURL *)url allowingReadAccessToURL:(NSURL *)readAccessURL;

- (void)loadRequest:(NSURLRequest *)request;

- (void)loadURL:(NSURL *)URL;

- (void)loadURLString:(NSString *)URLString;

- (void)loadHTMLString:(NSString *)HTMLString;

@end
