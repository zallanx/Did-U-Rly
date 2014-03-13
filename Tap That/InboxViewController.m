//
//  InboxViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/16/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "InboxViewController.h"
#import "InboxViewCell.h"
#import "TapRewardSelectViewController.h"
#import "ImageViewController.h"
#import "GameMessagesViewController.h"
#import "NSDate+TimeAgo.h"


@interface InboxViewController ()

@property (strong, nonatomic) NSMutableArray *myGames;
@property (strong, nonatomic) NSMutableArray *myRelatedGames;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) PFObject *selectedGame;



@property(nonatomic,assign) BOOL top,down;

@end

@implementation InboxViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Table view delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Row data for two sections in the table
    self.myGames = [[NSMutableArray alloc] init];
    self.myRelatedGames = [[NSMutableArray alloc] init];
    self.usernamesToStartGameWith = [[NSMutableArray alloc] init];
    //self.theirTurnGames = [[NSMutableArray alloc] init];
    
    //Table view apperance
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //Navigation view apperance
    self.navigationController.navigationItem.hidesBackButton = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if ([PFUser currentUser]){
        NSLog(@"Current user: %@", [PFUser currentUser].username);
    } else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    

    
    
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentUser = [PFUser currentUser]; //always needs to be set in view will appear
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.title = self.currentUser.username;

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startGameWithUsers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGameWithUser) name:@"startGameWithUsers" object:nil];
    //Appearance
    
    // ---- Retrive from Parse to populate myTurnGames and theirTurnGames
    // ---- Add cell for newGame
    
    [self populateGamesFromParse];
}



- (void)startGameWithUser
{
    NSLog(@"Start game with these users %@", self.usernamesToStartGameWith);
    [self.usernamesToStartGameWith removeObject:self.currentUser.username];
    [self startNewGameWithPresetUsers];
    [self.usernamesToStartGameWith removeAllObjects];
}
/*
- (void)startGameWithUser: (NSNotification *)notification
{
    //NSString *username = notification.object;
    //[self checkIfGameAlreadyExistWithUserOrStartNewGame:username];
}
 */

- (void)populateGamesFromParse
{
    [self.myGames removeAllObjects];

    PFQuery *queryForMyTurnGames = [PFQuery queryWithClassName:@"Game"];
    [queryForMyTurnGames whereKey:@"userIDsInGame" equalTo:self.currentUser.objectId]; //also works when contained in array
    [queryForMyTurnGames findObjectsInBackgroundWithBlock:^(NSArray *myTurnGames, NSError *error) {
        if (error){
            NSLog(@"Error, %@", error);
        } else {
            [self.myGames addObjectsFromArray:myTurnGames];
            [self addNewGameCell];
            [self retriveCurrentUserRelatedGames]; //reloadData inside this function

        }
    }];
}

- (void)retriveCurrentUserRelatedGames //Related games are assigned to the user
{
    [self.myRelatedGames removeAllObjects];
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *userGamesRelation = [currentUser objectForKey:@"gameRelation"];
    if (userGamesRelation){
        NSLog(@"relations are %@", userGamesRelation);
        PFQuery *queryForCurrentUserRelatedGames = [userGamesRelation query];
        [queryForCurrentUserRelatedGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error){
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"retrived related games are %@", objects);
                [self.myRelatedGames addObjectsFromArray:objects];
                [self.tableView reloadData];
            }
        }];
    } else {
        NSLog(@"First time set up no users");
        [self.tableView reloadData];
    }
    
    
}


- (void)addNewGameCell
{
    NSDictionary *newGame = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Begin a new game", @"title",
                             nil];
    [self.myGames addObject:newGame];

}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    
    if ([segue.identifier isEqualToString:@"showLogin"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES]; //hides the button Nav bar when signing up
    }
 
    if ([segue.identifier isEqualToString:@"choosePrompt"]){
        TapRewardSelectViewController *tapRewardVC = (TapRewardSelectViewController *)segue.destinationViewController;
        tapRewardVC.currentGame = self.currentGame;

    }
    
    if ([segue.identifier isEqualToString:@"startShowTurn"]){
        TurnIncrementViewController *turnIncrementVC = (TurnIncrementViewController *)segue.destinationViewController;
        turnIncrementVC.currentGame = self.selectedGame;
        turnIncrementVC.updateTurn = @"Do not update";
    }
    
    if ([segue.identifier isEqualToString:@"showPicture1"]){
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.currentGame = self.selectedGame;
    }
     
     */
    if ([segue.identifier isEqualToString:@"newGamePrompt"]){
        TapRewardSelectViewController *tapVC = (TapRewardSelectViewController *)segue.destinationViewController;
        tapVC.currentGame = self.currentGame;
    }

    if ([segue.identifier isEqualToString:@"viewGameMessages"]){
        GameMessagesViewController *gameVC = (GameMessagesViewController *)segue.destinationViewController;
        gameVC.currentGame = self.selectedGame;
    }
    
}

