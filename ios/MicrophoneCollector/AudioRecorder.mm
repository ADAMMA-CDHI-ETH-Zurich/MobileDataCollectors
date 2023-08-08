#import "AudioRecorder.hpp"
#import "CLAID.hpp"
#include <chrono>

@implementation AudioRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _recordedAudioIsReady = false;
        _session = [AVAudioSession sharedInstance];
        NSError *error;

        if (![_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
        {
            NSLog(@"Error setting session category: %@", error.localizedFailureReason);
        }
        if (![_session setActive:YES error:&error])
        {
            NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
        }
        
        

    }
    return self;
}

-(void) initializeRecorder
{
    NSDictionary *recordSettings = @{
        AVFormatIDKey: @(kAudioFormatLinearPCM),
        AVLinearPCMIsBigEndianKey: @NO,
        AVLinearPCMIsFloatKey: @NO,
        AVLinearPCMBitDepthKey: @32,
        AVNumberOfChannelsKey: @1,
        AVSampleRateKey: @16000.0f
    };
    NSString *audioFilePath = [NSTemporaryDirectory() stringByAppendingString:@"tempRecording.bin"];
    _audioFileURL = [NSURL fileURLWithPath:audioFilePath];

    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:_audioFileURL settings:recordSettings error:&error];
    
    if(error || ![_recorder prepareToRecord])
    {
        CLAID_THROW(claid::Exception, "Error initializing AudioRecorder.");
    }
}

- (void) startRecording:(int)secondsToRecord
{
    _recordedAudioIsReady = false;

   
    
    NSError *error;
    
    if (_recorder) {
        [_recorder recordForDuration:secondsToRecord];
        [_recorder setDelegate:self];
        [_recorder setMeteringEnabled:NO];
        std::cout<<"Start recording..."<<std::endl;
    }
    else{
        NSLog(@"Error initializing the recorder: %@", error.localizedDescription);
    }
    
}


// Sending as float 32 bit
//Callback function when "recordForDuration" finishes execution
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSError *error;
    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:_audioFileURL error:&error];
    if (error) {
        NSLog(@"Error loading recorded audio file: %@", error.localizedDescription);
    } else {
        AVAudioPCMBuffer *audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFile.processingFormat frameCapacity:(AVAudioFrameCount)audioFile.length];

        [audioFile readIntoBuffer:audioBuffer error:&error];
        if (error) {
            NSLog(@"Error reading audio data into buffer: %@", error.localizedDescription);
        } else {
            int audioDataSize = audioBuffer.frameLength * audioBuffer.format.streamDescription->mBytesPerFrame;
            std::cout<<"AudioData lenght: "<<audioDataSize<<" "<<audioBuffer.frameLength << " " << std::endl;
            _recordedAudioDataBytes.clear();
            _recordedAudioDataBytes.resize(audioDataSize);

            claid::Time time = claid::Time::now();
            
            memcpy(_recordedAudioDataBytes.data(), audioBuffer.floatChannelData, audioDataSize);
            /*
            for (int i = 0; i < audioBuffer.frameLength; i++)
            {
              for (int j = 0; j < audioBuffer.format.channelCount; j++)
              {
                float sample = audioBuffer.floatChannelData[j][i];
                uint8_t* sampleBytes = reinterpret_cast<uint8_t*>(&sample);
                _recordedAudioDataBytes.insert(_recordedAudioDataBytes.end(), sampleBytes, sampleBytes + sizeof(float));
              }
            }*/
            claid::Time end = claid::Time::now();
            std::cout << "elapsed time for copying: " << (end - time).count() << "\n";
            _recordedAudioIsReady = true;
        }
    }
}


// sending as PCM 32 bit int
//- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
//{
//    NSError *error;
//    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:_audioFileURL error:&error];
//    if (error) {
//        NSLog(@"Error loading recorded audio file: %@", error.localizedDescription);
//    } else {
//        AVAudioPCMBuffer *audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFile.processingFormat frameCapacity:(AVAudioFrameCount)audioFile.length];
//
//        [audioFile readIntoBuffer:audioBuffer error:&error];
//        if (error) {
//            NSLog(@"Error reading audio data into buffer: %@", error.localizedDescription);
//        } else {
//            AVAudioFormat *destinationFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt32 sampleRate:44100 channels:1 interleaved:false];
//            AVAudioPCMBuffer *convertedBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:destinationFormat frameCapacity:audioBuffer.frameCapacity];
//            AVAudioConverter *converter = [[AVAudioConverter alloc] initFromFormat:audioBuffer.format toFormat:destinationFormat];
//            [converter convertToBuffer:convertedBuffer fromBuffer:audioBuffer error:&error];
//
//            int audioDataSize = convertedBuffer.frameLength * convertedBuffer.format.streamDescription->mBytesPerFrame;
//            std::cout<<"AudioData lenght: "<<audioDataSize<<std::endl;
//
//            if (error) {
//                NSLog(@"Error converting audio data: %@", error.localizedDescription);
//            } else {
//                int32_t *pcmData = convertedBuffer.int32ChannelData[0];
//                int numSamples = convertedBuffer.frameLength;
//
//                for (int i = 0; i < numSamples; i++) {
//                    uint8_t* sampleBytes = reinterpret_cast<uint8_t*>(&pcmData[i]);
//                    _recordedAudioDataBytes.insert(_recordedAudioDataBytes.end(), sampleBytes, sampleBytes + sizeof(int32_t));
//                }
//                _recordedAudioIsReady = true;
//            }
//        }
//    }
//}



- (void)stopRecording {
    [_recorder stop];
    _recorder = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

// Can be useful to avoid overlapping recordings?
- (BOOL)isRecording {
    return self.recorder.isRecording;
}

@end
