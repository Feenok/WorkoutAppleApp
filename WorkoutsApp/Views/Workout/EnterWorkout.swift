//
//  EnterWorkout.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import SwiftUI

struct EnterWorkout: View {
    
    @Bindable var workout: Workout
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(workout : Workout) {
        self.workout = workout
    }
    
    var body: some View {
        Form {
            TextField("Workout name", text: $workout.name)
            VStack(alignment: .leading) {
                Text("Workout Info")
                    //.frame(width: .infinity, alignment: .leading)
                    .foregroundColor(.gray.opacity(0.5))
                TextEditor(text: $workout.info)
                    .frame(height: 200)
                    .foregroundColor(.gray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .navigationTitle("Add Workout")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    modelContext.delete(workout)
                    dismiss()
                }
            }
        }
    }
}
