//
//  TakePhoto1Controller.m
//  Tap That
//
//  Created by Allan Zhang on 12/27/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//


#import "TakePhoto1Controller.h"
#import "AppDelegate.h"
#import "TaskConfirmationViewController.h"
#import "TestFlight.h"
#import "UIImagePickerController+StatusBarHidden.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>



#define appDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


@interface TakePhoto1Controller ()
{
    //CGPoint tappedPoint;
    //CGPoint longPressedPoint;
    //CGPoint centerOfDrawnCircle;
    CGPoint startPoint;
    
    //CGPoint circleStartPoint;
    
    //int originalSize;
    float brushSize;
    //int switcher; //1 -> self.tapSelectionView activated and tapped inside circle 2 -> pen is activated 0 -> default, no self.tapSelectionview and pen is not activated
    
    BOOL firstTimeInteraction;
    BOOL justHitCancelledToPreventPresentingCamera;
    BOOL cameraIsReady;
    
}


@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *pickerTapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (strong, nonatomic) UIColor *selectedColor;


@end

@implementation TakePhoto1Controller


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.circleLayer = [CAShapeLayer layer];
    
    //Appearance configuration
    self.navigationItem.hidesBackButton = YES;
    
    //Enable touch interaction for image
    self.firstTakenImage.userInteractionEnabled = YES;
    //self.numberOfTriesPicker.userInteractionEnabled = NO;
    
    //Tap gesture for main view
    //self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTapped:)];
    //[self.firstTakenImage addGestureRecognizer:self.tapGestureRecognizer];
    
    //Tap gesture for picker view
    //self.pickerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerTapped:)];
    //[self.numberOfTriesPicker addGestureRecognizer:self.pickerTapGestureRecognizer];
    
    //Long press gesture to show Image
    //self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pictureLongTapped:)];
    //self.longPressGestureRecognizer.minimumPressDuration = 0.44; //requires one second to show
    //[self.firstTakenImage addGestureRecognizer:self.longPressGestureRecognizer];
    
    //Pinch gesture for circle zoom
    //self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    //[self.view addGestureRecognizer:self.pinchGestureRecognizer];
    
    //Initialize the drawView !!!! This part is hacked to work with aspect fill
    self.drawView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    NSLog(@"Draw view's frame is %@", NSStringFromCGRect(self.drawView.frame));
    self.drawView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.drawView];
    self.drawView.layer.zPosition = 10;
    
    //Walkthrough messanging
    //self.walkthroughMessage21.layer.zPosition = 20;
    //self.walkthroughMessage22.layer.zPosition = 21;
    //self.numberOfTriesPicker.layer.zPosition = 25;
    self.briefLabel.layer.zPosition = 24;
    
    //Drawing brush view
    brushSize = 4.0;
    
	//Camera configuration
    [self cameraConfiguration];
    
    //Try circle size
    //originalSize = 120;
    
    //self.numberOfTriesChoices = @[@"1 try", @"2 tries", @"3 tries", @"4 tries", @"6 tries", @"10 tries"];
    
    //Nav bar apperance
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"pictureWalkthrough"]){
        NSLog(@"This is the first time taking picture");
        [self firstTimeSetups];
    }
    
    //Textfield configuration
    self.briefLabel.delegate = self;
    self.briefLabel.returnKeyType=UIReturnKeyDone;
    
    justHitCancelledToPreventPresentingCamera = NO;
    
    NSLog(@"PIC 1 CONTROLLER The passed game is %@", self.currentGame);
    NSLog(@"PIC 1 CONTROLLER The passed prompt is %@", self.currentPromptForShell);
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //self.numberOfTriesPicker.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsReady:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    //Ensure that the tab and navigation bar is hidden
    if ([[[self tabBarController] tabBar] isHidden]){
        //Do nothing
    } else {
        self.tabBarController.tabBar.hidden = YES;
    }
    
    if ([[[self navigationController] navigationBar] isHidden]){
        //Do nothing
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    //Set the switcher: 0 is no tapselectionview and no highlight
    
    /*
    if (self.tapSelectionView){
        switcher = 1;
    } else {
        switcher = 0;
    }
     */
    
    //Hide the hue picker
    self.huePicker.hidden = YES;
    self.penBackgroundView.hidden = YES;
    self.drawingEraser.hidden = YES;
    
    //Default color
    if (!self.selectedColor){
        self.selectedColor = [UIColor colorWithHue:200.0/360.0 saturation:1.0 brightness:1.0 alpha:1.0];
    }
    
    //Ensure that the camera is used as default
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera; //if there is a camera avaliable
    } else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//otherwise go to the folder
    }
   
    BOOL modalPresent = (BOOL)(self.presentedViewController);
    //Present the Camera UIImagePicker if no image is taken
    if (justHitCancelledToPreventPresentingCamera == NO){
        if (!appDelegate.imageStorageDictionary[@"picture1"]){
            if (modalPresent == NO){ //checks if the UIImagePickerController is already modally active
                if (![[self imagePickerController] isBeingDismissed]) [self dismissViewControllerAnimated:NO completion:nil];
                [self presentViewController:self.imagePickerController animated:NO completion:nil];
            }
        }
    }
    justHitCancelledToPreventPresentingCamera = NO;

    
    if (!firstTimeInteraction){
        //self.walkthrough1MessageView.hidden = YES;
        //self.walkthroughMessage21.hidden = YES;
        //self.walkthroughMessage22.hidden = YES;
    }
    
    //Disabled tappointicon
    //self.tapPointIcon.userInteractionEnabled = NO;
    //self.tapPointIcon.hidden = YES;
    
    //Hide the typing element unless there is text
    if (self.briefLabel.text.length > 0){
        self.briefLabel.hidden = NO;
    } else {
        self.briefLabel.hidden = YES;
    }

    //Adjust the photo if necessary by its rotation
    [self considerOrientationOfTakenPhotoToMatchOrientationOfImageView];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //Present the camera controller
}

