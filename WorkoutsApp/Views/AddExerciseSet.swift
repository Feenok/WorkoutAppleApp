//
//  AddExerciseSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/12/24.
//

import SwiftUI

struct AddExerciseSet: View {
    @Bindable var exercise: Exercise
    @Bindable var exerciseSet: ExerciseSet
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(exercise: Exercise, exerciseSet: ExerciseSet) {
        self.exercise = exercise
        self.exerciseSet = exerciseSet
    }
    
    var body: some View {
        
        Form {
            Text(exerciseSet.exercise.name)
            
            DatePicker("Date", selection: $exerciseSet.date, displayedComponents: .date)
            TextField("Weight", value: $exerciseSet.weight, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
            TextField("Reps", value: $exerciseSet.reps, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
            
        }
        .navigationTitle("")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    exercise.exerciseSets.append(exerciseSet)
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    modelContext.delete(exerciseSet)
                    dismiss()
                }
            }
        }
    }
}
