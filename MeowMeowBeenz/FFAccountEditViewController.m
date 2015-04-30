//
//  FFAccountEditViewController.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/31/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFAccountEditViewController.h"
#import "FFMeowRating.h"
#import <Parse/Parse.h>
@interface FFAccountEditViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *youMeowLabel;
@property (weak, nonatomic) PFUser *user;
@property (nonatomic) BOOL avatarChanged;
@end

@implementation FFAccountEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.avatarChanged = NO;
    self.user = [PFUser currentUser];
    
    self.emailField.text = self.user.email;
    self.nameField.text = self.user[@"displayname"];
    self.usernameLabel.text = self.user.username;
    
    if(self.user[@"avatar"]){
            self.youMeowLabel.hidden = YES;
        self.avatar.image = [self clipImage:[UIImage imageWithData:self.user[@"avatar"]]];
    }else{
        self.avatar.image = [self clipImage:[UIImage imageNamed:@"meow_none.png"]];
    }
    
    PFObject * ratings = self.user[@"ratings"];
    [ratings refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        float cRating = [FFMeowRating calculateBeenz:self.user];
        [self updateBigRating:cRating];
    }];
}


- (void)updateBigRating:(float)rating{
    self.ratingLabel.text = [NSString stringWithFormat:@"%i", (int) floor(rating)];
}


- (IBAction)cancel:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)save:(id)sender {
    
    self.user.email = self.emailField.text;
    self.user[@"displayname"] = self.nameField.text;
    
    if(self.avatarChanged){
        float compression = 1.f;
        NSData * img;
        do {
            compression -= 0.2;
            img = UIImageJPEGRepresentation(self.avatar.image, compression);
        } while (img.length > (128*1024) || compression > 0);
        NSLog(@"File Size %lu", (unsigned long)img.length);
        
        self.user[@"avatar"] = img;
    }else{
        NSLog(@"No avatar change");
    }
    
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:errorString delegate:self cancelButtonTitle:@"Fix it!" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

- (IBAction)tapAvatar:(id)sender {
    //NSLog(@"Tapped image");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    self.youMeowLabel.hidden = YES;

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
    NSLog(@"Finsihed pick good");
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.avatar.image = [self setThumbnailFromImage:image];
    self.avatarChanged = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)clipImage:(UIImage *)image
{
    CGSize origImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0, image.size.width, image.size.height);
    float ratio = 1;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    
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


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self save:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}


@end
