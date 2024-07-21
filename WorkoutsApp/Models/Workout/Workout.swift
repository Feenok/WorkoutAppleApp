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
    var name: String
    var category: String
    
    @Relationship(deleteRule: .cascade) var templateSets: [WorkoutTemplateSet] = []
    
    init(name: String, category: String) {
            self.name = name
            self.category = category
        }
    
}
