/*

 import SwiftUI

 struct ContentView: View {
     
     var body: some View {
         TabView  {
             FilteredExerciseList()
             .tabItem {
                 Label("Exercises", systemImage: "dumbbell.fill")
             }
             NavigationStack {
                 FilteredWorkoutList()
             }
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

 */

// EXERCISE RELATED CODE
/*
 struct FilteredExerciseList: View {
     @State private var searchText = ""
     
     var body: some View {
         NavigationSplitView {
             ExerciseList(exerciseFilter: searchText)
                 .searchable(text: $searchText)
         } detail: {
             Text("Search exercises")
         }
     }
 }
 */

/*

 import SwiftUI
 import SwiftData

 struct ExerciseList: View {
     @Environment(\.modelContext) private var modelContext
     @Query private var exercises: [Exercise]
     
     @State private var newExercise: Exercise?
     @State private var addingNewExercise: Bool = false
     
     @State private var selectedCategory: ExerciseCategory?
     @State private var isDropdownVisible = false
     
     let exerciseFilter: String
     
     init(exerciseFilter: String = "") {
         self.exerciseFilter = exerciseFilter
         let predicate = #Predicate<Exercise> { exercise in
             exerciseFilter.isEmpty || exercise.name.localizedStandardContains(exerciseFilter)
         }
         _exercises = Query(filter: predicate, sort: \Exercise.name)
     }
     
     private var filteredExercises: [Exercise] {
         guard let selectedCategory = selectedCategory else {
             return exercises
         }
         return exercises.filter { $0.category == selectedCategory }
     }
     
     private var title: String {
         if !exercises.isEmpty {
             return selectedCategory?.rawValue.capitalized ?? "All Exercises"
         } else {
             return "Exercises"
         }
     }
     
     var body: some View {
         Group {
             if !exercises.isEmpty {
                 List {
                     ForEach(filteredExercises) { exercise in
                         ExerciseRow(exercise: exercise)
                     }
                     .onDelete(perform: deleteExercises)
                 }
             } else {
                 VStack {
                     Spacer()
                     Text("No Exercises")
                         .font(.title3)
                         .bold()
                     Spacer()
                     Button(action: addExercise) {
                         HStack (spacing: 5) {
                             Image(systemName: "plus")
                             Text("Add Exercise")
                         }
                         .foregroundStyle(.blue)
                         .font(.body)
                         .bold()
                         .padding(.bottom, 20)
                     }
                 }
             }
         }
         .navigationTitle(title)
         .toolbar {
             if !exercises.isEmpty {
                 ToolbarItem {
                     Button(action:
                         addExercise
                     ) {
                         Image(systemName: "plus")
                             .foregroundStyle(.blue)
                     }
                 }
                 
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Menu {
                         Button(action: { selectedCategory = nil }) {
                             Label("All", systemImage: selectedCategory == nil ? "checkmark" : "")
                         }
                         ForEach(ExerciseCategory.allCases) { category in
                             Button(action: { selectedCategory = category }) {
                                 Label(category.rawValue.capitalized, systemImage: selectedCategory == category ? "checkmark" : "")
                             }
                         }
                     } label: {
                         Image(systemName: "line.3.horizontal.decrease.circle")
                             .foregroundStyle(.blue)
                     }
                 }
             }
         }
         .sheet(isPresented: $addingNewExercise, onDismiss: {addingNewExercise = false}) {
             NavigationStack {
                 EnterExercise(exercise: newExercise ?? Exercise(name: "", category: ExerciseCategory.misc))
             }
             .interactiveDismissDisabled()
         }
     }

     private func addExercise() {
         withAnimation {
             newExercise = Exercise(name: "", category: ExerciseCategory.misc)
             modelContext.insert(newExercise!)
             addingNewExercise = true
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
     
     @State private var isPressed = false
     @GestureState private var longPress = false
     
     var body: some View {
         NavigationLink {
             ExerciseDetails(exercise: exercise)
         } label: {
             Text(exercise.name)
         }
     }
 }


 struct CategoryDropdown: View {
     let categories: [ExerciseCategory?]
     @Binding var selectedCategory: ExerciseCategory?
     var onDismiss: () -> Void
     
     var body: some View {
         VStack(alignment: .leading, spacing: 8) {
             ForEach(categories, id: \.self) { category in
                 Button(action: {
                     selectedCategory = category
                     onDismiss()
                 }) {
                     Text(category?.rawValue.capitalized ?? "All")
                         .foregroundColor(selectedCategory == category ? .blue : .primary)
                 }
             }
         }
         .padding()
         .background(Color(UIColor.systemBackground))
         .cornerRadius(8)
         .shadow(radius: 4)
     }
 }

 */


/*

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
             Picker("Category", selection: $exercise.category) {
                 Text("Choose a category").tag("")
                 ForEach(ExerciseCategory.allCases) { category in
                     Text(category.rawValue.capitalized).tag(category)
                 }
             }
             VStack(alignment: .leading) {
                 Text("Exercise Info")
                     //.frame(width: .infinity, alignment: .leading)
                     .foregroundColor(.gray.opacity(0.5))
                 TextEditor(text: $exercise.info)
                     .frame(height: 200)
                     .foregroundColor(.gray)
                     .overlay(
                         RoundedRectangle(cornerRadius: 8)
                             .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                     )
             }
         }
         .navigationTitle("Add Exercise")
         .toolbar{
             ToolbarItem(placement: .confirmationAction) {
                 Button("Done") {
                     dismiss()
                 }
                 .disabled(exercise.name == "")
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


 */

/*

 import SwiftUI

 struct EditExercise: View {
     @Bindable var exercise: Exercise
     
     @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var modelContext
     
     @State private var editedName: String
     @State private var editedCategory: ExerciseCategory
     @State private var editedInfo: String
     
     init(exercise : Exercise) {
         self.exercise = exercise
         _editedName = State(initialValue: exercise.name)
         _editedCategory = State(initialValue: exercise.category)
         _editedInfo = State(initialValue: exercise.info)
     }
     
     var body: some View {
         Group {
             Form {
                 TextField("Edit exercise name", text: $editedName)
                 Picker("Edit Category", selection: $editedCategory) {
                     Text("Exercise Category").tag("")
                     ForEach(ExerciseCategory.allCases) { category in
                         Text(category.rawValue.capitalized).tag(category)
                     }
                 }
                 VStack(alignment: .leading) {
                     Text("Exercise Info")
                         .frame(width: .infinity, alignment: .leading)
                     TextEditor(text: $editedInfo)
                         .frame(height: 200)
                         .foregroundColor(.gray)
                         .overlay(
                             RoundedRectangle(cornerRadius: 8)
                                 .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                         )
                 }
             }
         }
         .navigationTitle("Edit Exercise")
         .toolbar{
             ToolbarItem(placement: .confirmationAction) {
                 Button("Save") {
                     exercise.name = editedName
                     exercise.category = editedCategory
                     exercise.info = editedInfo
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

 */

