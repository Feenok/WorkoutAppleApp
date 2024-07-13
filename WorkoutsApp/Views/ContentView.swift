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
                Label("Exercises", systemImage: "film.stack")
                }
        }
    }
}
