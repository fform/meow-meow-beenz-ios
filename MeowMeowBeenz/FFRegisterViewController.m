//
//  FFRegisterViewController.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/7/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFRegisterViewController.h"
#import <Parse/Parse.h>

@interface FFRegisterViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *yourPicLabel;
@property (nonatomic) bool tryingToRegister;

@end

@implementation FFRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}
- (IBAction)tapAvatar:(id)sender {
    //NSLog(@"Tapped image");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    self.yourPicLabel.hidden = YES;
    // If the device ahs a camera, take a picture, otherwise,
    // just pick from the photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    
    // Place image picker on the screen
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.avatarImage.image = [self setThumbnailFromImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)setThumbnailFromImage:(UIImage *)image
{
    CGSize origImageSize = image.size;
    
    CGRect newRect = CGRectMake(0, 0, 400, 400);
    
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:400];
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return smallImage;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.passwordTextfield.delegate = self;
    self.emailTextfield.delegate = self;
    [self.usernameTextfield becomeFirstResponder];
    self.tryingToRegister = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.passwordTextfield || textField == self.emailTextfield) {
        [self registerUser:nil];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)usernameChanged:(id)sender {
    //NSLog(@"un change");
    if([self.displayNameTextfield.text isEqualToString:@""]){
        self.displayNameTextfield.text = self.usernameTextfield.text;
    }
}

- (IBAction)registerUser:(id)sender {
    if( self.tryingToRegister ){
        NSLog(@"Ignoring double register");
        return;
    }
    self.tryingToRegister = YES;
    PFUser *user = [PFUser user];
    user.username = self.usernameTextfield.text;
    user.password = self.passwordTextfield.text;
    if(![self.emailTextfield.text isEqualToString:@""]){
        user.email = self.emailTextfield.text;
    }
    if(![self.displayNameTextfield.text isEqualToString:@""]){
        user[@"displayname"] = self.displayNameTextfield.text;
    }
    float compression = 1.f;
    NSData * img;
    do {
        compression -= 0.2;
        img = UIImageJPEGRepresentation(self.avatarImage.image, compression);
    } while (img.length > (128*1024) || compression > 0);
    NSLog(@"File Size %lu", (unsigned long)img.length);

    user[@"avatar"] = img;
    
    
    PFObject *ratings = [PFObject objectWithClassName:@"Ratings"];
    ratings[@"beenz"] = @{@"beenz":@[@1,@5]};
    ratings[@"rating"] = @1;

    user[@"ratings"] = ratings;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:errorString delegate:self cancelButtonTitle:@"Fix it!" otherButtonTitles:nil];
            [alert show];
        }
    }];
}
- (IBAction)cancelRegister:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
