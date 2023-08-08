package BatteryCollector;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import JavaCLAID.CLAID;
import JavaCLAID.Channel;
import JavaCLAID.ChannelData;
import JavaCLAID.Module;
import JavaCLAID.Reflector;
import JavaCLAIDDataTypes.BatteryData;
import JavaCLAIDDataTypes.PeriodicValue;

public class BatteryCollector extends Module
{
    private Channel<BatteryData> batteryDataChannel;

    PeriodicValue periodicMonitoring = new PeriodicValue();

    String outputChannel = "";

    public void initialize()
    {
        System.out.println("Calling init of BatteryCollector " + outputChannel);
        this.batteryDataChannel = this.publish(BatteryData.class, this.outputChannel);

        this.registerPeriodicFunction("PeriodicBatteryMonitoring", () -> postBatteryData(), periodicMonitoring.getPeriodInMilliSeconds());
        System.out.println("BatteryCollector initialized");
    }

    public void reflect(Reflector r)
    {
        r.reflect("outputChannel", this.outputChannel);
        r.reflect("PeriodicMonitoring", this.periodicMonitoring);
    }

    public void postBatteryData()
    {
        IntentFilter intentFilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Context context = (Context) CLAID.getContext();
        Intent batteryStatus = context.registerReceiver(null, intentFilter);

        BatteryData batteryData = BatteryIntentHelper.extractBatteryDataFromIntent(batteryStatus);

        batteryDataChannel.post(batteryData);
    }




}
