//
//  DidTheyReallyViewController.h
//  Shelly
//
//  Created by Allan Zhang on 2/26/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DidTheyReallyViewController : UIViewController

@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) PFObject *message;
@property (strong, nonatomic) NSString *userDecision;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
- (IBAction)yesButtonTapped:(UIButton *)sender;
- (IBAction)noButtonTapped:(UIButton *)sender;


@end
