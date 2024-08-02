//
//  DailyExerciseView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/24/24.
//

import SwiftUI
import SwiftData

struct DailyExerciseView: View {
    @Query private var allExercises: [Exercise]
    @State private var selectedDate: Date = Date()
    @State private var exerciseSets: [ExerciseSet] = []
    @Environment(\.modelContext) private var modelContext
    
    @State private var addingNewSet: Bool = false
    @State private var newSet: ExerciseSet?
    
    var body: some View {
        VStack {
            DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .onChange(of: selectedDate) { oldValue, newValue in
                    exerciseSets = fetchExercisesForDate(newValue)
                }
                .padding(.horizontal)
            
            if exerciseSets.isEmpty {
                Spacer()
                Text("No exercises for this date")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(Array(exerciseSets.enumerated()), id: \.element.id) { index, set in
                        ExerciseSetRow(set: set, index: index)
                    }
                    .onMove(perform: moveItem)
                    .onDelete(perform: deleteItem)
                }
                .padding(.horizontal, -8)
            }
            
            Button(action: addNewSet) {
                Label("Add Set", systemImage: "plus")
            }
            .padding()
        }
        .navigationTitle("Daily Workout")
        .onAppear {
            exerciseSets = fetchExercisesForDate(selectedDate)
        }
        .sheet(isPresented: $addingNewSet) {
            NavigationStack {
                EnterSet(date: selectedDate, newSet: $newSet)
            }
            .interactiveDismissDisabled()
        }
        .onChange(of: newSet) { oldValue, newValue in
            if let newSet = newValue {
                exerciseSets.append(newSet)
                self.newSet = nil  // Reset newSet after appending
            }
        }
    }
    
    private func fetchExercisesForDate(_ date: Date) -> [ExerciseSet] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let allSets = allExercises.flatMap { exercise in
            exercise.allSets.filter { set in
                (startOfDay...endOfDay).contains(set.date)
            }
        }
        
        return allSets.sorted { $0.date < $1.date }
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        // Ensure the move is valid
        guard let sourceIndex = source.first, sourceIndex != destination else { return }
        
        // Get the item to move
        let itemToMove = exerciseSets[sourceIndex]
        
        // Remove the item from its original position
        exerciseSets.remove(at: sourceIndex)
        
        // Insert the item at its new position
        let destinationIndex = destination > sourceIndex ? destination - 1 : destination
        exerciseSets.insert(itemToMove, at: destinationIndex)
        
        // Update the order of all sets
        for (index, set) in exerciseSets.enumerated() {
            set.date = Calendar.current.date(byAdding: .second, value: index, to: Calendar.current.startOfDay(for: selectedDate)) ?? set.date
            
            // If the set's exercise reference is lost, reassign it
            if set.exercise == nil {
                set.exercise = itemToMove.exercise
            }
        }
        
        // Save changes to the model context
        do {
            try modelContext.save()
        } catch {
            print("Error saving context after reordering: \(error)")
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let setToDelete = exerciseSets[index]
            if let exercise = setToDelete.exercise {
                exercise.removeSet(setToDelete) 
                modelContext.delete(setToDelete)
            }
        }
        exerciseSets.remove(atOffsets: offsets)
        
        // Save changes to the model context
        do {
            try modelContext.save()
        } catch {
            print("Error saving context after deletion: \(error)")
        }
    }
    
    private func addNewSet() {
        addingNewSet = true
    }
    
}

struct ExerciseSetRow: View {
    let set: ExerciseSet
    let index: Int
    
    var body: some View {
        if let exercise = set.exercise {
            NavigationLink(destination: ExerciseDetails(exercise: exercise, displayedDate: set.date)) {
                rowContent
            }
        }
    }
    
    private var rowContent: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 2) {
                    Text("\(index + 1).")
                        .bold()
                    Text((set.exercise!.name).uppercased())
                }
                .padding(.leading, -10)
                .font(.caption)
                .foregroundColor(.secondary)
                HStack {
                    Text("\(set.weight)")
                    Text("LBS")
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .padding(.top, 3)
                    Spacer()
                    Text("\(set.reps)")
                    Text("REPS")
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .padding(.top, 3)
                }
                .font(.body)
            }
        }
    }
}

struct EnterSet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: ExerciseCategory?
    @State private var selectedExercise: Exercise?
    @State private var weight: Int = 0
    @State private var reps: Int = 0
    @State private var includesDuration: Bool = false
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @Query private var allExercises: [Exercise]
    
    let date: Date
    @Binding var newSet: ExerciseSet?
    
    private var categoriesWithExercises: [ExerciseCategory] {
        Array(Set(allExercises.map { $0.category })).sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        Form {
            Picker("Select Category", selection: $selectedCategory) {
                Text("Choose a category").tag(nil as ExerciseCategory?)
                ForEach(categoriesWithExercises, id: \.self) { category in
                    Text(category.rawValue.capitalized).tag(category as ExerciseCategory?)
                }
            }
            .onChange(of: selectedCategory) { _, _ in
                selectedExercise = nil
            }
            
            if let selectedCategory = selectedCategory {
                Picker("Select Exercise", selection: $selectedExercise) {
                    Text("Choose an exercise").tag(nil as Exercise?)
                    ForEach(filteredExercises(for: selectedCategory)) { exercise in
                        Text(exercise.name).tag(exercise as Exercise?)
                    }
                }
            }
            
            HStack {
                TextField("Weight", value: $weight, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                Text("lbs")
            }
            
            HStack {
                TextField("Reps", value: $reps, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                Text("reps")
            }
            
            Toggle("Include Duration", isOn: $includesDuration)
            
            if includesDuration {
                HStack {
                    TextField("Minutes", value: $minutes, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                    Text("min")
                    TextField("Seconds", value: $seconds, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                    Text("sec")
                }
            }
        }
        .navigationTitle("Add Exercise Set")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if let exercise = selectedExercise, weight > 0, reps > 0 {
                        let duration = includesDuration ? TimeInterval(minutes * 60 + seconds) : nil
                        let createdSet = ExerciseSet(weight: weight, reps: reps, duration: duration, date: date, exercise: exercise)
                        newSet = createdSet
                        exercise.addSet(createdSet)
                        modelContext.insert(createdSet)
                        try? modelContext.save()
                        dismiss()
                    }
                }
                .disabled(selectedExercise == nil || weight == 0 || reps == 0)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    private func filteredExercises(for category: ExerciseCategory) -> [Exercise] {
        return allExercises.filter { $0.category == category }
    }
}


