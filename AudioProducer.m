//
//  AudioProducer.m
//  Aruts
//
//  Created by JusonQiu on 3/18/16.
//
//

#import "AudioProducer.h"
#include "data_header.h"

#define BUFFERSIZE (1024*1024)

static AudioProducer *mAudioProducer;

@implementation AudioProducer


+(AudioProducer *)getInstance{
    if (mAudioProducer == nil)
        mAudioProducer = [[AudioProducer alloc] init];
    return mAudioProducer;
    
}
-(void)releaseInstance{
    TPCircularBufferCleanup(&buffer);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        frameIndex = 0;
        frameCount = 0;
        memset(frames, 0, sizeof(frames));
        queue = queue_create_limited(100);
        assert(queue != NULL);
        bool ret = TPCircularBufferInit(&buffer, TP_BUFFER_SIZE);
        assert(ret != false);
    }
    return self;
}

-(queue_t*) getQueue{
    return queue;
}

-(UInt16) getNextFrame{
    UInt32 returnval = 0;

    if (frameIndex >= frameCount){
        struct queue_buf *qb = NULL;
        if (queue_get(queue, (void *)&qb) == Q_OK && qb != NULL){
            UInt32 size = BUFFERSIZE >= qb->size ? qb->size : BUFFERSIZE;
            memcpy(frames, qb->buf, size);
            frameIndex = 0;
            frameCount = size;
            free(qb);
        }else{
            return 0;
        }
    }
    
    UInt16 *temp = malloc(sizeof(UInt16));
    memcpy(temp, &frames[frameIndex], 2);
    returnval = *temp;
    free(temp);
//    returnval = frames[frameIndex];
    frameIndex += 2;
    frameCount -= 2;
    return returnval;
}

-(UInt32)writeData:(void *)buf :(UInt32)size{
    int32_t availableBytes = 0;
    TPCircularBufferHead(&buffer, &availableBytes);
    if (availableBytes <= 0) return 0;
    UInt32 len =  (availableBytes >= size ? size : availableBytes);
    TPCircularBufferProduceBytes(&buffer, (void*)buf, len);
    return len;
}

-(UInt32) getNextPkg:(void *)buf :(UInt32)size{

    int32_t availableBytes = 0;
    void *bufferTail = TPCircularBufferTail(&buffer, &availableBytes);
    if (availableBytes >= size){
        UInt32 len = 0;
        len = (size > availableBytes ? availableBytes : size);
        memcpy(buf, bufferTail, len);
        TPCircularBufferConsume(&buffer, len);
//        NSLog(@"len = %d", len);
        return len;
    }
    return 0;
}


@end
