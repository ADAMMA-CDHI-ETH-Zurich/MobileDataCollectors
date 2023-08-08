#pragma once
#include "CLAID.hpp"
#include "CollectorAPI/Request.hpp"
#import "AccelerometerData.hpp"
#import <CoreMotion/CoreMotion.h>

namespace claid
{
    class AccelerometerCollector : public claid::Module
    {

        private:
            claid::Channel<AccelerometerData> accelerometerDataChannel;
            claid::Channel<claid::Request> requestChannel;
            CMMotionManager* motionManager;

            std::vector<AccelerometerSample> accelerometerSamples;

            AccelerometerData lastAccelerometerData;
        
            uint16_t samplingFrequency;

            
        
        public:

            void initialize();

            void gatherAccelerometerSample();

            void postAccelerometerData();

            void onAccelerometerDataRequested(claid::ChannelData<claid::Request> data);

            Reflect(AccelerometerCollector,
                    reflectMember(samplingFrequency);
            )
        
    };
}
