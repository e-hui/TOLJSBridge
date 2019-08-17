//
//  PluginOfJS.m
//  YGAP
//
//  Created by @HUI on 2019/5/31.
//  Copyright © 2019 justforYOU. All rights reserved.
//

#import "PluginOfJS.h"

@interface PluginOfJS () {
    bool logging;
    int logMaxLength;
}

@property(nonatomic, assign)NSInteger uniqueId;
@property(nonatomic, strong)NSMutableDictionary *responseCallbacks;

@end

@implementation PluginOfJS

- (instancetype)init
{
    self = [super init];
    if (self) {
        logging = false;
        logMaxLength = 500;
        _uniqueId = 0;
        _responseCallbacks = [NSMutableDictionary dictionary];
        _taskId = 0;
        _params = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)setPluginWith:(PluginOfJS *)plugin {
    self.wk = plugin.wk;
    self.vc = plugin.vc;
    self.params = plugin.params;
    self.uniqueId = plugin.uniqueId;
    self.responseCallbacks = plugin.responseCallbacks;
}

-(void)enableLogging {
    logging = true;
}

-(void)setLogMaxLength:(int)length {
    logMaxLength = length;
}

-(void)reset {
    logging = false;
    logMaxLength = 500;
    _uniqueId = 0;
    _responseCallbacks = [NSMutableDictionary dictionary];
    _taskId = 0;
    _data = nil;
    _params = [NSMutableDictionary dictionary];
}

-(void)clearAll {
    NSAssert(_wk != nil, @"空的webview对象");
    [self callHandler:@"mb_clearAll" data:nil responseCallback:^(id  _Nullable data) {
        __strong WKWebView *wk = self.wk;
        [wk.configuration.userContentController removeScriptMessageHandlerForName:kMsgHandlerName];
        [wk.configuration.userContentController removeScriptMessageHandlerForName:kCallBackHandlerName];
        [wk.configuration.userContentController removeAllUserScripts];
        [self reset];
        wk = nil;
    }];
}

-(void)callBack:(id)backData {
    if (![NSJSONSerialization isValidJSONObject:backData]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *js = [NSString stringWithFormat:@"mb_callSuccess(%ld, '%@')", (long)self.taskId, backData];
            [self.wk evaluateJavaScript:js completionHandler:^(id _Nullable action, NSError * _Nullable error) {
                NSLog(@"action: %@, error: %@", action, error);
            }];
        });
        return;
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:backData options:NSJSONWritingPrettyPrinted error:&error];
    if (error == nil) {
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *jsonStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *js = [NSString stringWithFormat:@"mb_callSuccess(%ld, %@)", (long)self.taskId, jsonStr];
            [self.wk evaluateJavaScript:js completionHandler:^(id _Nullable action, NSError * _Nullable error) {
                NSLog(@"action: %@, error: %@", action, error);
            }];
        });
        return;
    }
    NSLog(@"error: %@", error);
}

-(void)callError:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *js = [NSString stringWithFormat:@"mb_callError(%ld, '%@')", (long)self.taskId, errorMessage];
        [self.wk evaluateJavaScript:js completionHandler:^(id _Nullable action, NSError * _Nullable error) {
            NSLog(@"action: %@, error: %@", action, error);
        }];
    });
}

-(void)callHandler:(NSString *)handlerName data:(nullable id)data responseCallback:(PluginCallbackBlock)responseCallback {
    NSAssert(self.wk != nil, @"空的webview对象");
    if (!_responseCallbacks) {
        _responseCallbacks = [NSMutableDictionary dictionary];
    }
    self.data = data;
    [self sendTo:handlerName responseCallback:responseCallback];
}

-(void)registeFuncWith:(NSString *)functionName className:(NSString *)className {
    NSString *jsStr = [NSString stringWithFormat:@"mb_%@ = function(data, callback) {mb_sendMessage('%@', '%@', data, callback);};", functionName, className, functionName];
    [self.wk evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"result: %@, error: %@", result, result);
    }];
}

-(void)sendTo:(NSString*)handlerName responseCallback:(PluginCallbackBlock)responseCallback {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    if (self.data) {
        message[@"data"] = self.data;
    }
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"native_cb_id_%ldd",(long) ++_uniqueId];
        _responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
//    message[@"className"] = @"PluginOfJS";
//    message[@"funcName"] = @"callRespons";
    [self dispatchMessage:message];
}

-(void)dispatchMessage:(NSDictionary*)message {
    NSString *messageJSON = [self serializeMessage:message pretty:true];
    [self log:@"SEND" json:messageJSON];
    NSString* javascriptCommand = [NSString stringWithFormat:@"mb_getMessageFromNative(%@);", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self evaluateJavascript:javascriptCommand];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self evaluateJavascript:javascriptCommand];
        });
    }
}

-(void)evaluateJavascript:(NSString *)str {
    [self.wk evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"result: %@, error: %@", result, error);
    }];
}

-(NSString *)serializeMessage:(id)message pretty:(BOOL)pretty{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

-(NSDictionary *)deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

-(void)log:(NSString *)action json:(id)json {
    if (!logging) { return; }
    if (![json isKindOfClass:[NSString class]]) {
        json = [self serializeMessage:json pretty:YES];
    }
    if ([json length] > logMaxLength) {
        NSLog(@"MBJS %@: %@ [...]", action, [json substringToIndex:logMaxLength]);
    } else {
        NSLog(@"MBJS %@: %@", action, json);
    }
}

-(void)callRespons {
    if (self.data) {
        NSDictionary *dic = [self deserializeMessageJSON:self.data];
        if (dic) {
            NSString *uid = dic[@"responseId"];
            id respons = dic[@"responseData"];
            if (uid) {
                PluginCallbackBlock block = _responseCallbacks[uid];
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(respons);
                        if ([self.responseCallbacks.allKeys containsObject:uid]) {
                            [self.responseCallbacks removeObjectForKey:uid];
                        }
                    });
                }
            }
        }
    }
}

-(void)dealloc {
    [_wk.configuration.userContentController removeAllUserScripts];
    _wk = nil;
    _vc = nil;
    _taskId = 0;
    _data = nil;
    _params = nil;
    logging = nil;
    logMaxLength = 0;
    _uniqueId = 0;
    _responseCallbacks = nil;
}

@end
