//  MBWebViewController.h
//  WebViewTest
//
//  Created by @hui on 2019/6/19.
//  Copyright © 2019 @hui. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface MBWebViewController : UIViewController

/** 外部URL  如果有外部URL 则直接加载 */
@property (nonatomic,copy) NSString *URL;
/** 政务系统的url（需要拼接参数） */
@property (nonatomic,copy) NSString *SubURL;

@end


