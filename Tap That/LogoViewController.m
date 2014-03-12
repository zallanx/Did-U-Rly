//
//  LogoViewController.m
//  Tap That
//
//  Created by Allan Zhang on 1/21/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "LogoViewController.h"
#import "SignUpPart2ViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LogoViewController ()

@end

@implementation LogoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    
    
}

#pragma mark - Status bar controls

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"fbSignupName"]){
        SignUpPart2ViewController *usernameVC = (SignUpPart2ViewController *)segue.destinationViewController;
        usernameVC.facebookSignUpStatus = @"facebook";
    }
    
}

- (IBAction)loginWithFacebookAction:(UIButton *)sender
{
    NSArray *permissionsArray = @[@"user_photos", @"user_birthday"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        if (!user){
            if(!error){
                NSLog(@"User cancelled the Facebook login.");
            } else {
                NSLog(@"Error occured: %@", error);
            }
        } else if (user.isNew){
            NSLog(@"New Facebook user");
            NSLog(@"User is %@", user);
            [self performSegueWithIdentifier:@"fbSignupName" sender:self];
            
            
        } else {
            NSLog(@"Existing user with Facebook");
            NSLog(@"User is %@", user);
            [self.navigationController popToRootViewControllerAnimated:YES];
  
        }
    }];
}
@end
