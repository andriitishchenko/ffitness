//
//  TableViewController.m
//  ffitness
//
//  Created by AndruX on 7/29/14.
//  Copyright (c) 2014 AndruX. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
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

@end