/*

 import SwiftUI
 import SwiftData

 struct ExerciseDetails: View {
     @StateObject private var vm: ExerciseDetailsViewModel
     @State var selectedDate: Date? = nil
     @State private var displayedDate: Date // Date displayed for the daily sets list
     @State var selectedSetIndex: Int? // Set displayed for daily sets chart view
     
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
     
     @State private var setDeletionEnabled: Bool = false
     @State private var showingInfo = false
     
     @State private var sortByWeight: Bool = true
     @State private var sortByReps: Bool = false
     @State private var sortByTime: Bool = false
     @State private var editingExercise: Bool = false
     
     @State private var dailySetsChartExpanded: Bool = false
     
     private var hasSetsForDate: Bool {
         let dayStart = Calendar.current.startOfDay(for: displayedDate)
         return !(vm.allSetsDictionary[dayStart]?.isEmpty ?? true)
     }
     
     init(exercise: Exercise, displayedDate: Date = Calendar.current.startOfDay(for: Date())) {
         let viewModel = ExerciseDetailsViewModel(exercise: exercise)
         _vm = StateObject(wrappedValue: viewModel)
         _displayedDate = State(initialValue: displayedDate)
     }
     
     var body: some View {
         let displayedDateStart = Calendar.current.startOfDay(for: displayedDate)
         let hasTimedExercises = vm.exercise.allSets.contains { $0.duration != nil && $0.duration! > 0 }
         
         Group {
             if !vm.exercise.allSets.isEmpty {
                 ScrollView {
                     VStack () {
                         //Additional exercise info
                         AdditionalExerciseInfoView(vm: vm, showingInfo: $showingInfo)
                         
                         //Personal best set
                         if let prSet = vm.exercise.PRSet {
                             ExerciseSetView(vm: vm, exerciseSet: prSet, setType: .greatest)
                         }
                         
                         // Sort view by:
                         ViewSortingButtons(sortByWeight: $sortByWeight, sortByReps: $sortByReps, sortByTime: $sortByTime, hasTimedExercises: hasTimedExercises)
                             .padding(.bottom)
                             .padding(.horizontal, 16)
                         
                         //Chart
                         Group {
                             if !dailySetsChartExpanded {
                                 ExerciseChartView(vm: vm, sets: vm.allSetsDictionary, sortByWeight: sortByWeight, sortByReps: sortByReps, sortByTime: sortByTime, rawSelectedDate: $selectedDate)
                                     .onChange(of: selectedDate) { oldValue, newValue in
                                         if let newDate = newValue {
                                             displayedDate = newDate
                                         }
                                     }
                             } else {
                                 ExerciseChartDailyView(
                                     displayedDateStart: displayedDateStart,
                                     displayedDateSets: vm.allSetsDictionary[displayedDateStart] ?? [],
                                     sortByWeight: sortByWeight,
                                     sortByReps: sortByReps,
                                     sortByTime: sortByTime,
                                     selectedSetIndex: $selectedSetIndex
                                 )
                             }
                         }
                         .frame(height: 300)
                         .padding(.horizontal, 8)
                         
                         if let setsForDate = vm.allSetsDictionary[displayedDateStart], !setsForDate.isEmpty {
                             HStack {
                                 Spacer()
                                 Button (action: {
                                     withAnimation {
                                         dailySetsChartExpanded.toggle()
                                     }
                                 }, label: {
                                     Text(dailySetsChartExpanded ? "Contract Daily Sets" : "Expand Daily Sets")
                                         .font(.caption)
                                         .padding(.top, -10)
                                         .padding(.horizontal)
                                         .zIndex(2)
                                 })
                             }
                         }
                         
                         //Latest set
                         ExerciseSetView(vm:vm, exerciseSet: vm.findLatestSet()!, setType: .latest)
                         
                         HStack {
                             Text("\(displayedDate, format: .dateTime.year().month().day()) - Sets")
                                 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                 .font(.title3)
                                 .fontWeight(.bold)
                                 .padding(.vertical, 8)
                             
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
                         .padding(.horizontal)
                         .padding(.bottom)
                         
                         //Show more data
                         if showingMoreData && vm.allSetsDictionary[displayedDateStart] != nil && !vm.allSetsDictionary[displayedDateStart]!.isEmpty {
                             AdditionalDataView(displayedDate: displayedDate, vm: vm, timedExercise: timedExercise, showingMoreData: $showingMoreData)
                         } else {
                             Button(action: {
                                 withAnimation {
                                     showingMoreData = true
                                 }
                             }) {
                                 Text(vm.allSetsDictionary[displayedDateStart] != nil ? "Show More Exercise Data" : "")
                                     .foregroundStyle(vm.allSetsDictionary[displayedDateStart] != nil ? .blue : .gray)
                             }
                             .disabled(vm.allSetsDictionary[displayedDateStart] == nil)
                         }
                         
                         //Daily Set list
                         SetsByDateDetailsView(displayedDate: displayedDate, insetExpanded: $insetExpanded, vm: vm, setDeletionEnabled: $setDeletionEnabled, hasSetsForDate: hasSetsForDate)
                     }
                 }
             }
             else {
                 VStack {
                     Text("\(vm.exercise.info)")
                         .font(.body)
                         .padding()
                     Spacer()
                     Text("No Sets")
                         .bold()
                     Spacer()
                     
                     Button(action: {
                         withAnimation {
                             insetExpanded.toggle()
                         }
                     }) {
                         HStack (spacing: 5) {
                             Image(systemName: "plus")
                             Text("Add Set")
                         }
                         .foregroundStyle(.blue)
                         .font(.body)
                         .bold()
                         .padding(.bottom, 20)
                         .foregroundStyle(insetExpanded ? .gray : .blue)
                         .opacity(insetExpanded ? 0.5 : 1.0)
                     }
                     .disabled(insetExpanded)
                 }
             }
         }
         .navigationTitle("\(vm.exercise.name)")
         .toolbar {
             ToolbarItem(placement: .navigationBarTrailing) {
                 Button {
                     editingExercise = true
                 } label: {
                     Text("Edit")
                 }
             }
         }
         .sheet(isPresented: $editingExercise, onDismiss: {
             editingExercise = false
         }) {
             NavigationStack {
                 EditExercise(exercise: vm.exercise)
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
                             
                             let newSet = ExerciseSet(weight: weight, reps: reps, date: newSetDate, exercise: vm.exercise)
                             
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
     
     var vm: ExerciseDetailsViewModel
     var exerciseSet: ExerciseSet
     var setType: SetStanding
     let padding: CGFloat = -4
     
     var body: some View {
         Group {
             HStack {
                 VStack(alignment: .leading) {
                     HStack {
                         Text(setType == .latest ? "Latest:" : "Record:")
                             .padding(.trailing, -4)
                             .font(.caption)
                             .fontWeight(.semibold)
                             .foregroundStyle(.gray)
                         Text("\(exerciseSet.date, format: .dateTime.year().month().day())")
                             .fontWeight(.semibold)
                             .padding(.vertical, padding)
                     }
                     if let duration = exerciseSet.duration {
                         let (minutes, seconds) = vm.secondsToMinutesAndSeconds(Int(duration))
                         HStack {
                             Image(systemName: "stopwatch.fill")
                                 .foregroundStyle(.gray)
                                 .font(.caption)
                                 .padding(.trailing, -5)
                             DurationView(minutes: minutes, seconds: seconds)
                         }
                         .frame(width: .infinity, alignment: .leading)
                     }
                 }
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

 struct SetsByDateDetailsView: View {
     var displayedDate: Date
     @Binding var insetExpanded: Bool
     @ObservedObject var vm: ExerciseDetailsViewModel
     @Binding var setDeletionEnabled: Bool
     @State private var setToDelete: (set: ExerciseSet, index: Int)?
     var hasSetsForDate: Bool
      
     let padding: CGFloat = -4
     
     var body: some View {
         VStack {
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
             // Delete sets button
             if hasSetsForDate {
                 Button(action: {
                     withAnimation {
                         setDeletionEnabled.toggle()
                     }
                 }) {
                     Text(setDeletionEnabled ? "Cancel" : "Delete Set(s)")
                         .foregroundStyle(.red)
                 }
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

 struct AdditionalExerciseInfoView: View {
     
     var vm: ExerciseDetailsViewModel
     @Binding var showingInfo: Bool
     
     var body: some View {
         if !vm.exercise.info.isEmpty && !showingInfo {
             Button(action: {
                 withAnimation {
                     showingInfo.toggle()
                 }
             }) {
                 Text("Show Exercise Info")
                     .font(.body)
             }
         }
         if showingInfo {
             VStack {
                 Text("\(vm.exercise.info)")
                     .font(.body)
                 Button(action: {
                     withAnimation {
                         showingInfo.toggle()
                     }
                 }) {
                     Text("Collapse Exercise Info")
                         .font(.body)
                         .padding()
                 }
             }
         }
     }
 }

 struct ViewSortingButtons: View {
     
     @Binding var sortByWeight: Bool
     @Binding var sortByReps: Bool
     @Binding var sortByTime: Bool
     var hasTimedExercises: Bool
     
     var body: some View {
         VStack (spacing: 0) {
             Text("Sort Chart By:")
                 .foregroundStyle(.gray)
                 .font(.caption2)
     
             HStack {
                 Button {
                     // Sort by weight
                     sortByWeight = true
                     sortByReps = false
                     sortByTime = false
                 } label: {
                     Text("Weight")
                         .foregroundStyle(sortByWeight ? .blue : .gray)
                         .padding(.horizontal)
                 }
                 Spacer()
                 Button {
                     // Sort by reps
                     sortByWeight = false
                     sortByReps = true
                     sortByTime = false
                 } label: {
                     Text("Reps")
                         .foregroundStyle(sortByReps ? .blue : .gray)
                         .padding(.horizontal)
                 }
                 if hasTimedExercises {
                     Spacer()
                     Button {
                         // Sort by time
                         sortByWeight = false
                         sortByReps = false
                         sortByTime = true
                     } label: {
                         Text("Duration")
                             .foregroundStyle(sortByTime ? .blue : .gray)
                             .padding(.horizontal)
                     }
                     
                 }
             }
         }
         .padding(.vertical, 5)
         .background {
             RoundedRectangle(cornerRadius: 8)
                 .foregroundStyle(Color.gray.opacity(0.12))
         }
     }
 }

 */

