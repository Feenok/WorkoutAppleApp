//
//  DataManager.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    private init() {}
    
    func addWorkoutSetsToExercises(sets: [WorkoutTemplateSet], modelContext: ModelContext) throws {
        let baseDate = Date.now
        for (index, templateSet) in sets.enumerated() {
            guard let exercise = try fetchExercise(name: templateSet.name, context: modelContext) else {
                print("Exercise not found: \(templateSet.name)")
                continue
            }
            
            let setDate = baseDate.addingTimeInterval(Double(index))
            let newSet = ExerciseSet(weight: templateSet.targetWeight, reps: templateSet.targetReps, date: setDate, exercise: exercise)
            
            exercise.addSet(newSet)
            modelContext.insert(newSet)
        }
        
        try modelContext.save()
    }
    
    private func fetchExercise(name: String, context: ModelContext) throws -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == name })
        return try context.fetch(descriptor).first
    }
    
    func getDuration(minutes: Int, seconds: Int) -> TimeInterval? {
        return TimeInterval(minutes * 60 + seconds)
    }
    
    func secondsToMinutesAndSeconds(_ seconds: Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }
    
    
}

