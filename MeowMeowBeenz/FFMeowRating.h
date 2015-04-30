//
//  FFMeowRating.h
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/9/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FFMeowRating;

@protocol RateViewDelegate
- (void)rateView:(FFMeowRating *)rateView ratingDidChange:(float)rating;
@end

@interface FFMeowRating : UIView

@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;
@property (assign, nonatomic) float rating;
@property (assign) BOOL editable;
@property (strong) NSMutableArray * imageViews;
@property (assign, nonatomic) int maxRating;
@property (assign) int midMargin;
@property (assign) int leftMargin;
@property (assign) CGSize minImageSize;
@property (assign) id <RateViewDelegate> delegate;

+ (float)myRatingForUser:(PFObject *)user;
+ (void)myRatingForUser:(PFObject *)user inBackground:(void(^)(PFObject *object, NSError *error))block;
+ (float)calculateBeenz:(PFObject *)user;
+ (float)saveBeenzVote:(float)rating forUser:(PFObject *)user;

@end