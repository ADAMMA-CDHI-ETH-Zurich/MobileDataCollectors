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
