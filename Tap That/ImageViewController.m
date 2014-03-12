//
//  ImageViewController.m
//  Tap That
//
//  Created by Allan Zhang on 12/19/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//

#import "ImageViewController.h"
#import "ScoreAndRanksViewController.h"

#import "AFURLConnectionOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "TestFlight.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ImageViewController ()
{
    int numberOfTries;
    int numberAttempted;

}

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) NSMutableArray *alreadyViewedMessageIDs;
@property (strong, nonatomic) UIView *whereTappedView;
@property (strong, nonatomic) NSString *imageHasDownloaded;

@end

@implementation ImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.alreadyViewedMessageIDs = [[NSMutableArray alloc] init];
    self.briefLabel.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"textfieldBackground"]];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageViewer.userInteractionEnabled = YES;
    self.imageHasDownloaded = @"No";
    
    if ([[[self navigationController] navigationBar] isHidden]){
        
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }

    numberAttempted = 0;
    
    self.briefLabel.hidden = YES;
    self.progressView.hidden = YES;

    NSLog(@"Current game IN DID THEY REALLY %@", self.currentGame);
    
    [self downloadAndSetPictureFromParse];
}


- (void)downloadAndSetPictureFromParse
{
    //Download and setting image
    PFFile *imageFile = [self.currentMessage objectForKey:@"image"];
    NSLog(@"file is %@", imageFile);
    //UIImage *placeholder = [UIImage imageNamed:@"downloadingBackground"];
    //UIImage *placeholder480 = [UIImage imageNamed:@"downloading480"];
    NSURL *imageFileURL = [[NSURL alloc] initWithString:imageFile.url];
    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:imageFileURL];
    
    /*
    
    if (IS_IPHONE_5){
        self.imageViewer.image = placeholder;
    } else {
        self.imageViewer.image = placeholder480;
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
        
        self.progressView.hidden = NO;
        self.progressView.progress = progress;
    }];
    [operation setCompletionBlock:^{
        NSLog(@"Download succeeded");
        self.imageViewer.image = [UIImage imageWithContentsOfFile:filePath];
        self.progressView.hidden = YES;
        self.imageHasDownloaded = @"Yes";
        
        //Set the label's text what''s from the message
        if (self.currentMessage[@"imageBrief"]){
            self.briefLabel.hidden = NO;
            self.briefLabel.text = self.currentMessage[@"imageBrief"];
        }


    }];
    [operation start];

}

#pragma mark - Helper methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"scoreAdjustment"]){
        ScoreAndRanksViewController *scoreVC = (ScoreAndRanksViewController *)segue.destinationViewController;
        scoreVC.currentGame = self.currentGame;
        scoreVC.message = self.currentMessage;
        scoreVC.userDecision = self.userDecision;
    }

}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addCurrentUserToMessageSeenList
{
    [self.currentMessage addObject:[PFUser currentUser].username forKey:@"imageViewedBy"];
    [self.currentMessage saveInBackground];
}


#pragma mark - Alert view methods


- (IBAction)nextButtonTapped:(UIButton *)sender
{
    [self addCurrentUserToMessageSeenList];
    [self performSegueWithIdentifier:@"scoreAdjustment" sender:self];
}
@end
