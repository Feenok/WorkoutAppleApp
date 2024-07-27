//
//  Exercise.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import Foundation
import SwiftData

enum ExerciseCategory: String, CaseIterable, Codable, Identifiable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case traps
    case quads
    case hamstrings
    case glutes
    case calves
    case abs
    case forearms
    case misc
    
    var id: String { self.rawValue }
}

@Model
final class Exercise {
    var name: String
    var category: ExerciseCategory
    var info: String = ""
    
    @Relationship(deleteRule: .cascade) var allSets: [ExerciseSet] = []
    var PRSet: ExerciseSet? // Personal Record set
    
    
    init(name: String, category: ExerciseCategory) {
            self.name = name
            self.category = category
        }
    
}