- (void)cameraIsReady:(NSNotification *)notification
{
    NSLog(@"Camera is ready...");
    cameraIsReady = YES;
    
}

- (void)firstTimeSetups
{
    //Shows the walk through messages and enable interactions
    //self.walkthroughMessage22.hidden = YES;
    firstTimeInteraction = YES;
    
    //Makes sure next time does not show interaction
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pictureWalkthrough"];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Tap and Long Press Gesture methods

/*
-(void)pictureTapped: (UITapGestureRecognizer *)sender
{
    
    
    tappedPoint = [sender locationInView:self.view];
    NSLog(@"The picture 1 was tapped %@", NSStringFromCGPoint(tappedPoint));
    CGFloat yLocationForAlert;
    if (IS_IPHONE_5){
        yLocationForAlert = 525;
    } else {
        yLocationForAlert = 436;
    }

    
    if (self.numberOfTriesPicker.hidden == NO){ //dismiss the Picker if its enabled
        self.numberOfTriesPicker.hidden = YES;
        self.penIcon.userInteractionEnabled = YES;
        self.tapPointIcon.userInteractionEnabled = YES;
    } else if (tappedPoint.x >= 260 && tappedPoint.y >= yLocationForAlert){ //make this for iPhone 4 as well
        if (self.takeNextPhotoButton.enabled == NO){
            //Show the alert message
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Set a Secret Area"
                                                              message:@">Tap and Hold< to set a secret area on your photo first!"
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
            [message show];
        }
    } else if (self.briefLabel.hidden == YES && self.penIcon.selected == NO){
        
        //Only show the tap if the person has long tapped the first time
        if (firstTimeInteraction == NO || (firstTimeInteraction == YES && self.tapSelectionView)){
            self.briefLabel.hidden = NO;
            [self.briefLabel becomeFirstResponder];
        }
        
    } else if (self.briefLabel.hidden == NO){
        
        if (firstTimeInteraction == NO || (firstTimeInteraction == YES && self.tapSelectionView)){
            if (self.briefLabel.text.length == 0){
                self.briefLabel.hidden = YES;
            } else {
                
            }
            
            [self.briefLabel resignFirstResponder];
            [self saveBriefText];
        }
        
    }
     
    
}
 */

/*
- (void)pickerTapped: (UITapGestureRecognizer *)sender
{
    
    if ([sender view] == self.numberOfTriesPicker){
        NSLog(@"Tapped on the picker view");
        self.numberOfTriesPicker.hidden = YES;
        //Picker hidden, reenable the action of the rest of the icons
        self.penIcon.userInteractionEnabled = YES;
        self.tapPointIcon.userInteractionEnabled = YES;
        
    }
}


- (void)pictureLongTapped: (UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan){
        longPressedPoint = [sender locationInView:self.view];
    }
    NSLog(@"The point taken by the LONG pressed %@", NSStringFromCGPoint(longPressedPoint));
    
    if (longPressedPoint.y >= 36){ //not too high
        [self drawCircleAndSaveWhereTapped:longPressedPoint];
 
        //if (firstTimeInteraction == YES && self.walkthroughMessage22.hidden == YES){
        //    self.walkthroughMessage21.hidden = YES;
        //    self.walkthroughMessage22.hidden = NO;
        //    firstTimeInteraction = NO;
        //}
 
        [self screenTappedTesterToShowNextButton];
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ set a secret area", [PFUser currentUser].username]];
    }

}

- (void)drawCircleAndSaveWhereTapped: (CGPoint)whereTapped
{
    if (self.tapSelectionView){
        [self.tapSelectionView removeFromSuperview];
    }
    
    int size = originalSize;
    int radius = size/2;
    
    self.tapSelectionView = [[UIView alloc] initWithFrame:CGRectMake(whereTapped.x - radius, whereTapped.y - radius, size, size)];
    self.tapSelectionView.layer.cornerRadius = radius;
    self.tapSelectionView.layer.borderColor = [UIColor greenColor].CGColor;
    self.tapSelectionView.backgroundColor = [UIColor clearColor];
    self.tapSelectionView.layer.borderWidth = 2;
    
    CGPoint centerOfOriginalFrame = CGPointMake(self.tapSelectionView.frame.origin.x + radius, self.tapSelectionView.frame.origin.y + radius);
    centerOfDrawnCircle = centerOfOriginalFrame;
    
    [self saveFrameOfTheCircle];
    [self.view addSubview:self.tapSelectionView];
    switcher = 1; //allows for drawiing of the circle
}

- (void)saveFrameOfTheCircle
{
    NSString *photo1WhereTapped = NSStringFromCGRect(self.tapSelectionView.frame);
    [appDelegate.imageStorageDictionary setObject:photo1WhereTapped forKey:@"photo1WhereTapped"];
}

*/


#pragma mark - Pinch gesture methods

/*
- (void)pinchGesture: (UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    int size = originalSize;
    int radius = size/2;
    
    self.tapSelectionView.layer.cornerRadius = pinchGestureRecognizer.scale * radius;
    self.tapSelectionView.frame = CGRectMake(centerOfDrawnCircle.x - radius * pinchGestureRecognizer.scale, centerOfDrawnCircle.y - radius * pinchGestureRecognizer.scale, size * pinchGestureRecognizer.scale, size * pinchGestureRecognizer.scale); //centerOfDrawnCircle needs to be updated
    
    NSLog(@"The current size is %f", self.tapSelectionView.frame.size.height);
    NSLog(@"The pinch recognizer's scale is %f, ", pinchGestureRecognizer.scale);
    
    originalSize = self.tapSelectionView.frame.size.height;
    if (originalSize < 32){
        originalSize = 32;
    }
    pinchGestureRecognizer.scale = 1;
    [self saveFrameOfTheCircle];
    
}
 
 */


#pragma mark - Image picker controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (![[self imagePickerController] isBeingDismissed]) [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ cancelled taking picture", [PFUser currentUser].username]];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType]; //Imported new library
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        //A photo was taken/selected
        self.imageTakenOrSelected = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera){
            NSLog(@"the orientation is %d", self.imageTakenOrSelected.imageOrientation);
            NSLog(@"Before flip self.imageTaken width: %f, and height %f", self.imageTakenOrSelected.size.width, self.imageTakenOrSelected.size.height);
            //3 is upright
            //2 is upside-down
            //1 is button on the left
            //0 is button on the right
            
            if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear){
                if (self.imageTakenOrSelected.imageOrientation == 1){ //Taken landscape with button the left
                    UIImage *flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationRight];
                    self.imageTakenOrSelected = flippedImage;
                    //flip the label too
                    self.briefLabel.frame = CGRectMake(142, 0, 36, 568);
                    //[self.briefLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
                    
                    
                } else if (self.imageTakenOrSelected.imageOrientation == 0){ //Taken landscape with button the right
                    UIImage *flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationRight];
                    self.imageTakenOrSelected = flippedImage;
                    self.briefLabel.frame = CGRectMake(142, 0, 36, 568);
                    //[self.briefLabel setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                }
                
            } else if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront){
                //Flip image if using front view camera
                UIImage * flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationLeftMirrored];
                self.imageTakenOrSelected = flippedImage;
            }
            
            
            //NSLog(@"The original image's dimensions are %@", NSStringFromCGSize(self.imageTakenOrSelected.size));
            
            NSLog(@"AFTER flip self.imageTaken width: %f, and height %f", self.imageTakenOrSelected.size.width, self.imageTakenOrSelected.size.height);
   
        } else { //flip photos from Camera roll as well
            //Explore CGSize
            NSLog(@"The selected image's size is %@", NSStringFromCGSize(self.imageTakenOrSelected.size));
            
            if (CGSizeEqualToSize(self.imageTakenOrSelected.size, CGSizeMake(640, 1136)) == YES || CGSizeEqualToSize(self.imageTakenOrSelected.size, CGSizeMake(640, 960)) == YES){
                NSLog(@"Image is a screenshot");
            } else {
                
                //rudimentry image flip detection: if width is more than height, assume its landscape
                NSLog(@"Image is is landscape");
                if (self.imageTakenOrSelected.size.width > self.imageTakenOrSelected.size.height){
                    if (self.imageTakenOrSelected.imageOrientation == 1){ //Taken landscape with button the left
                        UIImage *flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationRight];
                        self.imageTakenOrSelected = flippedImage;
                        //[self.briefLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
                    } else if (self.imageTakenOrSelected.imageOrientation == 0){ //Taken landscape with button the right
                        UIImage *flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationRight];
                        self.imageTakenOrSelected = flippedImage;
                        //[self.briefLabel setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                    }
                } else {
                    NSLog(@"Image is already portrait");
                }
            }
            
        }
        
       
    }
    
    
    self.firstTakenImage.image = self.imageTakenOrSelected;
    //NSLog(@"the size height %f and width %f",self.firstTakenImage.frame.size.height, self.firstTakenImage.frame.size.width);
    
    //!sets the app delegate temporarily
    [appDelegate.imageStorageDictionary setObject:self.imageTakenOrSelected forKey:@"picture1"];

    //[appDelegate.imageStorageDictionary setObject:self.imageTakenOrSelected forKey:@"picture1"];  //add as App Delegate property
    //NSLog(@"%@", appDelegate.imageStorageDictionary[@"picture1"]);
    
    if (![[self imagePickerController] isBeingDismissed]) {
        
        //[self dismissViewControllerAnimated:NO completion:nil];
        dispatch_async(dispatch_get_main_queue(), ^(void){ [self dismissViewControllerAnimated:NO completion:nil]; });
    }
    
}


- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    NSLog(@"orientation is %d", orientation);
    float rotation = 0;
    
    //1 is portrait
    //3 is button on right
    //4 is button on left
    
    if (self.firstTakenImage.image.imageOrientation == 3){ //if the picture is upright
        if (orientation == 1){
            rotation = 0;
        } else if (orientation == 3){
            rotation = -M_PI/2;
        } else if (orientation == 4){
            rotation = M_PI/2;
        }
    } else if (self.firstTakenImage.image.imageOrientation == 0){ // if button is on the right
        if (orientation == 1){
            rotation = M_PI/2;
        }
    } else if (self.firstTakenImage.image.imageOrientation == 1){ //if button is on the left
        if (orientation == 1){
            rotation = -M_PI/2;
        }
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.firstTakenImage.transform = CGAffineTransformMakeRotation(rotation);
        self.firstTakenImage.frame = self.view.frame;
    }];
    
    [self considerOrientationOfTakenPhotoToMatchOrientationOfImageView];
}

- (void)considerOrientationOfTakenPhotoToMatchOrientationOfImageView
{
    
    NSLog(@"self.interfaceOrientation is %d", self.interfaceOrientation);
    
    /*
    
    float rotation = 0;
    
    //1 is portrait
    //3 is button on right
    //4 is button on left
    
    if (self.firstTakenImage.image.imageOrientation == 3){ //if the picture is upright
        if (self.interfaceOrientation == 1){
            rotation = 0;
        } else if (self.interfaceOrientation == 3){
            rotation = -M_PI/2;
        } else if (self.interfaceOrientation == 4){
            rotation = M_PI/2;
        }
    } else if (self.firstTakenImage.image.imageOrientation == 0){ // if button is on the right
        if (self.interfaceOrientation == 1){
            rotation = M_PI/2;
        }
    } else if (self.firstTakenImage.image.imageOrientation == 1){ //if button is on the left
        if (self.interfaceOrientation == 1){
            rotation = -M_PI/2;
        }
    }
    
    [UIView animateWithDuration:0.30f animations:^{
        self.firstTakenImage.transform = CGAffineTransformMakeRotation(rotation);
        self.firstTakenImage.frame = self.view.frame;
    }];
     
     */

}



