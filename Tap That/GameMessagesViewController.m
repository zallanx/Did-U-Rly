//
//  GameMessagesViewController.m
//  Shelly
//
//  Created by Allan Zhang on 2/25/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "GameMessagesViewController.h"
#import "DidTheyReallyViewController.h"
#import "TapRewardSelectViewController.h"
#import "UIImageView+AFNetworking.h"

@interface GameMessagesViewController ()

@property (strong, nonatomic) NSArray *usersInCurrentGame;
@property (strong, nonatomic) NSMutableDictionary *userNamesAndRanks;
@property (strong, nonatomic) NSMutableDictionary *userNamesAndShells;
@property (strong, nonatomic) NSMutableDictionary *userForMessage;
@property (strong, nonatomic) PFObject *selectedMessage;



@end

@implementation GameMessagesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.userForMessage = [[NSMutableDictionary alloc] init];
    
    //Table view apperance
    self.tableview.tableFooterView = [[UIView alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.messageButton.enabled = NO;
    [self findUnseenActiveMessages]; //This decides whether the button should be enabled or not
    [self loadUsersFromCurrentGame];
    [self retriveRelevantMessages];
    
}

- (void)findUnseenActiveMessages
{
    PFQuery *queryForUnseenActiveMessages = [PFQuery queryWithClassName:@"Message"];
    
    //Find all messages that are from the user, has a status of "active" and belongs to the current game
    [queryForUnseenActiveMessages whereKey:@"gameBelongingTo" equalTo:self.currentGame.objectId];
    [queryForUnseenActiveMessages whereKey:@"status" equalTo:@"active"];
    [queryForUnseenActiveMessages whereKey:@"senderUserID" equalTo:[PFUser currentUser].objectId];
    
    //If non are found, this user could create again
    [queryForUnseenActiveMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error: %@", error);
        } else {
            if (objects.count > 0){
                NSLog(@"There are still ones to be seen");
            } else {
                NSLog(@"Let the user create more content");
                self.messageButton.enabled = YES;
            }
        }
    }];
    
    
}

- (void)loadUsersFromCurrentGame
{
    self.userNamesAndRanks = [[NSMutableDictionary alloc] init];
    self.userNamesAndShells = [[NSMutableDictionary alloc] init];
    
    [self sortThroughItems:[self.currentGame objectForKey:@"userShellsInGame"] type:@"shells"];
    [self sortThroughItems:[self.currentGame objectForKey:@"userRankingInGame"] type:@"ranks"];
    
    self.usersInCurrentGame = [self.currentGame objectForKey:@"userNamesInGame"];
    
    
}

- (void)sortThroughItems: (NSDictionary *)sortDictionary type: (NSString *)type
{
    NSArray *sortedKeys = [sortDictionary keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    if ([type isEqualToString:@"shells"]){
        NSMutableDictionary *sortedUsersAndShells = [[NSMutableDictionary alloc] init];
        for (NSString *key in sortedKeys){
            //sets the shell value to the key, which is the username
            [sortedUsersAndShells setObject:[[self.currentGame objectForKey:@"userShellsInGame"] objectForKey:key] forKey:key];
        }
        self.userNamesAndShells = [[NSMutableDictionary alloc] initWithDictionary:sortedUsersAndShells];
    }
    
    if ([type isEqualToString:@"ranks"]){
        NSMutableDictionary *sortedUsersAndShells = [[NSMutableDictionary alloc] init];
        for (NSString *key in sortedKeys){
            //sets the shell value to the key, which is the username
            [sortedUsersAndShells setObject:[[self.currentGame objectForKey:@"userRankingInGame"] objectForKey:key] forKey:key];
        }
        self.userNamesAndRanks = [[NSMutableDictionary alloc] initWithDictionary:sortedUsersAndShells];
        
    }

}

#pragma mark - retriving messages

- (void)retriveRelevantMessages
{
    NSArray *arrayOfCurrentPlayer = @[[PFUser currentUser].username];
    
    PFQuery *messagesQuery = [PFQuery queryWithClassName:@"Message"];
    [messagesQuery whereKey:@"gameBelongingTo" equalTo:self.currentGame.objectId];
    [messagesQuery whereKey:@"status" equalTo:@"active"];
    [messagesQuery whereKey:@"imageViewedBy" notContainedIn:arrayOfCurrentPlayer];
    [messagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //set this to the dictionary
        if (error){
            NSLog(@"Error");
        } else {
            //NSLog(@"The objects are %@", objects);
            [self separateMessagesAndAssignToUsers:objects];
        }
    }];

}

- (void)separateMessagesAndAssignToUsers: (NSArray *)messages
{
    [self.userForMessage removeAllObjects];
    
    for (PFObject *message in messages){
        NSLog(@"Message sender is %@", message[@"senderUsername"]);
        for (NSString *username in self.usersInCurrentGame){
            NSLog(@"username is %@", username);
            if ([username isEqualToString: message[@"senderUsername"]]){
                [self.userForMessage setObject:message forKey:username];
                NSLog(@"The resultant is %@", self.userForMessage);
            }
        }
    }
    
    [self.tableview reloadData];
 
}


#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userNamesAndRanks allKeys].count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GameMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *username = [self.usersInCurrentGame objectAtIndex:indexPath.row];
    NSNumber *rank = [self.userNamesAndRanks objectForKey:username];
    NSString *stringRank = [NSString stringWithFormat:@"%@", rank];
    cell.usernameLabel.text = username;
    cell.rankLabel.text = stringRank;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([self.currentGame[@"usernameForAvatarInGame"] objectForKey:username]){
        NSString *imageName = [self.currentGame[@"usernameForAvatarInGame"] objectForKey:username];
        if (imageName.length > 8){ //is Facebook user
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height/2;
            cell.avatarImageView.clipsToBounds = YES;
            NSURL *pictureURL = [NSURL URLWithString:imageName];
            [cell.avatarImageView setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"userInvited"]];
            
        } else { //non Facebook user
            cell.avatarImageView.image = [UIImage imageNamed:imageName];
        }
        
        
    } else {
        cell.avatarImageView.image = [UIImage imageNamed:@"userInvited"];
    }
    
    
    if ([self.userForMessage objectForKey:username]){
        cell.statusLabel.text = @"New";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.statusLabel.text = @"";
    }

    return cell;
}

//Did select cell - selected cell will lead to user's most recent message

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    NSString *userSelected = [self.usersInCurrentGame objectAtIndex:indexPath.row];
    if ([self.userForMessage objectForKey:userSelected]){
        PFObject *message = [self.userForMessage objectForKey:userSelected];
        self.selectedMessage = message;
        [self performSegueWithIdentifier:@"didTheyReally" sender:nil];
        
    } else {
        NSLog(@"No message from %@ to display", userSelected);
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"didTheyReally"]){
        DidTheyReallyViewController *didTheyVC = (DidTheyReallyViewController *)segue.destinationViewController;
        didTheyVC.currentGame = self.currentGame;
        didTheyVC.message = self.selectedMessage;
    }

    if ([segue.identifier isEqualToString:@"makeNewGame"]){
        TapRewardSelectViewController *newGameVC = (TapRewardSelectViewController *)segue.destinationViewController;
        newGameVC.currentGame = self.currentGame;
    }
    
}

- (IBAction)createMessageAction:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"makeNewGame" sender:self];
}
@end
