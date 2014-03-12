//
//  ImageViewController.h
//  Tap That
//
//  Created by Allan Zhang on 12/19/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) PFObject *currentMessage;
@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) NSString *userDecision;

@property (weak, nonatomic) IBOutlet UILabel *briefLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)nextButtonTapped:(UIButton *)sender;


@end
