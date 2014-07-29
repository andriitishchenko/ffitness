//
//  ViewController.m
//  ffitness
//
//  Created by AndruX on 7/28/14.
//  Copyright (c) 2014 AndruX. All rights reserved.
//

#import "ViewController.h"
#import "ScannerViewController.h"
#import "TableViewController.h"
#import <ALAlertBanner/ALAlertBanner.h>


@interface ViewController ()<barCodeScanedDelegate>
@property(strong,nonatomic) NSMutableDictionary* datasource;
@property(strong,nonatomic) NSMutableDictionary* postCredentials;
-(void)observeKeyboard;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = NSLocalizedString(@"Fort-Fitness", @"Fort-Fitness");
    [self observeKeyboard];
    self.postCredentials = [API getSuccessCredentials];
    //[[[NSUserDefaults standardUserDefaults] objectForKey:PAYLOADS] mutableCopy];
    if (!self.postCredentials) {
        self.postCredentials = [NSMutableDictionary new];
    }
    else
    {
        self.textFieldCard.text = [self.postCredentials objectForKey:@"card"];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSString *day = [self.postCredentials valueForKey:@"day"];
        NSString *month = [self.postCredentials valueForKey:@"month"];
        NSString *year = [self.postCredentials valueForKey:@"year"];
        [components setDay:[day intValue]];
        [components setMonth:[month intValue]];
        [components setYear:[year intValue]];
        NSDate *_date = [calendar dateFromComponents:components];
        [self.datePicker setDate:_date];
        
        [[API sharedInstance] getUpdatesOnComplete:^(id response, NSError *error) {
            if (response && !error) {
                self.datasource = (NSMutableDictionary*)response;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"viewDetails" sender:self.view];
                });

            }
        }];
    }
    
}


- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground:)];
    [self.view addGestureRecognizer:tapBackground];
}

- (void)tapBackground:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.view endEditing:YES];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat ck = DefaultKeyboardHeigth+10;
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomConstraint.constant = ck;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomConstraint.constant = 10.0f;
        [self.view layoutIfNeeded];
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)barCodeDidScaned:(NSString*)barString{
    if (barString) {
        self.textFieldCard.text = barString;

    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"barcodesegue"]) {
        ScannerViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"viewDetails"]) {
            TableViewController *vc = (TableViewController*)segue.destinationViewController;
            vc.datasource = self.datasource;
        }
}



-(void)getSelection
{
    NSLocale *usLocale = [[NSLocale alloc]
                          initWithLocaleIdentifier:@"en_US"];
    

    NSDate* dt = self.datePicker.date;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:dt];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    
    [self.postCredentials setObject:[NSString withInteger: year] forKey:@"year"];
    [self.postCredentials setObject:[NSString withInteger: month] forKey:@"month"];
    [self.postCredentials setObject:[NSString withInteger: day] forKey:@"day"];
}

-(void)failMessage{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(failMessage) withObject:nil waitUntilDone:NO];
        return;
    }
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:ALAlertBannerStyleFailure
                                                     position:ALAlertBannerPositionTop
                                                        title:NSLocalizedString(@"Fail", @"Fail")
                                                     subtitle:NSLocalizedString(@"Code or birthday incorrect", @"Code or birthday incorrect")];
    [banner show];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textFieldCard) {
        [textField resignFirstResponder];
        [self buttonAuth_click:nil];
        return NO;
    }
    return YES;
}

- (IBAction)buttonAuth_click:(id)sender {
    [self getSelection];
    if ([self.textFieldCard.text length]==0) {
        return;
    }
    [self.postCredentials setObject:[self.textFieldCard.text copy] forKey:@"card"];

    [[API sharedInstance] userLogIn:self.postCredentials Complete:^(id response, NSError *error) {
        if (!error && response) {
            self.datasource = (NSMutableDictionary*)response;
            
            if ([self.datasource count] == 4){
                [[NSUserDefaults standardUserDefaults] setObject:self.datasource forKey:BACKGROUND_DATA_KEY];
                [[NSUserDefaults standardUserDefaults] setObject:self.postCredentials forKey:PAYLOADS];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"viewDetails" sender:sender];
                });
            }
        }
        else
        {
            ALog(@"Login err %@",[error domain]);
            [self failMessage];
        }

    }];
    

    
}
@end