#pragma mark - IBActions

- (IBAction)cancelTakePhoto:(UIButton *)sender
{
    NSLog(@"User is retaking the photo");
    [self resetPhotos];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera; //if there is a camera avaliable
    } else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//otherwise go to the folder
    }
    [self presentViewController:self.imagePickerController animated:NO completion:nil];
    
}

- (IBAction)takeNextPhotoAction:(UIButton *)sender
{
    //Frames
    NSLog(@"The frame of the taken picture is %@", NSStringFromCGRect(self.firstTakenImage.frame));
    NSLog(@"The frame of the drawing is %@", NSStringFromCGRect(self.drawView.frame));
    NSLog(@"The saved brief is %@", appDelegate.imageStorageDictionary[@"picture1Brief"]);
    
    CGSize fullSize = self.firstTakenImage.image.size;
    NSLog(@"The full size is: width %f height %f", self.firstTakenImage.image.size.width, self.firstTakenImage.image.size.height);
    
    CGSize newSize = self.firstTakenImage.frame.size;
    NSLog(@"The new size is: width %f height %f", self.firstTakenImage.frame.size.width, self.firstTakenImage.frame.size.height);
    
    CGFloat scale = newSize.height/fullSize.height;
    NSLog(@"The scale is %f", scale);
    
    CGFloat offset = (newSize.width - fullSize.width*scale)/2;
    
    
    CGRect offsetRect = CGRectMake(offset, 0, newSize.width-offset*2, newSize.height);
    NSLog(@"offset = %@",NSStringFromCGRect(offsetRect));
    
    UIGraphicsBeginImageContext(newSize);
    [self.firstTakenImage.image drawInRect:offsetRect];
    [self.drawView.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *combImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();


    self.penIcon.selected = NO;
    self.takeNextPhotoButton.selected = NO;
    
    [appDelegate.imageStorageDictionary setObject:combImage forKey:@"picture1"];
    [self performSegueWithIdentifier:@"goToConfirmation" sender:self];

}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)takePhoto:(UIButton *)sender
{
    if (cameraIsReady == YES){
        [self.imagePickerController takePicture];
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"!User %@ took photo 1", [PFUser currentUser].username]];
    } else {
        NSLog(@"Camera was not ready");
    }
}

