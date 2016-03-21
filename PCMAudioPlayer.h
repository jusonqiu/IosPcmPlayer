//
//  PCMAudioPlayer.h
//  Aruts
//
//  Created by JusonQiu on 3/19/16.
//
//

#ifndef __PCMAudioPlayer_H__
#define __PCMAudioPlayer_H__
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioProducer.h"

typedef void (*AudioPlayerFunc) (void *);

typedef struct _PCMAudioPlayer{
    AudioProducer *audioProducer;
    AudioComponentInstance audioUnit;
    AudioPlayerFunc start;
    AudioPlayerFunc stop;
    UInt32 (*addData)(void*, void *, UInt32 );
}PCMAudioPlayer;

void audioPlayerInit(PCMAudioPlayer *audioPlayer);
void audioPlayerRelease(PCMAudioPlayer *audioPlayer);
#endif