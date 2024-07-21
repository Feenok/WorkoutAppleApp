//
//  EnterWorkoutSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import SwiftUI
import SwiftData

struct EnterWorkoutSet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var workout: Workout
    
    @Query private var allExercises: [Exercise]
    
    @State private var selectedExerciseName: String?
    @State private var targetWeight: Int = 0
    @State private var targetReps: Int = 0
    
    var body: some View {
        Form {
            Picker("Select Exercise", selection: $selectedExerciseName) {
                Text("Choose an exercise").tag(nil as Exercise?)
                ForEach(allExercises) { exercise in
                    Text(exercise.name).tag(exercise.name as String?)
                }
            }
            HStack {
                TextField("Target Weight", value: $targetWeight, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                Text("lbs")
            }
            
            HStack {
                TextField("Target Reps", value: $targetReps, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                Text("reps")
            }
        }
        .navigationTitle("Add Set to Workout")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if let selectedExerciseName = selectedExerciseName {
                        let newSet = WorkoutTemplateSet(name: selectedExerciseName, targetWeight: targetWeight, targetReps: targetReps)
                        workout.templateSets.append(newSet)
                        dismiss()
                    }
                }
                .disabled(selectedExerciseName == nil)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        
    }
}
