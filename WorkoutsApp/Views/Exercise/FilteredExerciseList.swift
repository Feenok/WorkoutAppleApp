//
//  FilteredExerciseList.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import SwiftUI

struct FilteredExerciseList: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationSplitView {
            ExerciseList(exerciseFilter: searchText)
                .searchable(text: $searchText)
        } detail: {
            Text("Search exercises")
        }
    }
}

#Preview {
    FilteredExerciseList()
}
