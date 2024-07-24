//
//  EditExercise.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/24/24.
//

import SwiftUI

struct EditExercise: View {
    @Bindable var exercise: Exercise
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var editedName: String
    //@State private var editedCategory: String
    
    init(exercise : Exercise) {
        self.exercise = exercise
        _editedName = State(initialValue: exercise.name)
    }
    
    var body: some View {
        Form {
            TextField("Edit exercise name", text: $editedName)
        }
        .navigationTitle("Edit Exercise")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    exercise.name = editedName
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
}
