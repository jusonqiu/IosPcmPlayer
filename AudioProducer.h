//
//  AudioProducer.h
//  Aruts
//
//  Created by JusonQiu on 3/18/16.
//
//

#import <Foundation/Foundation.h>
#include "queue.h"
#include "TPCircularBuffer.h"
#define TP_BUFFER_SIZE  (1024*1024)

@interface AudioProducer : NSObject{


@public
    UInt32 frameIndex;
    UInt32 frameCount;
    UInt8 frames[1024*10];
    queue_t *queue;
    TPCircularBuffer buffer;
}

+(AudioProducer *)getInstance;
//-(queue_t*) getQueue;
-(UInt16) getNextFrame;
-(UInt32) getNextPkg:(void *)buf :(UInt32)size;
-(UInt32)writeData:(void *)buf :(UInt32)size;
-(void)releaseInstance;

@end