- (IBAction)cameraFlashSwitch:(UIButton *)sender
{
    [self activateChangeFlash];
}

- (IBAction)cameraTurnSwitch:(UIButton *)sender
{
    [UIView transitionWithView:self.imagePickerController.view
                      duration:0.6
                       options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear ){
                            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        } else {
                            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                        }
                    } completion:NULL];
}

- (IBAction)usePhotoLibrary:(UIButton *)sender
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}



- (IBAction)activatePen:(UIButton *)sender
{
    if (self.penIcon.selected == NO){ //Pen is activated
        self.penIcon.selected = YES;
        self.huePicker.hidden = NO;
        self.huePicker.userInteractionEnabled = YES;
        self.penBackgroundView.hidden = NO;
        self.drawingEraser.hidden = NO;
        //switcher = 2;
        
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ used the pen", [PFUser currentUser].username]];
    } else {
        self.penIcon.selected = NO;
        self.huePicker.hidden = YES;
        self.huePicker.userInteractionEnabled = NO;
        self.penBackgroundView.hidden = YES;
        self.drawingEraser.hidden = YES;
        //If tap selection view has something, then do something
        
        /*
        if (self.tapSelectionView){
            switcher = 1;
        } else {
            switcher = 0;
        }
         */
    }
}


/*
- (IBAction)pickNumberOfTries:(UIButton *)sender
{
    if (self.numberOfTriesPicker.hidden == YES){
        self.numberOfTriesPicker.hidden = NO;
        self.numberOfTriesPicker.userInteractionEnabled = YES;
        if (self.tapSelectionView){
            self.tapSelectionView.userInteractionEnabled = NO;
        }
        
        self.penIcon.userInteractionEnabled = NO;
        self.tapPointIcon.userInteractionEnabled = NO;
        
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ selected the number of tries", [PFUser currentUser].username]];
        
    } else {
        self.numberOfTriesPicker.hidden = YES;
        self.numberOfTriesPicker.userInteractionEnabled = NO;
        if (self.tapSelectionView){
            self.tapSelectionView.userInteractionEnabled = YES;
        }
        
        self.penIcon.userInteractionEnabled = YES;
        self.tapPointIcon.userInteractionEnabled = YES;
    }
}
 */

