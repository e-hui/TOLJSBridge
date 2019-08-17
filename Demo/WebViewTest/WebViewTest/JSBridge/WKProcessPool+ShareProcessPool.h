//
//  WKProcessPool+ShareProcessPool.h
//  WebViewTest
//
//  Created by @hui on 2019/6/19.
//  Copyright © 2019 @hui. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKProcessPool (ShareProcessPool)

+ (WKProcessPool*)sharedProcessPool;

@end

NS_ASSUME_NONNULL_END
