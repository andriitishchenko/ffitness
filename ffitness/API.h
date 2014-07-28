//
//  API.h
//  lottoSend
//
//  Created by Andrii Tishchenko on 11.12.13.
//  Copyright (c) 2013 Andrii Tishchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, RequestMethod) {
    RequestMethodPost = 0,
    RequestMethodGet = 1,
    RequestMethodPut = 2
};
#define RequestMethodList @[@"POST", @"GET", @"PUT"]


@interface API : NSObject
-(void)userLogIn:(NSDictionary*)params Complete:(void (^)(id response, NSError* error))completion;
+ (API *)sharedInstance ;
+(void)requestAsyncWith:(NSString*)action method:(RequestMethod)method params:(NSDictionary*)params completion:(void (^)(id response, NSError* error))completion;
+ (void)clearCookiesForURL:(NSURL*)url;
@end
