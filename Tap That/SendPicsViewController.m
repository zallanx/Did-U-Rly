//
//  SendPicsViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/18/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "SendPicsViewController.h"
#import "TakePhoto1Controller.h"
#import "TakePhoto2Controller.h"
#include "AppDelegate.h"

#define appDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface SendPicsViewController ()

@property (strong, nonatomic) UIImage *image1;
@property (strong, nonatomic) UIImage *image2;
@property (strong, nonatomic) NSString *photo1WhereTapped;
@property (strong, nonatomic) NSString *photo1NumberOfTries;
@property (strong, nonatomic) NSString *photo1Brief;
@property (strong, nonatomic) NSString *photo2Brief;
@property (strong, nonatomic) NSString *tapOrTakePicture;

@end

@implementation SendPicsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.enterPromptField.delegate = self;
    
    NSLog(@"SEND CONTROLLER The passed game is %@", self.currentGame);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.progressBar.hidden = NO;
    //Check if turn is 0.. if so, increment the turn quietly
    [self checkAndIncreaseFirstGameTurn];
    
    
    [self setInstructionMessage];
    [self saveAppDelegateImageStorage];
    [self uploadMessageAndAssociateWithGame];
}

- (void)checkAndIncreaseFirstGameTurn
{
    NSNumber *gameTurn = self.currentGame[@"currentTurnNumber"];
    NSString *stringRepresentation = [NSString stringWithFormat:@"%@", gameTurn];
    if ([stringRepresentation isEqualToString:@"0"]){
        [self.currentGame incrementKey:@"currentTurnNumber" byAmount:[NSNumber numberWithInt:1]];
        [self.currentGame saveInBackground];
    }
    
}

- (void)setInstructionMessage
{
    NSString *otherPlayer = [self getOtherPlayer:self.currentGame];
    NSString *message = [NSString stringWithFormat:@"Now you get to choose: what \nshould %@'s secret \nphoto be about?", otherPlayer];
    self.instructionLabel.text = message;
    self.tapsProgress.text = @"Sending Tap...";
    
}


- (void)saveAppDelegateImageStorage
{
    self.image1 = [appDelegate.imageStorageDictionary objectForKey:@"picture1"];
    self.image2 = [appDelegate.imageStorageDictionary objectForKey:@"picture2"];
    self.photo1NumberOfTries = [appDelegate.imageStorageDictionary objectForKey: @"picture1NumberOfTaps"];
    //! if condition to be removed
    if (!self.photo1NumberOfTries){
        self.photo1NumberOfTries = @"6";
    }
    self.photo1WhereTapped = [appDelegate.imageStorageDictionary objectForKey:@"photo1WhereTapped"];
    self.photo1Brief = [appDelegate.imageStorageDictionary objectForKey:@"picture1Brief"];
    self.photo2Brief = [appDelegate.imageStorageDictionary objectForKey:@"picture2Brief"];
}

