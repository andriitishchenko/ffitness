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
    
    UIButton* buttonbk = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonbk setTitle:@"<" forState:UIControlStateNormal];
    [buttonbk setContentEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    buttonbk.titleLabel.transform = CGAffineTransformMakeScale(1,2);
    [buttonbk sizeToFit];
    
    [buttonbk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [buttonbk addTarget:self action:@selector(leftItem_click:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem*leftItem = [[UIBarButtonItem alloc] initWithCustomView:buttonbk ];
    //    [leftItem setTarget:self];
    //    [leftItem setAction:@selector(leftItem_click:)];
    
    //                                WithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(leftItem_click:)];
    
    //    [[self navigationItem] setBackBarButtonItem:leftItem];
    [[self navigationItem] setLeftBarButtonItem:leftItem];
    
    
    [API skinButton:self.buttonLoguot];
    
    
        self.navigationItem.title = NSLocalizedString(@"Settings", @"Settings");
    
    self.labelAddNotifications.text  = NSLocalizedString(@"Notify on expire", @"Notify on expire");
    self.labelUpdateAutomaticaly.text  = NSLocalizedString(@"Update automatically", @"Update automatically");
    
    self.labelAddtoCalendar.text = NSLocalizedString(@"Create iCal events", @"Create iCal events");

    
    self.datasource = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONFIG] mutableCopy];
    self.switchNotifications.on = [[self.datasource objectForKey:KEY_CONFIG_NOTIFY] boolValue];
    self.switchUpdateAutomaticaly.on = [[self.datasource objectForKey:KEY_CONFIG_AUTOUPDATE] boolValue];
    self.switchAddToCalendar.on = [[self.datasource objectForKey:KEY_CONFIG_ADDTOCALENDAR] boolValue];

}


-(IBAction)leftItem_click:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)swichChanged:(id)sender {
    UISwitch *swt = (UISwitch *)sender;
    AppDelegate*ap = ApplicationDelegate;
    
    if (swt.tag == 100) {
        [self.datasource setObject:@(swt.isOn) forKey: KEY_CONFIG_NOTIFY];
    }
    else if(swt.tag == 200){
        [self.datasource setObject:@(swt.isOn) forKey: KEY_CONFIG_AUTOUPDATE];
        [ap setBGStatus:swt.isOn];
    }
    else if(swt.tag == 300) {
        [self.datasource setObject:@(swt.isOn) forKey: KEY_CONFIG_ADDTOCALENDAR];
    }

    
    [[NSUserDefaults standardUserDefaults] setObject:self.datasource forKey:KEY_CONFIG];
}

- (IBAction)button_logout_click:(id)sender {
    [[API sharedInstance] logOutOnComplete:^(id response, NSError *error) {
       
    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
@end