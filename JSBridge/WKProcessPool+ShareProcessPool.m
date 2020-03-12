//
//  WKProcessPool+ShareProcessPool.m
//  WebViewTest
//
//  Created by @hui on 2019/6/19.
//  Copyright © 2019 @hui. All rights reserved.
//

#import "WKProcessPool+ShareProcessPool.h"

@implementation WKProcessPool (ShareProcessPool)

+ (WKProcessPool*)sharedProcessPool {
    
    static WKProcessPool* SharedProcessPool;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        SharedProcessPool = [[WKProcessPool alloc] init];
        
    });
    
    return SharedProcessPool;
    
}

@end
