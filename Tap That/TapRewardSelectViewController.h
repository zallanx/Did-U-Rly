//
//  TapRewardSelectViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/17/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TaskSelectionCell.h"

@interface TapRewardSelectViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) IBOutlet UITableView *selectionTableview;
@property (weak, nonatomic) IBOutlet UILabel *selectedChallengeLabel;
- (IBAction)nextButtonTapped:(UIButton *)sender;







@end
