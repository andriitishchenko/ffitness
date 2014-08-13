//
//  API.m
//  lottoSend
//
//  Created by Andrii Tishchenko on 11.12.13.
//  Copyright (c) 2013 Andrii Tishchenko. All rights reserved.
//

#import "API.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#define baseurl @"https://aurora42.net/fortfitness/"

#define  BOUNDARY @"AaB03x"

#import "TFHpple.h"



@interface API()<NSURLConnectionDelegate, NSURLSessionDelegate>
@property (strong,nonatomic)NSURLSessionConfiguration *sessionConfig;
@property (strong,nonatomic) dispatch_queue_t requestQueue;
@property (strong,nonatomic) NSOperationQueue *queue;

@property (strong,nonatomic)  NSDateFormatter *dateFormatter;
@end

@implementation API
+ (API *)sharedInstance
{
    static dispatch_once_t  onceToken;
    static API * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [API alloc];
        
        sSharedInstance = [sSharedInstance init];
    });
    return sSharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.requestQueue = dispatch_queue_create("com.request-queue", NULL);
        self.queue = [NSOperationQueue new];
        [self.queue setMaxConcurrentOperationCount:1];
        [self.queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];

        
        self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//        self.sessionConfig.allowsCellularAccess = NO;
        self.sessionConfig.timeoutIntervalForRequest = 10.0;
        self.sessionConfig.timeoutIntervalForResource = 60.0;
        self.sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        self.sessionConfig.HTTPShouldSetCookies = YES;
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        
#if TARGET_OS_IPHONE
        NSString *cachePath = @"/MyCacheDirectory";
        
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *myPath    = [myPathList  objectAtIndex:0];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
//        ALog(@"Cache path: %@\n", fullCachePath);
#else
        NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/nsurlsessiondemo.cache"];
        
        ALog(@"Cache path: %@\n", cachePath);
#endif
        
        NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity: 16384 diskCapacity: 268435456 diskPath: cachePath];
        self.sessionConfig.URLCache = myCache;
        self.sessionConfig.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    return self;
}

- (void)dealloc
{
    [self.queue removeObserver:self forKeyPath:@"operations"];
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == self.queue && [keyPath isEqualToString:@"operations"]) {
        NSInteger opCount = [self.queue operationCount];
        if (opCount == 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{

            });
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{

            });
        }
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

-(void)setHeaders
{
//    NSString *userPasswordString = @"admin:k4gfno";
//    NSData * userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
//    NSString *authString = [NSString stringWithFormat:@"Basic %@", base64EncodedCredential];
//    
//    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithDictionary:
//                                           @{@"Content-Type": @"application/json",
//                                             @"Accept": @"application/json",
//                                             @"Accept-Language": @"en",
//                                             @"User-Agent":@"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53",
//                                             @"Authorization": authString
//                                             }];
//    
//    //need save headers
//    [self.sessionConfig setHTTPAdditionalHeaders:requestHeaders];
}


-(NSMutableDictionary*)parceHTML:(NSData*)dataHTML
{
    NSMutableDictionary *datasource= nil;
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:dataHTML];
    NSArray * tds  = [doc searchWithXPathQuery: @"//table[@class='block']/tr/td[position() mod 2 = 0]"];

    if (tds) {
        datasource = [NSMutableDictionary new];
    }
    
    for (NSInteger i=0;i<[tds count];i++) {
        TFHppleElement * e = [tds objectAtIndex:i];
        NSString*value  =  [e text];
        if (i == 0) { //fio
            [datasource setObject:value forKey:KEY_FIO];
        }
        else if (i == 1) { //expire date
            [datasource setObject:value forKey:KEY_EXPIRE];
        }
        else if (i == 2) { //training count
            [datasource setObject:value forKey:KEY_BALANCE];
        }
        else if (i == 3) { //money balance
            [datasource setObject:value forKey:KEY_MONEY];
        }
    }
    doc = nil;
    
    return datasource;
}


-(void)userLogIn:(NSDictionary*)params Complete:(void (^)(id response, NSError* error))completion
{
    //card=ss&day=1&month=1&year=1986
//    NSDictionary*auth =@{
//                         @"card":@"140102551",
//                         @"day":@"5",
//                         @"month":@"9",
//                         @"year":@"1986",
//                         
//                         };
    
    [API authWithParams:params completion:^(id response, NSError *error) {
        if (response && !error) {
            NSMutableDictionary*rez = [self parceHTML:(NSData*)response];
            if (completion) {
                completion(rez, error);
            }
        }
        else if (completion) {
            completion(nil, error);
        }
    }];
}

-(void)informIfUpdatenewDict:(NSMutableDictionary*)newD
{
    if (newD) {        
        AppDelegate*ap = ApplicationDelegate;
        if (![newD isEqualToDictionary:ap.userDictionary]) {
//            ALog(@"OLD = %@ \nNEW = %@",ap.userDictionary,newD );
            [ap addNottification:newD];
            ap.userDictionary = newD;
            
            NSString*newdate = [newD objectForKey:KEY_EXPIRE];

            if (![newdate isEqualToString:[ap.userDictionary objectForKey:KEY_EXPIRE]]) {
                ALog(@"ADDED iDate = %@", newdate);
                NSDate*ndate = [API stringToDate:newdate];
                [ap setiCalEventOnDate:ndate];
            }
            
        }
    }
}

+(NSDate*)stringToDate:(NSString*)datastring{
    NSDateFormatter *dateFormatter = [API sharedInstance].dateFormatter;
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    [dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    return [dateFormatter dateFromString:datastring];
}

+(NSString*)dateToString:(NSDate*)date{
    NSDateFormatter *dateFormatter = [API sharedInstance].dateFormatter;
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:date];;
}

