//
//  TapRewardSelectViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/17/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "TapRewardSelectViewController.h"
#import "TakePhoto1Controller.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface TapRewardSelectViewController ()
{
    int selectedRow;
}

@property (strong, nonatomic) NSDictionary *setOfChallenges;
@property (strong, nonatomic) NSString *selectedTask;
@property (strong, nonatomic) NSDictionary *chosenPromptForShells;

@end

@implementation TapRewardSelectViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectionTableview.delegate = self;
    self.selectionTableview.dataSource = self;
    NSLog(@"TAP REWARD CONTROLLER The passed game is %@", self.currentGame);
    
    self.selectionTableview.layer.cornerRadius = 4;
    self.selectionTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedTask = @"";
    self.chosenPromptForShells = nil;
    
    [self setSelectionToTable]; //updated

}

- (void)updateLabelText
{
    NSArray *playersInGame = [NSArray arrayWithArray:self.currentGame[@"userNamesInGame"]];
    NSString *theOtherPLayer;
    for (NSString *playerName in playersInGame){
        if (![playerName isEqualToString:[PFUser currentUser].username]){
            theOtherPLayer = playerName;
        }
    }
    
}

- (void)setSelectionToTable
{
    NSUserDefaults *currentUserSelections = [NSUserDefaults standardUserDefaults];
    NSArray *allSelections = [currentUserSelections objectForKey:@"selections"];
    NSUInteger randomIndex = arc4random() % [allSelections count];
    self.setOfChallenges = [allSelections objectAtIndex:randomIndex];
    
    
}

#pragma mark - Textfield delegate methods

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.setOfChallenges allKeys].count; //should always return 3
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TaskSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *key = [[self.setOfChallenges allKeys] objectAtIndex:indexPath.row];
    NSString *taskDescription = [self.setOfChallenges objectForKey:key];
    cell.taskLabel.text = taskDescription;
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.selectionTableview.bounds.size.width, 44)];
    headerLabel.text = @"Choose one to photo";
    headerLabel.backgroundColor= [UIColor colorWithRed:0/255.0 green:174/255.0 blue:235/255.0 alpha:1];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    return headerLabel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectionTableview deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = [[self.setOfChallenges allKeys] objectAtIndex:indexPath.row];
    NSString *selectedTask = [self.setOfChallenges objectForKey:key];
    self.selectedTask = selectedTask;
    selectedRow = indexPath.row;
    [self setChallengetoShells];
    
    self.selectedChallengeLabel.text = selectedTask;
    
    
}

- (void)setChallengetoShells
{
    NSDictionary *challengeForShells;
    
    if (selectedRow == 0){
        challengeForShells = @{self.selectedTask : [NSNumber numberWithInt:2]};
        
    } else if (selectedRow == 1){
        challengeForShells = @{self.selectedTask : [NSNumber numberWithInt:10]};
        
    } else if (selectedRow == 2){
        challengeForShells = @{self.selectedTask : [NSNumber numberWithInt:100]};
    }
    
    self.chosenPromptForShells = challengeForShells;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}



#pragma mark - other actions

- (IBAction)nextButtonTapped:(UIButton *)sender
{

    [self performSegueWithIdentifier:@"showCamera1" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCamera1"]){
        TakePhoto1Controller *takePhoto1Controller = (TakePhoto1Controller *)segue.destinationViewController;
        takePhoto1Controller.currentGame = self.currentGame;
        takePhoto1Controller.currentPromptForShell = self.chosenPromptForShells;
    }
}


@end
