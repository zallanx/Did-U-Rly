//
//  AddFriendsToGameViewController.m
//  Shelly
//
//  Created by Allan Zhang on 2/28/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "AddFriendsToGameViewController.h"
#import "InboxViewController.h"

@interface AddFriendsToGameViewController ()

@property (strong, nonatomic) NSMutableArray *friendsInGame;
@property (strong, nonatomic) NSMutableArray *allUsers;
@property (strong, nonatomic) NSMutableArray *tableSections;

@end

@implementation AddFriendsToGameViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.allUsers = [[NSMutableArray alloc] init];
    self.friendsInGame = [[NSMutableArray alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateAllUsers];
    [self checkIfAbleToStartGame];
    
}

- (void)checkIfAbleToStartGame
{
    if (self.friendsInGame.count > 0){
        self.startGameButton.enabled = YES;
    } else {
        self.startGameButton.enabled = NO;
    }
}

- (void)populateAllUsers
{
    NSArray *currentUserArray = @[[PFUser currentUser].username];
    PFQuery *usersQuery = [PFUser query];
    [usersQuery whereKey:@"username" notContainedIn:currentUserArray];
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error: %@", error);
        } else {
            self.allUsers = [[NSMutableArray alloc] initWithArray:objects];
            NSLog(@"self.allUsers is %@", self.allUsers);
            [self updateTables];
        }
    }];
}

- (void)updateTables
{
    self.tableSections = [[NSMutableArray alloc] init];
    NSArray *section1 = [NSArray arrayWithArray:self.friendsInGame]; //top group are those selected to be in game
    NSArray *section2 = [NSArray arrayWithArray:self.allUsers]; //bottom is current user friends
    [self.tableSections insertObject:section1 atIndex:0];
    [self.tableSections insertObject:section2 atIndex:1];
 
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.tableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[self.tableSections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    PFUser *user;
    
    
    if (indexPath.section == 0){
        user = [self.friendsInGame objectAtIndex:indexPath.row];
        cell.textLabel.text = user.username;
        
    }
    
    if (indexPath.section == 1){
        user = [self.allUsers objectAtIndex:indexPath.row];
        cell.textLabel.text = user.username;
    }
    
    if ([self isUserInFriend:user] == TRUE){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        PFUser *user = [self.friendsInGame objectAtIndex:indexPath.row];
        //Could only be removed
        [self removeUserFromGame:user];
    }
    
    if (indexPath.section == 1){
        //See if user belongs to self.userGroupDictionary[@"friendsInGroup"]
        PFUser *userSelected = [self.allUsers objectAtIndex:indexPath.row];
        if ([self friendAlreadyInGroup:userSelected] == YES){
            //Remove the user from
            NSLog(@"Remove %@ from the group", userSelected.username);
            [self removeUserFromGame:userSelected];
        } else {
            //Add the user
            NSLog(@"Add %@ to the group", userSelected.username);
            [self addUserToGame:userSelected];
            
        }
        
    }
    
    [self checkIfAbleToStartGame];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return [NSString stringWithFormat:@"People in my game (%i)", self.friendsInGame.count];
    } else {
        return @"All my friends";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:40/255.0 green:141/255.0 blue:215/255.0 alpha:1];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28;
}


#pragma mark - Helper methods

- (BOOL)isUserInFriend: (id)passedUser
{
    if ([passedUser isKindOfClass:[PFUser class]]){
        PFUser *user = (PFUser *)passedUser;
        for (PFUser *friend in self.friendsInGame){
            if ([friend.username isEqualToString: user.username]){
                return YES;
            }
        }
    } else {
        NSDictionary *user = (NSDictionary *)passedUser;
        for (NSDictionary *userInGroup in self.friendsInGame){
            if ([userInGroup[@"username"] isEqualToString: user[@"username"]]){
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)friendAlreadyInGroup: (PFUser *)userSelected
{
    for (PFUser *friend in self.friendsInGame){
        if ([friend.username isEqualToString: userSelected.username]){
            return YES;
        }
    }
    return NO;
}

- (void)removeUserFromGame: (PFUser *)user
{
    [self.friendsInGame removeObject:user];
    [self updateTables];
}

- (void)addUserToGame: (PFUser *)user
{
    [self.friendsInGame addObject:user];
    [self updateTables];
}

- (void)seeIfGameExistsWithFriendsSelected
{
    NSMutableArray *allGameParticipants = [[NSMutableArray alloc] init];
    for (PFUser *user in self.friendsInGame){
        [allGameParticipants addObject:user.username];
    }
    [allGameParticipants addObject:[PFUser currentUser].username];
    
    PFQuery *queryForGames = [PFQuery queryWithClassName:@"Game"];
    [queryForGames whereKey:@"userNamesInGame" containsAllObjectsInArray:allGameParticipants];
    [queryForGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@", error);
        } else {
            int totalGamesMatchingExactly = 0;
            
            NSLog(@"Number of games found %i", objects.count);
            for (PFObject *game in objects){
                int countOfNumberOfParticipantsInRetrivedGame = [game[@"userNamesInGame"] count];
                if (countOfNumberOfParticipantsInRetrivedGame == allGameParticipants.count){
                    totalGamesMatchingExactly++;
                }
            }
            
            if (totalGamesMatchingExactly == 0){
                NSLog(@"Allowed to crate new game with %@", allGameParticipants);
                
                //Call notification to begin new game
                if ([[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[InboxViewController class]]){
                    InboxViewController *inboxVC = (InboxViewController *)[self.navigationController.viewControllers objectAtIndex:0];
                    inboxVC.usernamesToStartGameWith = [[NSMutableArray alloc] initWithArray: allGameParticipants];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"startGameWithUsers" object:nil];
                
                //transition back
                [self.navigationController popViewControllerAnimated:NO];
                
            } else {
                NSLog(@"Game already exists");
            }
        }
    }];
    
}

- (IBAction)startButtonTapped:(UIBarButtonItem *)sender
{
    [self seeIfGameExistsWithFriendsSelected];
}
@end
