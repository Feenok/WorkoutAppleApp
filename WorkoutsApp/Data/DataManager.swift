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
    
    func addWorkoutSetsToExercises(workout: Workout, modelContext: ModelContext) {
        for templateSet in workout.templateSets {
            guard let exercise = fetchExercise(name: templateSet.name, context: modelContext) else {
                print("Exercise not found: \(templateSet.name)")
                continue
            }
            
            let newSet = ExerciseSet(weight: templateSet.targetWeight, reps: templateSet.targetReps, date: Date())
            
            // Create a temporary ViewModel to handle the dictionary updates
            let viewModel = ExerciseDetailsViewModel(exercise: exercise)
            viewModel.addSet(newSet: newSet)
            
            // Update the exercise in SwiftData
            exercise.allSets = viewModel.exercise.allSets
            exercise.PRSet = viewModel.exercise.PRSet
        }
        
        try? modelContext.save()
    }
    
    private func fetchExercise(name: String, context: ModelContext) -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == name })
        return try? context.fetch(descriptor).first
    }
}
