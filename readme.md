# CMMotionManager

## Motion

[CMMotionManager](https://developer.apple.com/documentation/coremotion/cmmotionmanager)
allows you to directly reading accelerometer, gyroscrope, and magnetometer sensors.
Below is some code to read the sensor independantly at a sampling interval. The
sampling rate is hardware dependant, but at a minimum, you can read at 100 Hz
(or 0.01 seconds).

**WARNING:** Only create one instance of the `CMMotionManager`

Units:
- rotationRate: rads/sec
- acceleration: g's
- magneticField: uT (micro-Tesla's)

```swift
motionManager.startDeviceMotionUpdates()

motionManager.accelerometerUpdateInterval = 0.1 // sampling rate in seconds
motionManager.startAccelerometerUpdates(to: .main) { (data, error) in

    if let motionData = data {
        self.accel = motionData.acceleration
    }
}

motionManager.gyroUpdateInterval = 0.1
motionManager.startGyroUpdates(to: .main) { (data, error) in

    if let motionData = data {
        self.gyro = motionData.rotationRate
    }
}

motionManager.magnetometerUpdateInterval = 0.1
motionManager.startMagnetometerUpdates(to: .main) { (data, error) in

    if let motionData = data {
        self.mag = motionData.magneticField
        dump(motionData)
    }
}
```

[CMDeviceMotion](https://developer.apple.com/documentation/coremotion/cmdevicemotion)
seems to impact power consumption very little compared to directly reading the
accelerometer, gyroscrope, and magnetometer sensors. Now, initially I wasn't getting
any magnetometer readings until I specified a [reference frame](https://developer.apple.com/documentation/coremotion/cmattitudereferenceframe).

Reference frames:

1. `static var xArbitraryZVertical`: `CMAttitudeReferenceFrame`
    - Describes a reference frame in which the Z axis is vertical and the X axis points in an arbitrary direction in the horizontal plane.
1. `static var xArbitraryCorrectedZVertical`: `CMAttitudeReferenceFrame`
    - Describes the same reference frame as xArbitraryZVertical except that the magnetometer, when available and calibrated, is used to improve long-term yaw accuracy. Using this constant instead of `xArbitraryZVertical` results in increased CPU usage.
1. `static var xMagneticNorthZVertical`: `CMAttitudeReferenceFrame`
    - Describes a reference frame in which the Z axis is vertical and the X axis points toward magnetic north. *Note that using this reference frame may require device movement to calibrate the magnetometer.*
1. `static var xTrueNorthZVertical`: `CMAttitudeReferenceFrame`
    - Describes a reference frame in which the Z axis is vertical and the X axis points toward true north. *Note that using this reference frame may require device movement to calibrate the magnetometer. It also requires the location to be available in order to calculate the difference between magnetic and true north.*

Units:
- attitude: quaternion with respect to reference frame
- rotationRate: rads/sec
- gravity: g's, vector showing direction of gravity
- userAcceleration: g's, accelerations applied to phone with gravity removed
- magneticField: uT, field with biases and some (potentially) surrounding magnetic fields removed
- heading: degrees with respect to reference frame
- sensorLocation

```swift
motionManager.deviceMotionUpdateInterval = 0.1 // sampling rate in seconds
motionManager.startDeviceMotionUpdates(
    using: CMAttitudeReferenceFrame.xMagneticNorthZVertical,
    to: .main){ (data, error) in
    guard error == nil else {
        print(error!)
        return
    }

    if let motion = data {
        self.accel = motion.userAcceleration
        self.gyro = motion.rotationRate
        self.mag = motion.magneticField.field
        self.q = motion.attitude.quaternion
    }
}
```

## Logging

- https://www.wwdcnotes.com/notes/wwdc20/10168/
