//
//  ExerciseSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import Foundation
import SwiftData

@Model
final class ExerciseSet: Identifiable, Equatable {
    // An exercise with its weights, and reps info
    var id = UUID()
    var weight: Int = 0
    var reps: Int = 0
    var duration: TimeInterval?
    var date: Date = Date.now
    var exercise: Exercise?
    var isPRSetFor: Exercise?
    
    init(weight: Int, reps: Int, duration: TimeInterval? = nil, date: Date = Date(), exercise: Exercise) {
        self.weight = weight
        self.reps = reps
        self.duration = duration
        self.date = date
        self.exercise = exercise
    }
    
}

