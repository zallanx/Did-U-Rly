//
//  DidTheyReallyViewController.m
//  Shelly
//
//  Created by Allan Zhang on 2/26/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "DidTheyReallyViewController.h"
#import "ImageViewController.h"
#import "UIImageView+AFNetworking.h"


@interface DidTheyReallyViewController ()

@end

@implementation DidTheyReallyViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupLabels];
     NSLog(@"Current game IN DID THEY REALLY %@", self.currentGame);
    [self setAvatarPicture];
    
}

- (void)setAvatarPicture
{
    self.avatarImageview.layer.cornerRadius = self.avatarImageview.frame.size.height/2;
    self.avatarImageview.clipsToBounds = YES;
    
    if ([self.message objectForKey:@"senderFBPicture"]){
        NSString *url = [self.message objectForKey:@"senderFBPicture"];
        NSURL *pictureURL = [NSURL URLWithString:url];
        [self.avatarImageview setImageWithURL:pictureURL];
    } else if ([self.message objectForKey:@"senderAvatarImage"]){
        NSNumber *avatarIndex = [self.message objectForKey:@"senderAvatarImage"];
        NSString *imageName = [NSString stringWithFormat:@"user%@", avatarIndex];
        self.avatarImageview.image = [UIImage imageNamed:imageName];
    }

}

- (void)setupLabels
{
    NSString *messageSender = self.message[@"senderUsername"];
    //self.usernameLabel.text = [NSString stringWithFormat:@"Did %@ really take a photo of", messageSender];
    
    NSDictionary *promptForShell = self.message[@"messagePromptForShell"];
    NSString *prompt = [[promptForShell allKeys] lastObject];
    
    //Replace "your" with sender name
    NSMutableArray* aList = [[NSMutableArray alloc] initWithObjects:@"your", nil];
    NSMutableArray* bList = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%@'s", messageSender], nil];
    
    for (int i=0; i<[aList count];i++)
    {
        prompt = [prompt stringByReplacingOccurrencesOfString:[aList objectAtIndex:i] withString:[bList objectAtIndex:i]];
    }
    //self.taskLabel.text = prompt;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewImage"]){
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.currentGame = self.currentGame;
        imageViewController.currentMessage = self.message;
        imageViewController.userDecision = self.userDecision;
    }
    
}


- (IBAction)yesButtonTapped:(UIButton *)sender
{
    NSDictionary *userAndAgreement = @{[PFUser currentUser].username : @"true"};
    
    [self.message addObject:userAndAgreement forKey:@"userAndAgreement"];
    [self.message saveInBackground];
    self.userDecision = @"true";
    
    [self performSegueWithIdentifier:@"viewImage" sender:self];
}

- (IBAction)noButtonTapped:(UIButton *)sender
{
    NSDictionary *userAndAgreement = @{[PFUser currentUser].username : @"false"};
    
    [self.message addObject:userAndAgreement forKey:@"userAndAgreement"];
    [self.message saveInBackground];
    self.userDecision = @"false";
    
    [self performSegueWithIdentifier:@"viewImage" sender:self];
}
@end
