//
//  InboxViewCell.h
//  Tap That
//
//  Created by Allan Zhang on 2/20/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;

@property (weak, nonatomic) IBOutlet UIImageView *profileView1;
@property (weak, nonatomic) IBOutlet UIImageView *profileView2;
@property (weak, nonatomic) IBOutlet UIImageView *profileView3;



//Join or decline view and buttons
@property (weak, nonatomic) IBOutlet UIView *invitationView;





@end
