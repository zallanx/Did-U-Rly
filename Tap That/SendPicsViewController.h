//
//  SendPicsViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/18/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SendPicsViewController : UIViewController <UITextFieldDelegate>

//Current game
@property (strong, nonatomic) PFObject *currentGame;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterPromptField;
- (IBAction)requestButtonTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *tapsProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;



@end
