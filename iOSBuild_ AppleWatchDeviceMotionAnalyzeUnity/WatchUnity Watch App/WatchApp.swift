//
//  WatchApp.swift
//  WatchUnity Watch App
//
//  Created by SSB4455 on 2023/07/21.
//

import SwiftUI

@main
struct WatchApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var workoutManager = WorkoutManager()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(workoutManager)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    print("Active")
                    if !workoutManager.running {
                        //workoutManager.startWorkout()
                    }
                } else if newPhase == .inactive {
                    print("Inactive")
                    /*let semaphore = DispatchSemaphore(value: 0)
                    ProcessInfo.processInfo.performExpiringActivity(withReason: "Gesture Recognition") { expiring in
                        if expiring {
                            print("ProcessInfo expiring")
#if DEBUG
                            WKInterfaceDevice.current().play(WKHapticType.stop)
#endif
                            semaphore.signal()
                        } else {
                            print("ProcessInfo Not Complete")
                            semaphore.wait(timeout: .now() + .seconds(30))
                        }
                    }*/
                } else if newPhase == .background {
                    print("Background")
#if DEBUG
                    if workoutManager.running {
                        workoutManager.endWorkout()
                        exit(0)
                    }
#endif
                }
            }
        }
    }
    
}