#pragma mark - Hue Picker methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint positionTouched = [touch locationInView:self.huePicker];
    if ([touch view] == self.huePicker){
        NSLog(@"The point begun is %@", NSStringFromCGPoint(positionTouched));
        [self selectColorBasedOnTouch:positionTouched];
    } else {
        startPoint = [touch locationInView:self.drawView];
    }
    
    /*
    if (switcher == 2){
        
        CGPoint positionTouched = [touch locationInView:self.huePicker];
        if ([touch view] == self.huePicker){
            NSLog(@"The point begun is %@", NSStringFromCGPoint(positionTouched));
            [self selectColorBasedOnTouch:positionTouched];
        } else {
            
            startPoint = [touch locationInView:self.drawView];
        }
    } else if (switcher == 1){
        UIView *touchedView = self.tapSelectionView;
        
        NSLog(@"The tapSelection's center is %f and %f", touchedView.center.x, touchedView.center.y);
        
        CGPoint circleTouchCenterPoint = [touch locationInView:self.view];
        
        circleStartPoint.x = circleTouchCenterPoint.x - touchedView.center.x;
        circleStartPoint.y = circleTouchCenterPoint.y - touchedView.center.y;
        
        circleTouchCenterPoint.x = circleTouchCenterPoint.x - circleStartPoint.x;
        circleTouchCenterPoint.y = circleTouchCenterPoint.y - circleStartPoint.y;
        touchedView.center = circleTouchCenterPoint;
    }
     */
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionTouched = [touch locationInView:self.huePicker];
    if ([touch view] == self.huePicker){
        //NSLog(@"The point touched is %@", NSStringFromCGPoint(positionTouched));
        [self selectColorBasedOnTouch:positionTouched];
    } else if (self.penIcon.selected == YES){
        CGPoint currentPoint = [touch locationInView:self.drawView];
        //Draw lines
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.drawView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)];
        
        //Line settings
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushSize);
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.selectedColor.CGColor);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        
        //Begin and Move Line
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
        //NSLog(@"The start points are %@", NSStringFromCGPoint(startPoint));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),currentPoint.x, currentPoint.y);
        //NSLog(@"The points draw on are %@", NSStringFromCGPoint(currentPoint));
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        startPoint = currentPoint;

    }


}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   

}


- (void)selectColorBasedOnTouch: (CGPoint)touch
{
    float colorValue = 1 - (touch.x / self.huePicker.frame.size.width);
    self.selectedColor = [UIColor colorWithHue: colorValue saturation:1.0 brightness:1.0 alpha:1.0];
    self.penBackgroundView.backgroundColor = self.selectedColor;
}

