//
//  Models.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/25/24.
//
/*
 
 import Foundation
 import SwiftData

 @Model
 final class Exercise {
     var name: String
     var category: String
     var PRSet: ExerciseSet? //Personal Record Set
     @Relationship(deleteRule: .cascade) var allSets: [ExerciseSet] = []
     
     init(name: String, category: String) {
             self.name = name
             self.category = category
         }
 }
 
 
 import Foundation
 import SwiftData

 @Model
 final class ExerciseSet: Identifiable {
     // An exercise with its weights, and reps info
     var id = UUID()
     var weight: Int
     var reps: Int
     var duration: TimeInterval?
     /*@Attribute(.unique) */ var date: Date
     @Relationship(inverse: \Exercise.allSets) var exercise: Exercise?
     
     init(weight: Int, reps: Int, duration: TimeInterval? = nil, date: Date = Date(), exercise: Exercise? = nil) {
         self.weight = weight
         self.reps = reps
         self.duration = duration
         self.date = date
         self.exercise = exercise
     }
     
 }
 
 
 import Foundation
 import SwiftData

 @Model
 final class Workout {
     var name: String
     var category: String
     
     @Relationship(deleteRule: .cascade) var templateSets: [WorkoutTemplateSet] = []
     
     init(name: String, category: String) {
             self.name = name
             self.category = category
         }
     
 }
 
 
 import Foundation
 import SwiftData

 @Model
 final class WorkoutTemplateSet: Identifiable {
     let id = UUID()
     var name: String
     var targetWeight: Int
     var targetReps: Int
     var date: Date = Date.now
     @Relationship(inverse: \Workout.templateSets) var workout: Workout?
     
     init(name: String, targetWeight: Int = 0, targetReps: Int = 0, workout: Workout? = nil) {
         self.name = name
         self.targetWeight = targetWeight
         self.targetReps = targetReps
         self.workout = workout
     }
     
 }

*/
