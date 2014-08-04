//
//  AppDelegate.h
//  ffitness
//
//  Created by AndruX on 7/28/14.
//  Copyright (c) 2014 AndruX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
-(void)setBGStatus:(BOOL)status;
-(void)addNottification:(NSMutableDictionary*)newuserdata;
-(void) setiCalEventOnDate:(NSDate*)iDate;
@property (strong,nonatomic) NSMutableDictionary* userDictionary;
-(void)saveState;
@end
