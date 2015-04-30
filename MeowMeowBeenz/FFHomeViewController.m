//
//  FFHomeViewController.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/7/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFHomeViewController.h"
#import <Parse/Parse.h>
#import "FFMeowViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FFMeowFx.h"

@interface FFHomeViewController ()
@end

@implementation FFHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:YES animated:NO];

    [[FFMeowFx player] meowUp];
}
- (IBAction)catFaceTap:(id)sender {

    [[FFMeowFx player] meowUp];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self userLoggedIn];
    }else{
        //NSLog(@"Not logged in");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)userLoggedIn
{
    //NSLog(@"User is logged in");

    FFMeowViewController *meow = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"meowview"];
    if(meow){
        // NSLog(@"Loading meow");
        meow.delegate = self;
        [[self navigationController] setToolbarHidden:NO animated:YES];
        [[self navigationController] pushViewController:meow animated:YES];
    }else{
        //NSLog(@"Couldn't find meow table view");
    }
   
}

-(void)logUserOut
{
    [PFUser logOut];
    //NSLog(@"home:logUserOut");
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   // NSLog(@"Prepare for %@ %@", segue, segue.identifier);
    if([segue.identifier isEqualToString:@"userLogOut"]){
       // NSLog(@"Logout");
        [PFUser logOut];
    }
}


@end
