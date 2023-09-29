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

#import "AccelerometerCollector.hpp"
#import "CollectorAPI/Request.hpp"

namespace claid
{
    void AccelerometerCollector::initialize()
    {
        std::cout<<"Calling init of AccelerometerCollector"<<std::endl;
        motionManager = [CMMotionManager new];
        
        float samplingPeriod = 1.0 / (1.0 * this->samplingFrequency);
        
        if (motionManager.isAccelerometerAvailable)
        {
            motionManager.accelerometerUpdateInterval = samplingPeriod; // 50 Hz
            [motionManager startAccelerometerUpdates];
            
        }
        else
        {
            CLAID_THROW(Exception, "Cannot start AccelerometerCollection, no accelerometer available on this phone. CMotionManager.isAccelerometerAvailable is false.");
        }
        
        this->registerPeriodicFunction("GatherAccelerometerSamples", &AccelerometerCollector::gatherAccelerometerSample, this, samplingPeriod * 1000);
                                       
                                       
        accelerometerDataChannel = publish<AccelerometerData>("AccelerometerData");
        requestChannel = subscribe<claid::Request>("Requests",
                                                   &AccelerometerCollector::onAccelerometerDataRequested, this);

        std::cout<<"AccelerometerCollector initialized"<<std::endl;
            
    }

    void AccelerometerCollector::gatherAccelerometerSample()
    {
        CMAccelerometerData* data = motionManager.accelerometerData;
        AccelerometerSample accelerometerSample;
        
        accelerometerSample.x = data.acceleration.x;
        accelerometerSample.y = data.acceleration.y;
        accelerometerSample.z = data.acceleration.z;
        
       this->accelerometerSamples.push_back(accelerometerSample);
    }


    void AccelerometerCollector::onAccelerometerDataRequested(claid::ChannelData<claid::Request> data)
    {
        claid::Request request = data->value();

        if(request.dataIdentifier == "AccelerometerData")
        {
            std::cout<<"AccelerometerData requested"<<std::endl;
            postAccelerometerData();
        }
    }


    void AccelerometerCollector::postAccelerometerData()
    {
        float TIME_SCALE = 1;
        float subSampleFrequency = 20;

        if(this->accelerometerSamples.size() < (1.0 * subSampleFrequency * TIME_SCALE))
        {
            accelerometerDataChannel.post(lastAccelerometerData);
        }
        else
        {
            AccelerometerData data;
            data.setAndSubsample(TIME_SCALE, subSampleFrequency, this->accelerometerSamples);
            this->accelerometerSamples.clear();
            this->lastAccelerometerData = data;
            this->accelerometerDataChannel.post(data);
        }
    }

}

REGISTER_MODULE(claid::AccelerometerCollector)



