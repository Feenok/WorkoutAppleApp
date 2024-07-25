//
//  DataManagers.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/25/24.
//
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
 
 import Foundation
 import SwiftData
 
 class DataManager {
 static let shared = DataManager()
 private init() {}
 
 func addWorkoutSetsToExercises(workout: Workout, modelContext: ModelContext) {
 
 let sortedSets = workout.templateSets.sorted { $0.date < $1.date }
 
 for templateSet in sortedSets {
 guard let exercise = fetchExercise(name: templateSet.name, context: modelContext) else {
 print("Exercise not found: \(templateSet.name)")
 continue
 }
 
 let newSet = ExerciseSet(weight: templateSet.targetWeight, reps: templateSet.targetReps, date: Date.now)
 
 // Create a temporary ViewModel to handle the dictionary updates
 let viewModel = ExerciseDetailsViewModel(exercise: exercise)
 viewModel.addSet(newSet: newSet)
 
 // Update the exercise in SwiftData
 viewModel.addSet(newSet: newSet)
 }
 
 try? modelContext.save()
 }
 
 private func fetchExercise(name: String, context: ModelContext) -> Exercise? {
 let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == name })
 return try? context.fetch(descriptor).first
 }
 }
 
 
 
 
 */
