//
//  ViewModels.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/25/24.
//

/*
 
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
        // Find the correct position to insert the new set
        let insertIndex = exercise.allSets.lastIndex(where: { $0.date <= newSet.date }) ?? -1
        let insertPosition = insertIndex + 1
        
        // Update SwiftData array and viewModel array
        exercise.allSets.insert(newSet, at: insertPosition)
        
        // Update viewmodel dictionary
        addSetToSetsDictionary(newSet)
        
        // Update Exercise Stats
        updatePRSet(newSet: newSet)
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
    
    private func updatePRSet(newSet: ExerciseSet) {
        if exercise.PRSet == nil || newSet.weight > exercise.PRSet?.weight ?? 0 || (newSet.weight == exercise.PRSet?.weight ?? 0 && newSet.reps > exercise.PRSet?.reps ?? 0) {
            exercise.PRSet = newSet
        }
    }
    
    func findLatestSet(consideringLast count: Int = 100) -> ExerciseSet? {
        exercise.allSets.suffix(count).max(by: { $0.date < $1.date })
    }
    
    func deleteSet(_ set: ExerciseSet) {
        // Remove from allSets
        if let index = exercise.allSets.firstIndex(where: { $0.id == set.id }) {
            exercise.allSets.remove(at: index)
        }
        
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
        
        // Update PRSet if necessary
        if exercise.PRSet?.id == set.id {
            exercise.PRSet = exercise.allSets.max(by: { $0.weight < $1.weight })
        }
    }
    
    func getDuration(minutes: Int, seconds: Int) -> TimeInterval? {
        return TimeInterval(minutes * 60 + seconds)
    }
    
    func secondsToMinutesAndSeconds(_ seconds: Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }
}

*/

