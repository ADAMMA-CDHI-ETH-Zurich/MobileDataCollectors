/***************************************************************************
* Copyright (C) 2023 ETH Zurich
* Core AI & Digital Biomarker, Acoustic and Inflammatory Biomarkers (ADAMMA)
* Centre for Digital Health Interventions (c4dhi.org)
* 
* Authors: Patrick Langer, Francesco Feher
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*         http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
***************************************************************************/

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
