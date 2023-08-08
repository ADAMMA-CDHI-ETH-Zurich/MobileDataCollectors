package AccelerometerCollector;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.locks.ReentrantLock;

import JavaCLAID.CLAID;
import JavaCLAID.ChannelData;
import JavaCLAID.Module;
import JavaCLAID.Channel;
import JavaCLAIDDataTypes.AccelerometerSample;
import JavaCLAIDDataTypes.AccelerometerData;


public class AccelerometerCollector extends Module implements SensorEventListener {
    private Channel<AccelerometerSample> accelerometerDataChannel;


    private ReentrantLock mutex = new ReentrantLock();
    private final short SAMPLING_FREQUENCY = 2;
    private final float TIME_SCALE = 1.0f; // 1s
    private long timeStart = System.currentTimeMillis();
    // Volatile to be thread safe.

    AtomicReference<AccelerometerSample> lastSample = new AtomicReference<>();

    SensorManager sensorManager;
    Sensor sensor;


    public void initialize()
    {
        System.out.println("Calling init of AccelerometerCollector");
        this.accelerometerDataChannel = this.publish(AccelerometerSample.class, "AccelerometerData");
        Context context = (Context) CLAID.getContext();
        sensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);  // Will be CLAID.getContext()
        sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);  // Or TYPE_LINEAR_ACCELERATION, which excludes gravity force?
        System.out.println("AccelerometerCollector initialized");
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL);
    }


    /*public synchronized void onAccelerometerDataRequested(ChannelData<Request> data)
    {
        Request request = data.value();
        System.out.println("Got request " + request.get_dataIdentifier());
        if(request.get_dataIdentifier().equals("AccelerometerData"))
        {
            AccelerometerSample sample = lastSample.get();
            System.out.println("Lastsample: " + sample);
            if(sample == null)
                return;

            accelerometerDataChannel.post(lastSample.get());
            lastSample.set(new AccelerometerSample());
        }
    }*/


    @Override
    public synchronized void onSensorChanged(SensorEvent sensorEvent)
    {
        if (sensorEvent.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
        {
            System.out.println("Time since last data: " + (System.currentTimeMillis() - timeStart));
            timeStart = System.currentTimeMillis();
            // Dividing per g to uniform with iOS
            float x = sensorEvent.values[0] / SensorManager.GRAVITY_EARTH;;
            float y = sensorEvent.values[1] / SensorManager.GRAVITY_EARTH;
            float z = sensorEvent.values[2] / SensorManager.GRAVITY_EARTH;

            AccelerometerSample sample = new AccelerometerSample();
            sample.set_x((double) x);
            sample.set_y((double) y);
            sample.set_z((double) z);

            lastSample.set(sample);

        }
    }


    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {}
}