/*

 import SwiftUI

 struct AdditionalDataView: View {
     var displayedDate: Date
     var vm: ExerciseDetailsViewModel
     var timedExercise: Bool
     @Binding var showingMoreData: Bool
     
     var dayStart: Date {
         Calendar.current.startOfDay(for: displayedDate)
     }
     
     var totalDuration: TimeInterval {
         vm.allSetsDictionary[dayStart]!.reduce(0) { sum, set in
             sum + (set.duration ?? 0)
         }
     }
     
     var body: some View {
                 
         VStack (alignment: .leading) {
             // Additional Weight & Rep Data
             WeightAndRepData
             // Additional Volume Load Data
             VLData
             
             // Additional Duration Data
             DurationData
             
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
     
     @ViewBuilder
     private var WeightAndRepData: some View {
         let averageRepWeightMonthly = vm.monthlyAverageWeight()
         let averageRepCountMonthly = vm.monthlyAverageRepsPerDay()
         
         HStack {
             Image(systemName: "dumbbell.fill")
                 .foregroundStyle(.blue)
                 .padding(.trailing, -5)
             Text("Weight & Reps")
                 .foregroundStyle(.blue)
                 .fontWeight(.bold)
         }
         .padding(.horizontal)
         .padding(.bottom)
         
         WeightAndRepPercentData
         
         Text("*Percent inc/dec from 30 day avg")
             .font(.caption2)
             .foregroundStyle(.gray)
             .padding(.top, 0)
             .padding(.horizontal)
             .padding(.bottom)
         
         Group {
             Text("Your average weight per rep over the last 30 days is approximately " ) +
             Text("\(averageRepWeightMonthly)").bold() +
             Text(" lbs." )
         }
         .padding(.horizontal)
         .padding(.bottom)
         
         Group {
             Text("You averaged approximately ") +
             Text("\(averageRepCountMonthly)").bold() +
             Text(" reps per day over the last 30 days." )
         }
         .padding(.horizontal)
         .padding(.bottom)
         
     }
     
     @ViewBuilder
     private var WeightAndRepPercentData: some View {
         let totalRepCountDaily = vm.totalRepsForDate(displayedDate)
         let averageRepWeightDaily = vm.averageRepWeightForDate(displayedDate)
         let weightPercentChange = vm.weightPercentChange(for: displayedDate)
         let repPercentChange = vm.dailyRepsPercentChange(for: displayedDate)
         
         Group {
             repText(totalRepCountDaily, repPercentChange) +
             weightText(averageRepWeightDaily, weightPercentChange)
         }
         .padding(.horizontal)
         .padding(.bottom, 0)
     }

     // Associated with WeightAndRepPercentData
     private func repText(_ count: Int, _ change: Double) -> Text {
         Text("You've completed ") +
         Text("\(count)").bold() +
         Text(" rep(s) (") +
         percentChangeText(change) +
         Text("*").foregroundStyle(.gray) +
         Text(") ")
     }

     // Associated with WeightAndRepPercentData
     private func weightText(_ weight: Int, _ change: Double) -> Text {
         Text("at an average weight of ") +
         Text("\(weight) lbs (").bold() +
         percentChangeText(change) +
         Text("*").foregroundStyle(.gray) +
         Text(").")
     }

     // Associated with WeightAndRepPercentData
     private func percentChangeText(_ change: Double) -> Text {
         Text("\(change >= 0 ? "+" : "")\(String(format: "%.1f%%", change))")
             .bold()
             .foregroundStyle(change >= 0 ? .green : .red)
     }
     
     @ViewBuilder
     private var VLData: some View {
         
         let volumeLoad = vm.volumeLoadForDate(displayedDate)
         let monthlyAvgVL = vm.monthlyAverageVolumeLoad()
         
         let volumeLoadPercentChange = vm.volumeLoadPercentChange(for: displayedDate)
         
         HStack {
             Image(systemName: "flame.fill")
                 .foregroundStyle(.blue)
                 .padding(.trailing, -5)
             Text("Volume Load")
                 .foregroundStyle(.blue)
                 .fontWeight(.bold)
         }
         .padding(.horizontal)
         .padding(.bottom)
         
         Group {
             Text("Your daily volume load is ") +
             Text("\(volumeLoad)").bold() +
             Text(" lbs (") +
             Text("\(volumeLoadPercentChange > 0 ? "+" : "")\(String(format: "%.1f%%", volumeLoadPercentChange))")
                 .bold()
                 .foregroundStyle(volumeLoadPercentChange >= 0 ? .green : .red) +
             Text("*").foregroundStyle(.gray) +
             Text(").")
         }
         .padding(.horizontal)
         .padding(.bottom,0)
         
         if volumeLoadPercentChange > 0 {
             Text("*Percent increase from 30 day avg")
                 .font(.caption2)
                 .foregroundStyle(.gray)
                 .padding(.top, 0)
                 .padding(.horizontal)
                 .padding(.bottom)
         } else {
             Text("Percent decrease from 30 day avg")
                 .font(.caption2)
                 .foregroundStyle(.gray)
                 .padding(.top, 0)
                 .padding(.horizontal)
                 .padding(.bottom)
         }
         
         
         Group {
             Text("Your 30 day average is " ) +
             Text("\(monthlyAvgVL)").bold() +
             Text(" lbs." )
         }
         .padding(.horizontal)
         .padding(.bottom)
         
         Group {
             Text("Your max volume load is ") +
             Text("\(vm.exercise.maxVolumeLoad)").bold() +
             Text(" lbs on \(vm.exercise.maxVolumeLoadDate, format: .dateTime.month().day().year()).")
         }
         .padding(.horizontal)
         .padding(.bottom)
     }
     
     @ViewBuilder
     private var DurationData: some View {
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
             .padding(.bottom)
             
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
             .padding(.horizontal)
             .padding(.bottom)
         }
     }
     
 }

 */

