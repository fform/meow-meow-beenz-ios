//
//  FFLoginViewController.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/7/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFHomeViewController.h"
#import "FFLoginViewController.h"
#import "FFMeowViewController.h"
#import <Parse/Parse.h>

@interface FFLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;

@end

@implementation FFLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   // NSLog(@"login NC %@", self.storyboard );
    [self.usernameInput becomeFirstResponder];
    self.passwordInput.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordInput) {
        [textField resignFirstResponder];
        [self loginUser:nil];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginUser:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameInput.text password:self.passwordInput.text
            block:^(PFUser *user, NSError *error) {
                if (user) {
                    UINavigationController *nc = (UINavigationController*)self.presentingViewController;
                    FFMeowViewController *meow = [nc.storyboard instantiateViewControllerWithIdentifier:@"meowview"];
                    [nc pushViewController:meow animated:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    

                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:errorString delegate:self cancelButtonTitle:@"Fix it!" otherButtonTitles:nil];
                    [alert show];
                }
            }];
}
- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
