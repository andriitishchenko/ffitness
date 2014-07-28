//
//  ViewController.h
//  ffitness
//
//  Created by AndruX on 7/28/14.
//  Copyright (c) 2014 AndruX. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UITextField *textFieldCard;

@property (weak, nonatomic) IBOutlet UIButton *buttonAuth;
- (IBAction)buttonAuth_click:(id)sender;



@end
