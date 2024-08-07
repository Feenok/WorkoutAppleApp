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
    @State private var timedWorkout: Bool = false
    @State private var showingInfo: Bool = false
    @State private var editingName: Bool = false
    
    //@State private var notificationOffset: CGFloat = -50 // Start above the screen
    //@State private var showingTrackingNotification = false
    
    @FocusState private var focusedField: UUID?
    
    var sortedSets: [WorkoutTemplateSet] {
        (workout.templateSets!.sorted { $0.date < $1.date })
    }
    
    private var editButton: some View {
        Button(isEditing ? "Done" : "Edit"){
            withAnimation {
                isEditing.toggle()
                focusedField = nil
            }
        }
        .foregroundColor(isEditing ? .red : .blue)
    }
    
    var body: some View {
        VStack {
            if !workout.templateSets!.isEmpty {
                    workoutList
            } else {
                VStack {
                    Spacer()
                    Text("No Exercises")
                        .foregroundColor(.secondary)
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
        .navigationTitle(workout.name)
        .navigationBarItems(trailing: !workout.templateSets!.isEmpty ? editButton : nil)
        .sheet(item: $newWorkoutTemplateSet) { set in
            NavigationStack {
                EnterWorkoutSet(workout: workout, newWorkoutTemplateSet: set)
            }
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $editingName, onDismiss: {
            editingName = false
        }) {
            NavigationStack {
                EditWorkout(workout: workout)
            }
        }
        .alert("Track Workout", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                let setsToTrack = sortedSets.filter { set in
                    selectedSetIDs.contains(set.id)
                }.sorted { first, second in
                    first.date < second.date
                }
                do {
                    try DataManager.shared.addWorkoutSetsToExercises(sets: setsToTrack, modelContext: modelContext)
                    selectedSetIDs.removeAll()
                    //showNotification()
                } catch {
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
                workout.templateSets?.removeAll { $0.id == setToDelete.id }
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
    
    private func duplicateSelectedSets() {
        if !selectedSetIDs.isEmpty {
            let setsToTrack = sortedSets.filter { set in
                selectedSetIDs.contains(set.id)
            }.sorted { first, second in
                first.date < second.date
            }
            
            for set in setsToTrack {
                let newSet = WorkoutTemplateSet(
                    name: set.name,
                    targetWeight: set.targetWeight,
                    targetReps: set.targetReps,
                    workout: workout
                )
                newSet.date = Date()
                modelContext.insert(newSet)
                workout.templateSets?.append(newSet)
            }
            
            selectedSetIDs.removeAll()
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving duplicated sets: \(error)")
            }
        }
    }
    
    @ViewBuilder
    private var workoutList: some View {
        VStack {
            if isEditing {
                VStack {
                    Button {
                        editingName.toggle()
                    } label: {
                        Text("Edit Workout Details")
                            .foregroundStyle(.blue)
                            .font(.caption)
                    }
                    HStack {
                        Text("Best Time:")
                        TextField("-", value: Binding(
                            get: { workout.bestTimeMinutes ?? 0 },
                            set: { workout.bestTimeMinutes = $0 > 0 ? $0 : nil }
                        ), formatter: NumberFormatter())
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .padding(.vertical, -1)
                        .padding(.trailing, 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                        )
                        .keyboardType(.numberPad)
                        
                        Text("min")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        
                        TextField("-", value: Binding(
                            get: { workout.bestTimeSeconds ?? 0 },
                            set: {
                                let validSeconds = min(max($0, 0), 59)
                                workout.bestTimeSeconds = validSeconds > 0 ? validSeconds : nil
                            }
                        ), formatter: NumberFormatter())
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .padding(.vertical, -1)
                        .padding(.trailing, 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                        )
                        .keyboardType(.numberPad)
                        
                        Text("sec")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .transition(.blurReplace)
                    .padding()
                }
            } else {
                AdditionalInfoView(showingInfo: $showingInfo, workout: workout)
                    .padding(.horizontal)
                if let minutes = workout.bestTimeMinutes, let seconds = workout.bestTimeSeconds {
                    Text("Best Time: \(minutes) min \(seconds) sec")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    //.bold()
                } else if let minutes = workout.bestTimeMinutes {
                    Text("Best Time: \(minutes) min")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    //.bold()
                } else if let seconds = workout.bestTimeSeconds {
                    Text("Best Time: \(seconds) sec")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    //.bold()
                }
            }
            
            Button(action: {
                withAnimation {
                    if selectedSetIDs.isEmpty {
                        // If no sets are selected, select all sets
                        selectedSetIDs = sortedSets.map { $0.id }
                    } else {
                        // If any sets are selected, unselect all
                        selectedSetIDs.removeAll()
                    }
                }
            }, label: {
                if selectedSetIDs.isEmpty {
                    HStack(spacing: 2) {
                        //Image(systemName: "plus")
                        Text("Select All Sets")
                    }
                } else {
                    HStack(spacing: 2) {
                        //Image(systemName: "minus")
                        Text("Deselect Sets")
                    }
                    .foregroundStyle(.red)
                }
            })
            .disabled(sortedSets.isEmpty)
            .padding(.top)
            .padding(.bottom, 0)
            .font(.subheadline)
            
            
            List {
                ForEach(Array(sortedSets.enumerated()), id: \.element.id) { index, set in
                    VStack {
                        HStack(spacing: 2) {
                            Text("\(index + 1).")
                            Text("\(set.name)".uppercased())
                        }
                        .foregroundStyle(.primary)
                        .font(.caption2)
                        .padding(.horizontal)
                        .padding(.bottom, -4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedSetIDs.contains(set.id) ? Color.blue.opacity(0.6) : Color.secondary.opacity(0.2))
                                .onTapGesture {
                                    //focusedField = nil
                                    if let index = selectedSetIDs.firstIndex(of: set.id) {
                                        selectedSetIDs.remove(at: index)
                                    } else {
                                        selectedSetIDs.append(set.id)
                                    }
                                }
                            
                            HStack {
                                TextField("", value: Binding(
                                    get: { set.targetWeight },
                                    set: { set.targetWeight = $0 }
                                ), formatter: NumberFormatter())
                                .focused($focusedField, equals: set.id)
                                .multilineTextAlignment(.center)
                                .frame(width: 50)
                                .padding(.vertical, -1)
                                .padding(.trailing, 3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary, lineWidth: 1)
                                )
                                .keyboardType(.numberPad)
                                
                                .background(Color.white.opacity(0.001))
                                .onTapGesture { focusedField == nil ? isEditing.toggle() : nil }
                                
                                Text("LBS")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                
                                Spacer()
                                
                                TextField("", value: Binding(
                                    get: { set.targetReps },
                                    set: { set.targetReps = $0 }
                                ), formatter: NumberFormatter())
                                .focused($focusedField, equals: set.id)
                                .multilineTextAlignment(.center)
                                .frame(width: 50)
                                .padding(.vertical, -1)
                                .padding(.trailing, 3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary, lineWidth: 1)
                                )
                                .keyboardType(.numberPad)
                                .background(Color.white.opacity(0.001))
                                .onTapGesture { focusedField == nil ? isEditing.toggle() : nil }
                                
                                Text("REPS")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .padding()
                        }
                        .transition(.blurReplace)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .onMove(perform: moveWorkoutSets)
                .onDelete(perform: deleteWorkoutSets)
                
                HStack (spacing: 1) {
                    Spacer()
                    Group {
                        if selectedSetIDs.isEmpty {
                            Button(action: addWorkoutSet) {
                                HStack(spacing: 2) {
                                    Image(systemName: "plus")
                                    Text("Add Set")
                                }
                            }
                        } else {
                            Button(action: {
                                //trackingAllSets.toggle()
                                duplicateSelectedSets()
                            }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "plus")
                                    Text("Duplicate Selected Sets")
                                }
                            }
                        }
                    }
                    .padding(.top, 0)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .foregroundColor(.blue)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            
            
            Button(action: { showingAlert = true }) {
                Label("Track Selected Sets (\(selectedSetIDs.count))", systemImage: "checkmark.circle")
                    .padding(.vertical)
            }
            .disabled(selectedSetIDs.isEmpty)
        
        }
    }
    
}


struct AdditionalInfoView: View {
    
    @Binding var showingInfo: Bool
    var workout: Workout
    
    var body: some View {
        if !workout.info.isEmpty && !showingInfo {
            HStack {
                Button(action: {
                    withAnimation {
                        showingInfo.toggle()
                    }
                }) {
                    Text("Show Exercise Info")
                        .font(.caption)
                        .padding(.bottom)
                        .padding(.top, -2)
                        //.padding(.horizontal)
                }
                Spacer()
            }
        }
        if showingInfo {
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            showingInfo.toggle()
                        }
                    }) {
                        Text("Collapse Exercise Info")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.top, -2)
                            //.padding(.horizontal)
                    }
                    Spacer()
                }
                
                Text("\(workout.info)")
                    .font(.body)
                    .padding(.top, 2)
                    .padding(.bottom)
            }
        }
    }
}


