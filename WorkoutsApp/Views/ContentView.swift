//
//  ContentView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView  {
            FilteredExerciseList()
            .tabItem {
                Label("Exercises", systemImage: "dumbbell.fill")
            }
            NavigationStack {
                FilteredWorkoutList()
            }
            .tabItem {
                Label("Workouts", systemImage: "list.bullet.circle.fill")
            }
            NavigationStack {
                DailyExerciseView()
            }
            .tabItem {
                Label("Daily Workout", systemImage: "figure.strengthtraining.traditional")
            }
            NavigationStack {
                StopwatchView()
            }
            .tabItem {
                Label("Stopwatch", systemImage: "fitness.timer.fill")
            }
        }
    }
}
