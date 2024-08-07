//
//  TestDataGenerator.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 8/4/24.
//

import Foundation
import SwiftData

struct TestDataGenerator {
    static func generateTestData(modelContext: ModelContext) {
        /*
        let exercises = [
            "Bench Press", "Squat", "Deadlift", "Overhead Press", "Pull-ups",
            "Rows", "Lunges", "Dips" /*, "Bicep Curls", "Tricep Extensions",
            "Leg Press", "Calf Raises", "Lat Pulldowns", "Shoulder Shrugs", "Leg Curls",
            "Chest Flyes", "Face Pulls", "Planks", "Russian Twists", "Leg Extensions",
            "Hammer Curls", "Skull Crushers", "Front Raises", "Side Raises", "Chin-ups",
            "Barbell Hip Thrusts", "Cable Crunches", "Seated Rows", "Incline Bench Press", "Romanian Deadlifts"*/
        ]

        let categories: [ExerciseCategory] = [.chest, .quads, .lowerBack, .shoulders, .upperBack,
                                              .upperBack, .quads, .chest, .biceps, .triceps,
                                              .quads, .calves, .upperBack, .traps, .hamstrings,
                                              .chest, .shoulders, .abs, .abs, .quads,
                                              .biceps, .triceps, .shoulders, .shoulders, .upperBack,
                                              .glutes, .abs, .upperBack, .chest, .hamstrings]

        
        let startDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())!
        let numberOfDays = 1 * 365 // 5 years
        let setsPerExercisePerDay = 0 // This will result in 20,075 sets per exercise over 5 years

        for (index, exerciseName) in exercises.enumerated() {
            let exercise = Exercise(name: exerciseName, category: categories[index])
            modelContext.insert(exercise)
            print("Adding: \(exercise.name)")

            for day in 0..<numberOfDays {
                let date = Calendar.current.date(byAdding: .day, value: day, to: startDate)!
                
                for _ in 0..<setsPerExercisePerDay {
                    let set = ExerciseSet(
                        weight: Int.random(in: 50...60),
                        reps: Int.random(in: 8...12),
                        date: date,
                        exercise: exercise
                    )
                    exercise.allSets.append(set)
                    print("Adding set: \(date)")
                }
            }
        }
        

        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
         */
    }
}
