//
//  TakePhoto2Controller.m
//  Tap That
//
//  Created by Allan Zhang on 12/27/13.
//  Copyright (c) 2013 Allan Zhang. All rights reserved.
//

#import "TakePhoto2Controller.h"
#import "TakePhoto1Controller.h"
#include "AppDelegate.h"
#include "SendPicsViewController.h"
#import <MobileCoreServices/UTCoreTypes.h> //Needed for progress bar
#import "TestFlight.h"

#define appDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface TakePhoto2Controller ()
{
    CGPoint startPoint;
    
    int originalSize;
    float brushSize;
    
    BOOL firstTimeInteraction;
}

@property (strong, nonatomic) UIColor *selectedColor;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation TakePhoto2Controller


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Appearance configuration
    
    
    //Initialize the drawView
    self.drawView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    NSLog(@"Draw view's frame is %@", NSStringFromCGRect(self.drawView.frame));
    self.drawView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.drawView];
    self.drawView.layer.zPosition = 10;
    self.briefLabel.layer.zPosition = 24;
    //Drawing brush view
    brushSize = 4.0;
    
    //Enable touch interaction for image
    
    
    //Tapgesture to be able to tap to write the brief
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picture2Tapped:)];
    [self.secondTakenImage addGestureRecognizer:self.tapGestureRecognizer];
    
    
    [self cameraConfiguration];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"picture2Walkthrough"]){
        NSLog(@"This is the first time taking picture TWO");
        [self firstTimeSetups];
    }
    
    //Textfield configuration
    self.briefLabel.delegate = self;
    
    NSLog(@"PIC 2 CONTROLLER The passed game is %@", self.currentGame);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    NSLog(@"viewWillAppear from 2 called");
    
    //Button appearances
    self.navigationItem.hidesBackButton = YES;
    self.secondTakenImage.userInteractionEnabled = YES;
    self.briefLabel.returnKeyType=UIReturnKeyDone;
    
    
    if ([[[self tabBarController] tabBar] isHidden]){
        
    } else {
        self.tabBarController.tabBar.hidden = YES;
    }
    
    if ([[[self navigationController] navigationBar] isHidden]){
        //Do nothing
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }
    
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

    //Present the Camera UIImagePicker if no image is taken
    BOOL modalPresent = (BOOL)(self.presentedViewController);
    //Present the Camera UIImagePicker if no image is taken
    if (!appDelegate.imageStorageDictionary[@"picture2"]){
        if (modalPresent == NO){ //checks if the UIImagePickerController is already modally active
            if (![[self imagePickerController] isBeingDismissed]) [self dismissViewControllerAnimated:NO completion:nil];
            [self presentViewController:self.imagePickerController animated:NO completion:nil];
        }
    }
    
    if (!firstTimeInteraction){
        self.walkthroughMessage.hidden = YES;
        self.walkthroughSendOff.hidden = YES;
    }
    
    //Hide the typing element unless there is text
    if (self.briefLabel.text.length > 0){
        self.briefLabel.hidden = NO;
    } else {
        self.briefLabel.hidden = YES;
    }
    
}

-(void)picture2Tapped: (UITapGestureRecognizer *)sender
{
    CGPoint tappedPoint = [sender locationInView:self.view];
    NSLog(@"The picture was tapped %@", NSStringFromCGPoint(tappedPoint));
    
    if (self.briefLabel.hidden == YES && self.penIcon.selected == NO){
        self.briefLabel.hidden = NO;
        [self.briefLabel becomeFirstResponder];
    } else if (self.briefLabel.hidden == NO){
        if (self.briefLabel.text.length == 0){
            self.briefLabel.hidden = YES;
        }
        [self.briefLabel resignFirstResponder];
        [self saveBriefText];
    }

}

- (void)firstTimeSetups
{
    self.walkthroughMessage.hidden = NO;
    self.walkthroughSendOff.hidden = NO;
    firstTimeInteraction = YES;
    
    //Makes sure next time does not show interaction
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"picture2Walkthrough"];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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

        self.imagePickerController.showsCameraControls = NO;
        
        [[NSBundle mainBundle] loadNibNamed:@"overlayView2" owner:self options:nil];
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
    
    //NSData *img1Data = UIImageJPEGRepresentation(self.drawView.image, 1.0);
    //NSLog(@"Size of Image1(bytes):%d",[img1Data length]);
    
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

#pragma mark - Image picker controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.tabBarController setSelectedIndex:0];
    [self dismissViewControllerAnimated:NO completion:nil];
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
                } else if (self.imageTakenOrSelected.imageOrientation == 0){ //Taken landscape with button the right
                    UIImage *flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationRight];
                    self.imageTakenOrSelected = flippedImage;
                }
                
            } else if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront){
                //Flip image if using front view camera
                UIImage * flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationLeftMirrored];
                self.imageTakenOrSelected = flippedImage;
            }
            
            //NSLog(@"The original image's dimensions are %@", NSStringFromCGSize(self.imageTakenOrSelected.size));
            
            NSLog(@"AFTER flip self.imageTaken width: %f, and height %f", self.imageTakenOrSelected.size.width, self.imageTakenOrSelected.size.height);
            
        } else { //flip photos from Camera roll as well
            if (CGSizeEqualToSize(self.imageTakenOrSelected.size, CGSizeMake(640, 1136)) == YES || CGSizeEqualToSize(self.imageTakenOrSelected.size, CGSizeMake(640, 960)) == YES){
                NSLog(@"Image is a screenshot");
            } else {
                //rudimentry image flip detection
                NSLog(@"Image is is landscape");
                if (self.imageTakenOrSelected.size.width > self.imageTakenOrSelected.size.height){
                    if (self.imageTakenOrSelected.imageOrientation == 1){ //Taken landscape with button the left
                        UIImage *flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationRight];
                        self.imageTakenOrSelected = flippedImage;
                    } else if (self.imageTakenOrSelected.imageOrientation == 0){ //Taken landscape with button the right
                        UIImage *flippedImage = [UIImage imageWithCGImage:self.imageTakenOrSelected.CGImage scale:self.imageTakenOrSelected.scale orientation:UIImageOrientationRight];
                        self.imageTakenOrSelected = flippedImage;
                    }
                } else {
                    NSLog(@"Image is already portrait");
                }
            }
        }
    
    }

    self.secondTakenImage.image = self.imageTakenOrSelected;
    
    [appDelegate.imageStorageDictionary setObject:self.imageTakenOrSelected forKey:@"picture2"];  //add as App Delegate property
    NSLog(@"%@", appDelegate.imageStorageDictionary[@"picture2"]);
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Helper methods

