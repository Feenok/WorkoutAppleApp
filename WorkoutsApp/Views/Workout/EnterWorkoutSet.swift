//
//  EnterWorkoutSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/22/24.
//

import SwiftUI
import SwiftData

struct EnterWorkoutSet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var workout: Workout
    @Bindable var newWorkoutTemplateSet: WorkoutTemplateSet
    @Query private var allExercises: [Exercise]
    
    var body: some View {
        Form {
            Picker("Select Exercise", selection: $newWorkoutTemplateSet.name) {
                Text("Choose an exercise").tag("")
                ForEach(allExercises) { exercise in
                    Text(exercise.name).tag(exercise.name)
                }
            }
            HStack {
                TextField("Weight", value: $newWorkoutTemplateSet.targetWeight, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                Text("lbs")
            }
            
            HStack {
                TextField("Reps", value: $newWorkoutTemplateSet.targetReps, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                Text("reps")
            }
        }
        .navigationTitle("Add Set to Workout")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if newWorkoutTemplateSet.name != "" && newWorkoutTemplateSet.targetWeight != 0 && newWorkoutTemplateSet.targetReps != 0 {
                        modelContext.insert(newWorkoutTemplateSet)
                        workout.templateSets.append(newWorkoutTemplateSet)
                        dismiss()
                    }
                }
                .disabled(newWorkoutTemplateSet.name == "" || newWorkoutTemplateSet.targetWeight == 0 || newWorkoutTemplateSet.targetReps == 0)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    modelContext.delete(newWorkoutTemplateSet)
                    dismiss()
                }
            }
        }
        
    }
}
