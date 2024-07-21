//
//  ExerciseDetails.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/12/24.
//

import SwiftUI
import SwiftData

struct ExerciseDetails: View {
    @ObservedObject private var vm: ExerciseDetailsViewModel
    @State var selectedDate: Date? = nil
    @State private var displayedDate: Date = Calendar.current.startOfDay(for: Date()) // Date displayed for the daily sets list
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // New exercise info to be added
    @State var newSetDate: Date = Date.now
    @State var newSetWeight: String?
    @State var newSetReps: String?
    
    @State private var showingMoreData = false // Check if showing more set data
    @State private var insetExpanded = false // Check if inset for adding a set is expanded
    
    
    init(exercise: Exercise) {
        _vm = ObservedObject(wrappedValue: ExerciseDetailsViewModel(exercise: exercise))
    }
    
    var body: some View {
        let displayedDateStart = Calendar.current.startOfDay(for: displayedDate)
        
        Group {
            if !vm.exercise.allSets.isEmpty {
                ScrollView {
                    VStack {
                        //Personal best set
                        ExerciseSetView(exerciseSet: vm.exercise.PRSet!, setType: .greatest)
                        
                        //Chart
                        Group {
                            ExerciseChartView(sets: vm.allSetsDictionary, rawSelectedDate: $selectedDate)
                                .onChange(of: selectedDate) { oldValue, newValue in
                                    if let newDate = newValue {
                                        displayedDate = newDate
                                    }
                                }
                        }
                        .frame(height: 300)
                        .padding(.horizontal, 8)
                        
                        //Latest set
                        ExerciseSetView(exerciseSet: vm.exercise.allSets.last!, setType: .latest)
                        
                        //Show more data
                        
                        if showingMoreData {
                            MoreDataView(displayedDate: displayedDate, vm: vm, showingMoreData: $showingMoreData)
                        } else {
                            Button(action: {
                                withAnimation {
                                    showingMoreData = true
                                }
                            }) {
                                Text("Show More Exercise Data")
                                    .foregroundStyle(vm.allSetsDictionary[displayedDateStart] != nil ? .blue : .gray.opacity(0))
                            }
                            .disabled(vm.allSetsDictionary[displayedDateStart] == nil)
                        }
                        
                        //Daily Set list
                        SetsByDateDetailsView(displayedDate: displayedDate, vm: vm)
                    }
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        insetExpanded.toggle()
                    }
                }) {
                    Text("Add Set")
                        .foregroundStyle(insetExpanded ? .gray : .blue)
                        .opacity(insetExpanded ? 0.5 : 1.0)
                }
                .disabled(insetExpanded)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if insetExpanded {
                let today = Date.now
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
    
    enum SetStanding {
        case latest
        case greatest
    }
    
    var exerciseSet: ExerciseSet
    var setType: SetStanding
    let padding: CGFloat = -4
    
    var body: some View {
        Group {
            HStack {
                Text(setType == .latest ? "Latest:" : "Record:")
                    .padding(.trailing, -4)
                Text("\(exerciseSet.date, format: .dateTime.year().month().day())")
                    .fontWeight(.semibold)
                    .padding(.vertical, padding)
                Spacer()
                VStack {
                    HStack {
                        Text("\(exerciseSet.weight)")
                            .fontWeight(.semibold)
                            .padding(.vertical, padding)
                            .padding(.trailing, -5)
                        Text("LBS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                            .padding(.vertical, padding)
                            .padding(.top, 3)
                    }
                    HStack {
                        Text("\(exerciseSet.reps)")
                            .fontWeight(.semibold)
                            .padding(.vertical, padding)
                            .padding(.trailing, -5)
                        Text("REPS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                            .padding(.vertical, padding)
                            .padding(.top, 3)
                    }
                }
            }
            .padding(6)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.gray.opacity(0.12))
            }
        }
        .padding(16)
    }
}

struct MoreDataView: View {
    
    var displayedDate: Date
    var vm: ExerciseDetailsViewModel
    @Binding var showingMoreData: Bool
    
    var body: some View {
        
        let dayStart = Calendar.current.startOfDay(for: displayedDate)
        
        let totalWeight: Int = vm.allSetsDictionary[dayStart]!.reduce(0) { sum, set in
            sum + (set.weight * set.reps)
        }
        let totalReps: Int = vm.allSetsDictionary[dayStart]!.reduce(0) { sum, set in
            sum + set.reps
        }
        let averageRepWeight: Int = (totalWeight/totalReps)
        let volumeLoad: Int = totalWeight
        
        VStack (alignment: .leading) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.blue)
                    .padding(.trailing, -5)
                Text("Weight & Reps")
                    .foregroundStyle(.blue)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            Group {
                Text("You've completed a total of ") +
                Text("\(totalReps)").bold() +
                Text(" reps with an average weight of ") +
                Text("\(averageRepWeight)").bold() +
                Text(" lbs.")
            }
            .padding()
            
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.blue)
                    .padding(.trailing, -5)
                Text("Volume Load")
                    .foregroundStyle(.blue)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            Group {
                Text("You've lifted a volume load of ") +
                Text("\(volumeLoad)").bold() +
                Text(" lbs.")
            }
            .padding()
            
            Button(action: {
                withAnimation {
                    showingMoreData = false
                }
            }, label: {
                Text("Collapse Additional Data")
                    .foregroundStyle(.red)
            })
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
}


struct SetsByDateDetailsView: View {
    var displayedDate: Date
    var vm: ExerciseDetailsViewModel
    let padding: CGFloat = -4

    var body: some View {
        VStack {
            Text("\(displayedDate, format: .dateTime.year().month().day()) - Sets")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.vertical, 8)

            let dayStart = Calendar.current.startOfDay(for: displayedDate)
            if let sets = vm.allSetsDictionary[dayStart] {
                if sets.isEmpty {
                    Text("No sets")
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(sets.enumerated()), id: \.element) { index, set in
                            SetDetailRow(set: set, index: index)
                                
                        }
                    }
                    .padding(.horizontal, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                }
            } else {
                Text("No sets for this date")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .cornerRadius(10)
    }
}

struct SetDetailRow: View {
    let set: ExerciseSet
    let index: Int
    
    let padding: CGFloat = 8
    
    var body: some View {
        VStack {
            HStack {
                Text("SET:")
                    .foregroundStyle(.gray)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                    .padding(.trailing, -5)
                Text("\(index+1)")
                    .foregroundStyle(.primary)
                Spacer()
                HStack {
                    Text("\(set.weight)")
                        .fontWeight(.semibold)
                        .padding(.trailing, -5)
                    Text("LBS")
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                }
                HStack {
                    Text("\(set.reps)")
                        .fontWeight(.semibold)
                        .padding(.trailing, -5)
                    Text("REPS")
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                }
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.1))
        }
        .padding(.top, 8)
    }
}
