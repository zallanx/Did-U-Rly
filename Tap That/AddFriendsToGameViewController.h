//
//  AddFriendsToGameViewController.h
//  Shelly
//
//  Created by Allan Zhang on 2/28/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddFriendsToGameViewController : UITableViewController

- (IBAction)startButtonTapped:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startGameButton;


@end
