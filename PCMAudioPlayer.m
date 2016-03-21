//
//  PCMAudioPlayer.m
//  Aruts
//
//  Created by JusonQiu on 3/19/16.
//
//


#import "PCMAudioPlayer.h"


#define CHECK_STATUS(x) printf("%s<%d>: %d\n", __func__, __LINE__, (int)x)
#define kOutputBus  0
#define kInputBus   1



static FILE *fp;

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {

    for (int i=0; i < ioData->mNumberBuffers; i++) {
        AudioBuffer buffer = ioData->mBuffers[i];
        
        int error = 0;
        if (0){
            if (fp == NULL ||  feof(fp)){
                if (fp != NULL) fclose(fp);
                NSString * path = [[NSBundle mainBundle] pathForResource:@"out1" ofType:@"raw"];
                if (path != NULL){
                    const char *cpath = [path UTF8String];
                    fp = fopen(cpath, "rb");
                    assert(fp != NULL);
                }
            }
            UInt32 ret = (UInt32)fread(buffer.mData , 1, buffer.mDataByteSize, fp);
            buffer.mDataByteSize = ret;
            if (ret <= 0) error = 1;
            
        }else{
            AudioProducer *mAP = (AudioProducer *)inRefCon;
            UInt32 ret = [mAP getNextPkg:buffer.mData :buffer.mDataByteSize];
            buffer.mDataByteSize = ret;
            if (ret == 0) error = 1;
        }
        if (error){
            UInt16 *frameBuffer = buffer.mData;
            for (int j = 0; j < inNumberFrames; j++) {
                frameBuffer[j] = 0;//[ap getNextFrame];//rand();
            }
        }
        // uncomment to hear random noise
    }
    
    return noErr;
}


static void init(PCMAudioPlayer *audioPlayer){
    
    audioPlayer->audioProducer = [[AudioProducer alloc] init];
    
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioPlayer->audioUnit);
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioPlayer->audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag, 
                                  sizeof(flag));
    CHECK_STATUS(status);
    
    //	 Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= 44100.00;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 2;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 4;
    audioFormat.mBytesPerFrame		= 4;
    
    status = AudioUnitSetProperty(audioPlayer->audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    CHECK_STATUS(status);
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = audioPlayer->audioProducer;
    status = AudioUnitSetProperty(audioPlayer->audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    CHECK_STATUS(status);
    
    status = AudioUnitInitialize(audioPlayer->audioUnit);
    CHECK_STATUS(status);
}

static void start(PCMAudioPlayer *audioPlayer){
    OSStatus status = AudioOutputUnitStart(audioPlayer->audioUnit);
    CHECK_STATUS(status);
}

static void stop(PCMAudioPlayer *audioPlayer){
    OSStatus status = AudioOutputUnitStop(audioPlayer->audioUnit);
    CHECK_STATUS(status);
}

static void release(PCMAudioPlayer *audioPlayer){
    AudioUnitUninitialize(audioPlayer->audioUnit);
}

static UInt32 addData(PCMAudioPlayer *audioPlayer, void *buf, UInt32 size){
    return [audioPlayer->audioProducer writeData:buf :size];
}
void audioPlayerInit(PCMAudioPlayer *audioPlayer){
    init(audioPlayer);
    audioPlayer->start = (AudioPlayerFunc)start;
    audioPlayer->stop = (AudioPlayerFunc)stop;
    audioPlayer->addData = addData;
}

void audioPlayerRelease(PCMAudioPlayer *audioPlayer){
    stop(audioPlayer);
    [audioPlayer->audioProducer releaseInstance];
    release(audioPlayer);
}

















