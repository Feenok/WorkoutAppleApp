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
    
    private var editButton: some View {
        Button(isEditing ? "Done" : "Edit") {
            withAnimation {
                isEditing.toggle()
            }
        }
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
        .navigationBarItems(trailing: editButton)
        .sheet(item: $newWorkoutTemplateSet) { set in
            NavigationStack {
                EnterWorkoutSet(workout: workout, newWorkoutTemplateSet: set)
            }
            .interactiveDismissDisabled()
        }
        .alert("Track Workout", isPresented: $showingAlert) {
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
                    Text("\(set.name)".uppercased())
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .padding(.horizontal)
                        .padding(.bottom, -4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if isEditing {
                        HStack {
                            TextField("Weight", value: Binding(
                                get: { set.targetWeight },
                                set: { set.targetWeight = $0 }
                            ), formatter: NumberFormatter())
                            .multilineTextAlignment(.center)
                            .frame(width: 50)
                            .padding(.vertical, -1)
                            .padding(.trailing, 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                            )
                            .keyboardType(.numberPad)
                            Text("LBS")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                
                            Spacer()
                            TextField("Reps", value: Binding(
                                get: { set.targetReps },
                                set: { set.targetReps = $0 }
                            ), formatter: NumberFormatter())
                            .multilineTextAlignment(.center)
                            .frame(width: 50)
                            .padding(.vertical, -1)
                            .padding(.trailing, 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                            )
                            .keyboardType(.numberPad)
                            Text("REPS")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                
                        }
                        .transition(.blurReplace)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(Color.secondary.opacity(0.2))
                        }
                    } else {
                        HStack {
                            Text("\(set.targetWeight)")
                                .font(.body)
                                
                            Text(" LBS")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                
                            Spacer()
                            Text("\(set.targetReps)")
                                .font(.body)
                                
                            Text(" REPS")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        .transition(.blurReplace)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(Color.secondary.opacity(0.2))
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: isEditing ? deleteWorkoutSets : nil)
        }
        .listStyle(PlainListStyle())
        
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


