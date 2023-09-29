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
#import "BatteryData.hpp"

//TODO: test on real device, emulator produces wrong values

namespace claid
{
    class BatteryCollector : public claid::Module
    {
        DECLARE_MODULE(BatteryCollector)
        
        private:
            claid::Channel<BatteryData> batteryDataChannel;
            claid::Channel<claid::Request> requestChannel;
        
        public:
        
            void initialize()
            {
                std::cout<<"Calling init of BatteryCollector"<<std::endl;
                batteryDataChannel = publish<BatteryData>("BatteryData");
                requestChannel = subscribe<claid::Request>("Requests", &BatteryCollector::onBatteryDataRequested, this);
                std::cout<<"BatteryCollector initialized"<<std::endl;
            }
            
            void postBatteryData()
            {
                UIDevice *device = [UIDevice currentDevice];
                [device setBatteryMonitoringEnabled:YES];
                
                // 0 unknown, 1 unplegged, 2 charging, 3 full
                int state = (int)[device batteryState];
                int level = (int)[device batteryLevel] * 100;
                
                BatteryData batteryData;
                batteryData.level = level;
                switch (state) {
                    case 1:
                        batteryData.state = UNPLUGGED;
                        break;
                    case 2:
                        batteryData.state = CHARGING;
                        break;
                    case 3:
                        batteryData.state = FULL;
                        break;
                    default:
                        batteryData.state = UNKNOWN;
                        break;
                }

                batteryDataChannel.post(batteryData);
            }
        
        
            void onBatteryDataRequested(claid::ChannelData<claid::Request> data)
            {
                std::cout<<"BatteryData requested"<<std::endl;
                if(data->value().dataIdentifier == "BatteryData")
                {
                    postBatteryData();
                }
            }
    };
}
REGISTER_MODULE(claid::BatteryCollector);
