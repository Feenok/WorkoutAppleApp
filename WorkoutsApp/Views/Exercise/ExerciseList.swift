//
//  ExerciseList.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import SwiftUI
import SwiftData

struct ExerciseList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    
    @State private var newExercise: Exercise?
    
    init(exerciseFilter: String = "") {
        let predicate = #Predicate<Exercise> { exercise in
            exerciseFilter.isEmpty || exercise.name.localizedStandardContains(exerciseFilter)
        }
        
        _exercises = Query(filter: predicate, sort: \Exercise.name)
    }

    var body: some View {
        Group {
            if !exercises.isEmpty {
                List {
                    ForEach(exercises) { exercise in
                        NavigationLink {
                            ExerciseDetails(exercise: exercise)
                        } label: {
                            Text(exercise.name)
                        }
                    }
                    .onDelete(perform: deleteExercises)
                }
            } else {
                ContentUnavailableView {
                    Label("Add Exercise", systemImage: "film.stack")
                }
            }
        }
        .navigationTitle("Exercises")
        .toolbar {
            ToolbarItem {
                Button(action: addExercise) {
                    Text("Add Exercise")
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(item: $newExercise) { exercise in
            NavigationStack {
                EnterExercise(exercise: exercise)
            }
            .interactiveDismissDisabled()
        }
    }

    private func addExercise() {
        withAnimation {
            let newItem = Exercise(name: "", category: "")
            modelContext.insert(newItem)
            newExercise = newItem
        }
    }

    private func deleteExercises(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(exercises[index])
            }
        }
    }
}

#Preview {
    ExerciseList()
        .modelContainer(for: Exercise.self, inMemory: true)
}
