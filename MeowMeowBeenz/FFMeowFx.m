//
//  FFMeowFx.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/10/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFMeowFx.h"

const NSString *kUpSound = @"meow-up";
const NSString *kDownSound = @"meow-down";

@interface FFMeowFx () <AVAudioPlayerDelegate>
    @property (nonatomic) NSMutableDictionary *sounds;
@end

@implementation FFMeowFx

- (void) thing
{
    
    

}

+ (instancetype)player
{
    static FFMeowFx *player = nil;
    
    if(!player){
        player = [[self alloc] initPrivate];
    }
    
    return player;
}

// Here is the real (secret) initializer
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _sounds = [[NSMutableDictionary alloc] init];
        NSArray *files = @[kUpSound, kDownSound];
        for(NSString *file in files){
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: file ofType: @"mp3"];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
            AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
            [newPlayer prepareToPlay];
            newPlayer.delegate = self;
            _sounds[file] = newPlayer;
        }
    }
    return self;
}

- (void)meowUp{
    AVAudioPlayer *sound = self.sounds[kUpSound];
    if(sound.isPlaying){
        [sound stop];
    }
    [sound play];
}
- (void)meowDown{
    AVAudioPlayer *sound = self.sounds[kDownSound];
    if(sound.isPlaying){
        [sound stop];
    }
    [sound play];
}

@end
