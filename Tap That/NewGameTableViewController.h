//
//  NewGameTableViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/19/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGameTableViewController : UITableViewController

- (IBAction)dismissView:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITableViewCell *facebookCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *userCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *randomCell;


@end
