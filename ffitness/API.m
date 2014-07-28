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



@interface API()<NSURLConnectionDelegate, NSURLSessionDelegate>
@property (strong,nonatomic)NSURLSessionConfiguration *sessionConfig;
@property (strong,nonatomic) dispatch_queue_t requestQueue;
@property (strong,nonatomic) NSOperationQueue *queue;
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
        
#if TARGET_OS_IPHONE
        NSString *cachePath = @"/MyCacheDirectory";
        
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *myPath    = [myPathList  objectAtIndex:0];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
        NSLog(@"Cache path: %@\n", fullCachePath);
#else
        NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/nsurlsessiondemo.cache"];
        
        NSLog(@"Cache path: %@\n", cachePath);
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
    
    [API requestAsyncWith:@"key2gym/login" method:RequestMethodPost params:params completion:^(id response, NSError *error) {
        if (response && !error) {

        }
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
    [request setTimeoutInterval:5];
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
    
    //            NSLog(@"%@",[request.HTTPBody toStringUTF8]);
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *session_error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        
        
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
//
//-(void)URLSession:(NSURLSession *)session
//     downloadTask:(NSURLSessionDownloadTask *)downloadTask
//didFinishDownloadingToURL:(NSURL *)location
//{
//    // use code above from completion handler
//    NSLog(@"Finished");
//}
//
//-(void)URLSession:(NSURLSession *)session
//     downloadTask:(NSURLSessionDownloadTask *)downloadTask
//     didWriteData:(int64_t)bytesWritten
//totalBytesWritten:(int64_t)totalBytesWritten
//totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
//{
//    NSLog(@"%f / %f", (double)totalBytesWritten,(double)totalBytesExpectedToWrite);
//}


@end
