//
//  AppDelegate.m
//  ffitness
//
//  Created by AndruX on 7/28/14.
//  Copyright (c) 2014 AndruX. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()
@property(assign)BOOL isAppResumingFromBackground;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.\
    
    
//    if(application.applicationState == UIApplicationStateActive){

//    }
/*
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        application.applicationIconBadgeNumber = 0;
    }
*/
    
    
        NSMutableDictionary*cfg = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONFIG] mutableCopy];
        if (!cfg) {
            cfg = [NSMutableDictionary new];
            [cfg setObject:@(YES) forKey: KEY_CONFIG_AUTOUPDATE];
            [cfg setObject:@(YES) forKey: KEY_CONFIG_NOTIFY];
            [[NSUserDefaults standardUserDefaults] setObject:cfg forKey:KEY_CONFIG];
        }
        [self setBGStatus:[[cfg objectForKey:KEY_CONFIG_AUTOUPDATE] boolValue ]];
        
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        
        
    
        
        
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
          [UIFont fontWithName:@"Verona Gothic Flourishe" size:38.0f], NSFontAttributeName, nil]
         ];
        
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor: colorNavigationBarBackground];
        [[UIToolbar appearance ] setTintColor:colorNavigationBarBackground];
    
//        [[UIButton appearance ] setTintColor:[UIColor whiteColor]];
//        [[UIButton appearance ] setBackgroundColor:colorButtonBackground];

//    }
    
    
    
    
//    [[API sharedInstance] getUpdatesOnComplete:^(id response, NSError *error) {
//        if (response && !error) {
//        }
//    }];
//    NSDictionary*auth =@{
//                         @"card":@"14010255",
//                         @"day":@"5",
//                         @"month":@"9",
//                         @"year":@"1986",
//
//                         };
//    [[API sharedInstance] userLogIn:auth Complete:^(id response, NSError *error) {
//        NSLog(@"1");
//    }];
    
     
     
//     :auth completion:^(id response, NSError *error) {
//        NSLog(@"1");
//    }];
    
    return YES;
}

-(void)setBGStatus:(BOOL)status
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0){
        if (status == YES) {
            if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
                [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];//14400 every 4 hr
                return;
            }
        }
    }
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
}

-(void)addNottification
{
//    if (![NSThread isMainThread]) {
//        [self performSelectorOnMainThread:@selector(addNottification) withObject:nil waitUntilDone:NO];
//        return;
//    }
    
    
    NSMutableDictionary*oldD = [[[NSUserDefaults standardUserDefaults] objectForKey:BACKGROUND_DATA_KEY] mutableCopy];
    if (!oldD) {
        return;
    }
    
    NSMutableDictionary*cfg = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONFIG] mutableCopy];
    if ([[cfg objectForKey:KEY_CONFIG_NOTIFY] boolValue]==NO) {
        return;
    }
    
    NSString* exp = [[oldD objectForKey:KEY_EXPIRE] emptyForNil];
    NSString* count = [[oldD objectForKey:KEY_BALANCE] emptyForNil];
    NSString*msg = [NSString stringWithFormat:@"%@: %@\n%@ %@", NSLocalizedString(@"Remaining visits", @"Remaining visits"),count,NSLocalizedString(@"till", @"till"),exp];
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.alertBody = msg;
    localNotification.alertAction = NSLocalizedString(@"View", nil);
    
    
    
    localNotification.fireDate = [NSDate date];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.applicationIconBadgeNumber = 1;

//    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    
//    localNotification.alertLaunchImage = launchImage;
    
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber++;
    
    localNotification.applicationIconBadgeNumber = application.applicationIconBadgeNumber;
    
    [self performSelectorOnMainThread:@selector(scheduleNotification:)
                           withObject:localNotification waitUntilDone:NO];
}

- (void)scheduleNotification: (id)notification
{
    UILocalNotification *localNotification = (UILocalNotification *)notification;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    /*
     UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
     
     id topViewController = navigationController.topViewController;
     if ([topViewController isKindOfClass:[ViewController class]]) {
     [(ViewController*)topViewController insertNewObjectForFetchWithCompletionHandler:completionHandler];
     } else {
     NSLog(@"Not the right class %@.", [topViewController class]);
     completionHandler(UIBackgroundFetchResultFailed);
     }
     */
   __block UIBackgroundFetchResult rez = UIBackgroundFetchResultNoData;
    
    NSMutableDictionary*auth = [API getSuccessCredentials];
    if (auth) {
        [[API sharedInstance] getUpdatesOnComplete:^(id response, NSError *error) {
            if (response && !error) {
                rez = UIBackgroundFetchResultNewData;
            }
            else
            {
                [self setBGStatus:NO];
            }
        }];
    }
    else
    {
        [self setBGStatus:NO];
    }
    
    completionHandler(rez);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [self addNottification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    self.isAppResumingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    
     application.applicationIconBadgeNumber = 0;
   self.isAppResumingFromBackground = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (self.isAppResumingFromBackground) {
        
        // Show Alert Here
    }
    application.applicationIconBadgeNumber = 0;
}

@end
