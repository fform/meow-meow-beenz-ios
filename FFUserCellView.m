//
//  FFUserCellView.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 4/12/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFUserCellView.h"
@interface FFUserCellView ()

@end



@implementation FFUserCellView

static NSInteger _loadingCount = 0;

+(NSMutableDictionary *)userlist{
    static NSMutableDictionary *fetched = nil;
    if(!fetched){
        fetched = [NSMutableDictionary new];
    }
    return fetched;
}
+(NSInteger)loadingCount{
    
    return _loadingCount;
}
+(void)loadingChange:(NSInteger)amount{
    _loadingCount += amount;
}
+(bool)areTooManyLoading{
    return ( _loadingCount > 10 );
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];

    if (self) {
        for( NSInteger i = 1; i <= 5; i++){
            UIImageView *cat = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"meow_empty"]];
            cat.tag = i;
            cat.frame = CGRectMake( self.frame.size.width - ( 10 + (30 * i)), 15, 25, 25 );
            cat.alpha = 0;
            cat.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:cat];
        }
        
        
        self.imageView.image =  [UIImage imageNamed:@"missing_avatar.png"];
        UIImageView *avatar = [[UIImageView alloc] initWithFrame: CGRectMake(10, 5, 50, 50) ];//self.imageView.frame
        avatar.clipsToBounds = YES;
        avatar.layer.cornerRadius = 25;
        avatar.image = nil;
        self.avatarView = avatar;
        [self.contentView addSubview:self.avatarView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(10, 5, 50, 50);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 25;
    NSInteger currentRating = [[NSNumber numberWithFloat:_rating] integerValue];
    for( NSInteger i = 0; i < 5; i ++ ){
        UIImageView *cat = (UIImageView *)[self viewWithTag: (i+1) ];
        cat.alpha = i == 0 || (i+1) <= currentRating ? 1 : 0;
        cat.frame = CGRectMake(65 + (10 + (i * cat.frame.size.width)), 30, cat.frame.size.width, cat.frame.size.height);
    }
    
    self.textLabel.frame = CGRectMake(75, 10, 250, 20);
}

-(void) loadAvatarWithFetch:(bool)force{
    //NSLog(@"loadAvatar: %@  forced:%d", self.userID, force);
    if([self.user isDataAvailable] && self.user[@"avatar"]){
        self.avatarView.image = [UIImage imageWithData:self.user[@"avatar"]];
    }else{
        //self.imageView.image =  [UIImage imageNamed:@"missing_avatar.png"];
        if(force){
            
            if( ![FFUserCellView userlist][ self.user.objectId ] ){
                //NSLog(@"fetching now");

                [FFUserCellView userlist][ self.user.objectId ] = @YES;
                //NSLog(@"Fetched %@ %@", self.user[@"displayname"], self.user.objectId);
                
                if( ![FFUserCellView areTooManyLoading] ){
                    [FFUserCellView loadingChange:1];
                    [self.user fetchInBackgroundWithTarget:self selector:@selector(processAvatar:error:)];
                }else{
                    //NSLog(@"Too many loading now");
                }
                
            }else{
                //NSLog(@"already fetched");
            }
            
        }
    }

}

-(void) processAvatar:(PFObject *)refreshedObject error:(NSError *)error{
    [FFUserCellView loadingChange:-1];
    if(!error){
        //NSLog(@"loaded %@ %@:%@", self.user[@"displayname"], self.user.objectId,refreshedObject.objectId );
        
        if([self.user.objectId isEqualToString:refreshedObject.objectId] ){
            
            self.avatarView.alpha = 0;
            [UIView beginAnimations:@"fade in" context:nil];
            [UIView setAnimationDuration:1.0];
            self.avatarView.image = [UIImage imageWithData:refreshedObject[@"avatar"]];
            self.avatarView.alpha = 1;
            [UIView commitAnimations];
        }else{
            //NSLog(@"Cell offscreen");
        }
    }else{
       // NSLog(@"Error Loading Avatar: %@" , error);
    }
    
}

+(void) resetAvatars{
    [[FFUserCellView userlist] removeAllObjects];
}

@end
