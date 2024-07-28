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
    
    var body: some View {
        VStack {
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .onChange(of: selectedDate) { oldValue, newValue in
                    exerciseSets = fetchExercisesForDate(newValue)
                }
                .padding(.horizontal)
            List {
                ForEach(Array(exerciseSets.enumerated()), id: \.element.id) { index, set in
                    ExerciseSetRow(set: set, index: index)
                }
                .onMove(perform: moveItem)
                .onDelete(perform: deleteItem)
            }
            .padding(.horizontal, -8)
        }
        .navigationTitle("Daily Workout")
        .onAppear {
            exerciseSets = fetchExercisesForDate(selectedDate)
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
        var updatedSets = exerciseSets
        updatedSets.move(fromOffsets: source, toOffset: destination)
        
        // Update dates to maintain order
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        for (index, set) in updatedSets.enumerated() {
            set.date = calendar.date(byAdding: .second, value: index, to: startOfDay) ?? set.date
        }
        
        exerciseSets = updatedSets
        
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
                exercise.allSets.removeAll { $0.id == setToDelete.id }
            }
            modelContext.delete(setToDelete)
        }
        exerciseSets.remove(atOffsets: offsets)
        
        // Save changes to the model context
        do {
            try modelContext.save()
        } catch {
            print("Error saving context after deletion: \(error)")
        }
    }
}

struct ExerciseSetRow: View {
    let set: ExerciseSet
    let index: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack (spacing: 2) {
                    Text("\(index + 1).")
                    .bold()
                    Text((set.exercise?.name ?? "Unknown Exercise").uppercased())
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

