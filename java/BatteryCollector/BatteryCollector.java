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
