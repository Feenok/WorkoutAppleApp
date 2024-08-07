//
//  Exercise.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

import Foundation
import SwiftData
import CloudKit

enum ExerciseCategory: String, CaseIterable, Codable, Identifiable {
    case chest
    case upperBack
    case lowerBack
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

enum MuscleGroups: String, CaseIterable, Codable, Identifiable {
    case upperBodyPull // back, biceps
    case upperBodyPush // chest, triceps
    case shouldersAndTraps // shoulders, traps
    case lowerBody // quads, hamstrings, glutes, calves
    case core // abs, lowerback
    case misc // forearms, misc
    
    var id: String { self.rawValue }
}

@Model
final class Exercise {
    var name: String = ""
    var category: ExerciseCategory = ExerciseCategory.misc
    var info: String = ""
    @Relationship(deleteRule: .cascade) var allSets: [ExerciseSet]? = []
    var PRSet: ExerciseSet? // Personal Weight Record set
    
    var maxVolumeLoadDate: Date = Date()
    var maxVolumeLoad: Int = 0
    
    var maxRepDate: Date = Date()
    var maxRepCount: Int = 0
    
    init(name: String, category: ExerciseCategory) {
        self.name = name
        self.category = category
    }
    
    var muscleGroupTargeted: MuscleGroups {
            switch self.category {
            case .chest, .triceps:
                return .upperBodyPush
            case .upperBack, .biceps:
                return .upperBodyPull
            case .shoulders, .traps:
                return .shouldersAndTraps
            case .quads, .hamstrings, .glutes, .calves:
                return .lowerBody
            case .abs, .lowerBack:
                return .core
            case .forearms, .misc:
                return .misc
            }
        }
    
    func updatePRSet() { //TODO:Can make more efficient
        PRSet = allSets!.max { a, b in
            if a.weight != b.weight {
                return a.weight < b.weight
            }
            if a.reps != b.reps {
                return a.reps < b.reps
            }
            // If weight and reps are equal, compare duration
            switch (a.duration, b.duration) {
            case (let durationA?, let durationB?):
                return durationA < durationB
            case (nil, .some):
                return true  // b is greater because it has a duration and a doesn't
            case (.some, nil):
                return false // a is greater because it has a duration and b doesn't
            case (nil, nil):
                return false // They're equal if both have no duration
            }
        }
    }
    
    func addSet(_ set: ExerciseSet) {
        
        // Find the correct position to insert the new set
        let insertIndex = allSets.lastIndex(where: { $0.date <= set.date }) ?? -1
        let insertPosition = insertIndex + 1
        
        // Update SwiftData array
        allSets.insert(set, at: insertPosition)
        
        updatePRSet()
        updateMaxVolumeLoad()
    }
    
    func removeSet(_ set: ExerciseSet) {
        // Remove from allSets
        if let index = allSets.firstIndex(where: { $0.id == set.id }) {
            allSets.remove(at: index)
        }
        
        updatePRSet()
        updateMaxVolumeLoad()
    }
    
    // Gets max volume load in one day
    func updateMaxVolumeLoad() {
        guard !allSets.isEmpty else {
            maxVolumeLoad = 0
            maxVolumeLoadDate = Date()
            return
        }
        
        let groupedSets = Dictionary(grouping: allSets) { Calendar.current.startOfDay(for: $0.date) }
        let dailyVolumes = groupedSets.mapValues { sets in
            sets.reduce(0) { $0 + ($1.weight * $1.reps) }
        }
        
        if let maxDay = dailyVolumes.max(by: { $0.value < $1.value }) {
            maxVolumeLoad = maxDay.value
            maxVolumeLoadDate = maxDay.key
        }
    }
    
    // Gets max reps done in one day
    func updateMaxRepCount() {
        guard !allSets.isEmpty else {
            maxRepCount = 0
            maxRepDate = Date()
            return
        }
        
        let groupedSets = Dictionary(grouping: allSets) { Calendar.current.startOfDay(for: $0.date) }
        let dailyReps = groupedSets.mapValues { sets in
            sets.reduce(0) { $0 + ($1.reps) }
        }
        
        if let maxDay = dailyReps.max(by: { $0.value < $1.value }) {
            maxRepCount = maxDay.value
            maxRepDate = maxDay.key
        }
    }
    
//TODO: May need to make storing/getting/updating the pr set, max rep, max volume load set more efficient. Which includes making the Exercise/ExerciseSet classes more efficient and include sorting by date
    
}