/*

 import Charts
 import SwiftUI

 struct ExerciseChartView: View {
     var vm: ExerciseDetailsViewModel
     var sets: [Date:[ExerciseSet]]
     
     var sortByWeight: Bool
     var sortByReps: Bool
     var sortByTime: Bool
     
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
     
     // Get highest weight for date
     var selectedDateMaxWeightDetails: (weight: Int, reps: Int, duration: TimeInterval?, maxSet: ExerciseSet)? {
         guard let selectedDate = selectedDate,
               let setsForDate = sets[selectedDate] else {
             return nil
         }
         
         return setsForDate.max(by: { $0.weight < $1.weight })
             .map { ($0.weight, $0.reps, $0.duration, $0.self) }
     }
     
     // Get highest reps for date
     var selectedDateMaxRepsDetails: (weight: Int, reps: Int, duration: TimeInterval?, maxSet: ExerciseSet)? {
         guard let selectedDate = selectedDate,
               let setsForDate = sets[selectedDate] else {
             return nil
         }
         
         return setsForDate.max(by: { $0.reps < $1.reps })
             .map { ($0.weight, $0.reps, $0.duration, $0.self) }
     }
     
     // Get highest weight for date
     var selectedDateMaxDurationDetails: (weight: Int, reps: Int, duration: TimeInterval?, maxSet: ExerciseSet)? {
         guard let selectedDate = selectedDate,
               let setsForDate = sets[selectedDate] else {
             return nil
         }
         
         return setsForDate.max(by: { $0.duration ?? 0 < $1.duration ?? 0 })
             .map { ($0.weight, $0.reps, $0.duration, $0.self) }
     }
     
     var body: some View {
         let maxWeight = sets.values.flatMap { $0 }.max(by: { $0.weight < $1.weight })?.weight ?? 0
         let maxReps = sets.values.flatMap { $0 }.max(by: { $0.reps < $1.reps })?.reps ?? 0
         let maxDuration = sets.values.flatMap { $0 }
             .compactMap { $0.duration }
             .max() ?? 0
         //let yAxisMax = Double(maxWeight) * 1.4
         var yAxisMax: Double {
             if sortByWeight {
                 return Double(maxWeight) * 1.45
             } else if sortByReps {
                 return Double(maxReps) * 1.45
             } else if sortByTime {
                 return Double(maxDuration) * 1.45
             }
             return 0.0
         }
         let mostRecentDate = sets.keys.max() ?? Date()
         HStack {
                 if sortByWeight {
                     Text("Weight (LBS)")
                         .font(.caption)
                         .foregroundStyle(.gray)
                         .rotationEffect(Angle(degrees: -90))
                         .fixedSize()
                         .frame(width: 15)
                         .padding(.top, -15)
                         .padding(.trailing, -15)
                 } else if sortByReps {
                     Text("Reps")
                         .font(.caption)
                         .foregroundStyle(.gray)
                         .rotationEffect(Angle(degrees: -90))
                         .fixedSize()
                         .frame(width: 15)
                         .padding(.top, -20)
                         .padding(.trailing, -15)
                 } else if sortByTime {
                     Text("Duration (Sec)")
                         .font(.caption)
                         .foregroundStyle(.gray)
                         .rotationEffect(Angle(degrees: -90))
                         .fixedSize()
                         .frame(width: 15)
                         .padding(.top, -20)
                         .padding(.trailing, -15)
                 }
             VStack {
                 
                 if sortByWeight {
                     Text("Max Weight per Date")
                         .font(.caption)
                         .bold()
                         .foregroundStyle(.gray)
                         .fixedSize()
                         .frame(width: 15)
                         //.padding(.leading, -15)
                         .padding(.vertical, -10)
                 } else if sortByReps {
                     Text("Max Reps per Date")
                         .font(.caption)
                         .bold()
                         .foregroundStyle(.gray)
                         .fixedSize()
                         .frame(width: 15)
                         //.padding(.leading, -15)
                         .padding(.vertical, -10)
                 } else if sortByTime {
                     Text("Max Duration per Date")
                         .font(.caption)
                         .bold()
                         .foregroundStyle(.gray)
                         .fixedSize()
                         .frame(width: 15)
                         //.padding(.leading, -15)
                         .padding(.vertical, -10)
                 }
                 
                 Chart {
                     ForEach(Array(sets.keys), id: \.self) { date in
                         if sortByWeight && !sortByReps && !sortByTime {
                             if let maxSet = sets[date]?.max(by: { $0.weight < $1.weight }) {
                                 BarMark(
                                     x: .value("Date", date, unit: .day),
                                     y: .value("Weight", maxSet.weight)
                                 )
                             }
                         }
                         else if !sortByWeight && sortByReps && !sortByTime {
                             if let maxSet = sets[date]?.max(by: { $0.reps < $1.reps }) {
                                 BarMark(
                                     x: .value("Date", date, unit: .day),
                                     y: .value("Reps", maxSet.reps)
                                 )
                             }
                         } else if !sortByWeight && !sortByReps && sortByTime {
                             if let maxSet = sets[date]?.max(by: { $0.duration ?? 0 < $1.duration ?? 0 }) {
                                 BarMark(
                                     x: .value("Date", date, unit: .day),
                                     y: .value("Time", maxSet.duration ?? 0)
                                 )
                             }
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
                             if sortByWeight {
                                 valueSelectionPopoverMaxWeight
                             } else if sortByReps {
                                 valueSelectionPopoverMaxReps
                             } else if sortByTime {
                                 valueSelectionPopoverMaxDuration
                             }
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
                 
                 Text("Date")
                     .font(.caption)
                     .foregroundStyle(.gray)
                     .fixedSize()
                     .frame(width: 15)
                     //.padding(.leading, -15)
             }
         }
     
     }
     
     @ViewBuilder
     var valueSelectionPopoverMaxWeight: some View {
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
                 durationView
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
     
     @ViewBuilder
     var valueSelectionPopoverMaxReps: some View {
         let padding: CGFloat = -4
         if let details = selectedDateMaxRepsDetails, let date = selectedDate {
             VStack(alignment: .leading) {
                 Text("MAX REPS").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
                 HStack{
                     HStack(alignment: .bottom) {
                         Text("\(details.reps)").font(.title3).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                         Text("REPS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                     }
                     HStack(alignment: .bottom) {
                         Text("\(details.weight)").font(.title3).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                         Text("LBS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                     }
                 }
                 durationView
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
     
     @ViewBuilder
     var valueSelectionPopoverMaxDuration: some View {
         let padding: CGFloat = -4
         if let details = selectedDateMaxDurationDetails, let date = selectedDate {
             VStack(alignment: .leading) {
                 Text("MAX TIME").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
                 durationView
                 HStack{
                     HStack(alignment: .bottom) {
                         Text("\(details.weight)").font(.caption).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                         Text("LBS").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
                     }
                     HStack(alignment: .bottom) {
                         Text("\(details.reps)").font(.caption).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                         Text("REPS").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
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
     
     @ViewBuilder
     private var durationView: some View {
         
         if sortByWeight {
             if let duration = selectedDateMaxWeightDetails?.duration {
                 let (minutes, seconds) = vm.secondsToMinutesAndSeconds(Int(duration))
                 HStack {
                     Image(systemName: "stopwatch.fill")
                         .foregroundStyle(.gray)
                         .font(.caption)
                         .padding(.trailing, -5)
                     DurationView(minutes: minutes, seconds: seconds)
                 }
             }
         } else if sortByReps {
             if let duration = selectedDateMaxRepsDetails?.duration {
                 let (minutes, seconds) = vm.secondsToMinutesAndSeconds(Int(duration))
                 HStack {
                     Image(systemName: "stopwatch.fill")
                         .foregroundStyle(.gray)
                         .font(.caption)
                         .padding(.trailing, -5)
                     DurationView(minutes: minutes, seconds: seconds)
                 }
             }
         } else if sortByTime {
             if let duration = selectedDateMaxDurationDetails?.duration {
                 let (minutes, seconds) = vm.secondsToMinutesAndSeconds(Int(duration))
                 HStack {
                     Image(systemName: "stopwatch.fill")
                         //.foregroundStyle(.gray)
                         .font(.title3)
                         .padding(.trailing, -5)
                     DurationView(minutes: minutes, seconds: seconds)
                 }
             }
         }
         
     }
     
 }

 */

