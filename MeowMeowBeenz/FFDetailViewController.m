//
//  FFDetailViewController.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/9/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFDetailViewController.h"
#import "FFMeowRating.h"

@interface FFDetailViewController () <RateViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet FFMeowRating *meowRating;
@property (weak, nonatomic) IBOutlet UILabel *bigRating;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@end

@implementation FFDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.user fetchIfNeeded];
    PFObject * ratings = self.user[@"ratings"];
    [ratings refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        float cRating = [FFMeowRating calculateBeenz:self.user];
        [self updateBigRating:cRating];
    }];
    
	self.meowRating.notSelectedImage = [UIImage imageNamed:@"meow_empty"];
    self.meowRating.halfSelectedImage = [UIImage imageNamed:@"meow_half"];
    self.meowRating.fullSelectedImage = [UIImage imageNamed:@"meow_full"];
    self.bigRating.text =@"";
    [FFMeowRating myRatingForUser:self.user inBackground:^(PFObject *object, NSError *error) {
        self.meowRating.rating = [FFMeowRating myRatingForUser:self.user];
    }];
    self.meowRating.rating = 0;
    self.meowRating.editable = YES;
    self.meowRating.maxRating = 5;
    self.meowRating.delegate = self;
    if([[PFUser currentUser].objectId isEqualToString:self.user.objectId]){
        self.meowRating.hidden = YES;
    }

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:0.718 green:0.200 blue:0.329 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1.000 green:0.984 blue:0.792 alpha:1.0]];
    self.usernameLabel.text = self.user[@"displayname"];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    if(self.user[@"avatar"]){
        self.avatarImage.image = [self clipImage:[UIImage imageWithData:self.user[@"avatar"]]];
    }else{
        self.avatarImage.image = [self clipImage:[UIImage imageNamed:@"meow_none.png"]];

    }
    
    self.scroller.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.scroller.contentSize = self.contentView.bounds.size;
    
    self.scroller.delegate = self;
  NSDictionary *viewsDictionary;
     viewsDictionary = NSDictionaryOfVariableBindings(_scroller, _contentView);
    //[self.view      addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scroller]|" options:0 metrics: 0 views:viewsDictionary]];
    //[self.view      addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scroller]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.scroller  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.scroller  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics: 0 views:viewsDictionary]];
    //NSLog(@"User Ratings: %@", self.user[@"Ratings"]);
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

- (void)rateView:(FFMeowRating *)rateView ratingDidChange:(float)rating {
    //self.statusLabel.text = [NSString stringWithFormat:@"Rating: %f", rating];
    float currentBeenz = [FFMeowRating saveBeenzVote:rating forUser:self.user];
    [self updateBigRating:currentBeenz];
    
}



- (void)updateBigRating:(float)rating{
    self.bigRating.text = [NSString stringWithFormat:@"%i", (int) floor(rating)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
