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
