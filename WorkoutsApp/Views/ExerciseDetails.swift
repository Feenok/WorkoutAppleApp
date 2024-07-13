//
//  ExerciseDetails.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/12/24.
//

import SwiftUI

struct ExerciseDetails: View {
    
    @Bindable var exercise: Exercise
    
    @State var newExerciseSet: ExerciseSet?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    var body: some View {
        
        Form {
            Text(exercise.name)
        }
        .navigationTitle("")
        .toolbar{
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            ToolbarItem {
                Button(action: addExerciseSet) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            
        }
        .sheet(item: $newExerciseSet) { exerciseSet in
            NavigationStack {
                AddExerciseSet(exerciseSet: exerciseSet)
            }
            .interactiveDismissDisabled()
        }
    }
    
    private func addExerciseSet() {
        var todaysDate: Date = Date()
        withAnimation {
            let newItem = ExerciseSet(exercise: exercise, weight: 0, reps: 0, date: todaysDate)
            modelContext.insert(newItem)
            newExerciseSet = newItem
        }
    }
    
}

