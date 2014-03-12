//
//  SettingsViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/3/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.usernameLabel.text = [PFUser currentUser].username;
    NSNumber *totalTapsCount = [[PFUser currentUser] objectForKey:@"tapsCount"];
    
    self.numberOfTapsLabel.text = [NSString stringWithFormat:@"%@", totalTapsCount];
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
    if (tappedCell == self.logoutCell){
        NSLog(@"Tapped logout cell");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                          message:@"Are you sure you want to log out?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Logout", nil];
        [message show];
    } else if (tappedCell == self.supportCell){
        NSString *recipients = @"mailto:team@teamtapthat.com?&subject=Support for Tap That";
        NSString *body = [NSString stringWithFormat: @"&body=This is %@', and I am emailing you about ...", [PFUser currentUser].username];
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:11/255.0 green:102/255.0 blue:168/255.0 alpha:1];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
}

- (void)logoutUser
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLogin"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES]; //hides the button Nav bar when signing up
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"The title is %@", title);
    if([title isEqualToString:@"Clear feed"])
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
        
    }
    if([title isEqualToString:@"Logout"])
    {
        [self logoutUser];
    }
    
    
}



@end
