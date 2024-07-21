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
    
    @State private var setToAdd: WorkoutTemplateSet?
    @State var isEditing: Bool = false
    
    var sortedSets: [WorkoutTemplateSet] {
        workout.templateSets.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Group {
            if !workout.templateSets.isEmpty {
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
                }
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
        .sheet(item: $setToAdd) { set in
            NavigationStack {
                EnterWorkoutSet(workout: workout)
            }
            .interactiveDismissDisabled()
        }
    }
    
    private func addWorkoutSet() {
        withAnimation {
            let newItem = WorkoutTemplateSet(name: "")
            modelContext.insert(newItem)
            setToAdd = newItem
        }
    }

    private func deleteWorkoutSets(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(workout.templateSets[index])
            }
        }
    }
}

