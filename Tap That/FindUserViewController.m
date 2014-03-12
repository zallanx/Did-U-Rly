//
//  FindUserViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/19/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "FindUserViewController.h"

@interface FindUserViewController ()

@end

@implementation FindUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.findUserField.delegate = self;
}

#pragma mark - Textfield delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *textFromTextfield = textField.text;
    [textField resignFirstResponder];
    [self searchForUser:textFromTextfield];
    return NO;
}

- (void)searchForUser: (NSString *)username
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:username];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error: %@", error);
        } else {
            if (objects.count > 0){
                NSLog(@"The found user is %@", [objects lastObject]);
                PFUser *foundUser = [objects lastObject];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"foundUsername" object:foundUser.username];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}

@end
