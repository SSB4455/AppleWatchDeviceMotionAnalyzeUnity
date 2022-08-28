//
//  ContentView.swift
//  Watch App WatchKit Extension
//
//  Created by SSB4455 on 2022/8/24.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject var tt: WCtest
    
    var body: some View {
        VStack {
            Text("\(tt.message)")
                .padding()
            Button("send") {
                tt.sendTestMsg()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
