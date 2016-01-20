//
//  RNSocialAuthManager.m
//  RNSocialAuth
//
//  Created by Dmitriy Kolesnikov on 18/12/15.
//  Copyright © 2015 Dmitriy Kolesnikov. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import <CommonCrypto/CommonHMAC.h>
#import <objc/runtime.h>

#import "RNSocialAuthManager.h"

#define twitterAppConsumerKey @""
#define twitterAppConsumerSecret @""

@implementation RNSocialAuthManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

+ (void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                             didFinishLaunchingWithOptions:launchOptions];
}

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation
     ];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"facebookPermissionsType": @{
                     @"read": @"read",
                     @"write": @"write",
                     }
             };
};

RCT_EXPORT_METHOD(setFacebookApp:(NSDictionary *)app) {
    [FBSDKSettings setAppID:app[@"id"]];
    [FBSDKSettings setDisplayName:app[@"name"]];
}


RCT_EXPORT_METHOD(getFacebookCredentials:(NSArray*)permissions
                  permissionsType:(NSString *)permissionsType
                  callback:(RCTResponseSenderBlock)callback)
{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    
    void (^handler)(FBSDKLoginManagerLoginResult *loginResult, NSError *error) = ^(FBSDKLoginManagerLoginResult *loginResult, NSError *error) {
        if (error) {
            callback(@[
                       @{
                           @"code": @(error.code),
                           @"cancelled": @NO,
                           @"message": error.localizedDescription
                           },
                       [NSNull null]]);
        }
        else {
            if (loginResult.isCancelled) {
                callback(@[
                           @{
                               @"code": @-1,
                               @"cancelled": @YES,
                               @"message": @"Credentials request was canceled"
                               },
                           [NSNull null]]);
                
                return;
                
            }
            
            if ([permissionsType isEqualToString:@"write"] && ![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
                callback(@[
                           @{
                               @"code": @-2,
                               @"cancelled": @NO,
                               @"message": @"Requested write permissions wasn't granted"
                               },
                           [NSNull null]]);
                
                return;
            }
            
            callback(@[[NSNull null], @{
                           @"userId": [FBSDKAccessToken currentAccessToken].userID,
                           @"accessToken": [FBSDKAccessToken currentAccessToken].tokenString,
                           @"hasWritePermissions": @([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]),
                           }]);
        }
    };
    
    if ([permissionsType isEqualToString:@"write"]) {
        [loginManager logInWithPublishPermissions:permissions fromViewController:nil handler:handler];
    }
    else {
        [loginManager logInWithReadPermissions:permissions fromViewController:nil handler:handler];
    }
}

RCT_EXPORT_METHOD(getTwitterSystemAccounts:(RCTResponseSenderBlock)callback)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        ACAccountType *twAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:twAccountType options:nil completion:^(BOOL granted, NSError *error) {
            if (error) {
                callback(@[
                           @{
                               @"code": @(error.code),
                               @"message": error.localizedDescription,
                               },
                           [NSNull null]]);
                
                return;
            }
            
            if (granted) {
                NSArray *twAccounts = [accountStore accountsWithAccountType:twAccountType];
                
                if ([twAccounts count]) {
                    ACAccount *account;
                    
                    NSMutableArray *accounts = [[NSMutableArray alloc] init];
                    
                    for (int i = 0; i < [twAccounts count]; i++) {
                        account = [twAccounts objectAtIndex:i];
                        
                        [accounts addObject:@{
                                              @"userName": account.username
                                              }];
                    }
                    
                    callback(@[[NSNull null], accounts]);
                }
                else {
                    callback(@[@{
                                   @"code": @-2,
                                   @"message": @"System twitter accounts weren't found",
                                   }, [NSNull null]]);
                }
            }
            else {
                callback(@[@{
                               @"code": @-1,
                               @"message": @"Access to get twitter system accounts wasn't granted",
                               }, [NSNull null]]);
            }
        }];
    });
}

