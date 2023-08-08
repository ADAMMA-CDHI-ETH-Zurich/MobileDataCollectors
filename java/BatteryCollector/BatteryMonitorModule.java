package BatteryCollector;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import JavaCLAID.CLAID;
import JavaCLAID.Channel;
import JavaCLAID.Module;
import JavaCLAID.Reflector;
import JavaCLAIDDataTypes.BatteryData;

// In contrast to the BatteryCollector, this module posts new battery data to a channel whenever it becomes available.
// For this, we use a BroadcastReceiver, to get notified by Android when the battery state has changed (battery level or charging state).
public class BatteryMonitorModule extends Module
{
    String outputChannel = "BatteryDataMonitored";
    BroadcastReceiver receiver;
    Intent batteryStatusIntent;
    Channel<BatteryData> batteryDataChannel;

    public void reflect(Reflector r)
    {
        r.reflectWithDefaultValue("outputChannel", this.outputChannel, "BatteryDataMonitored");
        //r.reflect("broadcastChargingState", this.broadcastChargingState);
       // r.reflect("broadcastBatteryLevel", this.broadcastBatteryLevel);
    }

    public void initialize()
    {
        this.batteryDataChannel = this.publish(BatteryData.class, this.outputChannel);

        Context context = (Context) CLAID.getContext();
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);

        receiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                BatteryData batteryData = BatteryIntentHelper.extractBatteryDataFromIntent(intent);
                batteryDataChannel.post(batteryData);
            }
        };

        this.batteryStatusIntent = context.registerReceiver(receiver, ifilter);
        // Send status once at startup.
        sendOnce();
    }

    void sendOnce()
    {
        // Can be used to retrieve battery status once at the beginning.
        Context context = (Context) CLAID.getContext();
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent intent = context.registerReceiver(null, ifilter);
        BatteryData batteryData = BatteryIntentHelper.extractBatteryDataFromIntent(intent);
        batteryDataChannel.post(batteryData);
    }
}
