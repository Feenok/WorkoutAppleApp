//
//  ExerciseDetails.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/12/24.
//

import SwiftUI

struct ExerciseDetails: View {
    @StateObject private var vm: ExerciseDetailsViewModel
    @State var selectedDate: Date? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(exercise: Exercise) {
        _vm = StateObject(wrappedValue: ExerciseDetailsViewModel(exercise: exercise))
    }
    
    var body: some View {
        VStack {
            if !vm.exercise.exerciseSets.isEmpty {
                
                    VStack {
                        
                        Group {
                            if vm.highestWeightSet != nil {
                                Text("Personal Best").fontWeight(.bold)
                                Text("On: \(vm.highestWeightSet!.date, style: .date)")
                                Text("Weight: \(vm.highestWeightSet!.weight) lbs")
                                Text("For: \(vm.highestWeightSet!.reps) reps")
                            }
                        }
                        //.opacity(selectedDate == nil ? 1.0 : 0.0)
                        
                        
                        
                        ExerciseChartView(exerciseSets: vm.exercise.exerciseSets, selectedDate: $selectedDate)
                        
                        
                        List {
                            ForEach(vm.exercise.exerciseSets) { exerciseSet in
                                VStack(alignment: .leading) {
                                    Text("\(exerciseSet.date)").fontWeight(.bold)
                                    Text("Weight:  \(exerciseSet.weight)")
                                    Text("Reps:  \(exerciseSet.reps)")
                                }
                            }
                        }
                        
                    }
                
            }
            else {
                ContentUnavailableView {
                    Label("Add set", systemImage: "film.stack")
                }
            }
        }
        .navigationTitle(vm.exercise.name)
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    vm.addExerciseSet()
                }) {
                    Label("Add Exercise", systemImage: "plus")
                }
            }
        }
        .sheet(item: $vm.newExerciseSet) { exerciseSet in
            NavigationStack {
                AddExerciseSet(exercise: vm.exercise, exerciseSet: exerciseSet)
            }
            .interactiveDismissDisabled()
            .onDisappear {
                vm.updateHighestWeightSet()
            }
        }
    }
}

