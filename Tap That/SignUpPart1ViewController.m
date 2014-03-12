//
//  SignUpPart1ViewController.m
//  Tap That
//
//  Created by Allan Zhang on 2/16/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "SignUpPart1ViewController.h"
#import "SignUpPart2ViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SignUpPart1ViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSDate *selectedBirthday;
@property (strong, nonatomic) NSString *successEmail;
@property (strong, nonatomic) NSString *successPass;
@property (strong, nonatomic) NSDate *successBirthdate;
@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation SignUpPart1ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.emailSignUpField.delegate = self;
    self.passwordSignUpField.delegate = self;
    
    self.view.backgroundColor = UIColorFromRGB(0x2bade5);
    
    
    UIView *mootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    [self.passwordSignUpField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordSignUpField setLeftView:mootView];
    
    UIView *loopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    [self.emailSignUpField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailSignUpField setLeftView:loopView];
    
    
    //self.textView.textContainer.lineFragmentPadding = 4;
    self.textView.textContainerInset = UIEdgeInsetsMake(10, 16, 4, 16);

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    self.signupButton.userInteractionEnabled = YES;
    self.signupButton.hidden = YES;
    
    
    
    UITapGestureRecognizer *textViewTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goViewPrivacyAndTerms)];
    textViewTapped.numberOfTapsRequired = 1;
    [self.textView addGestureRecognizer:textViewTapped];
    self.textView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *birthdayLabelTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(birthdayLabelTapped)];
    birthdayLabelTapped.numberOfTapsRequired = 1;
    [self.birthdateLabel addGestureRecognizer:birthdayLabelTapped];
    self.birthdateLabel.userInteractionEnabled = YES;
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self.emailSignUpField becomeFirstResponder];
    
    //init the date picker here
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 352, 320, 216)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.hidden = YES;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.datePicker removeTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)datePickerValueChanged: (id)sender
{
    NSDate *selectedDate = [self.datePicker date];
    self.selectedBirthday = selectedDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    NSString *textToBeShown = [formatter stringFromDate:selectedDate];
    self.birthdateLabel.text = [NSString stringWithFormat:@"    %@", textToBeShown];
    self.birthdateLabel.textColor = [UIColor blackColor];
    
    [self checkConditionsToSeeIfCanRegister];
}

- (void)birthdayLabelTapped
{
    if ([self.emailSignUpField isFirstResponder]){
        [self.emailSignUpField resignFirstResponder];
    }
    if ([self.passwordSignUpField isFirstResponder]){
        [self.passwordSignUpField resignFirstResponder];
    }
    
    self.datePicker.hidden = NO;
    
}

- (void)goViewPrivacyAndTerms
{
    [self performSegueWithIdentifier:@"showTerms" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSecondScreen"]){
        SignUpPart2ViewController *signUpPartTwoVC = (SignUpPart2ViewController *)segue.destinationViewController;
        
        signUpPartTwoVC.passedEmail = self.successEmail;
        signUpPartTwoVC.passedPass = self.successPass;
        signUpPartTwoVC.passedBirthdate = self.successBirthdate;
        
        self.successBirthdate = nil;
        self.successPass = nil;
        self.successEmail = nil;
        
    }
    
}

- (BOOL)userNameIsAcceptable: (NSString *)userNameInputted
{
    NSLog(@"The inputted result is >%@<", userNameInputted);
    NSCharacterSet *userNameAcceptedInput = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *filteredUserName = [[userNameInputted componentsSeparatedByCharactersInSet:userNameAcceptedInput] componentsJoinedByString:@""];
    NSLog(@"The filtered result >%@<", filteredUserName);
    
    if ([userNameInputted isEqualToString:filteredUserName]){
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"This method checks to see if all things fulfilled conditions");
    [self checkConditionsToSeeIfCanRegister];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.datePicker setHidden:YES];
    return YES;
}

- (void)checkConditionsToSeeIfCanRegister
{
    BOOL emailFieldFilled = NO;
    BOOL passFieldFilled = NO;
    BOOL datePickerpicked = NO;
    
    if (self.emailSignUpField.text.length > 0){
        emailFieldFilled = YES;
    }
    
    if (self.passwordSignUpField.text.length > 0){
        passFieldFilled = YES;
    }
    
    if (![self.birthdateLabel.text isEqualToString:@"    When is your birthday?"]){
        datePickerpicked = YES;
    }
    
    if (emailFieldFilled == YES && passFieldFilled == YES && datePickerpicked == YES){
        self.textView.hidden = YES;
        self.textView.userInteractionEnabled = NO;
        self.signupButton.hidden = NO;
    }
}




- (IBAction)signupButtonPressed:(UIButton *)sender
{
    NSString *password = [self.passwordSignUpField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailProvided = [self.emailSignUpField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDate *birthday = self.selectedBirthday;
    
    if (password.length < 4){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again..." message:@"For your safety, please make your password 4 characters or longer." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        self.signupButton.userInteractionEnabled = YES;
    } else if ([self calculateAge] < 13){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Persons under 13 years of age are unable to register for Tap That." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        self.signupButton.userInteractionEnabled = YES;
    } else if ([self NSStringIsValidEmail:emailProvided] == NO){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again..." message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        self.signupButton.userInteractionEnabled = YES;
    }
    else {
        [self.activityIndicator startAnimating];
        self.signupButton.userInteractionEnabled = NO;
        
        PFQuery *userQueryByEmail = [PFUser query];
        [userQueryByEmail whereKey:@"email" equalTo:emailProvided];
        [userQueryByEmail findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error){
                NSLog(@"Error, %@", error);
            } else {
                if (objects.count > 0){
                    //There is someone already registered
                    
                    NSLog(@"The object is %@", objects);
                    
                    [self.activityIndicator stopAnimating];
                    self.signupButton.userInteractionEnabled = YES;
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again..." message:@"Your email is already associated with an account." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alertView show];
                    self.signupButton.userInteractionEnabled = YES;
                    
                    
                } else {
                    
                    NSLog(@"The final registration are %@, %@, %@", emailProvided, password, birthday);
                    self.successEmail = emailProvided;
                    self.successPass = password;
                    self.successBirthdate = birthday;
                    
                    //Segue to next level to enter an username
                    [self.activityIndicator stopAnimating];
                    [self performSegueWithIdentifier:@"showSecondScreen" sender:self];
                    
                }
            }
        }];
        
        
    }
    
}

- (NSInteger)calculateAge
{
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:self.selectedBirthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    return age;
}

- (IBAction)dismissRegister:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}




@end