-(void)getUpdatesOnComplete:(void (^)(id response, NSError* error))completion
{
    [API requestAsyncWith:@"key2gym" method:RequestMethodGet params:nil completion:^(id response, NSError *error) {
        if (response && !error) {
            NSMutableDictionary*rez = [self parceHTML:(NSData*)response];
            [self informIfUpdatenewDict:rez];
            if (completion) {
                completion(rez, error);
            }
        }
        else if (completion) {
            completion(nil, error);
        }
    }];
}

-(void)logOutOnComplete:(void (^)(id response, NSError* error))completion
{
    [API requestAsyncWith:@"key2gym/logout" method:RequestMethodPost params:nil completion:^(id response, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PAYLOADS];
        if (completion) {
            completion(response, error);
            
        }
    }];
}

//+ (NSCachedURLResponse *)connection:(NSURLConnection *)connection
//                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
//{
//    return nil;
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}


+ (void)clearCookiesForURL:(NSURL*)url {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:url];
    for (NSHTTPCookie *cookie in cookies) {
        ALog(@"Deleting cookie for domain: %@", [cookie domain]);
        [cookieStorage deleteCookie:cookie];
    }
}



+(void)requestAsyncWith:(NSString*)action method:(RequestMethod)method params:(NSDictionary*)params completion:(void (^)(id response, NSError* error))completion
{
    NSString*method_call = [baseurl stringByAppendingString:action];

    if (method == RequestMethodGet && params) {
        method_call = [method_call stringByAppendingString:[params queryString]];
    }

    ALog(@"\nURL = %@",method_call);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: [[API sharedInstance] sessionConfig] delegate: [API sharedInstance] delegateQueue: [NSOperationQueue currentQueue]];
    
    NSURL*url_path = [method_call toURL];
    
    
    
    //NSArray*ll =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url_path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url_path];
    [request setTimeoutInterval:25];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    
//    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
//    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:YES];
    
    [request setHTTPMethod:RequestMethodList[method]];
    
    if (params && method != RequestMethodGet) {
        NSString*params_serialized = [[params queryString] substringFromIndex:1];
        NSMutableData *body = [params_serialized dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
    }

    ALog(@"\n\nREQUEST \n %@ \n%@",request.allHTTPHeaderFields,params);
    
    //            ALog(@"%@",[request.HTTPBody toStringUTF8]);
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *session_error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSString*absUrl = [httpResponse.URL.absoluteString lastPathComponent];
        
        if ([absUrl isContainSubstring:@"login"]) { //302 redirect
            NSMutableDictionary*postCred  = [API getSuccessCredentials];
            if (postCred) {
            ALog(@"request login and return");
               [API authWithParams:postCred completion:^(id response, NSError *error) {
                   if (completion) {
                       completion(response, error);
                   }
               }];
                return;
            }
        }

        
        ALog(@"RESULT %ld %@\n",(long)[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
        
        NSError*_e = nil;
        id result = nil;
        
        
        ALog(@"Response STATUS CODE %ld\n",(long)[httpResponse statusCode]);
        if (data) ALog(@"\n==============================\n%@\n==============================\n",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (completion) {
            completion(data, session_error);
        }
        
    }];
    
    [task resume];
}



+(void)authWithParams:(NSDictionary*)params completion:(void (^)(id response, NSError* error))completion
{
    NSString*method_call = [baseurl stringByAppendingString:@"key2gym/login"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: [[API sharedInstance] sessionConfig] delegate: [API sharedInstance] delegateQueue: [NSOperationQueue currentQueue]];

    NSURL*url_path = [method_call toURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url_path];
    [request setTimeoutInterval:15];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"POST"];
    
    NSString*params_serialized = [[params queryString] substringFromIndex:1];//remove "?"
    NSData *body = [params_serialized dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:body];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *session_error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSString*absUrl = [httpResponse.URL.absoluteString lastPathComponent];
        NSData*rdata = data;
        NSError*error = session_error;
        if ([absUrl isEqualToString:@"key2gym"]) {//logedin successfuly
            [[NSUserDefaults standardUserDefaults] setObject:params forKey:PAYLOADS];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PAYLOADS];
            rdata = nil;
            error = [[NSError alloc] initWithDomain:@"login.failed" code:401 userInfo:nil];
        }
        
        if (completion) {
            completion(rdata, error);
        }
        
    }];
    
    [task resume];
}



//
//-(void)URLSession:(NSURLSession *)session
//     downloadTask:(NSURLSessionDownloadTask *)downloadTask
//didFinishDownloadingToURL:(NSURL *)location
//{
//    // use code above from completion handler
//    ALog(@"Finished");
//}
//
//-(void)URLSession:(NSURLSession *)session
//     downloadTask:(NSURLSessionDownloadTask *)downloadTask
//     didWriteData:(int64_t)bytesWritten
//totalBytesWritten:(int64_t)totalBytesWritten
//totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
//{
//    ALog(@"%f / %f", (double)totalBytesWritten,(double)totalBytesExpectedToWrite);
//}

+(NSMutableDictionary*)getSuccessCredentials{
    return (NSMutableDictionary*)[[[NSUserDefaults standardUserDefaults] objectForKey:PAYLOADS] mutableCopy];
}


+(void)skinButton:(UIButton*)button
{
    button.tintColor = [UIColor whiteColor];
    button.backgroundColor = colorButtonBackground;
}
@end