/*

 import Charts
 import SwiftUI

 struct ExerciseChartDailyView: View {
     @Environment(\.calendar) var calendar
     
     var displayedDateStart: Date
     var displayedDateSets: [ExerciseSet]
     var sortByWeight: Bool
     var sortByReps: Bool
     var sortByTime: Bool
     
     @Binding var selectedSetIndex: Int?
     
     var body: some View {
         let maxWeight = displayedDateSets.max(by: { $0.weight < $1.weight })?.weight ?? 0
         let maxReps = displayedDateSets.max(by: { $0.reps < $1.reps })?.reps ?? 0
         let maxDuration = displayedDateSets.compactMap { $0.duration }.max() ?? 0
         
         var yAxisMax: Double {
             if sortByWeight {
                 return Double(maxWeight) * 1.45
             } else if sortByReps {
                 return Double(maxReps) * 1.45
             } else if sortByTime {
                 return Double(maxDuration) * 1.45
             }
             return 0.0
         }
         
         HStack {
             
             if sortByWeight {
                 Text("Weight (LBS)")
                     .font(.caption)
                     .foregroundStyle(.gray)
                     .rotationEffect(Angle(degrees: -90))
                     .fixedSize()
                     .frame(width: 15)
                     .padding(.top, -15)
                     .padding(.trailing, -15)
             } else if sortByReps {
                 Text("Reps")
                     .font(.caption)
                     .foregroundStyle(.gray)
                     .rotationEffect(Angle(degrees: -90))
                     .fixedSize()
                     .frame(width: 15)
                     .padding(.top, -20)
                     .padding(.trailing, -15)
             } else if sortByTime {
                 Text("Duration (Sec)")
                     .font(.caption)
                     .foregroundStyle(.gray)
                     .rotationEffect(Angle(degrees: -90))
                     .fixedSize()
                     .frame(width: 15)
                     .padding(.top, -20)
                     .padding(.trailing, -15)
             }
             
             VStack {
                 
                 Text("Sets for \(displayedDateStart, format: .dateTime.month().day().year())")
                     .font(.caption)
                     .bold()
                     .foregroundStyle(.gray)
                     .fixedSize()
                     .frame(width: 15)
                     .padding(.vertical, -10)
                 
                 Chart {
                     ForEach(Array(displayedDateSets.enumerated()), id: \.element.id) { index, set in
                         if sortByWeight && !sortByReps && !sortByTime {
                             BarMark(
                                 x: .value("Set", index + 1),
                                 y: .value("Weight", set.weight)
                             )
                         }
                         else if !sortByWeight && sortByReps && !sortByTime {
                             BarMark(
                                 x: .value("Set", index + 1),
                                 y: .value("Reps", set.reps)
                             )
                         } else if !sortByWeight && !sortByReps && sortByTime {
                             BarMark(
                                 x: .value("Set", index + 1),
                                 y: .value("Duration", set.duration ?? 0)
                             )
                         }
                     }
                     .foregroundStyle(.blue)
                     
                     
                     if let selectedSetIndex, selectedSetIndex >= 0, selectedSetIndex < displayedDateSets.count {
                         RuleMark(
                             x: .value("Selected", selectedSetIndex + 1)
                         )
                         .foregroundStyle(Color.red.opacity(0.3))
                         .offset(yStart: 50)
                         .zIndex(1)
                         .annotation(
                             position: .top,
                             alignment: .center,
                             spacing: 0,
                             overflowResolution: .init(
                                 x: .fit(to: .automatic),
                                 y: .fit(to: .automatic)
                             )
                         ) {
                             if selectedSetIndex < displayedDateSets.count {
                                 valueSelectionPopover(for: displayedDateSets[selectedSetIndex])
                             }
                         }
                     }
                     
                 }
                 .chartXSelection(value: Binding(
                     get: { selectedSetIndex.map { $0 + 1 } },
                     set: { newValue in
                         selectedSetIndex = newValue.map { $0 - 1 }
                     }
                 ))
                 .padding(8)
                 .chartXAxis {
                     AxisMarks(values: .stride(by: 1)) { value in
                         if let intValue = value.as(Int.self), intValue > 0 && intValue <= displayedDateSets.count {
                             AxisValueLabel {
                                 Text("\(intValue)")
                             }
                             AxisTick()
                             AxisGridLine()
                         }
                     }
                 }
                 .chartXScale(domain: 1...Double(displayedDateSets.count))
                 .chartYScale(domain: 0...yAxisMax)
                 .chartYAxis {
                     AxisMarks(position: .leading)
                 }
                 
                 Text("Set")
                     .font(.caption)
                     .foregroundStyle(.gray)
                     .fixedSize()
                     .frame(width: 15)
             }
         }
     }
     
     @ViewBuilder
     func valueSelectionPopover(for set: ExerciseSet) -> some View {
         let padding: CGFloat = -4
         VStack(alignment: .leading) {
             //Text("WEIGHT").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
             
             HStack {
                 HStack(alignment: .bottom) {
                     Text("\(set.weight)").font(.caption).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                     Text("LBS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                 }
                 HStack(alignment: .bottom) {
                     Text("\(set.reps)").font(.caption).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                     Text("REPS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                 }
                 if let duration = set.duration {
                     HStack {
                         Image(systemName: "stopwatch.fill")
                             .foregroundStyle(.gray)
                             .font(.caption)
                         DurationView(minutes: Int(duration) / 60, seconds: Int(duration) % 60)
                     }
                 }
             }
             
         }
         .padding(6)
         .background {
             RoundedRectangle(cornerRadius: 4)
                 .foregroundStyle(Color.gray.opacity(0.12))
         }
     }
     
 }



 */

