//
//  HiddenImageViewController.h
//  Tap That
//
//  Created by Allan Zhang on 1/3/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface HiddenImageViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) PFObject *message;
@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) IBOutlet UIImageView *hiddenImageViewer;
@property (weak, nonatomic) IBOutlet UILabel *briefLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *secretProgressView;
- (IBAction)nextButtonTapped:(UIButton *)sender;


@end
