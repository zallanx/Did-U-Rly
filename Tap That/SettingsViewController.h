//
//  SettingsViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/3/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SettingsViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *numberOfTapsLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *supportCell;


@end
