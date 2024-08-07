//
//  WorkoutsAppApp.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/11/24.
//

/*
import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct WorkoutsAppApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            ExerciseSet.self,
            Workout.self,
            WorkoutTemplateSet.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
*/

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct WorkoutsAppApp: App {
    @StateObject private var stopwatchManager = StopwatchManager()
    @Environment(\.modelContext) private var modelContext //TODO: DELETE once testing
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            ExerciseSet.self,
            Workout.self,
            WorkoutTemplateSet.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(stopwatchManager)
                .onAppear { //TODO: Delete once testing
                    if UserDefaults.standard.bool(forKey: "hasGeneratedTestData") == false {
                        Task {
                            await generateTestData()
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    //TODO: Delete once done testing
    func generateTestData() async {
        await MainActor.run {
            let context = sharedModelContainer.mainContext
            TestDataGenerator.generateTestData(modelContext: context)
            UserDefaults.standard.set(true, forKey: "hasGeneratedTestData")
        }
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.refreshTimer", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Update your stopwatch time here if needed
        stopwatchManager.updateElapsedTimeInBackground()
        task.setTaskCompleted(success: true)
        scheduleAppRefresh()
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.refreshTimer")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    
}


