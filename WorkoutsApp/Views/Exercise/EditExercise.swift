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
    @State private var editedCategory: ExerciseCategory
    @State private var editedInfo: String
    
    init(exercise : Exercise) {
        self.exercise = exercise
        _editedName = State(initialValue: exercise.name)
        _editedCategory = State(initialValue: exercise.category)
        _editedInfo = State(initialValue: exercise.info)
    }
    
    var body: some View {
        Group {
            Form {
                TextField("Edit exercise name", text: $editedName)
                Picker("Edit Category", selection: $editedCategory) {
                    Text("Exercise Category").tag("")
                    ForEach(ExerciseCategory.allCases) { category in
                        Text(category.rawValue.capitalized).tag(category)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Exercise Info")
                        .frame(width: .infinity, alignment: .leading)
                    TextEditor(text: $editedInfo)
                        .frame(height: 200)
                        .foregroundColor(.gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .navigationTitle("Edit Exercise")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    exercise.name = editedName
                    exercise.category = editedCategory
                    exercise.info = editedInfo
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
