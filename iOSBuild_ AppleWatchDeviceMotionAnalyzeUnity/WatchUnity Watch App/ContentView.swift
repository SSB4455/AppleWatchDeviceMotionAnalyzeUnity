/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The start view.
*/

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .display

    enum Tab {
        case controls, display, nowPlaying
    }

    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tag(Tab.controls)
            DataDisplayView().tag(Tab.display)
        }
        .border(workoutManager.isRecording ? .red : .clear)
        .navigationBarBackButtonHidden(true)
        //.navigationBarHidden(selection == .nowPlaying)
        
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

struct DataDisplayView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    
    
    var body: some View {
        ScrollView() {
            VStack {
                Text("\(workoutManager.frequency)hz").font(.headline)
                Divider()
            }
            
            VStack {
                Text("gravity")
                HStack {
                    Text(String(format: "%.2f", workoutManager.gravity.x))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.gravity.y))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.gravity.z))
                }.padding(.horizontal)
            }
            
            VStack {
                Text("userAcceleration")
                HStack {
                    Text(String(format: "%.2f", workoutManager.userAcceleration.x))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.userAcceleration.y))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.userAcceleration.z))
                }.padding(.horizontal)
            }
            
            VStack {
                Text("rotationRate")
                HStack {
                    Text(String(format: "%.2f", workoutManager.rotationRate.x))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.rotationRate.y))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.rotationRate.z))
                }.padding(.horizontal)
            }
            
            VStack {
                Text("attitude roll,pitch,yaw")
                HStack {
                    Text(String(format: "%.2f", workoutManager.attitude.roll))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.attitude.pitch))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.attitude.yaw))
                }.padding(.horizontal)
            }
            
            VStack {
                Text("attitude quaternion")
                HStack {
                    Text(String(format: "%.2f", workoutManager.attitude.quaternion.x))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.attitude.quaternion.y))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.attitude.quaternion.z))
                    Spacer()
                    Text(String(format: "%.2f", workoutManager.attitude.quaternion.w))
                }
            }
            
        }
    }
}

struct ControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button {
                        workoutManager.isRecording = !workoutManager.isRecording
                    } label: {
                        Image(systemName: workoutManager.isRecording ? "stop.circle" : "record.circle")
                    }
                    .scaledToFill()
                    //.tint(.red)
                    .font(.title2)
                    Text(workoutManager.isRecording ? "Stop" : "Record")
                }
            }
            Divider()
            HStack {
                Toggle("Sync to phone", isOn: $workoutManager.syncToPhone)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(WorkoutManager())
    }
}
