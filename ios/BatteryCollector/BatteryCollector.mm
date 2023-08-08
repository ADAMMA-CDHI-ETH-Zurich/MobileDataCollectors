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