- (void)uploadMessageAndAssociateWithGame
{
    UIImage *image1New = self.image1;
    NSData *fileDataForImage1 = UIImageJPEGRepresentation(image1New, 80);
    NSString *fileNameForImage1 = @"image1.jpg";
    
    UIImage *image2New = self.image2;
    NSData *fileDataForImage2 = UIImageJPEGRepresentation(image2New, 80);
    NSString *fileNameForImage2 = @"image2.jpg";
    
    PFFile *fileForImage1 = [PFFile fileWithName:fileNameForImage1 data:fileDataForImage1];
    PFFile *fileForImage2 = [PFFile fileWithName:fileNameForImage2 data:fileDataForImage2];
    
    [fileForImage1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was a connection issue and the Tap didn't get sent.  Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alertView show];
            
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"messageUploadInterrupted" object:nil];
            //NSLog(@"Posts interrupted notification ");
        } else {
            NSLog(succeeded ? @"Succeeded in uploading first picture" : @"No");
            [fileForImage2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was a connection issue and the Tap didn't get sent.  Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alertView show];
                    
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"messageUploadInterrupted" object:nil];
                    //NSLog(@"Posts interrupted notification ");
                } else {
                    NSLog(succeeded ? @"Succeeded in uploading second picture" : @"No");
                    PFObject *message = [PFObject objectWithClassName:@"Message"];
                    
                    [message setObject:fileForImage1 forKey:@"image1"];
                    [message setObject:fileForImage2 forKey:@"image2"];
                    [message setObject:self.photo1WhereTapped forKey:@"photo1WhereTapped"];
                    [message setObject:self.photo1NumberOfTries forKey:@"photo1NumberOfTries"];
                    //Game.objectId : currentTurnNumber
                    NSDictionary *gameAndTurn = @{self.currentGame.objectId : [NSString stringWithFormat:@"%@", self.currentGame[@"currentTurnNumber"]]};
                    [message setObject:[NSString stringWithFormat:@"%@", self.currentGame[@"currentTurnNumber"]] forKey:@"currentGameTurnBelongingTo"];
                    [message setObject:[NSString stringWithFormat:@"%@", self.currentGame[@"resetTurnSubtractor"]] forKey:@"currentGameTurnSubtractor"];
                    [message setObject:gameAndTurn forKey:@"gameAndTurn"];
                    [message setObject:self.currentGame.objectId forKey:@"gameBelongingTo"];
                    
                    
                    
                    
                    if (self.photo1Brief){
                        [message setObject:self.photo1Brief forKey:@"photo1Brief"];
                    }
                    if (self.photo2Brief){
                        [message setObject:self.photo2Brief forKey:@"photo2Brief"];
                    }
                    
                    
                    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error){
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was a connection issue and the Tap didn't get sent. Please try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            [alertView show];
                            
                            //[[NSNotificationCenter defaultCenter] postNotificationName:@"messageUploadInterrupted" object:nil];
                            //NSLog(@"Posts interrupted notification ");
                        } else {

                            NSLog(@"!---- Message has been uploaded ----!");

                            //<-- Send push notification here when needed
                            [self associateMessageWithCurrentGame:message];
                            [self incrementUserTapsCount];
                            [self resetPhotosVideosAndRecipients];
                            
                        }
                    }];
                }
            } progressBlock:^(int percentDone) {
                //!---- PROGRESS BLOCK for !--- Second Image
                NSLog(@"Second picture is %i done", percentDone);
                if (percentDone < 50) percentDone = 50;
                float barProgress = percentDone / 100.0;
                self.progressBar.progress = barProgress;
                
                if (percentDone == 100){
                    self.tapsProgress.text = @"Tap sent!";
                    self.progressBar.hidden = YES;
                }
                
            }];
        }
        
    } progressBlock:^(int percentDone) {
        //@---- PROGRESS BLOCK for @--- First Image
        NSLog(@"First picture is %i done", percentDone);
        float barProgress = percentDone / 200.0;
        self.progressBar.progress = barProgress;
        
    }];
}



- (void)associateMessageWithCurrentGame: (PFObject *)message
{
    PFRelation *gameMessage = [self.currentGame relationForKey:@"gameMessages"];
    [gameMessage addObject:message];
    [self.currentGame saveInBackground];
}

- (void)incrementUserTapsCount
{
    PFUser *currentUser = [PFUser currentUser];
    [currentUser incrementKey:@"tapsCount" byAmount:[NSNumber numberWithInt:1]];
    [currentUser saveInBackground];
}

