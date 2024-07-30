//
//  EditWorkout.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/30/24.
//

import SwiftUI

struct EditWorkout: View {
    @Bindable var workout: Workout
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var editedName: String
    @State private var editedInfo: String
    
    init(workout : Workout) {
        self.workout = workout
        _editedName = State(initialValue: workout.name)
        _editedInfo = State(initialValue: workout.info)
    }
    
    var body: some View {
        Group {
            Form {
                TextField("Edit workout name", text: $editedName)
                VStack(alignment: .leading) {
                    Text("Workout Info")
                        .frame(width: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
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
        .navigationTitle("Edit Workout")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    workout.name = editedName
                    workout.info = editedInfo
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
