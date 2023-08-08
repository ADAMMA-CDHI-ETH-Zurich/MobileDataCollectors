package ConnectivityCollector;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.LinkProperties;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.os.BatteryManager;


import JavaCLAID.CLAID;
import JavaCLAID.Channel;
import JavaCLAID.ChannelData;
import JavaCLAID.Module;
import JavaCLAIDDataTypes.ConnectivityData;

public class ConnectivityCollector extends Module
{
    private Channel<ConnectivityData> connectivityDataChannel;
   // private Channel<Request> connectivityRequestsChannel;

    private final String DATA_IDENTIFIER = "ConnectivityData";

    public void initialize()
    {
        System.out.println("Calling init of BatteryCollector");
        this.connectivityDataChannel = this.publish(ConnectivityData.class, DATA_IDENTIFIER);
      //  this.connectivityRequestsChannel = this.subscribe(Request.class, "Requests", r -> onConnectivityDataRequested(r));
        System.out.println("BatteryCollector initialized");
    }

  /* public void onConnectivityDataRequested(ChannelData<Request> data)
    {
        Request request = data.value();

        if(request.get_dataIdentifier().equals(DATA_IDENTIFIER))
        {
            System.out.println("ConnectivityData requested");
            this.postConnectivityData();
        }
    }*/


    public void postConnectivityData()
    {


        ConnectivityData connectivityData = new ConnectivityData();

        Context context = (Context) CLAID.getContext();
        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        Network currentNetwork = connectivityManager.getActiveNetwork();

        NetworkCapabilities caps = connectivityManager.getNetworkCapabilities(currentNetwork);


        if(caps != null)
        {
            connectivityData.set_connected(true);

            if (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                connectivityData.set_networkType(0);
            } else if (caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                connectivityData.set_networkType(1);
            } else {
                connectivityData.set_networkType(2);
            }
        }
        else
        {
            connectivityData.set_connected(false);
            connectivityData.set_networkType(2);
        }



        System.out.println("Connectivity connected " + connectivityData.get_connected() + " type " + connectivityData.get_networkType());

        connectivityDataChannel.post(connectivityData);
    }



}
