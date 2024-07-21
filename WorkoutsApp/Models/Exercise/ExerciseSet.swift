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
    //var exercise: Exercise
    var weight: Int
    var reps: Int
    var date: Date
    
    init(/*exercise: Exercise,*/ weight: Int, reps: Int, date: Date = Date()) {
        //self.exercise = exercise
        self.weight = weight
        self.reps = reps
        self.date = date
    }
    
}

