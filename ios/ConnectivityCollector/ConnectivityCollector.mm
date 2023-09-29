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

#include "CLAID.hpp"
#include "CollectorAPI/Request.hpp"
#include "ConnectivityData.hpp"
#import "Network/Network.h"
#import "Foundation/Foundation.h"
#import <CoreFoundation/CoreFoundation.h>

#import "Reachability.h"

namespace claid
{
    class ConnectivityCollector : public Module
    {
        DECLARE_MODULE(ConnectivityCollector)

        private:
            static const std::string CONNECTIVITY_DATA_TAG;

            Channel<Request> requestChannel;
            Channel<ConnectivityData> connectivityDataChannel;

            std::string requestChannelName;
            std::string outputChannelName;
            
            Reachability* reachability;

        public:

            void initialize()
            {
                this->requestChannel = this->subscribe<Request>(this->requestChannelName, &ConnectivityCollector::onRequest, this);
                
                this->connectivityDataChannel = this->publish<ConnectivityData>(this->outputChannelName);
                
                reachability = [Reachability reachabilityForInternetConnection];
                [reachability startNotifier];

                
                   
            }

            void onRequest(ChannelData<Request> data)
            {   
                const Request& request = data->value();

                if(request.dataIdentifier == CONNECTIVITY_DATA_TAG)
                {
                    this->postConnectivityData();
                }
            }

            void postConnectivityData()
            {
                ConnectivityData data;
                NetworkStatus status = [reachability currentReachabilityStatus];
                std::cout << "Onrequest\n";
                if(status == NotReachable)
                {
                    std::cout << "Network not reachable\n";
                    data.connected = false;
                    data.networkType = UNKNOWN;
                }
                else if (status == ReachableViaWiFi)
                {
                    std::cout << "Network reachable via wifi\n";
                    //WiFi
                    data.connected = true;
                    data.networkType = WIFI;
                }
                else if (status == ReachableViaWWAN)
                {
                    std::cout << "Network reachable via WWAN\n";
                    data.connected = true;
                    data.networkType = CELLULAR;
                }
                this->connectivityDataChannel.post(data);
            }

            Reflect(ConnectivityCollector,
                    reflectMemberWithDefaultValue(requestChannelName, std::string("Requests"));
                    reflectMemberWithDefaultValue(outputChannelName, CONNECTIVITY_DATA_TAG);
            )
    };
}

const std::string claid::ConnectivityCollector::CONNECTIVITY_DATA_TAG = "ConnectivityData";
REGISTER_MODULE(claid::ConnectivityCollector)
