//
//  SettingsViewController.h
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 12/25/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelAddNotifications;
@property (weak, nonatomic) IBOutlet UILabel *labelUpdateAutomaticaly;

@property (weak, nonatomic) IBOutlet UISwitch *switchNotifications;
@property (weak, nonatomic) IBOutlet UISwitch *switchUpdateAutomaticaly;
- (IBAction)swichChanged:(id)sender;
- (IBAction)button_logout_click:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonLoguot;

@end
