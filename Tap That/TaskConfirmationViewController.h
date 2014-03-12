//
//  TaskConfirmationViewController.h
//  Shelly
//
//  Created by Allan Zhang on 2/25/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TaskConfirmationViewController : UIViewController

@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) NSDictionary *currentPromptForShell;
@property (weak, nonatomic) IBOutlet UILabel *confirmationLabel;

- (IBAction)yesButtonTapped:(UIButton *)sender;
- (IBAction)noButtonTapped:(UIButton *)sender;



@end
