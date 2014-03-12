//
//  LoginViewController.m
//  Kenzo
//
//  Created by Allan Zhang on 12/10/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface LoginViewController ()

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.navigationItem.hidesBackButton = YES; //Hides the goes back message button
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        //use larger image
    }
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    [self.userNameField setLeftViewMode:UITextFieldViewModeAlways];
    [self.userNameField setLeftView:spacerView];
    
    UIView *mootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftView:mootView];
    
    //self.userNameField.delegate = self;
    //self.passwordField.delegate = self;
    self.view.backgroundColor = UIColorFromRGB(0x2bade5);
    [self.view addSubview:self.activityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    self.loginButton.userInteractionEnabled = YES;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.userNameField becomeFirstResponder];
}

- (IBAction)loginButtonTouched:(id)sender {
    self.loginButton.userInteractionEnabled = NO;
    [self.activityIndicator startAnimating];
    NSString *userName = [self.userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //trims white spaces
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([userName length] == 0 || [password length] == 0 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Enter something yo" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        self.loginButton.userInteractionEnabled = YES;
        [self.activityIndicator stopAnimating];
        
    } else {
        
        [PFUser logInWithUsernameInBackground:userName password:password block:^(PFUser *user, NSError *error) {
            
            if(error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                self.loginButton.userInteractionEnabled = YES;
                [self.activityIndicator stopAnimating];
            } else {
                //Associate the PFInstallatio with the current user that just logged in
                NSLog(@"The current user is %@", [PFUser currentUser].username);
                PFInstallation *installation = [PFInstallation currentInstallation];
                installation[@"user"] = [PFUser currentUser];
                [installation saveInBackground];
                
                [self.navigationController popToRootViewControllerAnimated:NO];
                self.loginButton.userInteractionEnabled = YES;
                [self.activityIndicator stopAnimating];
            }
        }];
    }
    
}

- (IBAction)dismissView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Text field delegate methods


/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
 */


@end






