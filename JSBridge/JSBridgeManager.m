//
//  JSBridgeManager.m
//  YGAP
//
//  Created by @hui on 2019/6/13.
//  Copyright © 2019 justforYOU. All rights reserved.
//

#import "JSBridgeManager.h"
#import "WKProcessPool+ShareProcessPool.h"

@interface JSBridgeManager ()<WKScriptMessageHandler>

@property(nonatomic, strong)PluginOfJS *plugin;

@end

@implementation JSBridgeManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        _plugin = [[PluginOfJS alloc]init];
    }
    return self;
}

+(instancetype)managerWith:(nonnull WKWebView *)wk vc:(nonnull UIViewController<WKScriptMessageHandler> *)vc {
    NSAssert(wk != nil, @"空的webview对象");
    NSAssert(vc != nil, @"空的viewController");
    
    JSBridgeManager *sharedManager = [[self alloc] init];
    
    [wk.configuration.userContentController addScriptMessageHandler:sharedManager name:kMsgHandlerName];
    [wk.configuration.userContentController addScriptMessageHandler:sharedManager name:kCallBackHandlerName];
    
    wk.configuration.processPool = [WKProcessPool sharedProcessPool];
    
    sharedManager.plugin.wk = wk;
    sharedManager.plugin.vc = vc;
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"MB_Base" ofType:@"js"];
    [sharedManager registeWithFile:path];
    
    return sharedManager;
}

-(void)setParamsWith:(NSString *)key value:(id)value {
    [_plugin.params setObject:value forKey:key];
}

-(void)reset {
    [_plugin reset];
}

-(void)enableLogging {
    [_plugin enableLogging];
}
-(void)setLogMaxLength:(int)length {
    [_plugin setLogMaxLength:length];
}

-(void)clearAllWith:(WKWebView *)wk {
    _plugin.wk = wk;
    [_plugin clearAll];
}

-(void)registeWithFile:(NSString *)filePath {
    if (!filePath || filePath.length == 0) {
        return;
    }
    NSError *err;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]) {
        NSLog(@"文件不存在");
        return;
    }
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    if(err) {
        NSLog(@"File error: %@, %@", filePath, err);
        return;
    }
    [_plugin.wk evaluateJavaScript:str completionHandler:^(id result, NSError * _Nullable error) {
        NSLog(@"result: %@, error: %@", result, error);
    }];
}

-(void)registeJSWith:(NSArray<NSString *> *)jsFiles {
    if (jsFiles == nil || jsFiles.count == 0) {
        return;
    }else {
        for (NSString *f in jsFiles) {
            [self registeWithFile:f];
        }
    }
}

-(void)registeFuncWith:(NSString *)functionName className:(NSString *)className {
    [_plugin registeFuncWith:functionName className:className];
}

-(void)sendMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kMsgHandlerName]) {
        NSString *className = message.body[@"className"];
        if (className != nil) {
            Class cls = NSClassFromString(className);
            if(!cls) {
                NSLog(@"未找到对应的类");
                return;
            }
            id tempCls = [[cls alloc]init];
            if (![tempCls isKindOfClass:[PluginOfJS class]]) {
                NSLog(@"非插件类");
                return;
            }
            PluginOfJS *plugin = (PluginOfJS *)tempCls;
            if (plugin != nil) {
                [plugin setPluginWith:_plugin];
                plugin.taskId = [(message.body[@"taskId"]) integerValue];
                plugin.data = message.body[@"data"];
                NSString *funcName = message.body[@"functionName"];
                SEL sel = NSSelectorFromString(funcName);
                if ([plugin respondsToSelector:sel]) {
                    IMP imp = [plugin methodForSelector:sel];
                    void (*function)(id, SEL) = (void *)imp;
                    function(plugin, sel);
                }else {
                    NSLog(@"未找到对应的方法");
                }
            }
        }
    }else if ([message.name isEqualToString:kCallBackHandlerName]) {
        id response = message.body[@"response"];
        if (!response) {
            NSLog(@"空的回调对象");
            return;
        }
        [self callResponsWith:response];
    }
}

-(void)callHandler:(NSString *)handlerName data:(nullable id)data responseCallback:(PluginCallbackBlock)responseCallback {
    [_plugin callHandler:handlerName data:data responseCallback:responseCallback];
}

-(void)callResponsWith:(id)data {
    _plugin.data = data;
    [_plugin callRespons];
}

-(void)dealloc {
    _plugin = nil;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"bridge message");
    [self sendMessage:message];
}

@end
