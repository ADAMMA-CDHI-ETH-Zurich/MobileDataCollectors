#pragma once
#import <AVFoundation/AVFoundation.h>

#import "CLAID.hpp"

@interface AudioRecorder : NSObject <AVAudioRecorderDelegate>
    
@property (strong) AVAudioRecorder *recorder;

@property AVAudioSession *session;

@property NSURL *audioFileURL;

@property (nonatomic) Byte *recordedAudioBytes;

@property bool recordedAudioIsReady;

@property std::vector<uint8_t> recordedAudioDataBytes;

- (void)startRecording:(int)secondsToRecord;

- (void) initializeRecorder;


@end
