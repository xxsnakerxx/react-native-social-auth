//
//  RNSocialAuthManager.h
//  RNSocialAuth
//
//  Created by Dmitriy Kolesnikov on 18/12/15.
//  Copyright © 2015 Dmitriy Kolesnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCTBridgeModule.h"

@interface RNSocialAuthManager : NSObject <RCTBridgeModule>

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
