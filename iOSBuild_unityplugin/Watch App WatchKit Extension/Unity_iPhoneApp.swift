//
//  Unity_iPhoneApp.swift
//  Watch App WatchKit Extension
//
//  Created by SSB4455 on 2022/8/24.
//

import SwiftUI

@main
struct Unity_iPhoneApp: App {
    
    @StateObject private var tt = WCtest()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(tt)
        }

    }
    
}
