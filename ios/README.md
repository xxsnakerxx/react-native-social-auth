## iOS setup

1. Link the library
- by using `react-native link` (__recommended__) (after go to step [Facebook setup](#facebook))
- or `manual` (see next steps)
2. Open `node_modules/react-native-social-auth` folder
3. Drag `RNSocialAuth.xcodeproj` into your Libraries group
4. Select your `main project` in the navigator to bring up settings
5. Under `Build Phases` expand the `Link Binary With Libraries` header
6. Scroll down and click the `+` to add a library
7. Find and add `libRNSocialAuth.a` under the Workspace group

### Facebook
8. Configure your `.plist` file as described [here](https://developers.facebook.com/docs/ios/getting-started/#xcode) and [here(__for >iOS9 only__)](https://developers.facebook.com/docs/ios/ios9)
    or you can use `setFacebookApp` method provided the API
    (__Using `setFacebookApp` method you are still must define custom URL scheme in your `info.plist`!!! If you are using a few environments (e.g. staging, production) you can define URL Schemes(`'fb'+APP_ID` string) for both of them and set needed app id and name using this method__)
9. Under `Build Settings` of your main project scroll down to `Search Paths`
10. Add the following path to your `Header Search Paths`
```
$(SRCROOT)/../node_modules/react-native-social-auth/ios
```
__Note__: You can skip this step if you linked the lib with ([rnpm](https://github.com/rnpm/rnpm))
11. Modify your AppDelegate.m
```
#import "RNSocialAuthManager.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
...

[RNSocialAuthManager application:application didFinishLaunchingWithOptions:launchOptions];

return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [RNSocialAuthManager application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
```
12. Open `node_modules/react-native-social-auth/ios/FacebookSDK` folder
13. Drag `FBSDKCoreKit.framework` , `FBSDKLoginKit.framework` and `Bolts.framework` into your project
14. Add the following path to your `Framework Search Paths`
```
$(SRCROOT)/../node_modules/react-native-social-auth/ios/FacebookSDK
```

### Twitter
15. Select your `main project` in the navigator to bring up settings
16. Under `Build Phases` expand the `Link Binary With Libraries` header
17. Scroll down and click the `+` to add a library
18. Find and add `Accounts.framework`
