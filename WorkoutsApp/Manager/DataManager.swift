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
        for templateSet in sets {
            guard let exercise = try fetchExercise(name: templateSet.name, context: modelContext) else {
                print("Exercise not found: \(templateSet.name)")
                continue
            }
            
            let newSet = ExerciseSet(weight: templateSet.targetWeight, reps: templateSet.targetReps, date: Date.now, exercise: exercise)
            
            // Directly add the set to the exercise
            exercise.addSet(newSet)
            
            // Insert the new set into the context
            modelContext.insert(newSet)
        }
        
        // Save changes
        try modelContext.save()
    }
    
    private func fetchExercise(name: String, context: ModelContext) throws -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == name })
        return try context.fetch(descriptor).first
    }
}

