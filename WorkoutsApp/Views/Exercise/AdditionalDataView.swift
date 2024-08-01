//
//  AdditionalDataView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/31/24.
//

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
