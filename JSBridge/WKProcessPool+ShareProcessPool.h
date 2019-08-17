//
//  WKProcessPool+ShareProcessPool.h
//  YGAP
//
//  Created by @HUI on 2019/6/3.
//  Copyright © 2019 justforYOU. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKProcessPool (ShareProcessPool)

+ (WKProcessPool*)sharedProcessPool;

@end

NS_ASSUME_NONNULL_END
