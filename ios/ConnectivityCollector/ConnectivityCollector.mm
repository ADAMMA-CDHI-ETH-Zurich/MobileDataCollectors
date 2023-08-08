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
