//
//  TurnIncrementViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/18/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface TurnIncrementViewController : UIViewController


@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) NSString *resetTurns;
@property (strong, nonatomic) NSString *updateTurn;
@property (weak, nonatomic) IBOutlet UILabel *showNewTurn;
- (IBAction)nextButtonTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;


@property (weak, nonatomic) IBOutlet UILabel *promptDisplayLabel;

@end
