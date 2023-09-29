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
