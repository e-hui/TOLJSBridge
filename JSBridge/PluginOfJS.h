//
//  PluginOfJS.h
//  WebViewTest
//
//  Created by @hui on 2019/6/19.
//  Copyright © 2019 @hui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef kMsgHandlerName
#define kMsgHandlerName @"MSGJSCALLNATIVE"
#endif

#ifndef kCallBackHandlerName
#define kCallBackHandlerName @"MSGNATIVECALLBACK"
#endif

@interface PluginOfJS : NSObject

typedef void(^PluginCallbackBlock)(id _Nullable data);

@property(nonatomic, weak)WKWebView *wk;
@property(nonatomic, weak)UIViewController<WKScriptMessageHandler> *vc;
@property(nonatomic, assign)NSInteger taskId;
@property(nonatomic, copy)id data;
@property(nonatomic, strong)NSMutableDictionary *params;

-(void)callBack: (id)backData;
-(void)callError: (NSString *)errorMessage;
-(void)callHandler:(NSString *)handlerName data:(nullable id)data responseCallback:(PluginCallbackBlock)responseCallback;
-(void)callRespons;
-(void)registeFuncWith:(NSString *)functionName className:(NSString *)className jsFuncPre:(NSString *)funcPre;

-(void)enableLogging;
-(void)setLogMaxLength:(int)length;
-(void)reset;
-(void)clearAll;

-(void)setPluginWith:(PluginOfJS *)plugin;

@end

NS_ASSUME_NONNULL_END
