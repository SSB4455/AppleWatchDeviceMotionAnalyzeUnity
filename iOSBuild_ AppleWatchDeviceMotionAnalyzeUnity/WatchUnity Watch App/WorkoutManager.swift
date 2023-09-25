//
//  WorkoutManager.swift
//  WatchUnity Watch App
//
//  Created by SSB4455 on 2023/05/12.
//

import CoreMotion
import HealthKit
import WatchConnectivity
import WatchKit

class WorkoutManager: NSObject, ObservableObject {
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    // The app's workout state.
    @Published var running = false
    
    lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.03
        return manager
    }()
    
    @Published var shotCount = 0
    @Published var userAcceleration = CMAcceleration()
    @Published var gravity = CMAcceleration()
    @Published var attitude = CMAttitude()
    @Published var magneticField = CMCalibratedMagneticField()
    @Published var heading = Double()
    @Published var rotationRate = CMRotationRate()
    @Published var sensorLocation = CMDeviceMotion.SensorLocation(rawValue: 0)
    @Published var frequency: Int = 30 {
        didSet {
            motionManager.deviceMotionUpdateInterval = 1 / Double(frequency)
        }
    }
    @Published var syncToPhone = true
    @Published var isRecording = false {
        didSet {
            if !oldValue && isRecording {
                if !running {
                    startWorkout()
                }
                sendMessageToiPhone(["isRecording" : true])
                recordData = "\(["frequency": frequency])"
            }
            if oldValue && !isRecording {
                sendMessageToiPhone(["isRecording" : false])
                sendMessageToiPhone(["recordJsonStr" : recordData])
                print(recordData)
            }
        }
    }
    var recordData = ""
    var sendDataType = "Attitude"
    var getDataTypeFunc = { (data: CMDeviceMotion) -> () in }
    
    enum DeviceMotionType {
        case userAcceleration, gravity, attitude, magneticField, heading, rotationRate, sensorLocation
    }
    
    
    
    override init() {
        super.init()
        
        let watchVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        print("watchVersion = \(watchVersion)")
        WKInterfaceDevice.current().play(WKHapticType.success)
        
        configureWCSession()
        startWorkout()
    }

    // Start the workout.
    func startWorkout() {
        print(#function)
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown

        // Create the session and obtain the workout builder.
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        } catch {
            // Handle any exceptions.
            return
        }

        // Setup session and builder.
        session?.delegate = self

        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        session?.pause()
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) {(data, error) in
#if DEBUG
            //print("timestamp \(data!.timestamp)")
#endif
            let timestamp = data!.timestamp
            
            self.getDataTypeFunc(data!)
            self.gravity = data!.gravity
            self.userAcceleration = data!.userAcceleration
            self.rotationRate = data!.rotationRate
            self.attitude = data!.attitude
            
            if self.isRecording {
                var frameData: [String : Any] = [
                    "timestamp": timestamp,
                    "gravity": ["type": "Vector3_16", "value":
                        [String(Int(self.gravity.x * 1000), radix: 16),
                         String(Int(self.gravity.y * 1000), radix: 16),
                         String(Int(self.gravity.z * 1000), radix: 16)]] as [String : Any],
                    "userAcceleration": ["type": "Vector3_16", "value":
                        [String(Int(self.userAcceleration.x * 1000), radix: 16),
                         String(Int(self.userAcceleration.y * 1000), radix: 16),
                         String(Int(self.userAcceleration.z * 1000), radix: 16)]] as [String : Any],
                    "rotationRate": ["type": "Vector3_16", "value":
                        [String(Int(self.rotationRate.x * 1000), radix: 16),
                         String(Int(self.rotationRate.y * 1000), radix: 16),
                         String(Int(self.rotationRate.z * 1000), radix: 16)]] as [String : Any],
                    "attitude_roll,pitch,yaw": ["type": "Vector3_16", "value":
                        [String(Int(self.attitude.roll * 1000), radix: 16),
                         String(Int(self.attitude.pitch * 1000), radix: 16),
                         String(Int(self.attitude.yaw * 1000), radix: 16)]] as [String : Any],
                    "attitude_quaternion": ["type": "Quaternion_16", "value":
                        [String(Int(self.attitude.quaternion.x * 1000), radix: 16),
                         String(Int(self.attitude.quaternion.y * 1000), radix: 16),
                         String(Int(self.attitude.quaternion.z * 1000), radix: 16),
                         String(Int(self.attitude.quaternion.w * 1000), radix: 16)]] as [String : Any]]
                self.recordData += "\(frameData)"
                if self.syncToPhone {
                    self.sendMessageToiPhone(frameData);
                }
            }
        }
        sendMessageToiPhone(["Watch": "startMotionUpdate"])
    }
    
    func changeSyncDatas(_ datas: [String]) {
        var types = [DeviceMotionType]()
        for data1 in datas {
            if (data1.contains("acc")) {
                types.append(.userAcceleration)
                
            }
            
        }
        
        getDataTypeFunc = { (data: CMDeviceMotion) -> () in
            print("sdfasdf")
            for type1 in types {
                switch type1 {
                case .userAcceleration:
                    self.userAcceleration = data.userAcceleration
                case .gravity:
                    self.gravity = data.gravity
                case .attitude:
                    self.attitude = data.attitude
                case .magneticField:
                    self.magneticField = data.magneticField
                case .heading:
                    self.heading = data.heading
                case .rotationRate:
                    self.rotationRate = data.rotationRate
                case .sensorLocation:
                    self.sensorLocation = data.sensorLocation
                }
            }
            
        }
        
    }

    // MARK: - Session State Control
    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func endWorkout() {
        print(#function)
        session?.end()
        motionManager.stopDeviceMotionUpdates()
        sendMessageToiPhone(["Watch": "endWorkout"])
    }
    
    func configureWCSession() {
        // Don't need to check isSupport state, because session is always available on WatchOS
        // if WCSession.isSupported() {}
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    func sendMessageToiPhone(_ message: [String: Any]) {
        print(#function + "\n\(message)")
        if !WCSession.default.isReachable {
            print("!WCSession.default.isReachable")
            /*let action = WKAlertAction(title: "OK", style: .default) {
                print("OK")
            }
            presentAlert(withTitle: "Failed", message: "Apple Watch is not reachable.", preferredStyle: .alert, actions: [action])*/
            return
        } else {
            // The counterpart is not available for living messageing
        }
        
        //let message = ["title": "Apple Watch send a messge to iPhone", "watchMessage": watchMessage]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            print(replyMessage)
            DispatchQueue.main.sync {
                print(replyMessage["replyContent"] as? String ?? "")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = (toState == .running || toState == .paused)
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            session?.delegate = nil
            session = nil
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print(error)
        UserDefaults.standard.set(error, forKey: "error")
    }
}

// MARK: - WCSessionDelegate
extension WorkoutManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error == nil {
            print(activationState)
        } else {
            print(error!.localizedDescription)
        }
        
        sendMessageToiPhone(["WCSessionActivationState": activationState])
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print(session)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        #if DEBUG
        print(#function + "\(message)")
        #endif
        replyHandler(["title": "received successfully", "replyContent": "This is a reply from watch"])
        if message.keys.contains("Datas") {
            let datas = message["Datas"] as? [String] ?? ["acc_x", "acc_y", "acc_z"]
            changeSyncDatas(datas)
        }
        if message.keys.contains("MotionPerSecond") {
            let mps = message["MotionPerSecond"] as? Int ?? 30
            motionManager.deviceMotionUpdateInterval = 1 / Double(mps)
        }
    }
}

// MARK: - clamped
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#if swift(<5.1)
extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
#endif

// MARK: - closer
extension Double {
    func closer(target: Double,_ down: Double,_ up: Double) -> Double {
        if (down != 0 && self < (target + down)) || (up != 0 && self > (target + up)) {
            return 0
        }
        if self == target || (down == 0 && self < target) || (up == 0 && self > target) {
            return 1
        }
        else if self < target {
            return (self - (target + down)) / -down
        } else {
            return ((target + up) - self) / up
        }
    }
}

extension CMAcceleration {
    func magnitude() -> Double {
        return sqrt(x * x + y * y + z * z)
    }
}
