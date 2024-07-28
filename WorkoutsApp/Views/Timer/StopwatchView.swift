//
//  StopwatchView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import SwiftUI

struct StopwatchView: View {
    @StateObject private var stopwatch = StopwatchManager()
    
    var body: some View {
        VStack {
            Text(timeString(time: stopwatch.elapsedTime))
                .font(.custom("Clock", size: 48))
                .padding(.top)
            
            HStack {
                Spacer()
                Button(action: stopwatch.start) {
                    Text("Start")
                }
                .disabled(stopwatch.isRunning)
                Spacer()
                Button(action: stopwatch.pause) {
                    Text("Pause")
                        .foregroundStyle(stopwatch.isRunning ? .red : .gray)
                }
                .disabled(!stopwatch.isRunning)
                Spacer()
                Button(action: stopwatch.stop) {
                    Text("Reset")
                }
                Spacer()
            }
            .padding(.bottom)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format:"%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)
    }
    
}
