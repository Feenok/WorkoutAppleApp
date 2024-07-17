//
//  ExerciseDetails.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/12/24.
//

import SwiftUI
import SwiftData

struct ExerciseDetails: View {
    @StateObject private var vm: ExerciseDetailsViewModel
    @State var selectedDate: Date? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // New exercise info to be added
    @State var newSetDate: Date = Date.now
    @State var newSetWeight: String?
    @State var newSetReps: String?
    
    @State private var insetExpanded = false // Check if inset for adding a set is expanded
    
    var defaultSet = ExerciseSet(weight: 0, reps: 0)
    
    init(exercise: Exercise) {
        _vm = StateObject(wrappedValue: ExerciseDetailsViewModel(exercise: exercise))
    }
    
    var body: some View {
        VStack {
            if !vm.exercise.allSets.isEmpty {
                
                VStack {
                    let padding: CGFloat = -4
                    ExerciseSetView(exerciseSet: vm.exercise.PRSet ?? defaultSet, setType: .greatest)
                    //.opacity(selectedDate == nil ? 1.0 : 0.0)
                    Group {
                        ExerciseChartView(exerciseSets: vm.exercise.allSets, selectedDate: $selectedDate)
                    }
                    .frame(height: 300)
                    .padding(.horizontal, 8)
                    ExerciseSetView(exerciseSet: vm.exercise.allSets.last ?? defaultSet, setType: .latest)
                    Spacer()
                }
                
            }
            else {
                ContentUnavailableView {
                    Label("Add Exercise Set", systemImage: "film.stack")
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
                    withAnimation {
                        insetExpanded.toggle()
                    }
                }) {
                    if !insetExpanded {
                        Label("Open adding set inset", systemImage: "plus")
                    } else {
                        Label("Close adding set inset", systemImage: "plus")
                            .foregroundStyle(.gray)
                            .opacity(0.5)
                    }
                }
            }
             
        }
        .safeAreaInset(edge: .bottom) {
            if insetExpanded {
                var today = Date.now
                VStack(alignment: .center, spacing: 20) {
                    ZStack {
                        Text("Add New Set")
                            .font(.headline)
                        HStack {
                            Spacer()
                            Button("Save") {
                                if let weight = Int(newSetWeight ?? ""),
                                   let reps = Int(newSetReps ?? "") {
                                    let newSet = ExerciseSet(weight: weight, reps: reps, date: newSetDate)
                                    vm.addSet(newSet: newSet)
                                    
                                    newSetWeight = nil
                                    newSetReps = nil
                                    newSetDate = Date.now
                                }
                            }
                            .bold()
                            .disabled(newSetWeight?.isEmpty ?? true || newSetReps?.isEmpty ?? true)
                            .opacity(!(newSetWeight?.isEmpty ?? true) && !(newSetReps?.isEmpty ?? true) ? 1.0 : 0.5)
                        }
                        HStack {
                            Button("Cancel") {
                                withAnimation {
                                    insetExpanded.toggle()
                                }
                            }
                            .foregroundStyle(.red)
                            Spacer()
                        }
                    }
                    DatePicker(selection: $newSetDate, in: ...today, displayedComponents: .date) {
                        HStack {
                            TextField("Weight", text: Binding(
                                get: { self.newSetWeight ?? "" },
                                set: { self.newSetWeight = $0.isEmpty ? nil : $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .onChange(of: newSetWeight) { _, newValue in
                                newSetWeight = newValue?.filter { "0123456789".contains($0) }
                            }
                            TextField("Reps", text: Binding(
                                get: { self.newSetReps ?? "" },
                                set: { self.newSetReps = $0.isEmpty ? nil : $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .onChange(of: newSetReps) { _, newValue in
                                newSetReps = newValue?.filter { "0123456789".contains($0) }
                            }
                        }
                    }
                }
                .padding()
                .background(.bar)
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
