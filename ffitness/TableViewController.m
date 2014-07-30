//
//  TableViewController.m
//  ffitness
//
//  Created by AndruX on 7/29/14.
//  Copyright (c) 2014 AndruX. All rights reserved.
//

#import "TableViewController.h"
#import <MessageUI/MessageUI.h>
#import <ALAlertBanner/ALAlertBanner.h>


@interface TableViewController ()<MFMailComposeViewControllerDelegate>
@property(strong,nonatomic) NSArray*keys ;
@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Fort-Fitness", @"Fort-Fitness");
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                               target:self
                               action:@selector(refresh:)];
    self.navigationItem.leftBarButtonItem = button;
    
    UIBarButtonItem *btnSetting = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)];

    self.navigationItem.rightBarButtonItem = btnSetting;
    
//    NSMutableDictionary*oldD = [[[NSUserDefaults standardUserDefaults] objectForKey:BACKGROUND_DATA_KEY] mutableCopy];
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
- (IBAction)buttonEmail_click:(id)sender {
    [self sendEmail];
}
- (IBAction)buttonCall_click:(id)sender {
    NSString *phoneNumber = [@"tel://" stringByAppendingString:SETTINGS_KEY_PHONE];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


-(IBAction)refresh:(id)sender{
    [[API sharedInstance] getUpdatesOnComplete:^(id response, NSError *error) {
        if (response && !error) {
            self.datasource = (NSMutableDictionary*)response;
            
            
            [self.tableView reloadDataInMainThread];
        }
    }];
}


-(IBAction)settings:(id)sender{
    [self performSegueWithIdentifier:@"settings_segue" sender:sender];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"detailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    NSString*key = nil;
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Name",@"Name");
        key = KEY_FIO;
    }else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Expire",@"Expire");
        key = KEY_EXPIRE;
    }else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Remaining visits",@"Remaining visits");
        key = KEY_BALANCE;
    }else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Balance $",@"Balance $");
        key = KEY_MONEY;
    }

    cell.detailTextLabel.text = [self.datasource objectForKey:key];
    
    return cell;
}


-(void)sendEmail {
    // Email Subject
    NSString *emailTitle = @"Hello there!";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:SETTINGS_KEY_EMAIL];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString*message = NSLocalizedString(@"Error", @"Error");
    ALAlertBannerStyle style =ALAlertBannerStyleFailure ;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message = NSLocalizedString(@"Mail cancelled", @"Mail cancelled");
            style =ALAlertBannerStyleWarning ;
            break;
        case MFMailComposeResultSaved:
            message = NSLocalizedString(@"Mail saved", @"Mail saved");
            style =ALAlertBannerStyleNotify ;
            break;
        case MFMailComposeResultSent:
            message = NSLocalizedString(@"Mail sent", @"Mail sent");
            style =ALAlertBannerStyleSuccess ;
            break;
        case MFMailComposeResultFailed:
            style =ALAlertBannerStyleFailure ;
            message = [error localizedDescription];
            break;
        default:
            style =ALAlertBannerStyleFailure ;
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:style
                                                     position:ALAlertBannerPositionTop
                                                        title:NSLocalizedString(@"Send email", @"Send email")
                                                     subtitle:message];
    [banner show];
}

@end
