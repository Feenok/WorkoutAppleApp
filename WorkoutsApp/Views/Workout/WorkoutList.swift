//
//  WorkoutList.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import SwiftUI
import SwiftData

struct WorkoutList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workouts: [Workout]
    
    @State private var newWorkout: Workout?
    
    init(workoutFilter: String = "") {
        let predicate = #Predicate<Workout> { workout in
            workoutFilter.isEmpty || workout.name.localizedStandardContains(workoutFilter)
        }
        
        _workouts = Query(filter: predicate, sort: \Workout.name)
    }

    var body: some View {
        Group {
            if !workouts.isEmpty {
                List {
                    ForEach(workouts) { workout in
                        NavigationLink {
                            WorkoutDetails(workout: workout)
                        } label: {
                            Text(workout.name)
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            } else {
                ContentUnavailableView {
                    Label("Add Workout", systemImage: "film.stack")
                }
            }
        }
        .navigationTitle("Workouts")
        .toolbar {
            ToolbarItem {
                Button(action: addWorkout) {
                    Text("Add Workout")
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(item: $newWorkout) { workout in
            NavigationStack {
                EnterWorkout(workout: workout)
            }
            .interactiveDismissDisabled()
        }
    }

    private func addWorkout() {
        withAnimation {
            let newItem = Workout(name: "", category: "")
            modelContext.insert(newItem)
            newWorkout = newItem
        }
    }

    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(workouts[index])
            }
        }
    }
}