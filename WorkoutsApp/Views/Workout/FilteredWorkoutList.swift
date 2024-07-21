//
//  FilteredWorkoutList.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import SwiftUI

import SwiftUI

struct FilteredWorkoutList: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationSplitView {
            WorkoutList(workoutFilter: searchText)
                .searchable(text: $searchText)
        } detail: {
            Text("Search workouts")
                .navigationTitle("Workouts")
        }
    }
}
