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
    
    var body: some View {
            List {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .onChange(of: selectedDate) { oldValue, newValue in
                        exerciseSets = fetchExercisesForDate(newValue)
                    }
                
                ForEach(exerciseSets) { set in
                    Section(header: Text(set.exercise?.name ?? "Unknown Exercise")) {
                        HStack {
                            Text("\(set.weight) lbs")
                            Spacer()
                            Text("\(set.reps) reps")
                        }
                    }
                }
            }
            .navigationTitle("Daily Exercises")
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
    
}

