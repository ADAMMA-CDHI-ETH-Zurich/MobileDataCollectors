#import "CLAID.hpp"
#import "CollectorAPI/Request.hpp"
#import "ViewController.hpp"
#import "AppDelegate.hpp"
#import "MicrophoneCollector.hpp"
#import "AudioRecorder.hpp"
#import "MicrophonePermission.hpp"

namespace claid
{
    void MicrophoneCollector::initialize()
    {
        std::cout<<"Calling init of MicrophoneCollector"<<std::endl;

        microphonePermission = [MicrophonePermission new];
    
        while (!microphonePermission.isGranted)
        {
            [microphonePermission blockingRequest];
            usleep(5000000);
        }

        audioDataChannel = publish<claid::AudioData>("MicrophoneAudioData");
        requestChannel = subscribe<claid::Request>("Requests", &MicrophoneCollector::onAudioDataRequested, this);
        audioRecorder = [AudioRecorder new];
        [audioRecorder initializeRecorder];

        
        std::cout<<"MicrophoneCollector initialized"<<std::endl;
        
        
    }

    void MicrophoneCollector::postAudioData()
    {
        claid::AudioData audioData;
        audioData.data = audioRecorder.recordedAudioDataBytes;
        audioDataChannel.post(audioData);
    }


    void MicrophoneCollector::onAudioDataRequested(claid::ChannelData<claid::Request> data)
    {
        claid::Request request = data->value();
        //TODO: Should be external
        int secondsToRecord = 9;
        if(request.dataIdentifier == "MicrophoneAudioData")
        {
            std::cout<<"AudioData requested"<<std::endl;
            
            [audioRecorder startRecording:secondsToRecord];
            
            while (![audioRecorder recordedAudioIsReady]);
            
            std::cout<<"AudioData ready"<<std::endl;
            postAudioData();
            audioRecorder.recordedAudioIsReady = false;
        }
        
    }
}


REGISTER_MODULE(claid::MicrophoneCollector)
