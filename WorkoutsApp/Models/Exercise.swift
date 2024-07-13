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
    
    var exerciseSets: [ExerciseSet] = []
    
    init(name: String, category: String) {
        self.name = name
        self.category = category
    }
    
}
