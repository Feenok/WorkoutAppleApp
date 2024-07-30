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
    @State private var selectedSetIDs: [UUID] = []
    
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
                VStack {
                    Spacer()
                    Text("No Exercises")
                        .bold()
                    Spacer()
                    Button(action: addWorkoutSet) {
                        HStack (spacing: 5) {
                            Image(systemName: "plus")
                            Text("Add Exercise")
                        }
                        .foregroundStyle(.blue)
                        .font(.body)
                        .bold()
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Workout Plan")
        .navigationBarItems(trailing: !workout.templateSets.isEmpty ? editButton : nil)
        .sheet(item: $newWorkoutTemplateSet) { set in
            NavigationStack {
                EnterWorkoutSet(workout: workout, newWorkoutTemplateSet: set)
            }
            .interactiveDismissDisabled()
        }
        .alert("Track Workout", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                let setsToTrack = sortedSets.filter { set in
                    selectedSetIDs.contains(set.id)
                }.sorted { first, second in
                    selectedSetIDs.firstIndex(of: first.id)! < selectedSetIDs.firstIndex(of: second.id)!
                }
                do {
                    try DataManager.shared.addWorkoutSetsToExercises(sets: setsToTrack, modelContext: modelContext)
                    selectedSetIDs.removeAll()
                } catch {
                    // Handle the error, perhaps show an alert to the user
                    print("Error tracking workout: \(error)")
                }
            }
        } message: {
            Text("Are you sure you want to add these sets to your exercises?")
        }
    }
    
    private func addWorkoutSet() {
        let newItem = WorkoutTemplateSet(name: "", targetWeight: 0, targetReps: 0, workout: workout)
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
    
    private func moveWorkoutSets(from source: IndexSet, to destination: Int) {
        var updatedSets = sortedSets
        updatedSets.move(fromOffsets: source, toOffset: destination)
        
        // Update the date of each set to maintain the new order
        for (index, set) in updatedSets.enumerated() {
            set.date = Date().addingTimeInterval(TimeInterval(index))
        }
        
        // Update the workout's templateSets
        workout.templateSets = updatedSets
        
        // Save changes to SwiftData
        try? modelContext.save()
    }
    
    @ViewBuilder
    private var workoutList: some View {
        List {
            ForEach(Array(sortedSets.enumerated()), id: \.element.id) { index, set in
                VStack {
                    HStack (spacing: 2) {
                        Text("\(index + 1).")
                        Text("\(set.name)".uppercased())
                    }
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
                                //.foregroundStyle(Color.secondary.opacity(0.2))
                                .fill(selectedSetIDs.contains(set.id) ? Color.blue.opacity(0.6) : Color.secondary.opacity(0.2))
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isEditing {
                        if let index = selectedSetIDs.firstIndex(of: set.id) {
                            selectedSetIDs.remove(at: index)
                        } else {
                            selectedSetIDs.append(set.id)
                        }
                    }
                }
            }
            .onMove(perform: isEditing ? moveWorkoutSets : nil)
            .onDelete(perform: isEditing ? deleteWorkoutSets : nil)
        }
        .listStyle(PlainListStyle())
        
        if isEditing {
            Button(action: addWorkoutSet) {
                Label("Add Set", systemImage: "plus")
                    .padding(.vertical)
            }
        } else {
            Button(action: { showingAlert = true }) {
                Label("Track Selected Sets (\(selectedSetIDs.count))", systemImage: "checkmark.circle")
                    .padding(.vertical)
            }
            .disabled(selectedSetIDs.isEmpty)
        }
    }
    
}


