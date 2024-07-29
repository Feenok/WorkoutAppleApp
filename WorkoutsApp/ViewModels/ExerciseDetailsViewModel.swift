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
        // Find the correct position to insert the new set
        let insertIndex = exercise.allSets.lastIndex(where: { $0.date <= newSet.date }) ?? -1
        let insertPosition = insertIndex + 1
        
        // Update SwiftData array and viewModel array
        exercise.allSets.insert(newSet, at: insertPosition)
        
        // Update viewmodel dictionary
        addSetToSetsDictionary(newSet)
        
        // Update Exercise Stats
        updatePRSet()
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
    
    func updatePRSet() {
        let newPRSet = allSetsDictionary.values
            .flatMap { $0 }
            .max { a, b in
                if a.weight != b.weight {
                    return a.weight < b.weight
                }
                if a.reps != b.reps {
                    return a.reps < b.reps
                }
                // If weight and reps are equal, compare duration
                // Assuming duration is optional (TimeInterval?)
                switch (a.duration, b.duration) {
                case (let durationA?, let durationB?):
                    return durationA < durationB
                case (nil, .some):
                    return true  // b is greater because it has a duration and a doesn't
                case (.some, nil):
                    return false // a is greater because it has a duration and b doesn't
                case (nil, nil):
                    return false // They're equal if both have no duration
                }
            }
        
        exercise.PRSet = newPRSet
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
        
        updatePRSet()
    }
    
    func getDuration(minutes: Int, seconds: Int) -> TimeInterval? {
        return TimeInterval(minutes * 60 + seconds)
    }
    
    func secondsToMinutesAndSeconds(_ seconds: Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }
    
    //TODO: IMPLEMENT DATA INDEX FOR CHART
    /*
    // Chart Functions
    func loadChartData(startDate: Date, endDate: Date) {
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate { $0.date >= startDate && $0.date <= endDate },
            sortBy: [SortDescriptor(\.date)]
        )
        let sets = try? modelContext.fetch(descriptor)
        let newData = Dictionary(grouping: sets ?? [], by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.map(\.weight).max() ?? 0 }
        
        chartData.merge(newData) { _, new in new }
        loadedDateRange = startDate...endDate
    }
    
    func loadMoreDataIfNeeded(for date: Date) {
        guard let loadedRange = loadedDateRange else {
            loadChartData(startDate: date, endDate: Date())
            return
        }
        
        if date < loadedRange.lowerBound {
            let newStartDate = Calendar.current.date(byAdding: .month, value: -3, to: loadedRange.lowerBound)!
            loadChartData(startDate: newStartDate, endDate: loadedRange.lowerBound)
        }
    }
     */
    
}

