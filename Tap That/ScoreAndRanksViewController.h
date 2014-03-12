//
//  ScoreAndRanksViewController.h
//  Shelly
//
//  Created by Allan Zhang on 2/27/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ScoreAndRanksViewController : UIViewController

@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) PFObject *message;
@property (strong, nonatomic) NSString *userDecision;

@property (weak, nonatomic) IBOutlet UILabel *coinsEarnedLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankChangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherGuessedLabel;
- (IBAction)doneButtonTapped:(UIButton *)sender;


@end
