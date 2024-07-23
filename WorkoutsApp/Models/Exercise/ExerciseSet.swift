//
//  ExerciseSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import Foundation
import SwiftData

@Model
final class ExerciseSet: Identifiable {
    // An exercise with its weights, and reps info
    var id = UUID()
    var weight: Int
    var reps: Int
    var duration: TimeInterval?
    var date: Date
    @Relationship(inverse: \Exercise.allSets) var exercise: Exercise?
    
    init(weight: Int, reps: Int, duration: TimeInterval? = nil, date: Date = Date(), exercise: Exercise? = nil) {
        self.weight = weight
        self.reps = reps
        self.duration = duration
        self.date = date
        self.exercise = exercise
    }
    
}

