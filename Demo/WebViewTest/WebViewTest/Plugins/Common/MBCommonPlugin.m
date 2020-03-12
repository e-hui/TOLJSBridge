//
//  MBCommonPlugin.m
//  WebViewTest
//
//  Created by @hui on 2019/6/19.
//  Copyright © 2019 @hui. All rights reserved.
//

#import "MBCommonPlugin.h"
@class JSBridgeManager;

@implementation MBCommonPlugin

//返回APP
-(void)popToApp {
    [self.vc.navigationController popViewControllerAnimated:YES];//返回APP
}

//定位
-(void)locateAction {
    NSString *address = @"{\"neighborhood\":null,\"building\":null,\"province\":\"云南省\",\"street\":\"马连道北路\",\"AOIName\":\"桔子酒店(西客站)\",\"formattedAddress\":\"云南省昆明市五华区马连道北路靠近桔子酒店(西客站)\",\"location\":\"(116.327047,39.891427)\",\"city\":\"昆明市\",\"citycode\":\"010\",\"district\":\"五华区\",\"adcode\":\"110102\",\"number\":\"甲1号\",\"country\":\"中国\",\"township\":null,\"POIName\":\"桔子酒店(西客站)\"}";
    
    NSLog(@"-------------定位成功当前位置%@,接下来调用js的getGpsMsg方法",address);
    [self callBack:address];
}

//计步器
-(void)qureyStep {
    NSString *str = self.params[@"qureyStep"];
    [self callBack:str];
}

-(void)postHandel {
    NSLog(@"post");
    [self callHandler:@"testHandel" data:@"hhhhhh" responseCallback:^(id  _Nullable data) {
        NSLog(@"handel: %@", data);
    }];
}

-(void)regist {
    NSLog(@"Test Register");
}

@end
