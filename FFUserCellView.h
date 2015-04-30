//
//  FFUserCellView.h
//  MeowMeowBeenz
//
//  Created by Will Froelich on 4/12/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFUserCellView : UITableViewCell
@property (weak, nonatomic) PFUser *user;
@property (strong, nonatomic) NSString *userID;
@property (nonatomic) float rating;
@property(weak,nonatomic) UIImageView * avatarView;

-(void) loadAvatarWithFetch:(bool)force;
+(void) resetAvatars;

@end
