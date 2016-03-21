//
//  AudioController.h
//  Aruts
//
//  Created by JusonQiu on 3/19/16.
//
//

#import <Foundation/Foundation.h>
#import "PCMAudioPlayer.h"

@interface AudioController : NSObject
{
    PCMAudioPlayer player;
    
}
-(void)stop;
-(void)start;
-(UInt32)writeData:(void*)buf :(UInt32)size;
-(void)releasePlayer;
@end
