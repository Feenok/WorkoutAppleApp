//
//  DailyExerciseAdditionalData.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 8/4/24.
//

import SwiftUI

struct DailyExerciseAdditionalData: View {
    @Environment(\.modelContext) private var modelContext
    @State var exerciseSets: [ExerciseSet]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(MuscleGroups.allCases, id: \.self) { group in
                    if let groupData = groupedExerciseData[group], !groupData.isEmpty {
                        GroupView(group: group, exercises: groupData)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Exercise Data")
    }

    private var groupedExerciseData: [MuscleGroups: [ExerciseData]] {
        Dictionary(grouping: calculateExerciseData()) { $0.muscleGroup }
    }

    private func calculateExerciseData() -> [ExerciseData] {
        let groupedSets = Dictionary(grouping: exerciseSets) { $0.exercise?.name ?? "" }
        
        return groupedSets.map { (name, sets) in
            let totalReps = sets.reduce(0) { $0 + $1.reps }
            let totalWeight = sets.reduce(0) { $0 + ($1.weight * $1.reps) }
            let averageWeight = totalReps > 0 ? Double(totalWeight) / Double(totalReps) : 0
            let muscleGroup = sets.first?.exercise?.muscleGroupTargeted ?? .misc
            
            return ExerciseData(
                name: name,
                muscleGroup: muscleGroup,
                totalReps: totalReps,
                averageWeight: averageWeight,
                volumeLoad: totalWeight
            )
        }
    }
}

struct GroupView: View {
    let group: MuscleGroups
    let exercises: [ExerciseData]
    
    private var groupTitle: String {
            switch group {
            case .upperBodyPull:
                return "Back & Biceps"
            case .upperBodyPush:
                return "Chest & Triceps"
            case .shouldersAndTraps:
                return "Shoulders & Traps"
            case .lowerBody:
                return "Legs"
            case .core:
                return "Core Work"
            case .misc:
                return "Miscellaneous"
            }
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(groupTitle)
                .font(.title2)
                .fontWeight(.bold)
            
           Text("Exercises completed:")
                .font(.headline)
            
            ForEach(exercises, id: \.name) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                
                    VStack {
                        Text("Reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(exercise.totalReps)")
                            //.font(.caption)
                            .bold()
                    }
                    
                    VStack {
                        Text("Avg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(String(format: "%.1f", exercise.averageWeight))")
                            //.font(.caption)
                            .bold() +
                        Text(" lbs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack {
                        Text("Vol")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(exercise.volumeLoad)")
                            //.font(.caption)
                            .bold() +
                        Text(" lbs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                Text("Total:")
                Spacer()
                HStack {
                    Text("Reps: ")
                        .foregroundStyle(.secondary)
                    Text("\(exercises.reduce(0) { $0 + $1.totalReps })")
                        .padding(.trailing)
                }
                //Spacer()
                HStack {
                    Text("Vol: ")
                        .foregroundStyle(.secondary)
                    Text("\(exercises.reduce(0) { $0 + $1.volumeLoad })")
                    Text("lbs")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
            .font(.headline)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
    
}

struct ExerciseData {
    let name: String
    let muscleGroup: MuscleGroups
    let totalReps: Int
    let averageWeight: Double
    let volumeLoad: Int
}
