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
            Picker("Category", selection: $exercise.category) {
                Text("Choose a category").tag("")
                ForEach(ExerciseCategory.allCases) { category in
                    Text(category.rawValue.capitalized).tag(category)
                }
            }
            VStack(alignment: .leading) {
                Text("Exercise Info")
                    .frame(width: .infinity, alignment: .leading)
                TextEditor(text: $exercise.info)
                    .frame(height: 200)
                    .foregroundColor(.gray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .navigationTitle("Add Exercise")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .disabled(exercise.name == "" || exercise.category == nil)
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

