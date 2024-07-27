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
    @State private var exerciseToEdit: Exercise?
    
    @State private var selectedCategory: ExerciseCategory?
    @State private var isDropdownVisible = false
    
    let exerciseFilter: String
    
    init(exerciseFilter: String = "") {
        self.exerciseFilter = exerciseFilter
        let predicate = #Predicate<Exercise> { exercise in
            exerciseFilter.isEmpty || exercise.name.localizedStandardContains(exerciseFilter)
        }
        _exercises = Query(filter: predicate, sort: \Exercise.name)
    }
    
    private var filteredExercises: [Exercise] {
        guard let selectedCategory = selectedCategory else {
            return exercises
        }
        return exercises.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        Group {
            if !exercises.isEmpty {
                List {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRow(
                            exercise: exercise,
                            onLongPress: {
                                exerciseToEdit = exercise
                            }
                        )
                    }
                    .onDelete(perform: deleteExercises)
                }
            } else {
                ContentUnavailableView {
                    Label("Add Exercise", systemImage: "plus.app")
                }
            }
        }
        .navigationTitle(selectedCategory == nil ? "All Exercises" : selectedCategory!.rawValue.capitalized)
        .toolbar {
            ToolbarItem {
                Button(action: addExercise) {
                    Image(systemName: "plus")
                        .foregroundStyle(.blue)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { selectedCategory = nil }) {
                                Label("All", systemImage: selectedCategory == nil ? "checkmark" : "")
                            }
                            ForEach(ExerciseCategory.allCases) { category in
                                Button(action: { selectedCategory = category }) {
                                    Label(category.rawValue.capitalized, systemImage: selectedCategory == category ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
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
        .sheet(item: $exerciseToEdit) { exercise in
            NavigationStack {
                EditExercise(exercise: exercise)
            }
            .interactiveDismissDisabled()
        }
    }

    private func addExercise() {
        withAnimation {
            newExercise = Exercise(name: "", category: ExerciseCategory.misc)
            modelContext.insert(newExercise!)
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


struct ExerciseRow: View {
    let exercise: Exercise
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    @GestureState private var longPress = false
    
    var body: some View {
        NavigationLink {
            ExerciseDetails(exercise: exercise)
        } label: {
            Text(exercise.name)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($longPress) { currentState, gestureState, _ in
                    gestureState = currentState
                }
                .onEnded { _ in
                    onLongPress()
                }
        )
        .scaleEffect(longPress ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: longPress)
    }
}


struct CategoryDropdown: View {
    let categories: [ExerciseCategory?]
    @Binding var selectedCategory: ExerciseCategory?
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(categories, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    onDismiss()
                }) {
                    Text(category?.rawValue.capitalized ?? "All")
                        .foregroundColor(selectedCategory == category ? .blue : .primary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
