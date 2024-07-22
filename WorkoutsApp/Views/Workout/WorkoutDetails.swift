//
//  WorkoutDetails.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import SwiftUI
import SwiftData

struct WorkoutDetails: View {
    @Bindable var workout: Workout
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var newWorkoutTemplateSet: WorkoutTemplateSet?
    @State private var isEditing: Bool = false
    @State private var showingAlert = false
    
    var sortedSets: [WorkoutTemplateSet] {
        workout.templateSets.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Group {
            if !workout.templateSets.isEmpty {
                workoutList
            } else {
                ContentUnavailableView {
                    Button(action: addWorkoutSet) {
                        Text("Add Set")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .navigationTitle("Workout Plan")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
            }
        }
        .sheet(item: $newWorkoutTemplateSet) { set in
            NavigationStack {
                EnterWorkoutSet(workout: workout, newWorkoutTemplateSet: set)
            }
            .interactiveDismissDisabled()
        }
        .alert("Confirm Workout", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                DataManager.shared.addWorkoutSetsToExercises(workout: workout, modelContext: modelContext)
            }
        } message: {
            Text("Are you sure you want to add these sets to your exercises?")
        }
    }
    
    private func addWorkoutSet() {
        let newItem = WorkoutTemplateSet(name: "", targetWeight: 0, targetReps: 0)
        newWorkoutTemplateSet = newItem
    }

    private func deleteWorkoutSets(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let setToDelete = sortedSets[index]
                workout.templateSets.removeAll { $0.id == setToDelete.id }
                modelContext.delete(setToDelete)
            }
        }
    }
    
    @ViewBuilder
    private var workoutList: some View {
        List {
            ForEach(sortedSets) {set in
                VStack {
                    Text("\(set.name)")
                    if isEditing {
                        HStack {
                            TextField("Weight", value: Binding(
                                get: { set.targetWeight },
                                set: { set.targetWeight = $0 }
                            ), formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            Text("LBS")
                            Spacer()
                            TextField("Reps", value: Binding(
                                get: { set.targetReps },
                                set: { set.targetReps = $0 }
                            ), formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            Text("REPS")
                        }
                    } else {
                        HStack {
                            Text("Weight: \(set.targetWeight) LBS")
                            Spacer()
                            Text("Reps: \(set.targetReps) REPS")
                        }
                    }
                }
            }
            .onDelete(perform: isEditing ? deleteWorkoutSets : nil)
        }
        
        if isEditing {
            Button(action: addWorkoutSet) {
                Label("Add Set", systemImage: "plus")
            }
        } else {
            Button(action: { showingAlert = true }) {
                Label("Track Selected Sets", systemImage: "checkmark.circle")
            }
        }
    }
    
}


