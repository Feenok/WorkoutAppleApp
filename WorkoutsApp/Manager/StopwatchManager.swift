//
//  StopwatchManager.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/22/24.
//

import Foundation
import SwiftUI

class StopwatchManager: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    private var timer: Timer?
    private var startTime: Date?
    
    @Published var isRunning = false
    
    func start() {
        if !isRunning {
            startTime = startTime ?? Date()
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                self?.updateElapsedTime()
            }
            isRunning = true
        }
    }
    
    func pause() {
        timer?.invalidate()
        isRunning = false
    }
    
    func stop() {
        timer?.invalidate()
        elapsedTime = 0
        startTime = nil
        isRunning = false
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    func updateElapsedTimeInBackground() {
        if isRunning {
            updateElapsedTime()
        }
    }
}
