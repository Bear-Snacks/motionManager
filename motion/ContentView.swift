//
//  ContentView.swift
//  motion
//
//  Created by Kevin Walchko on 11/30/21.
//

import SwiftUI
import CoreMotion
import os // logger

/*
 # Swift
 
 - https://github.com/SimpleBoilerplates/SwiftUI-Cheat-Sheet
 
 # Motion
 
 CMDeviceMotion seems to impact power consumption very little compared to directly reading accel, gyro, and
 mag sensors
 - attitude: quaternion
 - rotationRate: rads/sec
 - gravity: g's
 - userAcceleration: g's
 - magneticField: uT
 - heading
 - sensorLocation
 
 - https://www.advancedswift.com/get-motion-data-in-swift/
 - https://developer.apple.com/documentation/coremotion/cmmotionmanager
 
 # Logging
 
 - https://www.wwdcnotes.com/notes/wwdc20/10168/
 */


/**
 
 */
class ViewModel: ObservableObject {
    @Published var accel: CMAcceleration = CMAcceleration()
    @Published var gyro: CMRotationRate = CMRotationRate()
    @Published var mag: CMMagneticField = CMMagneticField()
    @Published var q: CMQuaternion = CMQuaternion()
    
    private var motionManager: CMMotionManager
    
    init(){
        // subsystem: which app
        // catagory: which part of the program
        let logger = Logger(subsystem: "motionapp", category: "viewmodel")
        
        self.motionManager = CMMotionManager()
        
        if motionManager.isDeviceMotionAvailable {
            
            // https://developer.apple.com/documentation/coremotion/cmdevicemotion
            // https://developer.apple.com/documentation/coremotion/cmattitudereferenceframe
            motionManager.deviceMotionUpdateInterval = 0.1
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
            /*
            motionManager.startDeviceMotionUpdates()
            
            motionManager.accelerometerUpdateInterval = 0.1
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
            */
            
        } else {
            logger.warning("Device motion data isn't available!")
        }
    }
}

struct SensorView: View {
    let name: String
    let x: Double
    let y: Double
    let z: Double
    let color: Color
    
    var body: some View {
        let txt = self.name + String(format: ": [%6.3f, %6.3f, %6.3f]",
                        self.x,
                        self.y,
                        self.z)
        Text(txt)
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(self.color)
    }
}

struct QView: View {
    let w: Double
    let x: Double
    let y: Double
    let z: Double
    let color: Color
    
    var body: some View {
        let txt = String(format: "Q[w,x,y,z]: [%6.3f, %6.3f, %6.3f, %6.3f]",
                         self.w,
                         self.x,
                         self.y,
                         self.z)
        Text(txt)
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(self.color)
    }
}


// draws screen
struct ContentView: View {
    @ObservedObject var vm = ViewModel()
    
    var body: some View {

#if targetEnvironment(simulator)
        Text(String(format: "Accel: [0.0, 0.0, 1.0] g"))
        Text(String(format: "Gyro: [0, 0, 0] rads/sec"))
        Text(String(format: "Mag: [0, 0, 0] uT"))
        Text(String(format: "Q: [1, 0, 0, 0]"))
#else
        SensorView(
            name: "Accel[g]",
            x: self.vm.accel.x,
                   y: self.vm.accel.y,
                   z: self.vm.accel.z,
                   color: Color.red
        )
        SensorView(
            name: "Gyro[rps]",
            x: self.vm.gyro.x,
            y: self.vm.gyro.y,
            z: self.vm.gyro.z,
            color: Color.green
        )
        SensorView(
            name: "Mag[uT]",
            x: self.vm.mag.x,
            y: self.vm.mag.y,
            z: self.vm.mag.z,
            color: Color.blue
        )
        QView(
            w: self.vm.q.w,
            x: self.vm.q.x,
            y: self.vm.q.y,
            z: self.vm.q.z,
            color: Color.cyan
        )
        
#endif
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

