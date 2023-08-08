#pragma once
#import <CoreLocation/CoreLocation.h>
#import "LocationData.hpp"

@interface LocationTracker: NSObject <CLLocationManagerDelegate>

@property (strong) CLLocationManager *locationManager;

-(LocationData) getLastKnownLocation;

@end

