//
//  ControlsView.swift
//  WatchUnity Watch App
//
//  Created by SSB4455 on 2023/07/21.
//

import SwiftUI

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
                    //.tint(.red)
                    .font(.title2)
                    Text(workoutManager.isRecording ? "Stop" : "Record")
                }
            }
            HStack {
                Toggle("Sync to phone", isOn: $workoutManager.syncToPhone)
            }
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView().environmentObject(WorkoutManager())
    }
}
