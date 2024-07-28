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
    
    func addWorkoutSetsToExercises(sets: [WorkoutTemplateSet], modelContext: ModelContext) {
            for templateSet in sets {
                guard let exercise = fetchExercise(name: templateSet.name, context: modelContext) else {
                    print("Exercise not found: \(templateSet.name)")
                    continue
                }
                
                let newSet = ExerciseSet(weight: templateSet.targetWeight, reps: templateSet.targetReps, date: Date.now)
                
                // Create a temporary ViewModel to handle the dictionary updates
                let viewModel = ExerciseDetailsViewModel(exercise: exercise)
                viewModel.addSet(newSet: newSet)
            }
            
            try? modelContext.save()
        }
    
    private func fetchExercise(name: String, context: ModelContext) -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == name })
        return try? context.fetch(descriptor).first
    }
}
