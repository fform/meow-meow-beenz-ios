//
//  FFMeowLoader.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/19/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFMeowLoader.h"
#import <QuartzCore/QuartzCore.h>

@implementation FFMeowLoader
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //NSLog(@"init frame");
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"meow_none"] CGImage];
        self.layer.mask = maskLayer;
        _percentLoaded = 0;
    }
    return self;
}
- (float)getpercentLoaded
{
    return _percentLoaded;
}
- (void)setpercentLoaded:(float)loaded
{
    _percentLoaded = loaded;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect
{
    
    CGRect bounds = self.bounds;
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    // The largest circle will circumstribe the view
    float maxRadius = hypot(bounds.size.width, bounds.size.height) / 2.0;
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(center.x + maxRadius, center.y)];
    [path addArcWithCenter:center
                    radius:maxRadius
                startAngle:0.0
                  endAngle:M_PI * 2.0 * (self.percentLoaded/1)
                 clockwise:YES];
    [path addLineToPoint:center];
    // Configure line width to 10 points

    [[UIColor redColor] setFill];
    [path fill];
}
@end