#pragma mark - New game setup

- (void)startNewGameWithPresetUsers
{
    PFQuery *userQuery = [PFUser query];
    NSArray *userNames = self.usernamesToStartGameWith;
    
    
    [userQuery whereKey:@"username" containedIn:userNames];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error: %@", error);
        } else {
            
            NSMutableArray *userIDsInGame = [[NSMutableArray alloc] initWithCapacity:objects.count];
            NSMutableArray *userNamesInGame = [[NSMutableArray alloc] initWithCapacity:objects.count];
            NSMutableDictionary *rankingInGame = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *shellsInGame = [[NSMutableDictionary alloc] init];
            

            for (PFUser *user in objects){
                [userIDsInGame addObject:user.objectId]; //User object ID
                [userNamesInGame addObject:user.username]; //Username
                [rankingInGame setObject:[NSNumber numberWithInt:0] forKey:user.username]; //User's rank in game
                [shellsInGame setObject:[NSNumber numberWithInt:0] forKey:user.username];

            }
            
            //Also add self to game
            [userIDsInGame addObject:self.currentUser.objectId];
            [userNamesInGame addObject:self.currentUser.username];
            [rankingInGame setObject:[NSNumber numberWithInt:0] forKey:self.currentUser.username];
            [shellsInGame setObject:[NSNumber numberWithInt:0] forKey:self.currentUser.username];
            
            //alphabetize the objectIDs and the usernames in the array
            [userIDsInGame sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [userNamesInGame sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

            //Set them into the PFObject Game
            PFObject *game = [PFObject objectWithClassName:@"Game"];
            [game setObject:userIDsInGame forKey:@"userIDsInGame"];
            [game setObject:userNamesInGame forKey:@"userNamesInGame"];
            [game setObject:rankingInGame forKey:@"userRankingInGame"];
            [game setObject:shellsInGame forKey:@"userShellsInGame"];
            [game setObject:self.currentUser.username forKey:@"gameCreator"];
            
            
            
            [game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error){
                    NSLog(@"Error %@", error);
                } else {
                    //<--- Game object created ---->
                    NSLog(@"Game is %@", game);
                    
                    [self associateGameWithCurrentUser:game];
                    self.currentGame = game;
                    NSLog(@"the current game is %@", self.currentGame);
                    if ([self.currentUser objectForKey:@"fbID"]){ //if user logged in using Facebook
                        [self associateUserToFBID:game];
                        [self associateFirstNameToUsernameForGame:game];
                    }
                    [self associateAvatarToUsernameForGame:game];
                    [self performSegueWithIdentifier:@"newGamePrompt" sender:self];

                }
            }];
            
            
        }
    }];
    
}

- (void)associateGameWithCurrentUser: (PFObject *)game
{
    //Associate game with current user
    PFRelation *gamerelation = [self.currentUser relationForKey:@"gameRelation"];
    [gamerelation addObject:game];
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            NSLog(@"Error %@, %@", error, [error userInfo]);
        } else {
            NSLog(@"Associated currentUser with game relation %@", gamerelation);
            
        }
    }];
}

- (void)associateUserToFBID: (PFObject *)game
{
    NSMutableDictionary *usernameForFBIDInGame = [[NSMutableDictionary alloc] initWithDictionary:game[@"usernameForFBIDInGame"]];
    NSLog(@"The retrived dicionary is %@", usernameForFBIDInGame);
    [usernameForFBIDInGame setObject:self.currentUser[@"fbID"] forKey:self.currentUser.username];
    NSLog(@"The new dicionary is %@", usernameForFBIDInGame);
    [game setObject:usernameForFBIDInGame forKey:@"usernameForFBIDInGame"];
    [game saveInBackground];
}

- (void)associateFirstNameToUsernameForGame: (PFObject *)game
{
    NSMutableDictionary *usernameForFirstNameInGame = [[NSMutableDictionary alloc] initWithDictionary:game[@"usernameForFirstNameInGame"]];
    [usernameForFirstNameInGame setObject:self.currentUser[@"fbFirstName"] forKey:self.currentUser.username];
    [game setObject:usernameForFirstNameInGame forKey:@"usernameForFirstNameInGame"];
    [game saveInBackground];
}