//WORKOUT RELATED CODE

/*
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
 */

/*

 import SwiftUI
 import SwiftData

 struct WorkoutList: View {
     @Environment(\.modelContext) private var modelContext
     @Query private var workouts: [Workout]
     
     @State private var newWorkout: Workout?
     @State private var addingNewWorkout: Bool = false
     
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
                             HStack (spacing: 2) {
                                 Text(workout.name)
                                 Spacer()
                                 if workout.bestTimeMinutes != nil || workout.bestTimeSeconds != nil {
                                     Image(systemName: "stopwatch.fill")
                                         .foregroundStyle(.gray)
                                         .font(.caption2)
                                 }
                                 if let minutes = workout.bestTimeMinutes {
                                     Text("\(minutes)")
                                         .foregroundStyle(.gray)
                                         .font(.caption2)
                                     Text("min")
                                         .foregroundStyle(.gray)
                                         .font(.caption2)
                                 }
                                 if let seconds = workout.bestTimeSeconds {
                                     Text("\(seconds)")
                                         .foregroundStyle(.gray)
                                         .font(.caption2)
                                     Text("sec")
                                         .foregroundStyle(.gray)
                                         .font(.caption2)
                                 }
                             }
                         }
                     }
                     .onDelete(perform: deleteWorkouts)
                 }
             } else {
                 VStack {
                     Spacer()
                     Text("No Workouts")
                         .font(.title3)
                         .bold()
                     Spacer()
                     Button(action: addWorkout) {
                         HStack (spacing: 5) {
                             Image(systemName: "plus")
                             Text("Add Workout")
                         }
                         .foregroundStyle(.blue)
                         .font(.body)
                         .bold()
                         .padding(.bottom, 20)
                     }
                 }
             }
         }
         .navigationTitle("Workouts")
         .toolbar {
             if !workouts.isEmpty {
                 ToolbarItem {
                     Button(action: addWorkout) {
                         Text("Add Workout")
                             .foregroundStyle(.blue)
                     }
                 }
             }
             ToolbarItem(placement: .topBarLeading) {
                 Button(action: {}) {
                     Image(systemName: "info.circle")
                         .foregroundStyle(.blue)
                 }
             }
         }
         .sheet(isPresented: $addingNewWorkout, onDismiss: {addingNewWorkout = false}) {
             NavigationStack {
                 EnterWorkout(workout: newWorkout ?? Workout(name: "", category: ""))
             }
             .interactiveDismissDisabled()
         }
     }

     private func addWorkout() {
         withAnimation {
             newWorkout = Workout(name: "", category: "")
             modelContext.insert(newWorkout!)
             addingNewWorkout = true
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

 */

/*
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
             VStack(alignment: .leading) {
                 Text("Workout Info")
                     //.frame(width: .infinity, alignment: .leading)
                     .foregroundColor(.gray.opacity(0.5))
                 TextEditor(text: $workout.info)
                     .frame(height: 200)
                     .foregroundColor(.gray)
                     .overlay(
                         RoundedRectangle(cornerRadius: 8)
                             .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                     )
             }
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

 */

/*
 
 import SwiftUI

 struct EditWorkout: View {
     @Bindable var workout: Workout
     
     @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var modelContext
     
     @State private var editedName: String
     @State private var editedInfo: String
     
     init(workout : Workout) {
         self.workout = workout
         _editedName = State(initialValue: workout.name)
         _editedInfo = State(initialValue: workout.info)
     }
     
     var body: some View {
         Group {
             Form {
                 TextField("Edit workout name", text: $editedName)
                 VStack(alignment: .leading) {
                     Text("Workout Info")
                         .frame(width: .infinity, alignment: .leading)
                         .foregroundColor(.gray)
                     TextEditor(text: $editedInfo)
                         .frame(height: 200)
                         .foregroundColor(.gray)
                         .overlay(
                             RoundedRectangle(cornerRadius: 8)
                                 .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                         )
                 }
             }
         }
         .navigationTitle("Edit Workout")
         .toolbar{
             ToolbarItem(placement: .confirmationAction) {
                 Button("Save") {
                     workout.name = editedName
                     workout.info = editedInfo
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

 */

