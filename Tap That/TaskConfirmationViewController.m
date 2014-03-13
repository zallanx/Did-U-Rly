//
//  TaskConfirmationViewController.m
//  Shelly
//
//  Created by Allan Zhang on 2/25/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#define appDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#import "TaskConfirmationViewController.h"
#import "AppDelegate.h"
#import "TakePhoto1Controller.h"



@interface TaskConfirmationViewController ()

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageBrief;
@property (strong, nonatomic) NSString *senderTruePhoto;

@end

@implementation TaskConfirmationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"TASK CONFIRMATION The passed game is %@", self.currentGame);
    NSLog(@"TASK CONFIRMATION The passed prompt is %@", self.currentPromptForShell);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self saveAppDelegateImageStorage];
}

- (void)saveAppDelegateImageStorage
{
    self.image = [appDelegate.imageStorageDictionary objectForKey:@"picture1"];
    self.imageBrief = [appDelegate.imageStorageDictionary objectForKey:@"picture1Brief"];
}

- (void)testForNil
{
    NSLog(@"Image: %@", self.image);
    NSLog(@"Imagebrief: %@", self.imageBrief);
    NSLog(@"trueSender: %@", self.senderTruePhoto);
    NSLog(@"promptforshell: %@", self.currentPromptForShell);
    NSLog(@"gameID: %@", self.currentGame.objectId);
}

#pragma mark - Image upload

- (void)uploadMessageAndAssociateWithGame
{
    UIImage *image1New = self.image;
    NSData *fileDataForImage1 = UIImageJPEGRepresentation(image1New, 80);
    NSString *fileNameForImage1 = @"image.jpg";
    PFFile *fileForImage1 = [PFFile fileWithName:fileNameForImage1 data:fileDataForImage1];
    PFUser *currentUser = [PFUser currentUser];
    
    [fileForImage1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was a connection issue and the Tap didn't get sent.  Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alertView show];

        } else {
            NSLog(succeeded ? @"Succeeded in uploading second picture" : @"No");
            PFObject *message = [PFObject objectWithClassName:@"Message"];
            
            [message setObject:fileForImage1 forKey:@"image"];
            [message setObject:self.senderTruePhoto forKey:@"senderTruePhotoTaken"];
            [message setObject:self.currentPromptForShell forKey:@"messagePromptForShell"];
            if (self.imageBrief){
                [message setObject:self.imageBrief forKey:@"imageBrief"];
            }
            [message setObject:self.currentGame.objectId forKey:@"gameBelongingTo"];  //Associate message with the game
            [message setObject:[PFUser currentUser].username forKey:@"senderUsername"];
            [message setObject:[PFUser currentUser].objectId forKey:@"senderUserID"];
            
            NSString *imageURL = [currentUser objectForKey:@"fbProfilePicture"];
            NSNumber *avatarIndex = [currentUser objectForKey:@"avatarImageIndex"];
            if (imageURL.length > 0){
                //indeed FB
                [message setObject:imageURL forKey:@"senderFBPicture"];
            } else {
                [message setObject:avatarIndex forKey:@"senderAvatarImage"];
            }
            
            [message setObject:@"active" forKey:@"status"];
            [message addObject:[PFUser currentUser].username forKey:@"imageViewedBy"];
            
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was a connection issue and the Tap didn't get sent. Please try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                    
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"messageUploadInterrupted" object:nil];
                    //NSLog(@"Posts interrupted notification ");
                } else {
                    
                    NSLog(@"!---- Message has been uploaded ----!");
                    
                    //<-- Send push notification here when needed
                    [self resetPhotosVideosAndRecipients];
                    [self associateMessageWithCurrentGame:message];
                    
                    
                    
                }
            }];
        }
        
    } progressBlock:^(int percentDone) {
        //@---- PROGRESS BLOCK for @--- First Image
        NSLog(@"First picture is %i done", percentDone);

    }];
}

#pragma mark - Helper methods

- (void)associateMessageWithCurrentGame: (PFObject *)message
{
    PFRelation *gameMessage = [self.currentGame relationForKey:@"gameMessages"];
    [gameMessage addObject:message];
    [self.currentGame saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            NSLog(@"Error %@", error);
        } else {
            //[self.currentGame addObject:[PFUser currentUser].username forKey:@"newPhotosFromUsers"];
            //[self.currentGame saveInBackground];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
    
    
}

- (void)resetPhotosVideosAndRecipients
{
    TakePhoto1Controller *takePhoto1Controller;
    for (UIViewController *viewController in self.navigationController.viewControllers){
        if ([viewController isKindOfClass:[TakePhoto1Controller class]]){
            takePhoto1Controller = (TakePhoto1Controller *)viewController;
        }

    }
    NSLog(@"The controller is %@", takePhoto1Controller);
    NSLog(@"Done");
    takePhoto1Controller.imageTakenOrSelected = nil;
    takePhoto1Controller.briefLabel.text = nil;
    takePhoto1Controller.drawView.image = nil;
    //[takePhoto1Controller.tapSelectionView removeFromSuperview];
    
    [appDelegate.imageStorageDictionary removeAllObjects];
}


#pragma mark - IB Actions

- (IBAction)yesButtonTapped:(UIButton *)sender
{
    self.senderTruePhoto = @"true";
    [self uploadMessageAndAssociateWithGame];
}

- (IBAction)noButtonTapped:(UIButton *)sender
{
    self.senderTruePhoto = @"false";
    [self uploadMessageAndAssociateWithGame];

}
@end