- (void)associateAvatarToUsernameForGame: (PFObject *)game
{
    NSMutableDictionary *usernameForFBIDInGame = [[NSMutableDictionary alloc] initWithDictionary:game[@"usernameForAvatarInGame"]];
    NSString *imageName;
    if ([self.currentUser objectForKey:@"fbID"]){//if user is a facebook user
        imageName = [self.currentUser objectForKey:@"fbProfilePicture"];
    } else { //if email user
        NSNumber *indexOfAvatar = [self.currentUser objectForKey:@"avatarImageIndex"];
        imageName = [NSString stringWithFormat:@"user%@", indexOfAvatar];
    }
    [usernameForFBIDInGame setObject:imageName forKey:self.currentUser.username];
    [game setObject:usernameForFBIDInGame forKey:@"usernameForAvatarInGame"];
    [game saveInBackground];
}


/*
- (void)updateTurnAndReward: (NSDictionary *)turnAndReward forGame: (PFObject *)game
{
    [game addObject:turnAndReward forKey:@"turnAndReward"];
    [game saveInBackground];
}
 */

#pragma mark - Table view delegate methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InboxViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //NSLog(@"My turn games count %i", self.myTurnGames.count);
    //cell.turnLabel.hidden = NO;
    cell.invitationView.hidden = NO;
    
    if (self.myGames.count > 0){
        id myGame = [self.myGames objectAtIndex:indexPath.row];
        
        if ([myGame isKindOfClass:[PFObject class]]){
            PFObject *game = (PFObject *)myGame;
            if ([self hasCurrentUserJoinedGame:game] == YES){
                NSString *allPlayersInGame = [self getAllPlayers:game];
                
                cell.invitationView.hidden = YES;
                cell.majorLabel.text = allPlayersInGame;
                //cell.turnLabel.text = nil;
                //cell.turnImageView.image = nil;
                //cell.actionTurnLabel.text = nil;
                [self cycleThroughUsernamesToGetSetAvatar:game andCell:cell];
                [self setDateForGame:game andCell:cell];
                
            } else {
                
                NSLog(@"\n\n!!!! invited to join game \n\n");
                
                
                cell.majorLabel.text = @"You were invited to join a game";
                cell.minorLabel.text = nil;
                //cell.turnLabel.text = nil;
                //cell.turnImageView.image = nil;
                //cell.actionTurnLabel.text = nil;
            }
        
        } else {
            //This cell is the "start new game" cell
            NSDictionary *addGame = (NSDictionary *)myGame;
            cell.invitationView.hidden = YES;
            cell.majorLabel.text = addGame[@"title"];
            cell.minorLabel.text = nil;
            //cell.turnLabel.text = nil;
            //cell.turnImageView.image = nil;
            //cell.actionTurnLabel.text = nil;
            
        }
    }
    
    return cell;
}

- (void)setDateForGame: (PFObject *)game andCell: (InboxViewCell *)cell
{
    //Sets the subtext element with date and subMessage
    NSDate *date = [[NSDate alloc] init];
    date = game.updatedAt;
    NSString *ago = [date timeAgo];

    cell.minorLabel.text = [NSString stringWithFormat:@"Latest activity: %@", ago];
}

- (void)cycleThroughUsernamesToGetSetAvatar: (PFObject *)game andCell: (InboxViewCell *)cell
{
    NSArray *usernamesInGame = game[@"userNamesInGame"];
    int i = 0;
    for (NSString *username in usernamesInGame){
        NSDictionary *usernameForImage = [game objectForKey:@"usernameForAvatarInGame"];
        NSString *imageName = [usernameForImage objectForKey:username];
        if (imageName.length > 8){
            //Is facebook image
            imageName = @"user10";
        } else if (!imageName){
            NSLog(@"%@ hasn't joined game yet", username);
            imageName = @"userInvited";
            
        }
        
        //sets it to the UIImages of the cell
        if (i == 0){
            cell.profileView1.image = [UIImage imageNamed:imageName];
        }
        
        if (i == 1){
            cell.profileView2.image = [UIImage imageNamed:imageName];
        }
        
        if (i == 2){
            cell.profileView3.image = [UIImage imageNamed:imageName];
        }
        
        i++;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id gameSelected = [self.myGames objectAtIndex:indexPath.row];
    if ([gameSelected isKindOfClass:[PFObject class]]){
        PFObject *game = (PFObject *)gameSelected;
        if ([self hasCurrentUserJoinedGame:game] == YES){
            self.selectedGame = game;
            [self performSegueWithIdentifier:@"viewGameMessages" sender:self];
        }
    } else {
        NSDictionary *game = (NSDictionary *)gameSelected;
        if ([game[@"title"] isEqualToString:@"Begin a new game"]){
            //show add friends view
            [self performSegueWithIdentifier:@"showFriendsSelection" sender:self];
        }
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myGames.count;
}



#pragma mark - Table section setups

/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 26;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:0/255.0 green:174/255.0 blue:235/255.0 alpha:1];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (section == 0){
        title = @"My turn";
    } else if (section == 1){
        title = @"Their turn";
    }
    
    return title;
}
 */


