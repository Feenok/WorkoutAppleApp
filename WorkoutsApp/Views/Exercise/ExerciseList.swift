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
    @State private var addingNewExercise: Bool = false
    
    @State private var selectedCategory: ExerciseCategory?
    @State private var isDropdownVisible = false
    
    @State private var showingDeleteConfirmation = false
    @State private var exerciseToDelete: Exercise?
    
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
    
    private var title: String {
        if !exercises.isEmpty {
            return selectedCategory?.rawValue.capitalized ?? "All Exercises"
        } else {
            return "Exercises"
        }
    }
    
    var body: some View {
        Group {
            if !exercises.isEmpty {
                List {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                    .onDelete(perform: deleteExercises)
                }
            } else {
                VStack {
                    Spacer()
                    Text("No Exercises")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: addExercise) {
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
        .navigationTitle(title)
        .toolbar {
            if !exercises.isEmpty {
                ToolbarItem {
                    Button(action:
                            addExercise
                    ) {
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
        }
        .sheet(isPresented: $addingNewExercise, onDismiss: {addingNewExercise = false}) {
            NavigationStack {
                EnterExercise(exercise: newExercise ?? Exercise(name: "", category: ExerciseCategory.misc))
            }
            .interactiveDismissDisabled()
        }
        .confirmationDialog("Are you sure you want to delete this exercise?",
                            isPresented: $showingDeleteConfirmation,
                            presenting: exerciseToDelete) { exercise in
            Button("Delete", role: .destructive) {
                withAnimation {
                    modelContext.delete(exercise)
                    try? modelContext.save()
                }
            }
        } message: { exercise in
            Text("Are you sure you want to delete '\(exercise.name)'?")
        }
    }

    private func addExercise() {
        withAnimation {
            newExercise = Exercise(name: "", category: ExerciseCategory.misc)
            modelContext.insert(newExercise!)
            addingNewExercise = true
        }
    }
    
    private func deleteExercises(offsets: IndexSet) {
        guard let index = offsets.first else { return }
        exerciseToDelete = filteredExercises[index]
        showingDeleteConfirmation = true
    }
    
}


struct ExerciseRow: View {
    let exercise: Exercise
    
    @State private var isPressed = false
    @GestureState private var longPress = false
    
    var body: some View {
        NavigationLink {
            ExerciseDetails(exercise: exercise)
        } label: {
            Text(exercise.name)
        }
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
