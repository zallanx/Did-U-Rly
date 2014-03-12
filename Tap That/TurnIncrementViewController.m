//
//  TurnIncrementViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/18/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "TurnIncrementViewController.h"
#import "TapRewardSelectViewController.h"
#import "TakePhoto1Controller.h"

@interface TurnIncrementViewController ()


@end

@implementation TurnIncrementViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showWhatOtherUserWantPrompt];
    
    NSLog(@"Passed info %@", self.updateTurn);
    
    if ([self.updateTurn isEqualToString:@"Do not update"]){
        
    } else {
        if([self.resetTurns isEqualToString:@"Yes"]){
            [self updateTurnSubtractor];
        } else {
            [self incrementTurn];
        }
    }

    
}

- (void)showWhatOtherUserWantPrompt
{
    NSString *prompt = self.currentGame[@"currentTurnReward"];
    NSArray *playersInGame = [NSArray arrayWithArray:self.currentGame[@"userNamesInGame"]];
    NSString *theOtherPLayer;
    for (NSString *playerName in playersInGame){
        if (![playerName isEqualToString:[PFUser currentUser].username]){
            theOtherPLayer = playerName;
        }
    }
    NSString *message = [NSString stringWithFormat:@"Its your turn! %@ asked \nyou to take a picture of '%@'.", prompt, theOtherPLayer];
    
    self.instructionLabel.text = message;
}

- (void)updateTurnSubtractor
{
    NSNumber *resetTurnSubtractor = [self.currentGame objectForKey:@"currentTurnNumber"];
    [self.currentGame setObject:resetTurnSubtractor forKey:@"resetTurnSubtractor"];
    [self.currentGame saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            NSLog(@"Error %@", error);
        } else {
            [self incrementTurn];
        }
    }];
    
    
}

- (void)incrementTurn
{
    [self.currentGame incrementKey:@"currentTurnNumber" byAmount:[NSNumber numberWithInt:1]];
    [self.currentGame saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            
        } else {
            NSNumber *currentTurn = self.currentGame[@"currentTurnNumber"];
            NSNumber *resetTurnSubtractor = self.currentGame[@"resetTurnSubtractor"];
            NSNumber *turnToShow = [NSNumber numberWithInt:([currentTurn intValue] - [resetTurnSubtractor intValue])];
            self.showNewTurn.text = [NSString stringWithFormat:@"%@", turnToShow];
            
            [self updateGameStatus];
        }
    }];
}

- (void)updateGameStatus
{
    [self.currentGame setObject:@"Take picture" forKey:@"gameStatus"];
    [self.currentGame saveInBackground];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goTakePicture"]){
        TapRewardSelectViewController *tapRewardSelectionVC = (TapRewardSelectViewController *)segue.destinationViewController;
        tapRewardSelectionVC.currentGame = self.currentGame;
    }
}

- (IBAction)nextButtonTapped:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"goTakePicture" sender:self];
}
@end
