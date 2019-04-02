//
//  ViewController.m
//  jqueryLazyLoad-OC
//
//  Created by niexiaobo on 2019/4/2.
//  Copyright © 2019 NXB. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()<WKNavigationDelegate>
@property(nonatomic,strong)UILabel *msgLab;
@property(nonatomic,strong)WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgLab = [[UILabel alloc]initWithFrame:self.view.bounds];
    self.msgLab.textAlignment = 1;
    self.msgLab.text = @"点击开始加载";
    self.msgLab.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:self.msgLab];
    
    //实际项目中可以使用单例预加载WKWebView, 并在其他地方使用时直接获取
    self.webView.hidden = YES;
    
}

/**
 :开始加载
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view addSubview:self.webView];
    self.webView.hidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //获取到需要加载的HTML
    NSString *HtmlString = [self getHTMLString];
    
    // 标签替换
    NSString *originalStr = [HtmlString stringByReplacingOccurrencesOfString:@"src" withString:@"data-original"];
    
    //获取temp文件的路径
    NSString *tempPath = [[NSBundle mainBundle]pathForResource:@"webLazyloadHead" ofType:@"html"];
    
    //加载temp内容为字符串
    NSString *tempHtml = [NSString stringWithContentsOfFile:tempPath encoding:NSUTF8StringEncoding error:nil];
    
    //替换temp内的占位符{{Content_holder}}为需要加载的HTML代码
    tempHtml = [tempHtml stringByReplacingOccurrencesOfString:@"{{Content_holder}}" withString:originalStr];
    
    //Temp目录下的js文件在根路径，因此需要在加载HTMLString时指定根路径
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    
    //加载HTMLString
    [self.webView loadHTMLString:tempHtml baseURL:baseURL];
}

#pragma mark OC调js
/**
 :开始加载图片
 */
- (void)beginLoadImages {
    NSString *jsStr = [NSString stringWithFormat:@"loadImages('%@')", @"1"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"错误:%@", error.localizedDescription);
        }
    }];
}

/** didStartProvisionalNavigation
 :开始加载时调用
 :获取高度: 只有文字的高度,不包含图片
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    //[self beginLoadImages];
}


/** didFinishNavigation
 :加载完成时调用
 :获取高度: 包含文字,图片 的高度
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self beginLoadImages];
}

/**
 :内容文件
 */
- (NSString*)getHTMLString {
    NSString *tempPath = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"html"];
    NSString *HtmlString = [NSString stringWithContentsOfFile:tempPath encoding:NSUTF8StringEncoding error:nil];
    return HtmlString;
}


- (WKWebView *)webView {
    if (!_webView) {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        webView.backgroundColor = [UIColor whiteColor];
        _webView = webView;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

@end
