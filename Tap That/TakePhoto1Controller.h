//
//  TakePhoto1Controller.h
//  Tap That
//
//  Created by Allan Zhang on 12/27/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>


@interface TakePhoto1Controller : UIViewController  <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIImage *imageTakenOrSelected;
//@property (strong, nonatomic) UIView *tapSelectionView;
//property (strong, nonatomic) CAShapeLayer *circleLayer;
//@property (strong, nonatomic) NSArray *numberOfTriesChoices;
@property (strong, nonatomic) UIImageView *drawView;
@property (weak, nonatomic) IBOutlet UIImageView *firstTakenImage;
@property (strong, nonatomic) IBOutlet UIView *overlayView;

// Cancel or take next photo
@property (strong, nonatomic) IBOutlet UIButton *takeNextPhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *snapPictureButton;
- (IBAction)takeNextPhotoAction:(UIButton *)sender;
- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)cancelTakePhoto:(UIButton *)sender;

//Icons from xib
@property (strong, nonatomic) IBOutlet UIButton *cameraFlashIcon;
@property (strong, nonatomic) IBOutlet UIButton *cameraTurnIcon;
@property (strong, nonatomic) IBOutlet UIButton *goBackIcon;
- (IBAction)cameraFlashSwitch:(UIButton *)sender;
- (IBAction)cameraTurnSwitch:(UIButton *)sender;
- (IBAction)usePhotoLibrary:(UIButton *)sender;



//Pen and color picker icons
@property (weak, nonatomic) IBOutlet UIButton *penIcon;
@property (weak, nonatomic) IBOutlet UIButton *drawingEraser;
- (IBAction)activatePen:(UIButton *)sender;
- (IBAction)eraseDrawing:(UIButton *)sender;

//Drawing
@property (weak, nonatomic) IBOutlet UIImageView *huePicker;
@property (weak, nonatomic) IBOutlet UIView *penBackgroundView;

//Typing views
@property (weak, nonatomic) IBOutlet UITextField *briefLabel;

//Tap point icons
//@property (strong, nonatomic) IBOutlet UIButton *tapPointIcon;
//@property (strong, nonatomic) IBOutlet UILabel *pickerTriesLabel;
//- (IBAction)pickNumberOfTries:(UIButton *)sender;

//Tries picker
//@property (weak, nonatomic) IBOutlet UIPickerView *numberOfTriesPicker;

//Current game
@property (strong, nonatomic) PFObject *currentGame;
@property (strong, nonatomic) NSDictionary *currentPromptForShell;


@end
