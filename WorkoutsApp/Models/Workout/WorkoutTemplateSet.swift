//
//  WorkoutTemplateSet.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/21/24.
//

import Foundation
import SwiftData

@Model
final class WorkoutTemplateSet {
    var name: String
    
    var targetWeight: Int
    var targetReps: Int
    var date: Date = Date.now
    
    init(name: String, targetWeight: Int = 0, targetReps: Int = 0) {
        self.name = name
        self.targetWeight = targetWeight
        self.targetReps = targetReps
    }
    
}