RCT_EXPORT_METHOD(getTwitterCredentials:(NSString *)userName
                  reverseAuthResponse:(NSString *)reverseAuthResponse
                  callback:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

        [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
            if (error) {
                callback(@[
                           @{
                               @"code": @(error.code),
                               @"message": error.localizedDescription,
                               },
                           [NSNull null]]);
                
                return;
            }
            
            if (granted) {
                // If access granted, then get the Twitter account and try get tokens
                NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
                
                ACAccount *twitterAccount;
                
                for (int i = 0; i < [accounts count]; i++) {
                    ACAccount *account = [accounts objectAtIndex:i];
                    
                    if ([account.username isEqualToString:userName]) {
                        twitterAccount = account;
                    }
                }
                
                NSString *reverseAuthResponseString = @"";
                
                // Auth using key and secret  !!! IT'S NOT SAFE because secret exists in the app code!!!
                if ([twitterAppConsumerKey length] != 0 && [twitterAppConsumerSecret length] != 0) {
                    // OAuth parameters
                    NSString *oauthNonce = [[self class] randomAlphanumericStringWithLength:20];
                    
                    NSString *oauthSignatureMethod = [NSString stringWithFormat:@"HMAC-SHA1"];
                    
                    time_t oauthTimeStamp = (time_t) [[NSDate date] timeIntervalSince1970];
                    
                    NSString *baseStr = @"";
                    
                    // generating signature param
                    baseStr = [baseStr stringByAppendingFormat:@"oauth_consumer_key=%@&",twitterAppConsumerKey];
                    baseStr = [baseStr stringByAppendingFormat:@"oauth_nonce=%@&",oauthNonce];
                    baseStr = [baseStr stringByAppendingFormat:@"oauth_signature_method=%@&",oauthSignatureMethod];
                    baseStr = [baseStr stringByAppendingFormat:@"oauth_timestamp=%ld&",oauthTimeStamp];
                    baseStr = [baseStr stringByAppendingFormat:@"oauth_version=1.0&"];
                    baseStr = [baseStr stringByAppendingFormat:@"x_auth_mode=reverse_auth"];
                    
                    baseStr = [NSString stringWithFormat:@"POST&%@&%@",[[self class] percentDecodeString:@"https://api.twitter.com/oauth/request_token"],[[self class] percentDecodeString:baseStr]];
                    
                    NSString *oauthSignature = [[self class] percentDecodeString:[[self class] hmacsha1:baseStr withKey:[NSString stringWithFormat:@"%@&", twitterAppConsumerSecret]]];
                    
                    // prepare request header
                    NSString *oauthString = @"OAuth ";
                    oauthString = [oauthString stringByAppendingFormat:@"oauth_consumer_key=\"%@\"",twitterAppConsumerKey];
                    oauthString = [oauthString stringByAppendingFormat:@",oauth_signature=\"%@\"",oauthSignature];
                    oauthString = [oauthString stringByAppendingFormat:@",oauth_signature_method=\"%@\"",oauthSignatureMethod];
                    oauthString = [oauthString stringByAppendingFormat:@",oauth_timestamp=\"%ld\"",oauthTimeStamp];
                    oauthString = [oauthString stringByAppendingFormat:@",oauth_nonce=\"%@\"",oauthNonce];
                    oauthString = [oauthString stringByAppendingFormat:@",oauth_version=\"1.0\""];
                    
                    NSURL *requestTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:requestTokenUrl];
                    
                    request.HTTPMethod = @"POST";
                    
                    [request setValue:oauthString forHTTPHeaderField:@"Authorization"];
                    
                    request.HTTPBody = [@"x_auth_mode=reverse_auth" dataUsingEncoding:NSUTF8StringEncoding];
                    
                    NSURLResponse *response;
                    
                    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
                    
                    reverseAuthResponseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
                }
                else {
                    if (reverseAuthResponse) {
                        reverseAuthResponseString = reverseAuthResponse;
                    }
                    else {
                        callback(@[@{
                                       @"code": @0,
                                       @"message": @"Twitter's app consumer key and secret not found"
                                       }, [NSNull null]]);
                        
                        return;
                    }
                }
                
                // STEP TWO (access token)
                NSDictionary *accessTokenRequestParams = [[NSMutableDictionary alloc] init];
                
                __block NSString *twitterAppConsumerKeyStr = twitterAppConsumerKey;
                
                if ([twitterAppConsumerKeyStr length] == 0) {
                    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"oauth_consumer_key=\"(.*?)\"" options:0 error:nil];
                    
                    [regex enumerateMatchesInString:reverseAuthResponseString options:0 range:NSMakeRange(0, [reverseAuthResponseString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                        NSRange range = [result rangeAtIndex:1];
                        NSString *found = [reverseAuthResponseString substringWithRange:range];
                        
                        twitterAppConsumerKeyStr = found;
                    }];
                }
                
                if ([twitterAppConsumerKeyStr length] != 0) {
                    [accessTokenRequestParams setValue:twitterAppConsumerKeyStr forKey:@"x_reverse_auth_target"];
                    
                    [accessTokenRequestParams setValue:reverseAuthResponseString forKey:@"x_reverse_auth_parameters"];
                    
                    NSURL *accessTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
                    
                    SLRequest *accessTokenRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                       requestMethod:SLRequestMethodPOST
                                                                                 URL:accessTokenUrl
                                                                          parameters:accessTokenRequestParams];
                    
                    [accessTokenRequest setAccount:twitterAccount];
                    
                    // execute the request
                    [accessTokenRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        
                        if (error || [urlResponse statusCode] != 200 ) {
                            if (error) {
                                callback(@[@{
                                               @"code": @(error.code),
                                               @"message": error.localizedDescription
                                               }, [NSNull null]]);
                            } else {
                                callback(@[@{
                                               @"code": @-3,
                                               @"message": [NSString stringWithFormat:@"SLRequest failed with status %ld", (long)[urlResponse statusCode]]
                                               }, [NSNull null]]);
                            }
                        }
                        else {
                            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                            
                            NSDictionary *paramsInResponse = [[self class] parseQueryString:responseStr];
                            
                            callback(@[[NSNull null], @{
                                           @"oauthToken": [paramsInResponse objectForKey:@"oauth_token"],
                                           @"oauthTokenSecret": [paramsInResponse objectForKey:@"oauth_token_secret"],
                                           @"userName": [paramsInResponse objectForKey:@"screen_name"]
                                           }]);
                        }
                    }];
                }
                else {
                    callback(@[@{
                                   @"code": @-2,
                                   @"message": @"Twitter's app consumer key not found"
                                   }, [NSNull null]]);
                }
            } else {
                callback(@[@{
                               @"code": @-1,
                               @"message": @"Access to get twitter system accounts wasn't granted",
                               }, [NSNull null]]);
            }
        }];
    });
}

+ (NSDictionary *)parseQueryString:(NSString *)string
{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [string componentsSeparatedByString:@"&"];

    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];

        [queryStringDictionary setObject:value forKey:key];
    }

    return queryStringDictionary;
}

+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];

    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }

    return randomString;
}

+ (NSString *)percentDecodeString:(NSString *)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,                                                                                    (CFStringRef)string,                                                                                   NULL,                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",                                                                                    kCFStringEncodingUTF8 ));
}

+ (NSString *)hmacsha1:(NSString *)string withKey:(NSString *)key;
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

    return [HMAC base64EncodedStringWithOptions:0];
}

@end


@interface NSDictionary(dictionaryWithObject)

+(NSDictionary *) dictionaryWithPropertiesOfObject:(id) obj;

@end

@implementation NSDictionary(dictionaryWithObject)

+(NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);

    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        NSObject *temp_obj = [obj valueForKey:key];

        if (temp_obj == nil) {
            temp_obj = @"";
        }

        [dict setObject:temp_obj forKey:key];
    }

    free(properties);

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
