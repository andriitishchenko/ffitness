//
//  ViewController.h
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SettingsViewController.h"

@protocol barCodeScanedDelegate;
@interface ScannerViewController : UIViewController<UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray * allowedBarcodeTypes;

@property(assign,nonatomic) id<barCodeScanedDelegate> delegate;

- (IBAction)button_cancel_click:(id)sender;

@end


@protocol barCodeScanedDelegate <NSObject>
-(void)barCodeDidScaned:(NSString*)barString;
@end