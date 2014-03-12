//
//  SignUpPart2ViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/16/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SignUpPart2ViewController : UIViewController

@property (strong, nonatomic) NSString *passedEmail;
@property (strong, nonatomic) NSString *passedPass;
@property (strong, nonatomic) NSDate *passedBirthdate;
@property (strong, nonatomic) NSString *facebookSignUpStatus;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)registerButtonAction:(UIButton *)sender;



@end
