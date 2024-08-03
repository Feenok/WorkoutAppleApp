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
    @State private var addingNewWorkout: Bool = false
    
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
                            HStack (spacing: 2) {
                                Text(workout.name)
                                Spacer()
                                if workout.bestTimeMinutes != nil || workout.bestTimeSeconds != nil {
                                    Image(systemName: "stopwatch.fill")
                                        .foregroundStyle(.gray)
                                        .font(.caption2)
                                }
                                if let minutes = workout.bestTimeMinutes {
                                    Text("\(minutes)")
                                        .foregroundStyle(.gray)
                                        .font(.caption2)
                                    Text("min")
                                        .foregroundStyle(.gray)
                                        .font(.caption2)
                                }
                                if let seconds = workout.bestTimeSeconds {
                                    Text("\(seconds)")
                                        .foregroundStyle(.gray)
                                        .font(.caption2)
                                    Text("sec")
                                        .foregroundStyle(.gray)
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            } else {
                VStack {
                    Spacer()
                    Text("No Workouts")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: addWorkout) {
                        HStack (spacing: 5) {
                            Image(systemName: "plus")
                            Text("Add Workout")
                        }
                        .foregroundStyle(.blue)
                        .font(.body)
                        .bold()
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Workouts")
        .toolbar {
            if !workouts.isEmpty {
                ToolbarItem {
                    Button(action: addWorkout) {
                        Text("Add Workout")
                            .foregroundStyle(.blue)
                    }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $addingNewWorkout, onDismiss: {addingNewWorkout = false}) {
            NavigationStack {
                EnterWorkout(workout: newWorkout ?? Workout(name: "", category: ""))
            }
            .interactiveDismissDisabled()
        }
    }

    private func addWorkout() {
        withAnimation {
            newWorkout = Workout(name: "", category: "")
            modelContext.insert(newWorkout!)
            addingNewWorkout = true
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