- (void)resetPhotos
{
    self.imageTakenOrSelected = nil;
    
    self.penIcon.selected = NO;
    self.huePicker.userInteractionEnabled = NO;
    self.briefLabel.text = nil;
    
    TakePhoto1Controller *takePhoto1Controller = [self.navigationController.viewControllers objectAtIndex:0];
    takePhoto1Controller.imageTakenOrSelected = nil;
    takePhoto1Controller.briefLabel.text = nil;
    //[takePhoto1Controller.tapSelectionView removeFromSuperview];
    
    self.drawView.image = nil;
    [appDelegate.imageStorageDictionary removeAllObjects];
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"!User %@ cancelled from photo 2", [PFUser currentUser].username]];
    
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

#pragma mark - IB Actions

- (IBAction)cancelPhotos:(UIButton *)sender //this lets person retake photo
{
    //Retake the photo
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ retook photo 2", [PFUser currentUser].username]];
    
    self.imageTakenOrSelected = nil;
    self.penIcon.selected = NO;
    self.huePicker.userInteractionEnabled = NO;
    self.briefLabel.text = nil;
    self.drawView.image = nil;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera; //if there is a camera avaliable
    } else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//otherwise go to the folder
    }

    [self presentViewController:self.imagePickerController animated:NO completion:nil];
    
}

- (IBAction)takePhoto:(UIButton *)sender
{
    [self.imagePickerController takePicture];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"!User %@ took photo 2", [PFUser currentUser].username]];
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
                    } completion:nil];
}

- (IBAction)penSwitch:(UIButton *)sender
{
    if (self.penIcon.selected == NO){
        self.penIcon.selected = YES;
        self.huePicker.hidden = NO;
        self.huePicker.userInteractionEnabled = YES;
        self.penBackgroundView.hidden = NO;
        self.drawingEraser.hidden = NO;
        
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ used the pen on pic 2", [PFUser currentUser].username]];
    } else {
        self.penIcon.selected = NO;
        self.huePicker.hidden = YES;
        self.huePicker.userInteractionEnabled = NO;
        self.penBackgroundView.hidden = YES;
        self.drawingEraser.hidden = YES;
    }
}



- (IBAction)eraseDrawing:(UIButton *)sender
{
    self.drawView.image = nil;
}

- (IBAction)sendMessageAction:(UIButton *)sender
{
    NSLog(@"The frame of the taken picture is %@", NSStringFromCGRect(self.secondTakenImage.frame));
    NSLog(@"The frame of the drawing is %@", NSStringFromCGRect(self.drawView.frame));
    NSLog(@"The saved 2 brief is %@", appDelegate.imageStorageDictionary[@"picture2Brief"]);
    
    
    CGSize fullSize = self.secondTakenImage.image.size;
    CGSize newSize = self.secondTakenImage.frame.size;
    CGFloat scale = newSize.height/fullSize.height;
    CGFloat offset = (newSize.width - fullSize.width*scale)/2;
    CGRect offsetRect = CGRectMake(offset, 0, newSize.width-offset*2, newSize.height);
    NSLog(@"offset = %@",NSStringFromCGRect(offsetRect));
    
    UIGraphicsBeginImageContext(newSize);
    [self.secondTakenImage.image drawInRect:offsetRect];
    [self.drawView.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *combImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.penIcon.selected = NO;
    
    [appDelegate.imageStorageDictionary setObject:combImage forKey:@"picture2"];
    
    [self performSegueWithIdentifier:@"goToSendPic" sender:self];
}

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
        [appDelegate.imageStorageDictionary setObject:self.briefLabel.text forKey:@"picture2Brief"];
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ typed/edited something on pic 2", [PFUser currentUser].username]];
    }
}


- (IBAction)leavePhotoTaking:(UIButton *)sender
{
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"User %@ wants to revisit photo 1", [PFUser currentUser].username]];
    //Convert this to go back to TP1
    /*
    [self dismissViewControllerAnimated:NO completion:nil];
    [self resetPhotos];
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
     */
    [self dismissViewControllerAnimated:NO completion:^{
        [appDelegate.imageStorageDictionary removeObjectForKey:@"picture2"];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (IBAction)usePhotoLibrary:(UIButton *)sender
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToSendPic"]){
        SendPicsViewController *sendPicsVewController = (SendPicsViewController *)segue.destinationViewController;
        sendPicsVewController.currentGame = self.currentGame;
    }
}



@end
