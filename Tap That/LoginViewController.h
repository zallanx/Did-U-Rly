//
//  LoginViewController.h
//  Kenzo
//
//  Created by Allan Zhang on 12/10/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)loginButtonTouched:(id)sender;
- (IBAction)dismissView:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



@end
