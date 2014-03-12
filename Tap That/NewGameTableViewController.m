//
//  NewGameTableViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/19/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "NewGameTableViewController.h"

@interface NewGameTableViewController ()

@end

@implementation NewGameTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] init];;
}



#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tappedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tappedCell == self.facebookCell){
        NSLog(@"Start game with Facebook friend");
    } else if (tappedCell == self.userCell){
        NSLog(@"Start game with a user friend");
        [self performSegueWithIdentifier:@"findUser" sender:self];
    }
    
}


- (IBAction)dismissView:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
