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
        BOOL bgstatus =[[cfg objectForKey:KEY_CONFIG_AUTOUPDATE] boolValue ];
        [self setBGStatus:bgstatus];
        
        
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
    NSString*msg = [NSString stringWithFormat:@"%@: %@\n%@ %@",
                    NSLocalizedString(@"Remaining visits", @"Remaining visits"),
                    count,
                    NSLocalizedString(@"till", @"till"),
                    exp];
    
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
    
   __block UIBackgroundFetchResult rez = UIBackgroundFetchResultNoData;
    
    NSMutableDictionary*auth = [API getSuccessCredentials];
    if (auth) {
        [[API sharedInstance] getUpdatesOnComplete:^(id response, NSError *error) {
            if (response && !error) {
                rez = UIBackgroundFetchResultNewData;
                [self addNottification];
            }
            else
            {
                [self setBGStatus:NO];
            }
            
            completionHandler(rez);
        }];
    }
    else
    {
        [self setBGStatus:NO];
        completionHandler(rez);
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
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



- (void)scheduleAlarmForDate:(NSDate*)theDate
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    
    // Create a new notification.
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm)
    {
        alarm.fireDate = theDate;
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.soundName = @"alarmsound.caf";
        alarm.alertBody = @"Time to wake up!";
        
        [app scheduleLocalNotification:alarm];
    }
}
@end
