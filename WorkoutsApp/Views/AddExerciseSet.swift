//
//  AddExerciseSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/12/24.
//

import SwiftUI

struct AddExerciseSet: View {
    
    @Bindable var exerciseSet: ExerciseSet
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet
    }
    
    var body: some View {
        
        Form {
            Text(exerciseSet.exercise.name)
            
            DatePicker("Date", selection: $exerciseSet.date, displayedComponents: .date)
        }
        .navigationTitle("")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
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
