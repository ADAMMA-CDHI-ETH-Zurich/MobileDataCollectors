package BatteryCollector;

import android.content.Intent;
import android.os.BatteryManager;

import JavaCLAIDDataTypes.BatteryData;

public class BatteryIntentHelper
{
    static BatteryData extractBatteryDataFromIntent(Intent batteryIntent)
    {
        // Are we charging / charged?
        int status = batteryIntent.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
        boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                status == BatteryManager.BATTERY_STATUS_FULL;

        // How are we charging?
        int chargePlug = batteryIntent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);
        boolean usbCharge = chargePlug == BatteryManager.BATTERY_PLUGGED_USB;
        boolean acCharge = chargePlug == BatteryManager.BATTERY_PLUGGED_AC;
        boolean wirelessCharge = chargePlug == BatteryManager.BATTERY_PLUGGED_WIRELESS;

        BatteryData batteryData = new BatteryData();
        batteryData.set_level(getBatteryLevel(batteryIntent));

        if (usbCharge)
        {
            batteryData.set_state(4);
        }
        else if (acCharge)
        {
            batteryData.set_state(5);
        }
        else if(wirelessCharge)
        {
            batteryData.set_state(6);
        }
        else if (isCharging)
        {
            batteryData.set_state(3);
        }
        else if (getBatteryLevel(batteryIntent) == 100)
        {
            batteryData.set_state(2);
        }
        else
        {
            batteryData.set_state(1);
        }
        return batteryData;
    }

    static short getBatteryLevel(Intent batteryStatus)
    {
        int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        short batteryLevel = (short) (level * 100 / (float)scale);
        return batteryLevel;
    }
}
