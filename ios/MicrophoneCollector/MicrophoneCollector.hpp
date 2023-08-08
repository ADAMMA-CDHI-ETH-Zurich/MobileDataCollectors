#pragma once
#include "CLAID.hpp"
#include "CollectorAPI/Request.hpp"
#include "AudioRecorder.hpp"
#include "MicrophonePermission.hpp"
#include "AudioData.hpp"

namespace claid
{
    class MicrophoneCollector : public claid::Module
    {
        DECLARE_MODULE(MicrophoneCollector)

        private:
            MicrophonePermission* microphonePermission;
            AudioRecorder* audioRecorder;
            claid::Channel<claid::AudioData> audioDataChannel;
            claid::Channel<claid::Request> requestChannel;

        public:

            void initialize();

            void postAudioData();

            void onAudioDataRequested(claid::ChannelData<claid::Request> data);

    };
}

