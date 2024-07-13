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
    @Published var highestWeightSet: ExerciseSet?
    @Published var newExerciseSet: ExerciseSet? {
            didSet {
                if let _ = newExerciseSet {
                    updateHighestWeightSet()
                }
            }
        }
    
    init(exercise: Exercise) {
        self.exercise = exercise
        updateHighestWeightSet()
    }
    
    func updateHighestWeightSet() {
            highestWeightSet = exercise.exerciseSets.max(by: { $0.weight < $1.weight })
        }
    
    func addExerciseSet(weight: Int = 100, reps: Int = 10, date: Date = Date()) {
        let newItem = ExerciseSet(exercise: exercise, weight: weight, reps: reps, date: date)
        exercise.exerciseSets.append(newItem)
        newExerciseSet = newItem
        updateHighestWeightSet()
    }
}
