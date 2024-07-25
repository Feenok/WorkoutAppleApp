//
//  Exercise.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var category: String
    @Relationship(deleteRule: .cascade) var allSets: [ExerciseSet] = []
    var PRSet: ExerciseSet? // Personal Record set
    
    init(name: String, category: String) {
            self.name = name
            self.category = category
        }
    
}


