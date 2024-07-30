//
//  ExerciseDetailsViewModel.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/13/24.
//

import Foundation
import Combine
import SwiftUI

class ExerciseDetailsViewModel: ObservableObject {
    @Published var exercise: Exercise
    @Published var allSetsDictionary: [Date: [ExerciseSet]] = [:] // Dictionary to hold all sets per day
    
    @Published var chartData: [Date: Int] = [:]
    private var loadedDateRange: ClosedRange<Date>?
    
    init(exercise: Exercise) {
        self.exercise = exercise
        initializeSetsDictionary()
    }
    
    private func initializeSetsDictionary() {
        allSetsDictionary = Dictionary(grouping: exercise.allSets) { Calendar.current.startOfDay(for: $0.date) }
    }
    
    func addSet(newSet: ExerciseSet) {
        // Add to array
        exercise.addSet(newSet)
        
        // Update viewmodel dictionary
        addSetToSetsDictionary(newSet)
    }
    
    private func addSetToSetsDictionary(_ newSet: ExerciseSet) {
        let dayStart = Calendar.current.startOfDay(for: newSet.date)
        if var setsForDay = allSetsDictionary[dayStart] {
            setsForDay.append(newSet)
            allSetsDictionary[dayStart] = setsForDay
        } else {
            allSetsDictionary[dayStart] = [newSet]
        }
    }
    
    func findLatestSet(consideringLast count: Int = 100) -> ExerciseSet? {
        exercise.allSets.suffix(count).max(by: { $0.date < $1.date })
    }
    
    func deleteSet(_ set: ExerciseSet) {
        // Remove from allSets
        exercise.removeSet(set)
        
        // Remove from allSetsDictionary
        let dayStart = Calendar.current.startOfDay(for: set.date)
        if var setsForDay = allSetsDictionary[dayStart] {
            setsForDay.removeAll { $0.id == set.id }
            if setsForDay.isEmpty {
                allSetsDictionary[dayStart] = nil
            } else {
                allSetsDictionary[dayStart] = setsForDay
            }
        }
        
    }
    
    func getDuration(minutes: Int, seconds: Int) -> TimeInterval? {
        return TimeInterval(minutes * 60 + seconds)
    }
    
    func secondsToMinutesAndSeconds(_ seconds: Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }
    
}

