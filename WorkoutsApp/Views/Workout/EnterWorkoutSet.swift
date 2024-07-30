//
//  EnterWorkoutSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/22/24.
//

/*
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
        .navigationTitle("Add Exercise Set")
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

*/

import SwiftUI
import SwiftData

struct EnterWorkoutSet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var workout: Workout
    @Bindable var newWorkoutTemplateSet: WorkoutTemplateSet
    @Query private var allExercises: [Exercise]
    
    @State private var selectedCategory: ExerciseCategory?
    @State private var selectedExerciseName: String = ""
    
    private var categoriesWithExercises: [ExerciseCategory] {
        Array(Set(allExercises.map { $0.category })).sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        Form {
            Picker("Select Category", selection: $selectedCategory) {
                Text("Choose a category").tag(nil as ExerciseCategory?)
                ForEach(categoriesWithExercises, id: \.self) { category in
                    Text(category.rawValue.capitalized).tag(category as ExerciseCategory?)
                }
            }
            .onChange(of: selectedCategory) { _, _ in
                selectedExerciseName = ""
            }
            
            if let selectedCategory = selectedCategory {
                Picker("Select Exercise", selection: $selectedExerciseName) {
                    Text("Choose an exercise").tag("")
                    ForEach(filteredExercises(for: selectedCategory)) { exercise in
                        Text(exercise.name).tag(exercise.name)
                    }
                }
                .onChange(of: selectedExerciseName) { _, newValue in
                    newWorkoutTemplateSet.name = newValue
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
        .navigationTitle("Add Exercise Set")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if newWorkoutTemplateSet.name != "" && newWorkoutTemplateSet.targetWeight != 0 && newWorkoutTemplateSet.targetReps != 0 {
                        newWorkoutTemplateSet.workout = workout
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
    
    private func filteredExercises(for category: ExerciseCategory) -> [Exercise] {
        return allExercises.filter { $0.category == category }
    }
}
