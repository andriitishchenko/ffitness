//
//  SettingsViewController.m
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 12/25/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong,nonatomic) NSMutableDictionary*datasource;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        self.navigationItem.title = NSLocalizedString(@"Settings", @"Settings");
    
    self.labelAddNotifications.text  = NSLocalizedString(@"Notify on expire", @"Notify on expire");
    self.labelUpdateAutomaticaly.text  = NSLocalizedString(@"Update automatically", @"Update automatically");
    
    self.datasource = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONFIG] mutableCopy];
    if (!self.datasource) {
        self.datasource = [NSMutableDictionary new];
        [self.datasource setObject:@(NO) forKey: KEY_CONFIG_AUTOUPDATE];
        [self.datasource setObject:@(NO) forKey: KEY_CONFIG_NOTIFY];
    }
    
    
    self.switchNotifications.on = [[self.datasource objectForKey:KEY_CONFIG_NOTIFY] boolValue];
    self.switchUpdateAutomaticaly.on = [[self.datasource objectForKey:KEY_CONFIG_AUTOUPDATE] boolValue];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)swichChanged:(id)sender {
    UISwitch *swt = (UISwitch *)sender;
    if (swt.tag == 100) {
        [self.datasource setObject:@(swt.isOn) forKey: KEY_CONFIG_NOTIFY];
    }
    else
    {
         [self.datasource setObject:@(swt.isOn) forKey: KEY_CONFIG_AUTOUPDATE];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.datasource forKey:KEY_CONFIG];
}
@end