//
//  InboxViewController.h
//  Tap That
//
//  Created by Allan Zhang on 2/16/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface InboxViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *usernamesToStartGameWith;

- (IBAction)joinGame:(UIButton *)sender;
- (IBAction)declineGame:(UIButton *)sender;
- (IBAction)groupsButtonTapped:(UIBarButtonItem *)sender;




@end
