//
//  ExerciseChartView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/14/24.
//

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
                    Text("Reps Count")
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
    private var durationView: some View {
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
    }
    
}

