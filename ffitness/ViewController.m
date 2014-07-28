//
//  ViewController.m
//  ffitness
//
//  Created by AndruX on 7/28/14.
//  Copyright (c) 2014 AndruX. All rights reserved.
//

#import "ViewController.h"
#import "TFHpple.h"
#import "ScannerViewController.h"
#import "TableViewController.h"

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
    
    [self observeKeyboard];

    self.postCredentials = [NSMutableDictionary new];

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
            TableViewController *vc = segue.destinationViewController;
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

- (IBAction)buttonAuth_click:(id)sender {
    [self getSelection];
    [self.postCredentials setObject:[self.textFieldCard.text copy] forKey:@"card"];
    
    [[API sharedInstance] userLogIn:self.postCredentials Complete:^(id response, NSError *error) {
        if (!error && response) {
            self.datasource = [NSMutableDictionary new];
            
            TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:(NSData*)response];
            NSArray * tds  = [doc searchWithXPathQuery: @"//table[@class='block']/tr/td[position() mod 2 = 0]"];
            
            for (NSInteger i;i<[tds count];i++) {
                TFHppleElement * e = [tds objectAtIndex:i];
                NSString*value  =  [e text];
                if (i == 0) { //fio
                    [self.datasource setObject:value forKey:@"fio"];
                }
                else if (i == 1) { //expire date
                    [self.datasource setObject:value forKey:@"expire"];
                }
                else if (i == 2) { //training count
                    [self.datasource setObject:value forKey:@"balance"];
                }
                else if (i == 3) { //money balance
                    [self.datasource setObject:value forKey:@"money"];
                }
                
            }
            
            if ([self.datasource count] == 4){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"viewDetails" sender:sender];
                });
            }
            
            
        }

    }];
     

    
}
@end
