//
//  WorkoutTemplateSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import Foundation
import SwiftData

@Model
final class WorkoutTemplateSet: Identifiable {
    let id = UUID()
    var name: String = ""
    var targetWeight: Int = 0
    var targetReps: Int = 0
    var date: Date = Date.now
    @Relationship(inverse: \Workout.templateSets) var workout: Workout?
    
    init(name: String, targetWeight: Int = 0, targetReps: Int = 0, workout: Workout? = nil) {
        self.name = name
        self.targetWeight = targetWeight
        self.targetReps = targetReps
        self.workout = workout
    }

    
}
