//
//  Views.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/25/24.
//
/*
 
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView  {
            FilteredExerciseList()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
            FilteredWorkoutList()
                .tabItem {
                    Label("Workouts", systemImage: "list.bullet.circle.fill")
                }
            NavigationStack {
                DailyExerciseView()
            }
            .tabItem {
                Label("Daily Workout", systemImage: "figure.strengthtraining.traditional")
            }
            NavigationStack {
                StopwatchView()
            }
            
            .tabItem {
                Label("Stopwatch", systemImage: "fitness.timer.fill")
            }
        }
    }
}
 
 import SwiftUI

 struct FilteredExerciseList: View {
     @State private var searchText = ""
     
     var body: some View {
         NavigationSplitView {
             ExerciseList(exerciseFilter: searchText)
                 .searchable(text: $searchText)
         } detail: {
             Text("Search exercises")
                 .navigationTitle("Exercises")
         }
     }
 }

 #Preview {
     FilteredExerciseList()
 }

 import SwiftUI
 import SwiftData

 struct ExerciseList: View {
     @Environment(\.modelContext) private var modelContext
     @Query private var exercises: [Exercise]
     
     @State private var newExercise: Exercise?
     @State private var exerciseToEdit: Exercise?
     
     init(exerciseFilter: String = "") {
         let predicate = #Predicate<Exercise> { exercise in
             exerciseFilter.isEmpty || exercise.name.localizedStandardContains(exerciseFilter)
         }
         
         _exercises = Query(filter: predicate, sort: \Exercise.name)
     }

     var body: some View {
         Group {
             if !exercises.isEmpty {
                 List {
                     ForEach(exercises) { exercise in
                         ExerciseRow(
                             exercise: exercise,
                             onLongPress: {
                                 exerciseToEdit = exercise
                             }
                         )
                     }
                     .onDelete(perform: deleteExercises)
                 }
             } else {
                 ContentUnavailableView {
                     Label("Add Exercise", systemImage: "film.stack")
                 }
             }
         }
         .navigationTitle("Exercises")
         .toolbar {
             ToolbarItem {
                 Button(action: addExercise) {
                     Text("Add Exercise")
                         .foregroundStyle(.blue)
                 }
             }
         }
         .sheet(item: $newExercise) { exercise in
             NavigationStack {
                 EnterExercise(exercise: exercise)
             }
             .interactiveDismissDisabled()
         }
         .sheet(item: $exerciseToEdit) { exercise in
             NavigationStack {
                 EditExercise(exercise: exercise)
             }
             .interactiveDismissDisabled()
         }
     }

     private func addExercise() {
         withAnimation {
             let newItem = Exercise(name: "", category: "")
             modelContext.insert(newItem)
             newExercise = newItem
         }
     }

     private func deleteExercises(offsets: IndexSet) {
         withAnimation {
             for index in offsets {
                 modelContext.delete(exercises[index])
             }
         }
     }
     
 }


 struct ExerciseRow: View {
     let exercise: Exercise
     let onLongPress: () -> Void
     
     @State private var isPressed = false
     @GestureState private var longPress = false
     
     var body: some View {
         NavigationLink(destination: ExerciseDetails(exercise: exercise)) {
             Text(exercise.name)
         }
         .simultaneousGesture(
             LongPressGesture(minimumDuration: 0.5)
                 .updating($longPress) { currentState, gestureState, _ in
                     gestureState = currentState
                 }
                 .onEnded { _ in
                     onLongPress()
                 }
         )
         .scaleEffect(longPress ? 0.95 : 1.0)
         .animation(.easeInOut(duration: 0.2), value: longPress)
     }
 }

 
 import SwiftUI

 struct EnterExercise: View {
     
     @Bindable var exercise: Exercise
     
     @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var modelContext
     
     init(exercise : Exercise) {
         self.exercise = exercise
     }
     
     var body: some View {
         Form {
             TextField("Exercise name", text: $exercise.name)
         }
         .navigationTitle("Add Exercise")
         .toolbar{
             ToolbarItem(placement: .confirmationAction) {
                 Button("Done") {
                     dismiss()
                 }
             }
             ToolbarItem(placement: .cancellationAction) {
                 Button("Cancel") {
                     modelContext.delete(exercise)
                     dismiss()
                 }
             }
         }
     }
     
 }
 
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
     @State private var newSetWeight: String?
     @State private var newSetReps: String?
     @State private var minutes: String?
     @State private var seconds: String?
     
     @State private var showingMoreData = false // Check if showing more set data
     @State private var insetExpanded = false // Check if inset for adding a set is expanded
     @State private var timedExercise = false // Check if exercise has a duration
     
     
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
                         ExerciseSetView(exerciseSet: vm.findLatestSet()!, setType: .latest)
                         
                         //Show more data
                         
                         if showingMoreData && vm.allSetsDictionary[displayedDateStart] != nil && !vm.allSetsDictionary[displayedDateStart]!.isEmpty {
                             MoreDataView(displayedDate: displayedDate, vm: vm, timedExercise: timedExercise, showingMoreData: $showingMoreData)
                         } else {
                             Button(action: {
                                 withAnimation {
                                     showingMoreData = true
                                 }
                             }) {
                                 Text(vm.allSetsDictionary[displayedDateStart] != nil ? "Show More Exercise Data" : "No Exercise Data")
                                     .foregroundStyle(vm.allSetsDictionary[displayedDateStart] != nil ? .blue : .gray)
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
                 AddNewSetView(
                     vm: vm,
                     insetExpanded: $insetExpanded,
                     newSetWeight: $newSetWeight,
                     newSetReps: $newSetReps,
                     newSetDate: $newSetDate,
                     minutes: $minutes,
                     seconds: $seconds,
                     timedExercise: $timedExercise
                 )
             }
         }
     }
 }

 struct AddNewSetView: View {
     @ObservedObject var vm: ExerciseDetailsViewModel
     @Binding var insetExpanded: Bool
     @Binding var newSetWeight: String?
     @Binding var newSetReps: String?
     @Binding var newSetDate: Date
     @Binding var minutes: String?
     @Binding var seconds: String?
     @Binding var timedExercise: Bool
     
     var body: some View {
         let today = Date.now
         VStack(alignment: .center, spacing: 20) {
             ZStack {
                 Text("Add New Set")
                     .font(.headline)
                 HStack {
                     Spacer()
                     Button(action: {
                         if let weight = Int(newSetWeight ?? ""),
                            let reps = Int(newSetReps ?? "")
                         {
                             if Calendar.current.isDateInToday(newSetDate) {
                                 newSetDate = today
                             }
                             
                             let newSet = ExerciseSet(weight: weight, reps: reps, date: newSetDate)
                             
                             // Add duration data if timed
                             if timedExercise {
                                 let minutesInt = Int(minutes ?? "") ?? 0
                                 let secondsInt = Int(seconds ?? "") ?? 0
                                 if let duration = vm.getDuration(minutes: minutesInt, seconds: secondsInt) {
                                     newSet.duration = duration
                                 }
                             }
                             
                             vm.addSet(newSet: newSet)
                             
                             // Reset new set data
                             newSetWeight = nil
                             newSetReps = nil
                             minutes = nil
                             seconds = nil
                             newSetDate = Date.now
                         }
                     }) {
                         Text("Save")
                     }
                     .disabled(newSetWeight?.isEmpty ?? true || newSetReps?.isEmpty ?? true || timedExercise && minutes?.isEmpty ?? true && seconds?.isEmpty ?? true)
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
             Button("Timed Exercise") {
                 //Add duration of exercise
                     timedExercise.toggle()
             }
             .foregroundStyle(timedExercise ? .red : .blue)
             .frame(maxWidth: .infinity, alignment: .center)
             
             if timedExercise {
                 withAnimation{
                     SetDurationInputView(minutes: $minutes, seconds: $seconds)
                 }
             }
             
         }
         .padding()
         .background(.bar)
     }
     
 }

 struct SetDurationInputView: View {
     @Binding var minutes: String?
     @Binding var seconds: String?
     
     var body: some View {
         HStack {
             TextField("Min", text: Binding(
                 get: { self.minutes ?? "" },
                 set: { self.minutes = $0.isEmpty ? nil : $0 }
             ))
                 .keyboardType(.numberPad)
                 .frame(width: 100)
                 .onChange(of: minutes) { _, newValue in
                     minutes = newValue?.filter { "0123456789".contains($0) }
                 }
             Text(":")
             TextField("Sec", text: Binding(
                 get: { self.seconds ?? "" },
                 set: { self.seconds = $0.isEmpty ? nil : $0 }
             ))
                 .keyboardType(.numberPad)
                 .frame(width: 100)
                 .onChange(of: seconds) { _, newValue in
                     seconds = newValue?.filter { "0123456789".contains($0) }
                 }
         }
         .textFieldStyle(RoundedBorderTextFieldStyle())
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
                 RoundedRectangle(cornerRadius: 8)
                     .foregroundStyle(Color.gray.opacity(0.12))
             }
         }
         .padding(16)
     }
 }

 struct MoreDataView: View {
     
     var displayedDate: Date
     var vm: ExerciseDetailsViewModel
     var timedExercise: Bool
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
         
         let totalDuration: TimeInterval = vm.allSetsDictionary[dayStart]!.reduce(0) { sum, set in
             sum + (set.duration ?? 0)
         }
         
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
             
             if totalDuration > 0 {
                 HStack {
                     Image(systemName: "stopwatch.fill")
                         .foregroundStyle(.blue)
                         .padding(.trailing, -5)
                     Text("Stopwatch")
                         .foregroundStyle(.blue)
                         .fontWeight(.bold)
                 }
                 .padding(.horizontal)
                 
                 Group {
                     let (minutes, seconds) = vm.secondsToMinutesAndSeconds(Int(totalDuration))
                     if minutes > 0 {
                         if seconds > 0 {
                         Text("The total duration of today's sets is ") +
                         Text("\(minutes)").bold() +
                         Text(" minutes and ") +
                         Text("\(seconds)").bold() +
                         Text(" seconds.")
                         } else {
                             Text("The total duration of today's sets is ") +
                             Text("\(minutes)").bold() +
                             Text(" minutes.")
                         }
                     } else {
                         Text("The total duration of today's sets is ") +
                         Text("\(seconds)").bold() +
                         Text(" seconds.")
                     }
                 }
                 .padding()
             }
             
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
     @ObservedObject var vm: ExerciseDetailsViewModel
     
     @State private var setDeletionEnabled: Bool = false
     @State private var setToDelete: (set: ExerciseSet, index: Int)?
     
     let padding: CGFloat = -4
     
     private var hasSetsForDate: Bool {
             let dayStart = Calendar.current.startOfDay(for: displayedDate)
             return !(vm.allSetsDictionary[dayStart]?.isEmpty ?? true)
         }

     var body: some View {
         VStack {
             HStack {
                 Text("\(displayedDate, format: .dateTime.year().month().day()) - Sets")
                     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                     .font(.title3)
                     .fontWeight(.bold)
                     .padding(.vertical, 8)
                 
                 if hasSetsForDate {
                     Button(action: {
                         setDeletionEnabled.toggle()
                     }, label: {
                         Text(setDeletionEnabled ? "Cancel" : "Delete Set")
                             .foregroundStyle(.red)
                     })
                 }
             }

             let dayStart = Calendar.current.startOfDay(for: displayedDate)
             if let sets = vm.allSetsDictionary[dayStart], !sets.isEmpty {
                 
                 let sortedSets = sets.sorted { $0.date < $1.date }
                 
                 VStack(spacing: 0) {
                     ForEach(Array(sortedSets.enumerated()), id: \.element) { index, set in
                         SetDetailRow(vm: vm, set: set, index: index, onDelete: {setToDelete = (set: set, index: index + 1)}, deletionEnabled: setDeletionEnabled)
                     }
                 }
                 .padding(.horizontal, 4)
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(4)
             } else {
                 Text("No sets for this date")
                     .foregroundColor(.secondary)
             }
         }
         .padding(.horizontal)
         .cornerRadius(10)
         .alert("Confirm Deletion", isPresented: Binding(
             get: { setToDelete != nil },
             set: { if !$0 { setToDelete = nil } }
         )) {
             Button("Cancel", role: .cancel) { setToDelete = nil }
             Button("Delete", role: .destructive) {
                 if let setInfo = setToDelete {
                     vm.deleteSet(setInfo.set)
                     setToDelete = nil
                 }
             }
         } message: {
             if let setInfo = setToDelete {
                 Text("Are you sure you want to delete set \(setInfo.index)?")
             }
         }
     }
 }

 struct SetDetailRow: View {
     let vm: ExerciseDetailsViewModel
     let set: ExerciseSet
     let index: Int
     let onDelete: () -> Void
     let deletionEnabled: Bool
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
                 
                 //Add duration if available
                 durationView
                 
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
                 
                 if deletionEnabled {
                     Button(action: onDelete) {
                         Image(systemName: "trash")
                             .foregroundColor(.red)
                     }
                 }
                 
             }
             Rectangle()
                 .frame(height: 1)
                 .foregroundColor(.gray.opacity(0.1))
         }
         .padding(.top, 8)
     }
     
     @ViewBuilder
     private var durationView: some View {
         if let duration = set.duration {
             let (minutes, seconds) = vm.secondsToMinutesAndSeconds(Int(duration))
             HStack {
                 Image(systemName: "stopwatch.fill")
                     .foregroundStyle(.gray)
                     .font(.caption)
                     .padding(.trailing, -5)
                 DurationView(minutes: minutes, seconds: seconds)
             }
         }
     }
     
 }

 struct DurationView: View {
     let minutes: Int
     let seconds: Int
     
     var body: some View {
         Group {
             if minutes > 0 {
                 if seconds > 0 {
                     Text("\(minutes)").bold() +
                     Text(" min ") +
                     Text("\(seconds)").bold() +
                     Text(" sec")
                 } else {
                     Text("\(minutes)").bold() +
                     Text(" min")
                 }
             } else {
                 Text("\(seconds)").bold() +
                 Text(" sec")
             }
         }
         .foregroundStyle(.gray)
         .font(.caption)
     }
 }
 
 import Charts
 import SwiftUI

 struct ExerciseChartView: View {
     
     var sets: [Date:[ExerciseSet]]
     @Environment(\.calendar) var calendar
     @Binding var rawSelectedDate: Date?
     
     func endOfDay(for date: Date) -> Date {
         calendar.date(byAdding: .day, value: 1, to: date)!
     }
     
     var selectedDate: Date? {
         if let rawSelectedDate {
             return sets.keys.first(where: { date in
                 let endOfDay = endOfDay(for: date)
                 return (date ... endOfDay).contains(rawSelectedDate)
             })
         }
         return nil
     }
     
     var selectedDateMaxWeightDetails: (weight: Int, reps: Int)? {
         guard let selectedDate = selectedDate,
               let setsForDate = sets[selectedDate] else {
             return nil
         }
         
         return setsForDate.max(by: { $0.weight < $1.weight })
             .map { ($0.weight, $0.reps) }
     }
     
     var body: some View {
         let maxWeight = sets.values.flatMap { $0 }.max(by: { $0.weight < $1.weight })?.weight ?? 0
         let yAxisMax = Double(maxWeight) * 1.3
         let mostRecentDate = sets.keys.max() ?? Date()
         
         Chart {
             ForEach(Array(sets.keys), id: \.self) { date in
                 if let maxSet = sets[date]?.max(by: { $0.weight < $1.weight }) {
                     BarMark(
                         x: .value("Date", date, unit: .day),
                         y: .value("Weight", maxSet.weight)
                     )
                 }
             }
             .foregroundStyle(.blue)
             
             if let selectedDate {
                 RuleMark(
                     x: .value("Selected", selectedDate, unit: .day)
                 )
                 .foregroundStyle(Color.red.opacity(0.3))
                 .offset(yStart: -10)
                 .zIndex(1)
                 .annotation(
                     position: .top,
                     alignment: sets.count < 9 ? .trailing : .leading,
                     spacing: 0,
                     overflowResolution: .init(
                         x: .fit(to: .automatic),
                         y: .fit(to: .chart)
                     )
                 ) {
                     valueSelectionPopover
                 }
             }
         }
         .chartXSelection(value: $rawSelectedDate)
         .padding(8)
         .chartScrollableAxes(.horizontal)
         .chartXVisibleDomain(length: 3600 * 24 * 21)
         .chartScrollPosition(initialX: Calendar.current.date(byAdding: .day, value: -19, to: Date()) ?? Date())
         .chartScrollTargetBehavior(
             .valueAligned(
                 matching: DateComponents(hour: 0),
                 majorAlignment: .matching(DateComponents(day: 1))))
         .chartXAxis {
             AxisMarks(values: .stride(by: .month, count: 1)) {
                 AxisTick()
                 AxisGridLine()
                 AxisValueLabel(format: .dateTime.month(), collisionResolution: AxisValueLabelCollisionResolution.disabled)
                     .offset(y: 12)
             }
             AxisMarks(values: .stride(by: .day, count: 7)) {
                 AxisTick()
                 AxisGridLine()
                 AxisValueLabel(format: .dateTime.day())
             }
         }
         .chartYScale(domain: 0...yAxisMax)
         .chartYAxis {
             AxisMarks(position: .leading)
         }
     }
     
     @ViewBuilder
     var valueSelectionPopover: some View {
         let padding: CGFloat = -4
         if let details = selectedDateMaxWeightDetails, let date = selectedDate {
             VStack(alignment: .leading) {
                 Text("MAX WEIGHT").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
                 HStack{
                     HStack(alignment: .bottom) {
                         Text("\(details.weight)").font(.title3).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                         Text("LBS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                     }
                     HStack(alignment: .bottom) {
                         Text("\(details.reps)").font(.title3).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                         Text("REPS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                     }
                 }
                 Text("\(date, format: .dateTime.year().month().day())").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
             }
             .padding(6)
             .background {
                 RoundedRectangle(cornerRadius: 4)
                 .foregroundStyle(Color.gray.opacity(0.12))
             }
         } else {
             if let date = selectedDate {
                 VStack {
                     Text("\(date, format: .dateTime.year().month().day())").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
                     Text("No data available").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
                 }
                 .padding(6)
                 .background {
                     RoundedRectangle(cornerRadius: 4)
                         .foregroundStyle(Color.gray.opacity(0.12))
                 }
             }
         }
     }
     
 }
 
 
 import SwiftUI

 struct EditExercise: View {
     @Bindable var exercise: Exercise
     
     @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var modelContext
     
     @State private var editedName: String
     //@State private var editedCategory: String
     
     init(exercise : Exercise) {
         self.exercise = exercise
         _editedName = State(initialValue: exercise.name)
     }
     
     var body: some View {
         Form {
             TextField("Edit exercise name", text: $editedName)
         }
         .navigationTitle("Edit Exercise")
         .toolbar{
             ToolbarItem(placement: .confirmationAction) {
                 Button("Save") {
                     exercise.name = editedName
                     dismiss()
                 }
             }
             ToolbarItem(placement: .cancellationAction) {
                 Button("Cancel") {
                     dismiss()
                 }
             }
         }
     }
     
 }
 
 import SwiftUI

 struct FilteredWorkoutList: View {
     @State private var searchText = ""
     
     var body: some View {
         NavigationStack {
             WorkoutList(workoutFilter: searchText)
                 .searchable(text: $searchText)
         }
     }
 }
 
 import SwiftUI
 import SwiftData

 struct WorkoutList: View {
     @Environment(\.modelContext) private var modelContext
     @Query private var workouts: [Workout]
     
     @State private var newWorkout: Workout?
     
     init(workoutFilter: String = "") {
         let predicate = #Predicate<Workout> { workout in
             workoutFilter.isEmpty || workout.name.localizedStandardContains(workoutFilter)
         }
         
         _workouts = Query(filter: predicate, sort: \Workout.name)
     }

     var body: some View {
         Group {
             if !workouts.isEmpty {
                 List {
                     ForEach(workouts) { workout in
                         NavigationLink {
                             WorkoutDetails(workout: workout)
                         } label: {
                             Text(workout.name)
                         }
                     }
                     .onDelete(perform: deleteWorkouts)
                 }
             } else {
                 ContentUnavailableView {
                     Label("Add Workout", systemImage: "film.stack")
                 }
             }
         }
         .navigationTitle("Workouts")
         .toolbar {
             ToolbarItem {
                 Button(action: addWorkout) {
                     Text("Add Workout")
                         .foregroundStyle(.blue)
                 }
             }
         }
         .sheet(item: $newWorkout) { workout in
             NavigationStack {
                 EnterWorkout(workout: workout)
             }
             .interactiveDismissDisabled()
         }
     }

     private func addWorkout() {
         withAnimation {
             let newItem = Workout(name: "", category: "")
             modelContext.insert(newItem)
             newWorkout = newItem
         }
     }

     private func deleteWorkouts(offsets: IndexSet) {
         withAnimation {
             for index in offsets {
                 modelContext.delete(workouts[index])
             }
         }
     }
 }
 
 import SwiftUI
 import SwiftData

 struct WorkoutDetails: View {
     @Bindable var workout: Workout
     @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var modelContext
     
     @State private var newWorkoutTemplateSet: WorkoutTemplateSet?
     @State private var isEditing: Bool = false
     @State private var showingAlert = false
     
     var sortedSets: [WorkoutTemplateSet] {
         workout.templateSets.sorted { $0.date < $1.date }
     }
     
     private var editButton: some View {
         Button(isEditing ? "Done" : "Edit") {
             withAnimation {
                 isEditing.toggle()
             }
         }
     }
     
     var body: some View {
         Group {
             if !workout.templateSets.isEmpty {
                 workoutList
             } else {
                 ContentUnavailableView {
                     Button(action: addWorkoutSet) {
                         Text("Add Set")
                             .foregroundStyle(.blue)
                     }
                 }
             }
         }
         .navigationTitle("Workout Plan")
         .navigationBarItems(trailing: editButton)
         .sheet(item: $newWorkoutTemplateSet) { set in
             NavigationStack {
                 EnterWorkoutSet(workout: workout, newWorkoutTemplateSet: set)
             }
             .interactiveDismissDisabled()
         }
         .alert("Track Workout", isPresented: $showingAlert) {
             Button("Cancel", role: .cancel) { }
             Button("Confirm") {
                 DataManager.shared.addWorkoutSetsToExercises(workout: workout, modelContext: modelContext)
             }
         } message: {
             Text("Are you sure you want to add these sets to your exercises?")
         }
     }
     
     private func addWorkoutSet() {
         let newItem = WorkoutTemplateSet(name: "", targetWeight: 0, targetReps: 0)
         newWorkoutTemplateSet = newItem
     }

     private func deleteWorkoutSets(offsets: IndexSet) {
         withAnimation {
             for index in offsets {
                 let setToDelete = sortedSets[index]
                 workout.templateSets.removeAll { $0.id == setToDelete.id }
                 modelContext.delete(setToDelete)
             }
         }
     }
     
     @ViewBuilder
     private var workoutList: some View {
         List {
             ForEach(sortedSets) {set in
                 VStack {
                     Text("\(set.name)".uppercased())
                         .foregroundStyle(.secondary)
                         .font(.caption2)
                         .padding(.horizontal)
                         .padding(.bottom, -4)
                         .frame(maxWidth: .infinity, alignment: .leading)
                     if isEditing {
                         HStack {
                             TextField("Weight", value: Binding(
                                 get: { set.targetWeight },
                                 set: { set.targetWeight = $0 }
                             ), formatter: NumberFormatter())
                             .multilineTextAlignment(.center)
                             .frame(width: 50)
                             .padding(.vertical, -1)
                             .padding(.trailing, 3)
                             .overlay(
                                 RoundedRectangle(cornerRadius: 8)
                                     .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                             )
                             .keyboardType(.numberPad)
                             Text("LBS")
                                 .foregroundStyle(.secondary)
                                 .font(.caption)
                                 
                             Spacer()
                             TextField("Reps", value: Binding(
                                 get: { set.targetReps },
                                 set: { set.targetReps = $0 }
                             ), formatter: NumberFormatter())
                             .multilineTextAlignment(.center)
                             .frame(width: 50)
                             .padding(.vertical, -1)
                             .padding(.trailing, 3)
                             .overlay(
                                 RoundedRectangle(cornerRadius: 8)
                                     .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                             )
                             .keyboardType(.numberPad)
                             Text("REPS")
                                 .foregroundStyle(.secondary)
                                 .font(.caption)
                                 
                         }
                         .transition(.blurReplace)
                         .padding()
                         .background {
                             RoundedRectangle(cornerRadius: 16)
                                 .foregroundStyle(Color.secondary.opacity(0.2))
                         }
                     } else {
                         HStack {
                             Text("\(set.targetWeight)")
                                 .font(.body)
                                 
                             Text(" LBS")
                                 .foregroundStyle(.secondary)
                                 .font(.caption)
                                 
                             Spacer()
                             Text("\(set.targetReps)")
                                 .font(.body)
                                 
                             Text(" REPS")
                                 .foregroundStyle(.secondary)
                                 .font(.caption)
                         }
                         .transition(.blurReplace)
                         .padding()
                         .background {
                             RoundedRectangle(cornerRadius: 16)
                                 .foregroundStyle(Color.secondary.opacity(0.2))
                         }
                     }
                 }
                 .listRowSeparator(.hidden)
             }
             .onDelete(perform: isEditing ? deleteWorkoutSets : nil)
         }
         .listStyle(PlainListStyle())
         
         if isEditing {
             Button(action: addWorkoutSet) {
                 Label("Add Set", systemImage: "plus")
             }
         } else {
             Button(action: { showingAlert = true }) {
                 Label("Track Selected Sets", systemImage: "checkmark.circle")
             }
         }
     }
     
 }
 
 import SwiftUI

 struct EnterWorkout: View {
     
     @Bindable var workout: Workout
     
     @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var modelContext
     
     init(workout : Workout) {
         self.workout = workout
     }
     
     var body: some View {
         Form {
             TextField("Workout name", text: $workout.name)
         }
         .navigationTitle("Add Workout")
         .toolbar{
             ToolbarItem(placement: .confirmationAction) {
                 Button("Done") {
                     dismiss()
                 }
             }
             ToolbarItem(placement: .cancellationAction) {
                 Button("Cancel") {
                     modelContext.delete(workout)
                     dismiss()
                 }
             }
         }
     }
 }

 
 import SwiftUI
 import SwiftData

 struct EnterWorkoutSet: View {
     @Environment(\.modelContext) private var modelContext
     @Environment(\.dismiss) private var dismiss
     
     @Bindable var workout: Workout
     @Bindable var newWorkoutTemplateSet: WorkoutTemplateSet
     @Query private var allExercises: [Exercise]
     
     var body: some View {
         Form {
             Picker("Select Exercise", selection: $newWorkoutTemplateSet.name) {
                 Text("Choose an exercise").tag("")
                 ForEach(allExercises) { exercise in
                     Text(exercise.name).tag(exercise.name)
                 }
             }
             HStack {
                 TextField("Weight", value: $newWorkoutTemplateSet.targetWeight, formatter: NumberFormatter())
                     .keyboardType(.numberPad)
                 Text("lbs")
             }
             
             HStack {
                 TextField("Reps", value: $newWorkoutTemplateSet.targetReps, formatter: NumberFormatter())
                     .keyboardType(.numberPad)
                 Text("reps")
             }
         }
         .navigationTitle("Add Set to Workout")
         .toolbar {
             ToolbarItem(placement: .confirmationAction) {
                 Button("Add") {
                     if newWorkoutTemplateSet.name != "" && newWorkoutTemplateSet.targetWeight != 0 && newWorkoutTemplateSet.targetReps != 0 {
                         modelContext.insert(newWorkoutTemplateSet)
                         workout.templateSets.append(newWorkoutTemplateSet)
                         dismiss()
                     }
                 }
                 .disabled(newWorkoutTemplateSet.name == "" || newWorkoutTemplateSet.targetWeight == 0 || newWorkoutTemplateSet.targetReps == 0)
             }
             ToolbarItem(placement: .cancellationAction) {
                 Button("Cancel") {
                     modelContext.delete(newWorkoutTemplateSet)
                     dismiss()
                 }
             }
         }
         
     }
 }
 
 import SwiftUI
 import SwiftData

 struct DailyExerciseView: View {
     @Query private var allExercises: [Exercise]
     @State private var selectedDate: Date = Date()
     @State private var exerciseSets: [ExerciseSet] = []
     //@State private var isEditing: Bool = false
     @Environment(\.modelContext) private var modelContext
     
     var body: some View {
         VStack {
             DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                 .datePickerStyle(CompactDatePickerStyle())
                 .onChange(of: selectedDate) { oldValue, newValue in
                     exerciseSets = fetchExercisesForDate(newValue)
                 }
             
             List {
                 ForEach(exerciseSets) { set in
                     ExerciseSetRow(set: set)
                 }
                 .onMove(perform: moveItem)
                 .onDelete(perform: deleteItem)
             }
             //.environment(\.editMode, .constant(isEditing ? .active : .inactive))
         }
         .navigationTitle("Daily Workout")
         .onAppear {
             exerciseSets = fetchExercisesForDate(selectedDate)
         }
     }
     
     private func fetchExercisesForDate(_ date: Date) -> [ExerciseSet] {
         let calendar = Calendar.current
         let startOfDay = calendar.startOfDay(for: date)
         let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
         
         let allSets = allExercises.flatMap { exercise in
             exercise.allSets.filter { set in
                 (startOfDay...endOfDay).contains(set.date)
             }
         }
         
         return allSets.sorted { $0.date < $1.date }
     }
     
     private func moveItem(from source: IndexSet, to destination: Int) {
             var updatedSets = exerciseSets
             updatedSets.move(fromOffsets: source, toOffset: destination)
             
             // Update dates to maintain order
             let sortedDates = updatedSets.map { $0.date }.sorted()
             for (index, set) in updatedSets.enumerated() {
                 set.date = sortedDates[index]
                 modelContext.insert(set)
             }
             
             exerciseSets = updatedSets
         }
         
         private func deleteItem(at offsets: IndexSet) {
             for index in offsets {
                 let setToDelete = exerciseSets[index]
                 if let exercise = setToDelete.exercise {
                     exercise.allSets.removeAll { $0.id == setToDelete.id }
                 }
                 modelContext.delete(setToDelete)
             }
             exerciseSets.remove(atOffsets: offsets)
         }
 }

 struct ExerciseSetRow: View {
     let set: ExerciseSet
     
     var body: some View {
         HStack {
             VStack(alignment: .leading) {
                 Text(set.exercise?.name ?? "Unknown Exercise")
                     .font(.caption2)
                     .foregroundColor(.secondary)
                 
                 HStack {
                     Text("\(set.weight) LBS")
                     Spacer()
                     Text("\(set.reps) REPS")
                 }
                 .font(.body)
             }
         }
     }
 }
 
 import SwiftUI


 struct StopwatchView: View {
     @StateObject private var stopwatch = StopwatchManager()
     
     var body: some View {
         VStack {
             Text(timeString(time: stopwatch.elapsedTime))
                 .font(.largeTitle)
                 .padding()
             
             HStack {
                 Button(action: stopwatch.start) {
                     Text("Start")
                 }
                 .disabled(stopwatch.isRunning)
                 
                 Button(action: stopwatch.pause) {
                     Text("Pause")
                 }
                 .disabled(!stopwatch.isRunning)
                 
                 Button(action: stopwatch.stop) {
                     Text("Reset")
                 }
             }
         }
         .onAppear {
             UIApplication.shared.isIdleTimerDisabled = true
         }
         .onDisappear {
             UIApplication.shared.isIdleTimerDisabled = false
         }
     }
     
     private func timeString(time: TimeInterval) -> String {
         let hours = Int(time) / 3600
         let minutes = Int(time) / 60 % 60
         let seconds = Int(time) % 60
         let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
         return String(format:"%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)
     }
     
 }

*/
