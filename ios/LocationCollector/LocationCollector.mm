#import "CollectorAPI/Request.hpp"
#import "LocationCollector.hpp"
#import "LocationData.hpp"
#import "LocationPermission.hpp"
#import <CoreLocation/CoreLocation.h>

namespace claid
{
    void LocationCollector::initialize()
    {
        std::cout<<"Calling init of LocationCollector"<<std::endl;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            locationPermission = [LocationPermission new];
        });
        
        while (true) {
            if (locationPermission.isGranted) {
                break;
            }
            [NSThread sleepForTimeInterval:3.0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            locationTracker = [LocationTracker new];
        });

        locationDataChannel = publish<LocationData>("LocationData");
        requestChannel = subscribe<claid::Request>("Requests",
                                                   &LocationCollector::onLocationDataRequested, this);

        std::cout<<"LocationCollector initialized"<<std::endl;
            
    }


    void LocationCollector::postLocationData()
    {
        LocationData locationData;
        locationData = locationTracker.getLastKnownLocation;
        locationDataChannel.post(locationData);
    }


    void LocationCollector::onLocationDataRequested(claid::ChannelData<claid::Request> data)
    {
        claid::Request request = data->value();
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            locationTracker = [LocationTracker new];
        });
        
        if(request.dataIdentifier == "LocationData")
        {
            std::cout<<"LocationData requested"<<std::endl;
            postLocationData();
        }
        
    }
}
REGISTER_MODULE(claid::LocationCollector)



