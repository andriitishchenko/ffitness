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
    
}


-(IBAction)refresh:(id)sender{
    
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
    
    NSArray*keys = [self.datasource allKeys];
    NSString*key = keys[indexPath.row];
    
    cell.detailTextLabel.text = [self.datasource objectForKey:key];
    
    if ([key isEqualToString:KEY_FIO]) {
        cell.textLabel.text = NSLocalizedString(@"Name",@"Name");
    }else if ([key isEqualToString:KEY_EXPIRE]) {
        cell.textLabel.text = NSLocalizedString(@"Expire",@"Expire");
    }
    else if ([key isEqualToString:KEY_BALANCE]) {
        cell.textLabel.text = NSLocalizedString(@"Membership",@"Membership");
    }
    else if ([key isEqualToString:KEY_MONEY]) {
        cell.textLabel.text = NSLocalizedString(@"Balance $",@"Balance $");
    }
    return cell;
}

@end
