//
//  JSBridgeManager.h
//  WebViewTest
//
//  Created by @hui on 2019/6/19.
//  Copyright © 2019 @hui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "PluginOfJS.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSBridgeManager : NSObject

@property (nonatomic, copy) NSString *jsFuncPre;

+(instancetype)managerWith:(WKWebView *)wk vc:(UIViewController *)vc;

-(void)reset;
-(void)enableLogging; //打印日志
-(void)setLogMaxLength:(int)length; //日志最大长度
-(void)clearAllWith:(WKWebView *)wk;
-(void)registeJSWith:(nullable NSArray<NSString *> *)jsFiles;
-(void)callHandler:(NSString *)handlerName data:(nullable id)data responseCallback:(PluginCallbackBlock)responseCallback;
-(void)setParamsWith:(NSString *)key value:(id)value; //设置本地方法参数
-(void)registeFuncWith:(NSString *)functionName className:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
