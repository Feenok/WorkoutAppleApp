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
                    let padding: CGFloat = -4
                    ExerciseSetView(exerciseSet: vm.highestWeightSet!, setType: .greatest)
                    /*
                    VStack {
                        if vm.highestWeightSet != nil {
                            Text("PERSONAL BEST")
                                .foregroundStyle(.gray)
                                .fontWeight(.semibold)
                                .padding(.vertical, padding)
                            HStack {
                                Text("\(vm.highestWeightSet!.weight)")
                                    .fontWeight(.bold)
                                    .font(.callout)
                                    .padding(.vertical, padding)
                                Text("LBS")
                                    .foregroundStyle(.gray)
                                    .padding(.vertical, padding)
                            }
                            HStack {
                                Text("\(vm.highestWeightSet!.reps)")
                                    .fontWeight(.bold)
                                    .padding(.vertical, padding)
                                Text("REPS")
                                    .foregroundStyle(.gray)
                                    .padding(.vertical, padding)
                            }
                            Text("\(vm.highestWeightSet!.date, format: .dateTime.year().month().day())")
                                .foregroundStyle(.gray)
                                .padding(.vertical, padding)
                        }
                    }
                 */
                    //.opacity(selectedDate == nil ? 1.0 : 0.0)
                    Group {
                        ExerciseChartView(exerciseSets: vm.exercise.exerciseSets, selectedDate: $selectedDate)
                    }
                    .padding(.horizontal, 8)
                    
                    if vm.latestExerciseSet != nil {
                        ExerciseSetView(exerciseSet: vm.latestExerciseSet!, setType: .latest)
                    }
                    
                    /*
                     List {
                     ForEach(vm.exercise.exerciseSets) { exerciseSet in
                     VStack(alignment: .leading) {
                     Text("\(exerciseSet.date)").fontWeight(.bold)
                     Text("Weight:  \(exerciseSet.weight)")
                     Text("Reps:  \(exerciseSet.reps)")
                     }
                     }
                     }
                     */
                    
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

struct ExerciseSetView: View {
    
    enum setStanding {
        case latest
        case greatest
    }
    
    var exerciseSet: ExerciseSet
    var setType: setStanding
    let padding: CGFloat = -4
    
    var body: some View {
        Group {
            HStack {
                Text(setType == .latest ? "Latest" : "PR")
                Text("\(exerciseSet.date, format: .dateTime.year().month().day())")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .padding(.vertical, padding)
                Spacer()
                VStack {
                    HStack {
                        Text("\(exerciseSet.weight)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.vertical, padding)
                        Text("LBS")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.vertical, padding)
                    }
                    HStack {
                        Text("\(exerciseSet.reps)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.vertical, padding)
                        Text("REPS")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.vertical, padding)
                    }
                }
            }
            .padding(6)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.gray.opacity(0.12))
            }
        }
        .padding(.horizontal, 16)
    }
}
