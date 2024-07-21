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
