//
//  AudioController.m
//  Aruts
//
//  Created by JusonQiu on 3/19/16.
//
//

#import "AudioController.h"

@implementation AudioController

- (instancetype)init
{
    self = [super init];
    if (self) {
        audioPlayerInit(&player);
    }
    return self;
}

-(void)stop{
    player.stop(&player);
}

-(void)start{
    player.start(&player);
}

-(UInt32)writeData:(void*)buf :(UInt32)size{
    return player.addData(&player, buf, size);
}

-(void)releasePlayer{
    audioPlayerRelease(&player);
}

@end