- (void)drawAtPointTouched: (CGPoint)touch
{
    CGPoint currentPoint = touch;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.drawView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height)];
    
    //Line settings
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushSize);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.selectedColor.CGColor);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);

    //Begin and Move Line
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), touch.x, touch.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    self.drawView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    startPoint = currentPoint;
    
}

#pragma mark - Helper methods

- (void)resetPhotos
{
    self.imageTakenOrSelected = nil;
    self.penIcon.selected = NO;
    //self.tapPointIcon.selected = NO;
    self.huePicker.userInteractionEnabled = NO;
    self.briefLabel.text = nil;
    self.takeNextPhotoButton.selected = NO;
    
    self.drawView.image = nil;
    [appDelegate.imageStorageDictionary removeAllObjects];
    NSLog(@"%@", appDelegate.imageStorageDictionary[@"picture1"]);
    //[self.tapSelectionView removeFromSuperview];
    //switcher = 0;
}

- (void)cameraConfiguration
{
    //UIImagePickerController initialization and setup
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera; //if there is a camera avaliable
    } else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//otherwise go to the folder
    }
    self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        /*
         The user wants to use the camera interface. Set up our custom overlay view for the camera.
         */
        self.imagePickerController.showsCameraControls = NO;
        
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
        [[NSBundle mainBundle] loadNibNamed:@"overlayView" owner:self options:nil];
        self.overlayView.frame = self.imagePickerController.cameraOverlayView.frame;
        self.imagePickerController.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        
        //For iphone 5+
        //Camera is 426 * 320. Screen height is 568.  Multiply by 1.333 in 5 inch to fill vertical
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
        self.imagePickerController.cameraViewTransform = translate;
        
        CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
        self.imagePickerController.cameraViewTransform = scale;
        
        //Disable flash
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
    
    
}

- (void)activateChangeFlash
{
    BOOL buttonStatus = self.cameraFlashIcon.selected;
    if (buttonStatus == NO){
        [self.cameraFlashIcon setSelected:YES];
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    } else {
        [self.cameraFlashIcon setSelected:NO];
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
    
    NSLog(buttonStatus ? @"Selected" : @"Not selected");
}

#pragma mark - Test Upload of WebP


/*
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.numberOfTriesChoices.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.numberOfTriesChoices[row];
}

#pragma mark PickerView Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //! Must set number of tries
    NSString *numberOfTries = [[[NSString stringWithFormat:@"%@", self.numberOfTriesChoices[row]] componentsSeparatedByString:@" "] objectAtIndex:0];
    self.pickerTriesLabel.text = numberOfTries;
    if (numberOfTries){
        [appDelegate.imageStorageDictionary setObject:numberOfTries forKey:@"picture1NumberOfTaps"];  //add as App Delegate property
        NSLog(@"%@ saved to app delegate", appDelegate.imageStorageDictionary[@"picture1NumberOfTaps"]);
    }
}
*/

#pragma mark - TextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.briefLabel.text.length == 0){
        self.briefLabel.hidden = YES;
    }
    [self saveBriefText];
    return NO;
}

- (void)saveBriefText
{
    if (self.briefLabel.text.length > 0){
        [appDelegate.imageStorageDictionary setObject:self.briefLabel.text forKey:@"picture1Brief"];
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ typed/edited something", [PFUser currentUser].username]];
    }
}



- (IBAction)eraseDrawing:(UIButton *)sender
{
    NSLog(@"Drawing eraser used.");
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstTimeEraser"]){
        NSLog(@"This is the first time using eraser");
        [self firstTimeEraser];
    } else {
        self.drawView.image = nil;
    }
}

- (void)firstTimeEraser
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstTimeEraser"];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Clear drawing"
                                                      message:@"This button clears your drawing. Are you sure?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Clear", nil];
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"The title is %@", title);
    if([title isEqualToString:@"Clear"])
    {
        self.drawView.image = nil;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToConfirmation"]){
        TaskConfirmationViewController *taskVC = (TaskConfirmationViewController *)segue.destinationViewController;
        taskVC.currentGame = self.currentGame;
        taskVC.currentPromptForShell = self.currentPromptForShell;
    }
    
}

@end
