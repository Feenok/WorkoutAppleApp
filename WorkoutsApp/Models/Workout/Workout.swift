//
//  Workout.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import Foundation
import SwiftData

@Model
final class Workout {
    var name: String = ""
    var category: String = ""
    var bestTimeMinutes: Int?
    var bestTimeSeconds: Int?
    var info: String = ""
    
    @Relationship(deleteRule: .cascade) var templateSets: [WorkoutTemplateSet]? = []
    
    
    init(name: String, category: String, bestTimeMinutes: Int? = nil, bestTimeSeconds: Int? = nil) {
        self.name = name
        self.category = category
        self.bestTimeMinutes = bestTimeMinutes
        self.bestTimeSeconds = bestTimeSeconds
    }
    
}
