//
//  ScoreAndRanksViewController.m
//  Shelly
//
//  Created by Allan Zhang on 2/27/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "ScoreAndRanksViewController.h"
#import "GameMessagesViewController.h"

@interface ScoreAndRanksViewController ()

@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation ScoreAndRanksViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    NSLog(@"the current game is %@", self.currentGame);
    self.currentUser = [PFUser currentUser];
    [self assessWhetherRecipientIsCorrect];
    [self checkIfMessageStillActive];
    
}

#pragma mark - Helper methods

- (void)assessWhetherRecipientIsCorrect
{
    NSString *senderTruePhotoTaken = self.message[@"senderTruePhotoTaken"]; //true or false
    if ([senderTruePhotoTaken isEqualToString:self.userDecision]){
        //User is correct, gets coins, etc
        [self giveOrTakeUserShells: @"give"];
        
        //Compare all ranks
        //Gets what other people guessed
    } else {
        [self giveOrTakeUserShells: @"take"];
        //User is incorrect, loses coins
        //Compare all ranks
        //Gets what other people guessed
    }
    
}

- (void)giveOrTakeUserShells: (NSString *)giveOrTake
{
    
    NSDictionary *messagePromptForShell = self.message[@"messagePromptForShell"];
    NSNumber *messageShellValue = [messagePromptForShell objectForKey:[messagePromptForShell allKeys].lastObject];
    NSLog(@"The messageShell Value is %@", messageShellValue);
    
    NSMutableDictionary *usersAndShellsInGame = [[NSMutableDictionary alloc] initWithDictionary: self.currentGame[@"userShellsInGame"]];
    
    NSNumber *userCurrentShellValue;
    for (NSString *key in [usersAndShellsInGame allKeys]){
        if ([key isEqualToString: self.currentUser.username]){
            userCurrentShellValue = [usersAndShellsInGame objectForKey:key];
            
            if ([giveOrTake isEqualToString:@"give"]){
                NSLog(@"User was right");
                
                NSString *coinsEarned = [NSString stringWithFormat: @"+%@", messageShellValue];
                self.coinsEarnedLabel.text = coinsEarned;
                
                userCurrentShellValue = [NSNumber numberWithFloat: ([userCurrentShellValue floatValue] + [messageShellValue floatValue])];
                

                
            } else if ([giveOrTake isEqualToString:@"take"]){
                NSLog(@"User was wrong");
                
                NSString *coinsEarned = [NSString stringWithFormat: @"-%f", [messageShellValue floatValue]*0.10];
                self.coinsEarnedLabel.text = coinsEarned;
                
                userCurrentShellValue = [NSNumber numberWithFloat: ([userCurrentShellValue floatValue] - ([messageShellValue floatValue]*0.10))];
                if ([userCurrentShellValue floatValue] < 0){
                    userCurrentShellValue = [NSNumber numberWithFloat:0.0];
                }
                
            }
            [usersAndShellsInGame setObject:userCurrentShellValue forKey:self.currentUser.username];
            
        }
    }
    
    NSLog(@"New value is %@", userCurrentShellValue);
    NSLog(@"The new scores dictionary is %@", usersAndShellsInGame);
    [self saveNewScoresDictionary:usersAndShellsInGame]; //Save to Parse
    
    [self recaluateRankBasedOnUsersAndCoins:usersAndShellsInGame];
    
}

- (void)saveNewScoresDictionary: (NSDictionary *)usersAndShellsInGame
{
    [self.currentGame setObject:usersAndShellsInGame forKey:@"userShellsInGame"];
    [self.currentGame saveInBackground];
}

- (void)recaluateRankBasedOnUsersAndCoins: (NSDictionary *)usersAndCoins
{

    NSArray *sortedKeys = [usersAndCoins keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        NSComparisonResult result;
        if ([obj1 integerValue] > [obj2 integerValue]) {
            
            result = (NSComparisonResult)NSOrderedAscending;
            return result;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            
            result = (NSComparisonResult)NSOrderedDescending;
            return result;
        }
        
        result = (NSComparisonResult)NSOrderedSame;
        return result;
    }];
    
    NSLog(@"The sortedKeys are %@", sortedKeys);
    
    
    NSMutableDictionary *newRankAndUserDictionary = [[NSMutableDictionary alloc] init];
    int previousScore;
    int currentScore;
    NSString *previousUserSeen;
    
    for (int i = 0; i < sortedKeys.count; i++){
        NSString *username = [sortedKeys objectAtIndex:i];
        if (i == 0){
            [newRankAndUserDictionary setObject: [NSNumber numberWithInt:i+1] forKey:username]; //sets the value as standard
        
        } else {
            currentScore = [[usersAndCoins objectForKey:username] intValue];
            if (currentScore == previousScore){ //If there is a tie between two ranks
                NSNumber *previousUsersRank = [newRankAndUserDictionary objectForKey:previousUserSeen];
                [newRankAndUserDictionary setObject:previousUsersRank forKey:username];
                
            } else {
                [newRankAndUserDictionary setObject: [NSNumber numberWithInt:i+1] forKey:username]; //sets the value as standard
            }
            
        }
    
        previousScore = [[usersAndCoins objectForKey:username] intValue];
        previousUserSeen = username;
    }
    
    NSLog(@"The new ranks are %@", newRankAndUserDictionary);
    [self saveNewRanksDictionary:newRankAndUserDictionary];
    
    self.rankChangeLabel.text = [NSString stringWithFormat:@"Your new rank is %@", [newRankAndUserDictionary objectForKey:self.currentUser.username]];

}

- (void)saveNewRanksDictionary: (NSDictionary *)newRanks
{
    [self.currentGame setObject:newRanks forKey:@"userRankingInGame"];
    [self.currentGame saveInBackground];
    
}


- (void)whatOthersGuessed
{
    NSString *messageSender = self.message[@"senderUsername"];
    NSString *currentUserName = [PFUser currentUser].username;
    NSArray *doNotMatchUsernames = @[messageSender, currentUserName];
    
    NSArray *usersAndAgreements = self.message[@"userAndAgreement"];
    for (NSDictionary *userAgreement in usersAndAgreements){
        if ([doNotMatchUsernames containsObject:[userAgreement allKeys].lastObject]){
            //show this item:
            NSLog(@"Useragreement %@ is fine", userAgreement);
        }
    }
    
    
}

- (void)checkIfMessageStillActive
{
    NSArray *currentMessageViewedBy = self.message[@"imageViewedBy"];
    NSArray *participantsInGame = self.currentGame[@"userNamesInGame"];
    
    currentMessageViewedBy = [currentMessageViewedBy sortedArrayUsingSelector:@selector(compare:)];
    participantsInGame = [participantsInGame sortedArrayUsingSelector:@selector(compare:)];
    
    if ([currentMessageViewedBy isEqualToArray:participantsInGame]) {
        NSLog(@"The arrays are the same, setting status to all seen");
        [self.message setObject:@"all seen" forKey:@"status"];
        [self.message saveInBackground];
        
    }
}


- (IBAction)doneButtonTapped:(UIButton *)sender
{
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for(int i=0 ; i<[viewControllers count]; i++){
        id obj = [viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[GameMessagesViewController class]]){
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
@end
