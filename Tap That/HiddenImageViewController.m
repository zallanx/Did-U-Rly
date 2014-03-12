//
//  HiddenImageViewController.m
//  Tap That
//
//  Created by Allan Zhang on 1/3/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "HiddenImageViewController.h"
#import "ImageViewController.h"
#import "TurnIncrementViewController.h"
#import "TestFlight.h"

#import "AFURLConnectionOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface HiddenImageViewController ()

@property (strong, nonatomic) NSMutableArray *alreadyViewedMessageIDs; //!redundant when time countdown implemented

@end

@implementation HiddenImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.alreadyViewedMessageIDs = [[NSMutableArray alloc] init]; //!redundant when time countdown implemented
    
    self.briefLabel.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"textfieldBackground"]];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[[self tabBarController] tabBar] isHidden]){
        //Do nothing
    } else {
        self.tabBarController.tabBar.hidden = YES;
    }
    
    if ([[[self navigationController] navigationBar] isHidden]){
        //Do nothing
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    self.briefLabel.hidden = YES;
    self.secretProgressView.hidden = YES;
    
    [self downloadAndSetPictureFromParse];

    
    //[TestFlight passCheckpoint:[NSString stringWithFormat:@"%@ attempted to view pic 2 of message ID %@", [PFUser currentUser].username, self.message.objectId]];
    
}

- (void)downloadAndSetPictureFromParse
{
    //Download and setting image
    PFFile *imageFile = [self.message objectForKey:@"image2"];
    UIImage *placeholder = [UIImage imageNamed:@"downloadingBackground"];
    UIImage *placeholder480 = [UIImage imageNamed:@"downloading480"];
    NSURL *imageFileURL = [[NSURL alloc] initWithString:imageFile.url];
    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:imageFileURL];
    
    
    /*
    if (IS_IPHONE_5){
        self.hiddenImageViewer.image = placeholder;
    } else {
        self.hiddenImageViewer.image = placeholder480;
    }
    */
     
    AFURLConnectionOperation *operation =  [[AFHTTPRequestOperation alloc] initWithRequest:imageURLRequest];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"downloadImage.jpg"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = (float)totalBytesRead / totalBytesExpectedToRead;
        if (progress < 0.01){
            progress = 0.01;
        }
        
        self.secretProgressView.hidden = NO;
        self.secretProgressView.progress = progress;
    }];
    [operation setCompletionBlock:^{
        NSLog(@"Download succeeded");
        self.hiddenImageViewer.image = [UIImage imageWithContentsOfFile:filePath];
        self.secretProgressView.hidden = YES;
        
        //Set the label's text what''s from the message
        if (self.message[@"photo2Brief"]){
            self.briefLabel.hidden = NO;
            self.briefLabel.text = self.message[@"photo2Brief"];
        }
        
        //Save this message's view to Parse
        //Save this message's view to Parse
        if (![[self.message objectForKey:@"photo2Viewed"] containsObject: [[PFUser currentUser] username] ]){
            if (![self.alreadyViewedMessageIDs containsObject:self.message.objectId]){
                [self saveMessageViewsToParse];
            }
        }

        
        //Testflight
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@ viewed pic 2 of message ID %@", [PFUser currentUser].username, self.message.objectId]];
    }];
    [operation start];
    
    }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTurnUp"]){
        TurnIncrementViewController *turnIncrementViewController = (TurnIncrementViewController *)segue.destinationViewController;
        turnIncrementViewController.currentGame = self.currentGame;
        turnIncrementViewController.resetTurns = @"No";
    }
}

#pragma mark - Parse methods

- (void)saveMessageViewsToParse
{
    [self.message addObject:[[PFUser currentUser] username] forKey:@"photo2Viewed"];
    [self.message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            NSLog(@"An error has occured %@", error);
        } else {
            NSLog(@"Photo 1 view successfully updated");
        }
    }];
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Alertview methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Go back"])
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
}

#pragma mark - IBActions

- (IBAction)nextButtonTapped:(UIButton *)sender
{
    [self performSegueWithIdentifier: @"showTurnUp" sender:self];
}
@end
