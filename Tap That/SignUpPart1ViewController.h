//
//  SignUpPart1ViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/16/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SignUpPart1ViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *emailSignUpField;
@property (weak, nonatomic) IBOutlet UITextField *passwordSignUpField;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)signupButtonPressed:(UIButton *)sender;





@end