/*

 import SwiftUI
 import SwiftData

 struct WorkoutDetails: View {
     @Bindable var workout: Workout
     @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var modelContext
     
     @State private var newWorkoutTemplateSet: WorkoutTemplateSet?
     @State private var isEditing: Bool = false
     @State private var showingAlert = false
     @State private var selectedSetIDs: [UUID] = []
     @State private var timedWorkout: Bool = false
     @State private var showingInfo: Bool = false
     @State private var editingName: Bool = false
     
     var sortedSets: [WorkoutTemplateSet] {
         workout.templateSets.sorted { $0.date < $1.date }
     }
     
     private var editButton: some View {
         Button(isEditing ? "Done" : "Edit"){
             withAnimation {
                 isEditing.toggle()
             }
         }
         .foregroundColor(isEditing ? .red : .blue)
     }
     
     var body: some View {
         Group {
             if !workout.templateSets.isEmpty {
                     workoutList
             } else {
                 VStack {
                     Spacer()
                     Text("No Exercises")
                         .bold()
                     Spacer()
                     Button(action: addWorkoutSet) {
                         HStack (spacing: 5) {
                             Image(systemName: "plus")
                             Text("Add Exercise")
                         }
                         .foregroundStyle(.blue)
                         .font(.body)
                         .bold()
                         .padding(.bottom, 20)
                     }
                 }
             }
         }
         .navigationTitle(workout.name)
         .navigationBarItems(trailing: !workout.templateSets.isEmpty ? editButton : nil)
         .sheet(item: $newWorkoutTemplateSet) { set in
             NavigationStack {
                 EnterWorkoutSet(workout: workout, newWorkoutTemplateSet: set)
             }
             .interactiveDismissDisabled()
         }
         .sheet(isPresented: $editingName, onDismiss: {
             editingName = false
         }) {
             NavigationStack {
                 EditWorkout(workout: workout)
             }
         }
         .alert("Track Workout", isPresented: $showingAlert) {
             Button("Cancel", role: .cancel) { }
             Button("Confirm") {
                 let setsToTrack = sortedSets.filter { set in
                     selectedSetIDs.contains(set.id)
                 }.sorted { first, second in
                     selectedSetIDs.firstIndex(of: first.id)! < selectedSetIDs.firstIndex(of: second.id)!
                 }
                 do {
                     try DataManager.shared.addWorkoutSetsToExercises(sets: setsToTrack, modelContext: modelContext)
                     selectedSetIDs.removeAll()
                 } catch {
                     // Handle the error, perhaps show an alert to the user
                     print("Error tracking workout: \(error)")
                 }
             }
         } message: {
             Text("Are you sure you want to add these sets to your exercises?")
         }
     }
     
     private func addWorkoutSet() {
         let newItem = WorkoutTemplateSet(name: "", targetWeight: 0, targetReps: 0, workout: workout)
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
     
     private func moveWorkoutSets(from source: IndexSet, to destination: Int) {
         var updatedSets = sortedSets
         updatedSets.move(fromOffsets: source, toOffset: destination)
         
         // Update the date of each set to maintain the new order
         for (index, set) in updatedSets.enumerated() {
             set.date = Date().addingTimeInterval(TimeInterval(index))
         }
         
         // Update the workout's templateSets
         workout.templateSets = updatedSets
         
         // Save changes to SwiftData
         try? modelContext.save()
     }
     
     @ViewBuilder
     private var workoutList: some View {
         VStack {
             if isEditing {
                 VStack {
                     Button {
                         editingName.toggle()
                     } label: {
                         Text("Edit Workout Details")
                             .foregroundStyle(.blue)
                             .font(.caption)
                     }
                     HStack {
                         Text("Best Time:")
                         TextField("-", value: Binding(
                             get: { workout.bestTimeMinutes ?? 0 },
                             set: { workout.bestTimeMinutes = $0 > 0 ? $0 : nil }
                         ), formatter: NumberFormatter())
                         .foregroundColor(.gray)
                         .multilineTextAlignment(.center)
                         .frame(width: 50)
                         .padding(.vertical, -1)
                         .padding(.trailing, 3)
                         .overlay(
                             RoundedRectangle(cornerRadius: 8)
                                 .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                         )
                         .keyboardType(.numberPad)
                         
                         Text("min")
                             .foregroundStyle(.secondary)
                             .font(.caption)
                         
                         TextField("-", value: Binding(
                             get: { workout.bestTimeSeconds ?? 0 },
                             set: {
                                 let validSeconds = min(max($0, 0), 59)
                                 workout.bestTimeSeconds = validSeconds > 0 ? validSeconds : nil
                             }
                         ), formatter: NumberFormatter())
                         .foregroundColor(.gray)
                         .multilineTextAlignment(.center)
                         .frame(width: 50)
                         .padding(.vertical, -1)
                         .padding(.trailing, 3)
                         .overlay(
                             RoundedRectangle(cornerRadius: 8)
                                 .stroke(Color.secondary, lineWidth: 1)  // Border around the TextField
                         )
                         .keyboardType(.numberPad)
                         
                         Text("sec")
                             .foregroundStyle(.secondary)
                             .font(.caption)
                     }
                     .transition(.blurReplace)
                     .padding()
                 }
             } else {
                 AdditionalInfoView(showingInfo: $showingInfo, workout: workout)
                 if let minutes = workout.bestTimeMinutes, let seconds = workout.bestTimeSeconds {
                     Text("Best Time: \(minutes) min \(seconds) sec")
                         .font(.callout)
                         .foregroundStyle(.gray)
                         //.bold()
                 } else if let minutes = workout.bestTimeMinutes {
                     Text("Best Time: \(minutes) min")
                         .font(.callout)
                         .foregroundStyle(.gray)
                         //.bold()
                 } else if let seconds = workout.bestTimeSeconds {
                     Text("Best Time: \(seconds) sec")
                         .font(.callout)
                         .foregroundStyle(.gray)
                         //.bold()
                 }
             }
             List {
                 ForEach(Array(sortedSets.enumerated()), id: \.element.id) { index, set in
                     VStack {
                         HStack (spacing: 2) {
                             Text("\(index + 1).")
                             Text("\(set.name)".uppercased())
                         }
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
                                 //.foregroundStyle(Color.secondary.opacity(0.2))
                                     .fill(selectedSetIDs.contains(set.id) ? Color.blue.opacity(0.6) : Color.secondary.opacity(0.2))
                             }
                         }
                     }
                     .listRowSeparator(.hidden)
                     .listRowBackground(Color.clear)
                     .contentShape(Rectangle())
                     .onTapGesture {
                         if !isEditing {
                             if let index = selectedSetIDs.firstIndex(of: set.id) {
                                 selectedSetIDs.remove(at: index)
                             } else {
                                 selectedSetIDs.append(set.id)
                             }
                         }
                     }
                 }
                 .onMove(perform: isEditing ? moveWorkoutSets : nil)
                 .onDelete(perform: isEditing ? deleteWorkoutSets : nil)
             }
             .listStyle(PlainListStyle())
             
             if isEditing {
                 Button(action: addWorkoutSet) {
                     Label("Add Set", systemImage: "plus")
                         .padding(.vertical)
                 }
             } else {
                 Button(action: { showingAlert = true }) {
                     Label("Track Selected Sets (\(selectedSetIDs.count))", systemImage: "checkmark.circle")
                         .padding(.vertical)
                 }
                 .disabled(selectedSetIDs.isEmpty)
             }
         }
     }
     
 }


 struct AdditionalInfoView: View {
     
     @Binding var showingInfo: Bool
     var workout: Workout
     
     var body: some View {
         if !workout.info.isEmpty && !showingInfo {
             Button(action: {
                 withAnimation {
                     showingInfo.toggle()
                 }
             }) {
                 Text("Show Exercise Info")
                     .font(.caption)
                     .padding(.bottom)
             }
         }
         if showingInfo {
             VStack {
                 Text("\(workout.info)")
                     .font(.body)
                 Button(action: {
                     withAnimation {
                         showingInfo.toggle()
                     }
                 }) {
                     Text("Collapse Exercise Info")
                         .font(.caption)
                         .padding()
                 }
             }
         }
     }
 }



 */