- (void)resetPhotosVideosAndRecipients
{

    TakePhoto2Controller *takePhoto2Controller;
    TakePhoto1Controller *takePhoto1Controller;

    for (UIViewController *viewController in self.navigationController.viewControllers){
        if ([viewController isKindOfClass:[TakePhoto1Controller class]]){
            takePhoto1Controller = (TakePhoto1Controller *)viewController;
        }
        if ([viewController isKindOfClass:[TakePhoto2Controller class]]){
            takePhoto2Controller = (TakePhoto2Controller *)viewController;
        }
    }

    NSLog(@"The controller is %@", takePhoto2Controller);
    NSLog(@"Done");
    takePhoto2Controller.imageTakenOrSelected = nil;
    takePhoto2Controller.briefLabel.text = nil;
    takePhoto2Controller.drawView.image = nil;

    NSLog(@"The controller is %@", takePhoto1Controller);
    NSLog(@"Done");
    takePhoto1Controller.imageTakenOrSelected = nil;
    takePhoto1Controller.briefLabel.text = nil;
    takePhoto1Controller.drawView.image = nil;
    //[takePhoto1Controller.tapSelectionView removeFromSuperview];
    
    [appDelegate.imageStorageDictionary removeAllObjects];
}

- (void)changeGameStatusAndCurrentTurnPlayerAndRetutnToInbox{ //Currently works with 2 players
    //1. Change game status
    [self.currentGame setObject:@"Tap" forKey:@"gameStatus"];
    
    //2. Change the current game's currenTurnPlayer - both username and ID
    NSArray *playersInGame = [NSArray arrayWithArray:self.currentGame[@"userNamesInGame"]];
    NSString *thisPlayersTurnToPlay;
    for (NSString *playerName in playersInGame){
        if (![playerName isEqualToString:[PFUser currentUser].username]){
            thisPlayersTurnToPlay = playerName;
        }
    }
    NSLog(@"the new player is %@", thisPlayersTurnToPlay);
    NSLog(@"Done");
    
    [self.currentGame setObject:thisPlayersTurnToPlay forKey:@"currentTurnPlayerName"];
    
    NSArray *playerIDsInGame = [NSArray arrayWithArray:self.currentGame[@"userIDsInGame"]];
    NSString *thisPlayerIDsTurnToPLay;
    for (NSString *playerID in playerIDsInGame){
        if (![playerID isEqualToString:[PFUser currentUser].objectId]){
            thisPlayerIDsTurnToPLay = playerID;
        }
    }
    NSLog(@"the new player ID is %@", thisPlayerIDsTurnToPLay);
    NSLog(@"Done");
    
    [self.currentGame setObject:thisPlayerIDsTurnToPLay forKey:@"currentTurnPlayer"];
    
    //3. Save, then seguer
    [self.currentGame saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            NSLog(@"Error %@", error);
        } else {
            //All good here
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
}

#pragma mark - Textfield delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *textFromTextfield = textField.text;
    self.promptLabel.text = textFromTextfield;
    [textField resignFirstResponder];
    return NO;
}

- (void)updateGameObjectWithNewPrompt
{
    [self.currentGame setObject: self.promptLabel.text forKey:@"currentTurnReward"];
    [self.currentGame setObject:@"Take picture" forKey:@"gameStatus"];
    
    NSNumber *presentTurn= self.currentGame[@"currentTurnNumber"];
    NSDictionary *currentTurnAndReward = @{[NSString stringWithFormat:@"%@", presentTurn] : self.promptLabel.text};
    
    [self.currentGame addObject:currentTurnAndReward forKey:@"turnAndReward"];
    [self.currentGame saveInBackground];
    
}

- (IBAction)requestButtonTapped:(UIButton *)sender
{
    [self updateGameObjectWithNewPrompt];
    [self changeGameStatusAndCurrentTurnPlayerAndRetutnToInbox];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Helper methods

- (NSString *)getOtherPlayer: (PFObject *)game
{
    NSString *theOtherPlayer;
    NSArray *playersInGame = [NSArray arrayWithArray:game[@"userNamesInGame"]];
    for (NSString *playerName in playersInGame){
        if (![playerName isEqualToString:[PFUser currentUser].username]){
            theOtherPlayer = playerName;
        }
    }
    
    return theOtherPlayer;
}

@end
