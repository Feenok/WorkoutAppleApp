//
//  EnterExercise.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import SwiftUI

struct EnterExercise: View {
    
    @Bindable var exercise: Exercise
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(exercise : Exercise) {
        self.exercise = exercise
    }
    
    var body: some View {
        Form {
            TextField("Exercise name", text: $exercise.name)
        }
        .navigationTitle("Add Exercise")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    modelContext.delete(exercise)
                    dismiss()
                }
            }
        }
    }
    
}
