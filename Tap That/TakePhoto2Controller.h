//
//  TakePhoto2Controller.h
//  Tap That
//
//  Created by Allan Zhang on 12/27/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface TakePhoto2Controller : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIImage *imageTakenOrSelected;
@property (weak, nonatomic) IBOutlet UIImageView *secondTakenImage;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *snapPhotoButton;
@property (strong, nonatomic) UIImageView *drawView;

- (IBAction)cancelPhotos:(UIButton *)sender;
- (IBAction)takePhoto:(UIButton *)sender;

//xib icons
@property (weak, nonatomic) IBOutlet UIButton *cameraFlashIcon;
@property (weak, nonatomic) IBOutlet UIImageView *walkthroughMessage;
@property (weak, nonatomic) IBOutlet UIImageView *walkthroughSendOff;
- (IBAction)cameraFlashSwitch:(UIButton *)sender;
- (IBAction)cameraTurnSwitch:(UIButton *)sender;
- (IBAction)leavePhotoTaking:(UIButton *)sender;
- (IBAction)usePhotoLibrary:(UIButton *)sender;


//Storyboard icons
@property (weak, nonatomic) IBOutlet UIButton *penIcon;
@property (weak, nonatomic) IBOutlet UITextField *briefLabel;
@property (weak, nonatomic) IBOutlet UIView *penBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *huePicker;
@property (weak, nonatomic) IBOutlet UIButton *drawingEraser;
- (IBAction)eraseDrawing:(UIButton *)sender;
- (IBAction)penSwitch:(UIButton *)sender;
- (IBAction)sendMessageAction:(UIButton *)sender;

//Current game
@property (strong, nonatomic) PFObject *currentGame;

@end
