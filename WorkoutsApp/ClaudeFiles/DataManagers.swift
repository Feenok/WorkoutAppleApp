/*
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
     
     func getDuration(minutes: Int, seconds: Int) -> TimeInterval? {
         return TimeInterval(minutes * 60 + seconds)
     }
     
     func secondsToMinutesAndSeconds(_ seconds: Int) -> (Int, Int) {
         return (seconds / 60, seconds % 60)
     }
     
     
 }
 */

/*
 
 import Foundation
 import SwiftUI

 class StopwatchManager: ObservableObject {
     @Published var elapsedTime: TimeInterval = 0
     private var timer: Timer?
     private var startTime: Date?
     
     @Published var isRunning = false
     
     func start() {
         if !isRunning {
             startTime = startTime ?? Date()
             timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                 self?.updateElapsedTime()
             }
             isRunning = true
         }
     }
     
     func pause() {
         timer?.invalidate()
         isRunning = false
     }
     
     func stop() {
         timer?.invalidate()
         elapsedTime = 0
         startTime = nil
         isRunning = false
     }
     
     private func updateElapsedTime() {
         guard let startTime = startTime else { return }
         elapsedTime = Date().timeIntervalSince(startTime)
     }
     
     func updateElapsedTimeInBackground() {
         if isRunning {
             updateElapsedTime()
         }
     }
 }

 */
