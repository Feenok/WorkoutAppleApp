//
//  AddExerciseSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/12/24.
//

import SwiftUI
/*
struct AddExerciseSet: View {
    @Bindable var exercise: Exercise
    @Bindable var newExerciseSet: ExerciseSet
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let today = Date()
    
    init(exercise: Exercise, exerciseSet: ExerciseSet) {
        self.exercise = exercise
        self.newExerciseSet = exerciseSet
    }
    
    var body: some View {
        
        Form {
            Text(newExerciseSet.exercise.name)
            
            DatePicker("Date", selection: $newExerciseSet.date, in: ...today, displayedComponents: .date)
            TextField("Weight", value: $newExerciseSet.weight, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
            TextField("Reps", value: $newExerciseSet.reps, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
            
        }
        .navigationTitle("")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    exercise.exerciseSets.append(newExerciseSet)
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    modelContext.delete(newExerciseSet)
                    dismiss()
                }
            }
        }
    }
}
*/