#pragma mark - Status bar controls

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Helper methods



- (NSString *)getAllPlayers: (PFObject *)game
{
    NSMutableString *allPlayers = [[NSMutableString alloc] init];
    NSArray *playersInGame = [NSArray arrayWithArray:game[@"userNamesInGame"]];
   
    for (int i = 0; i < playersInGame.count; i++){
        NSString *username = [playersInGame objectAtIndex:i];
        if (i == 0){
            if ([[game objectForKey:@"usernameForFirstNameInGame"] objectForKey:username]){ //If a first name exists for this username
                [allPlayers appendString:[[game objectForKey:@"usernameForFirstNameInGame"] objectForKey:username]];
            } else {
                [allPlayers appendString:username];
            }
        } else {
            if ([[game objectForKey:@"usernameForFirstNameInGame"] objectForKey:username]){ //If a first name exists for this username
                [allPlayers appendString:[NSString stringWithFormat:@", %@", [[game objectForKey:@"usernameForFirstNameInGame"] objectForKey:username]]];
            } else {
                [allPlayers appendString:[NSString stringWithFormat:@", %@", username]];
            }
 
        }
    }
    return allPlayers;
}


- (BOOL)hasCurrentUserJoinedGame: (PFObject *)game
{
    BOOL hasJoinedGame = NO;
    for (PFObject *relatedGame in self.myRelatedGames){
        if ([relatedGame.objectId isEqualToString:game.objectId]){
            hasJoinedGame = YES;
            break;
        }
    }
    return hasJoinedGame;
}
/*
- (void)trackGameMessagesCount: (PFObject *)game
{
    NSUserDefaults *savedGameSettings = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *gameAndNumberOfMessages = [NSMutableDictionary dictionaryWithDictionary: [savedGameSettings objectForKey:@"gameAndNumberOfMessagesStored"]];

    PFRelation *userGamesRelation = [game objectForKey:@"gameMesssages"];
    PFQuery *queryForGameRelatedMessages = [userGamesRelation query];
    [queryForGameRelatedMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@", error);
        } else {
            NSString *messagesCount = [NSString stringWithFormat:@"%i", objects.count];
            [gameAndNumberOfMessages setObject:messagesCount forKey:game.objectId];
            [savedGameSettings setObject:gameAndNumberOfMessages forKey:@"gameAndNumberOfMessagesStored"];
            
            NSLog(@"What is stored is %@", [savedGameSettings objectForKey:@"gameAndNumberOfMessagesStored"]);
        }
    }];
    
    
}
*/

- (IBAction)joinGame:(UIButton *)sender
{
    NSLog(@"Wants to join game");
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFObject *game = [self.myGames objectAtIndex:indexPath.row];
    self.selectedGame = game;
    [self associateGameWithCurrentUser:game];
    if ([self.currentUser objectForKey:@"fbID"]){ //if user logged in using Facebook
        [self associateUserToFBID:game];
        [self associateFirstNameToUsernameForGame:game];
        
    }
    [self associateAvatarToUsernameForGame:game];
    [self performSegueWithIdentifier:@"viewGameMessages" sender:self];
    
}

- (IBAction)declineGame:(UIButton *)sender
{

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFObject *game = [self.myGames objectAtIndex:indexPath.row];
    [self removeCurrentUserFromGame:game];
    
}

- (IBAction)groupsButtonTapped:(UIBarButtonItem *)sender {
}

- (void)removeCurrentUserFromGame: (PFObject *)game
{
    NSMutableArray *gameUsernames = game[@"userNamesInGame"];
    NSMutableArray *gameUserIDs = game[@"userIDsInGame"];
    NSMutableDictionary *userRankingsInGame = game[@"userRankingInGame"];
    NSMutableDictionary *userShellsInGame = game[@"userShellsInGame"];
    
    [gameUsernames removeObject:self.currentUser.username];
    [gameUserIDs removeObject:self.currentUser.objectId];
    [userRankingsInGame removeObjectForKey:self.currentUser.username];
    [userShellsInGame removeObjectForKey:self.currentUser.username];
    
    
    [game setObject:gameUsernames forKey:@"userNamesInGame"];
    [game setObject:gameUserIDs forKey:@"userIDsInGame"];
    [game setObject:userRankingsInGame forKey:@"userRankingInGame"];
    [game setObject:userShellsInGame forKey:@"userShellsInGame"];
    
    [game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"Happened");
        if (error){
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Saved");
            [self populateGamesFromParse]; //will reload Data
        }
    }];
    
}
@end












