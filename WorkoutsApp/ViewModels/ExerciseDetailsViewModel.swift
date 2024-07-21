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
    
    //UI FUNCTIONS
    func getPeakSetForDate(_ date: Date) -> ExerciseSet? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return allSetsDictionary[dayStart]?.max(by: { $0.weight < $1.weight })
    }
    
    func getAllPeakSets() -> [Date: ExerciseSet] {
        return allSetsDictionary.mapValues { sets in
            sets.max(by: { $0.weight < $1.weight })!
        }
    }
    
}

