package LocationCollector;
//import static com.google.android.gms.location.Priority.PRIORITY_BALANCED_POWER_ACCURACY;
import android.annotation.SuppressLint;
import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
//import com.google.android.gms.location.FusedLocationProviderClient;
////import com.google.android.gms.location.LocationServices;
//import AndroidPermissions.LocationPermission;
import JavaCLAID.CLAID;
import JavaCLAID.Channel;
import JavaCLAID.ChannelData;
import JavaCLAID.Module;
import JavaCLAIDDataTypes.LocationData;

public class LocationCollector extends Module {
    private Channel<LocationData> locationDataChannel;
    private Location lastLocation = new Location("invalid");

    private LocationManager locationManager;

    public void initialize() {
        System.out.println("Calling init of LocationCollector");
      //  new LocationPermission().blockingRequest();

        this.locationManager = (LocationManager) CLAID.getContext().getSystemService(Context.LOCATION_SERVICE);



        this.locationDataChannel = this.publish(LocationData.class, "LocationData");
        System.out.println("LocationCollector initialized");
    }


   /* public void onLocationDataRequested(ChannelData<Request> data)
    {
        Request request = data.value();

        if(request.get_dataIdentifier().equals("LocationData"))
        {
            System.out.println("Requested LocationData request");
            updateLocationData();
        }
    }*/

    @SuppressLint("MissingPermission")
    public void updateLocationData()
    {
        Location location = locationManager.getLastKnownLocation(LocationManager.FUSED_PROVIDER);
        postLocation(location);
        /*
        FusedLocationProviderClient fusedLocationClient = LocationServices.
                getFusedLocationProviderClient((Context) CLAID.getContext());
         fusedLocationClient.getCurrentLocation(PRIORITY_BALANCED_POWER_ACCURACY, null)
                .addOnSuccessListener(location -> {
                    // Got current location. In some rare situations this can be null.
                    if (location != null)
                    {
                        postLocation(location);
                        lastLocation = location;
                    }
                    else
                    {
                        postLocation(lastLocation);
                    }
                })
                .addOnFailureListener(e -> postLocation(lastLocation));

         */
    }

    void postLocation(Location location)
    {
        LocationData locationData = new LocationData();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            locationData.set_vAccuracy((double) location.getVerticalAccuracyMeters());
        }
        else {
            locationData.set_vAccuracy(null);
        }
        locationData.set_hAccuracy((double) location.getAccuracy());
        locationData.set_bearing((double) location.getBearing());
        locationData.set_speed((double) location.getSpeed());
        locationData.set_timestamp((long) location.getTime());
        locationData.set_altitude(location.getAltitude());
        locationData.set_latitude(location.getLatitude());
        locationData.set_longitude(location.getLongitude());
        locationData.set_elapsedRealtimeSeconds((double) location.getElapsedRealtimeNanos()/1000000000);
        locationData.set_provider(location.getProvider());

        locationDataChannel.post(locationData);
    }

}
