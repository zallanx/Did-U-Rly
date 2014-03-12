//
//  GameMessagesViewController.h
//  Shelly
//
//  Created by Allan Zhang on 2/25/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GameMessageCell.h"

@interface GameMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PFObject *currentGame;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)createMessageAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;


@end
