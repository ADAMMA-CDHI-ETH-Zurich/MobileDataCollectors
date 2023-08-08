#import "LocationTracker.hpp"


@implementation LocationTracker

LocationData locationData;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self startLocationListener];
    }
    return self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = locations.lastObject;

    std::string sourceInformation = "Only available on iOS 15+";
    int16_t floor = (int16_t) location.floor.level;
    double hAccuracy = location.horizontalAccuracy;
    double vAccuracy = location.verticalAccuracy;
    double speed = location.speed;
    double altitude = location.altitude;
    double latitude = location.coordinate.latitude;
    double longitude = static_cast<double>(location.coordinate.longitude);
    int64_t timestamp = (int64_t) [location.timestamp timeIntervalSince1970];
    double elapsedRealtimeSeconds = [[NSProcessInfo processInfo] systemUptime];
    double course = location.course;
    
    // TODO: Check why sourceInformation returns object and not value
    if (@available(iOS 15.0, *)) {
        NSString *NSSourceInformation = [NSString stringWithFormat:@"%@", location.sourceInformation];
        sourceInformation = [NSSourceInformation UTF8String];
    }
    
    NSLog(@"floor.level: %d", location.floor.level);
    NSLog(@"horizontalAccuracy: %f", location.horizontalAccuracy);
    NSLog(@"verticalAccuracy: %f", location.verticalAccuracy);
    NSLog(@"speed: %f", location.speed);
    NSLog(@"altitude: %f", location.altitude);
    NSLog(@"latitude: %f", location.coordinate.latitude);
    NSLog(@"longitude: %f", location.coordinate.longitude);
    NSLog(@"timestamp: %lld", [location.timestamp timeIntervalSince1970]);
    NSLog(@"elapsedRealtimeSeconds: %f", [[NSProcessInfo processInfo] systemUptime]);
    NSLog(@"course: %f", location.course);
    
    std::cout<<std::setprecision(12);
    std::cout<<std::endl<<"---Floor: "<<floor<<" HAccuracy: "<<hAccuracy<<" VAccuracy: "<<vAccuracy<<" Speed: "<<speed<<" Altitude: "<<
    altitude<<" Latitude: "<<latitude<<" Longitude: "<<longitude<<" Timestamp: "<<timestamp<<" ElapsedNano: "<<elapsedRealtimeSeconds<<
    " Course: "<<course<<" Source Info: "<<sourceInformation<<"---"<<std::endl<<std::endl;
    
    time_t seconds = (time_t)((int64_t) timestamp);
    std::string dateString = std::ctime(&seconds);
    std::cout << "timestamp formatted: "<<dateString<< std::endl;
  
    
    locationData.floor = floor;
    locationData.hAccuracy = hAccuracy;
    locationData.vAccuracy = vAccuracy;
    locationData.speed = speed;
    locationData.altitude = altitude;
    locationData.latitude = latitude;
    locationData.longitude = longitude;
    locationData.timestamp = timestamp;
    locationData.elapsedRealtimeSeconds = elapsedRealtimeSeconds;
    locationData.bearing = course;
    locationData.provider = sourceInformation;

}


- (void)startLocationListener {
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
}

- (void)stopLocationListener {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_locationManager stopMonitoringSignificantLocationChanges];
        [_locationManager stopUpdatingLocation];
    });
}

- (LocationData)getLastKnownLocation {
    [self stopLocationListener];
    return locationData;
}


@end
