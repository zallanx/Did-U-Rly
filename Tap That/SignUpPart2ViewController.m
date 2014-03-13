//
//  SignUpPart2ViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/16/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "SignUpPart2ViewController.h"
#include <stdlib.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SignUpPart2ViewController ()

@end

@implementation SignUpPart2ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColorFromRGB(0x2bade5);
    //self.view.backgroundColor = [UIColor colorWithRed:25/255.0 green:117/255.0 blue:189/255.0 alpha:1];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    [self.usernameField setLeftViewMode:UITextFieldViewModeAlways];
    [self.usernameField setLeftView:spacerView];
    
    self.textView.textContainerInset = UIEdgeInsetsMake(20, 16, 4, 16);

}

#pragma mark - helper methods

- (BOOL)userNameIsAcceptable: (NSString *)userNameInputted
{
    NSLog(@"The inputted result is >%@<", userNameInputted);
    NSCharacterSet *userNameAcceptedInput = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *filteredUserName = [[userNameInputted componentsSeparatedByCharactersInSet:userNameAcceptedInput] componentsJoinedByString:@""];
    NSLog(@"The filtered result >%@<", filteredUserName);
    
    if ([userNameInputted isEqualToString:filteredUserName]){
        return YES;
    } else {
        return NO;
    }
}

- (void)associatePFInstallation
{
    //Associate the PFInstallatio with the current user that just signed up
    NSLog(@"The current user is %@", [PFUser currentUser].username);
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
}

- (void)associateUserTapsSentCount
{
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:[NSNumber numberWithInt:0] forKey:@"tapsCount"];
    [currentUser saveInBackground];
}

- (void)associateBirthdateWithCurrentUser
{
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:self.passedBirthdate forKey:@"birthdate"];
    [currentUser saveInBackground];
}



- (IBAction)registerButtonAction:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    NSString *userName = [self.usernameField.text lowercaseString];
    BOOL userNameAcceptable = [self userNameIsAcceptable:userName];
    NSLog(userNameAcceptable ? @"Name is accepted" : @"Name is NOT accepted");
    
    if ([userName length] == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"Please enter an username" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        [self.activityIndicator stopAnimating];
        self.registerButton.userInteractionEnabled = YES;
    } else if (userNameAcceptable == NO){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again..." message:@"Please use only regular characters and numbers without any spaces in your username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [self.activityIndicator stopAnimating];
        self.registerButton.userInteractionEnabled = YES;
    } else if (([[userName componentsSeparatedByString:@" "] count] - 1) > 0 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username error" message:@"Please do not have any spaces in your username" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [self.activityIndicator stopAnimating];
        self.registerButton.userInteractionEnabled = YES;
    } else if (userName.length < 4){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again..." message:@"Please make your username 4 characters or longer." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [self.activityIndicator stopAnimating];
        self.registerButton.userInteractionEnabled = YES;
    } else {
        
        //Sign up new user if NOT using Facebook
        if (![self.facebookSignUpStatus isEqualToString:@"facebook"]){
        
            PFUser *newUser = [PFUser new];
            newUser.username = userName;
            newUser.password = self.passedPass;
            newUser.email = self.passedEmail;
            
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    [self.activityIndicator stopAnimating];
                    self.registerButton.userInteractionEnabled = YES;
                } else {
                    [self associatePFInstallation];
                    [self associateUserTapsSentCount];
                    [self associateBirthdateWithCurrentUser];
                    [self associateDefaultAvatar];
                    
                    [self.navigationController popToRootViewControllerAnimated:NO]; //Goes back to inbox
                    
                    [self.activityIndicator stopAnimating];
                    self.registerButton.userInteractionEnabled = YES;
                    
                    
                }
            }];
        
        } else if ([self.facebookSignUpStatus isEqualToString:@"facebook"]){
            // Else, merely associate the new username
            // There is a current user
            
            NSLog(@"Facebook set up");
            
            PFUser *currentUser = [PFUser currentUser];
            currentUser.username = userName;
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    [self.activityIndicator stopAnimating];
                    self.registerButton.userInteractionEnabled = YES;
                } else {
                    [self associatePFInstallation];
                    [self facebookFirstTimeSetup];
                    [self.navigationController popToRootViewControllerAnimated:NO]; //Goes back to inbox
                    
                    [self.activityIndicator stopAnimating];
                    self.registerButton.userInteractionEnabled = YES;
                }
            }];
            
        }
        
    }

}

- (void)facebookFirstTimeSetup
{
    NSLog(@"Commencing Facebook setup.");
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error){
            NSDictionary *userData = (NSDictionary *)result;
            NSLog(@"The retrived data is %@", userData);
            
            //- Store Facebook ID and full name
            NSString *facebookID = userData[@"id"];
            NSString *userFirstName = userData[@"first_name"];
            NSString *userLastName = userData[@"last_name"];
            
            //-Calculate age
            NSString *birthdayString = userData[@"birthday"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            NSDate *birthDate = [dateFormat dateFromString:birthdayString];
            
            //- Store gender and gender preferences
            NSString *gender = userData[@"gender"];
            
            //- Save Facebook information to Parse
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:facebookID forKey:@"fbID"];
            [currentUser setObject:userFirstName forKey:@"fbFirstName"];
            [currentUser setObject:userLastName  forKey:@"fbLastName"];
            [currentUser setObject:birthDate forKey:@"birthdate"];
            [currentUser setObject:gender forKey:@"fbGender"];
            
            [currentUser saveInBackground];
            [self storeFBProfilePictureURLS];
            [self getListOfFriends];
            
        } //end if(!error)

    }];

}

- (void)associateDefaultAvatar
{
    int r = (arc4random() % 9) + 1;
    NSNumber *avatarImageIndex = [NSNumber numberWithInt:r];
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:avatarImageIndex forKey:@"avatarImageIndex"];
    [currentUser saveInBackground];
}

-(void)storeFBProfilePictureURLS
{
    NSString *queryForProfilePicturesFromCurrentUser =
    @"SELECT owner, src_big FROM photo WHERE aid IN ( SELECT aid FROM album WHERE name='Profile Pictures' AND owner=me()) LIMIT 4";
    NSMutableArray *profilePictureArraysToStore = [[NSMutableArray alloc] init];
    NSDictionary *queryParam = @{ @"q": queryForProfilePicturesFromCurrentUser };
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error){
            NSArray *parsedResultData = [result objectForKey:@"data"]; //result is natively a dictionary, 4 dictionaries inside.  gets those 4 inside an array
            for (NSDictionary *eachPictureDictionary in parsedResultData){
                NSString *pictureURLString = [eachPictureDictionary objectForKey:@"src_big"];
                [profilePictureArraysToStore addObject:pictureURLString];
            }
            
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        
        //- After populating queryForProfilePicturesFromCurrentUser, save it to Parse
        PFUser *currentUser = [PFUser currentUser];
        [currentUser setObject:profilePictureArraysToStore forKey:@"fbProfilePictures"];
        [currentUser saveInBackground];
    }];
    NSLog(@"Pictures stored!");
}

-(void) getListOfFriends
{
    PFUser *currentUser = [PFUser currentUser];
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSString *friendIDToStore = friend.id;
            [currentUser addObject:friendIDToStore forKey:@"fbUserFriendIDs"]; //store user's list of friends in array
        }
        [currentUser saveEventually];
    }];
    
}

@end














