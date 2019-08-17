//
//  WKProcessPool+ShareProcessPool.m
//  YGAP
//
//  Created by @HUI on 2019/6/3.
//  Copyright © 2019 justforYOU. All rights reserved.
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
