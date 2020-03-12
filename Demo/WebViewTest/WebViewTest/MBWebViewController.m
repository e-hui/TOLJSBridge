//  MBWebViewController.m
//  WebViewTest
//
//  Created by @hui on 2019/6/19.
//  Copyright © 2019 @hui. All rights reserved.
//

#import "MBWebViewController.h"
#import "JSBridgeManager.h"

@interface MBWebViewController ()
<WKNavigationDelegate,
WKUIDelegate,
WKScriptMessageHandler,
UINavigationControllerDelegate>

@property (nonatomic,strong) WKWebView  *webView;
@property (nonatomic, strong) JSBridgeManager *manager;

@end

@implementation MBWebViewController
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)dealloc
{
    [_manager clearAllWith:_webView];
    _manager = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // 这是创建configuration 的过程
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    _webView.frame = self.view.bounds;
    _webView.allowsBackForwardNavigationGestures = YES;//开了支持滑动返回
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    
    _URL = @"https://www.baidu.com";
    NSURL *url = [[NSURL alloc]initWithString:_URL];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self.view addSubview:_webView];
    
    _manager = [JSBridgeManager managerWith:self.webView vc:self];
    [_manager enableLogging];
    NSArray *paths = paths = [[NSBundle mainBundle]pathsForResourcesOfType:@".js" inDirectory:@"www"];
    [_manager registeJSWith:paths];
    [_manager setParamsWith:@"qureyStep" value:@{@"qurey":@"stepStep"}];
    _manager.jsFuncPre = @"mb";
    [_manager registeFuncWith:@"regist" className:@"MBCommonPlugin"];
}

#pragma mark—————————————webView代理方法部分——————————————
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>网页加载内容<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>网页加载完成<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
}
// 当内容开始到达时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>内容开始到达<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>加载失败<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
}

//js调用Acert函数时调用此方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?alertController.textFields[0].text:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame])
    {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark—————————————js与OC交互部分——————————————
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"controller message");

}




@end
