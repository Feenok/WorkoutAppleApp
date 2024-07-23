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
            FilteredWorkoutList()
                .tabItem {
                    Label("Workouts", systemImage: "list.bullet.circle.fill")
                }
            StopwatchView()
                .tabItem {
                    Label("Stopwatch", systemImage: "fitness.timer.fill")
                }
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial) // Customize the blur effect style
            
            // Apply the appearance to the tabBar
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
