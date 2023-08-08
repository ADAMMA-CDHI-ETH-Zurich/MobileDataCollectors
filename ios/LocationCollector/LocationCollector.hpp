#pragma once
#include "CLAID.hpp"
#include "CollectorAPI/Request.hpp"
#include "LocationData.hpp"
#include "LocationTracker.hpp"
#include "LocationPermission.hpp"

namespace claid
{
    class LocationCollector : public claid::Module
    {
        DECLARE_MODULE(LocationCollector)

        private:
            LocationTracker* locationTracker;
            LocationPermission* locationPermission;
            claid::Channel<LocationData> locationDataChannel;
            claid::Channel<claid::Request> requestChannel;
        public:

            void initialize();
                
            void postLocationData();

            void onLocationDataRequested(claid::ChannelData<claid::Request> data);

    };
}