/*

 /*
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
         .navigationTitle("Add Exercise Set")
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

 */

 import SwiftUI
 import SwiftData

 struct EnterWorkoutSet: View {
     @Environment(\.modelContext) private var modelContext
     @Environment(\.dismiss) private var dismiss
     
     @Bindable var workout: Workout
     @Bindable var newWorkoutTemplateSet: WorkoutTemplateSet
     @Query private var allExercises: [Exercise]
     
     @State private var selectedCategory: ExerciseCategory?
     @State private var selectedExerciseName: String = ""
     
     private var categoriesWithExercises: [ExerciseCategory] {
         Array(Set(allExercises.map { $0.category })).sorted { $0.rawValue < $1.rawValue }
     }
     
     var body: some View {
         Form {
             Picker("Select Category", selection: $selectedCategory) {
                 Text("Choose a category").tag(nil as ExerciseCategory?)
                 ForEach(categoriesWithExercises, id: \.self) { category in
                     Text(category.rawValue.capitalized).tag(category as ExerciseCategory?)
                 }
             }
             .onChange(of: selectedCategory) { _, _ in
                 selectedExerciseName = ""
             }
             
             if let selectedCategory = selectedCategory {
                 Picker("Select Exercise", selection: $selectedExerciseName) {
                     Text("Choose an exercise").tag("")
                     ForEach(filteredExercises(for: selectedCategory)) { exercise in
                         Text(exercise.name).tag(exercise.name)
                     }
                 }
                 .onChange(of: selectedExerciseName) { _, newValue in
                     newWorkoutTemplateSet.name = newValue
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
         .navigationTitle("Add Exercise Set")
         .toolbar {
             ToolbarItem(placement: .confirmationAction) {
                 Button("Add") {
                     if newWorkoutTemplateSet.name != "" && newWorkoutTemplateSet.targetWeight != 0 && newWorkoutTemplateSet.targetReps != 0 {
                         newWorkoutTemplateSet.workout = workout
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
     
     private func filteredExercises(for category: ExerciseCategory) -> [Exercise] {
         return allExercises.filter { $0.category == category }
     }
 }

 */

// DAILY EXERCISE VIEW CODE
/*

 import SwiftUI
 import SwiftData

 struct DailyExerciseView: View {
     @Query private var allExercises: [Exercise]
     @State private var selectedDate: Date = Date()
     @State private var exerciseSets: [ExerciseSet] = []
     @Environment(\.modelContext) private var modelContext
     
     @State private var addingNewSet: Bool = false
     @State private var newSet: ExerciseSet?
     
     var body: some View {
         VStack {
             DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                 .datePickerStyle(CompactDatePickerStyle())
                 .onChange(of: selectedDate) { oldValue, newValue in
                     exerciseSets = fetchExercisesForDate(newValue)
                 }
                 .padding(.horizontal)
             List {
                 ForEach(Array(exerciseSets.enumerated()), id: \.element.id) { index, set in
                     ExerciseSetRow(set: set, index: index)
                 }
                 .onMove(perform: moveItem)
                 .onDelete(perform: deleteItem)
             }
             .padding(.horizontal, -8)
             Button(action: addNewSet) {
                 Label("Add Set", systemImage: "plus")
             }
             .padding()
         }
         .navigationTitle("Daily Workout")
         .onAppear {
             exerciseSets = fetchExercisesForDate(selectedDate)
         }
         .sheet(isPresented: $addingNewSet) {
             NavigationStack {
                 EnterSet(date: selectedDate, newSet: $newSet)
             }
             .interactiveDismissDisabled()
         }
         .onChange(of: newSet) { oldValue, newValue in
             if let newSet = newValue {
                 exerciseSets.append(newSet)
                 self.newSet = nil  // Reset newSet after appending
             }
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
         let calendar = Calendar.current
         let startOfDay = calendar.startOfDay(for: selectedDate)
         for (index, set) in updatedSets.enumerated() {
             set.date = calendar.date(byAdding: .second, value: index, to: startOfDay) ?? set.date
         }
         
         exerciseSets = updatedSets
         
         // Save changes to the model context
         do {
             try modelContext.save()
         } catch {
             print("Error saving context after reordering: \(error)")
         }
     }
     
     private func deleteItem(at offsets: IndexSet) {
         for index in offsets {
             let setToDelete = exerciseSets[index]
             if let exercise = setToDelete.exercise {
                 exercise.removeSet(setToDelete)
                 modelContext.delete(setToDelete)
             }
         }
         exerciseSets.remove(atOffsets: offsets)
         
         // Save changes to the model context
         do {
             try modelContext.save()
         } catch {
             print("Error saving context after deletion: \(error)")
         }
     }
     
     private func addNewSet() {
         addingNewSet = true
     }
     
 }

 struct ExerciseSetRow: View {
     let set: ExerciseSet
     let index: Int
     
     var body: some View {
         if let exercise = set.exercise {
             NavigationLink(destination: ExerciseDetails(exercise: exercise, displayedDate: set.date)) {
                 rowContent
             }
         }
     }
     
     private var rowContent: some View {
         HStack {
             VStack(alignment: .leading) {
                 HStack(spacing: 2) {
                     Text("\(index + 1).")
                         .bold()
                     Text((set.exercise!.name).uppercased())
                 }
                 .padding(.leading, -10)
                 .font(.caption)
                 .foregroundColor(.secondary)
                 HStack {
                     Text("\(set.weight)")
                     Text("LBS")
                         .foregroundStyle(.secondary)
                         .font(.caption2)
                         .padding(.top, 3)
                     Spacer()
                     Text("\(set.reps)")
                     Text("REPS")
                         .foregroundStyle(.secondary)
                         .font(.caption2)
                         .padding(.top, 3)
                 }
                 .font(.body)
             }
         }
     }
 }

 struct EnterSet: View {
     @Environment(\.modelContext) private var modelContext
     @Environment(\.dismiss) private var dismiss
     
     @State private var selectedCategory: ExerciseCategory?
     @State private var selectedExercise: Exercise?
     @State private var weight: Int = 0
     @State private var reps: Int = 0
     @State private var includesDuration: Bool = false
     @State private var minutes: Int = 0
     @State private var seconds: Int = 0
     
     @Query private var allExercises: [Exercise]
     
     let date: Date
     @Binding var newSet: ExerciseSet?
     
     private var categoriesWithExercises: [ExerciseCategory] {
         Array(Set(allExercises.map { $0.category })).sorted { $0.rawValue < $1.rawValue }
     }
     
     var body: some View {
         Form {
             Picker("Select Category", selection: $selectedCategory) {
                 Text("Choose a category").tag(nil as ExerciseCategory?)
                 ForEach(categoriesWithExercises, id: \.self) { category in
                     Text(category.rawValue.capitalized).tag(category as ExerciseCategory?)
                 }
             }
             .onChange(of: selectedCategory) { _, _ in
                 selectedExercise = nil
             }
             
             if let selectedCategory = selectedCategory {
                 Picker("Select Exercise", selection: $selectedExercise) {
                     Text("Choose an exercise").tag(nil as Exercise?)
                     ForEach(filteredExercises(for: selectedCategory)) { exercise in
                         Text(exercise.name).tag(exercise as Exercise?)
                     }
                 }
             }
             
             HStack {
                 TextField("Weight", value: $weight, formatter: NumberFormatter())
                     .keyboardType(.numberPad)
                 Text("lbs")
             }
             
             HStack {
                 TextField("Reps", value: $reps, formatter: NumberFormatter())
                     .keyboardType(.numberPad)
                 Text("reps")
             }
             
             Toggle("Include Duration", isOn: $includesDuration)
             
             if includesDuration {
                 HStack {
                     TextField("Minutes", value: $minutes, formatter: NumberFormatter())
                         .keyboardType(.numberPad)
                     Text("min")
                     TextField("Seconds", value: $seconds, formatter: NumberFormatter())
                         .keyboardType(.numberPad)
                     Text("sec")
                 }
             }
         }
         .navigationTitle("Add Exercise Set")
         .toolbar {
             ToolbarItem(placement: .confirmationAction) {
                 Button("Add") {
                     if let exercise = selectedExercise, weight > 0, reps > 0 {
                         let duration = includesDuration ? TimeInterval(minutes * 60 + seconds) : nil
                         let createdSet = ExerciseSet(weight: weight, reps: reps, duration: duration, date: date, exercise: exercise)
                         newSet = createdSet
                         exercise.addSet(createdSet)
                         modelContext.insert(createdSet)
                         try? modelContext.save()
                         dismiss()
                     }
                 }
                 .disabled(selectedExercise == nil || weight == 0 || reps == 0)
             }
             ToolbarItem(placement: .cancellationAction) {
                 Button("Cancel") {
                     dismiss()
                 }
             }
         }
     }
     
     private func filteredExercises(for category: ExerciseCategory) -> [Exercise] {
         return allExercises.filter { $0.category == category }
     }
 }

 */
