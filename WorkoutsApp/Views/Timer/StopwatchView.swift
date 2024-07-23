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
                .font(.largeTitle)
                .padding()
            
            HStack {
                Button(action: stopwatch.start) {
                    Text("Start")
                }
                .disabled(stopwatch.isRunning)
                
                Button(action: stopwatch.pause) {
                    Text("Pause")
                }
                .disabled(!stopwatch.isRunning)
                
                Button(action: stopwatch.stop) {
                    Text("Reset")
                }
            }
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


/*
struct StopwatchView: View {
    @StateObject private var stopwatch = StopwatchManager()
    
    var body: some View {
        VStack {
            Text(timeString(time: stopwatch.elapsedTime))
                .font(.system(size: 54, weight: .bold, design: .monospaced))
                .padding()
            
            HStack(spacing: 20) {
                Button(action: stopwatch.start) {
                    Text("Start")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(stopwatch.isRunning)
                
                Button(action: stopwatch.pause) {
                    Text("Pause")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!stopwatch.isRunning)
                
                Button(action: stopwatch.stop) {
                    Text("Reset")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
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
*/
