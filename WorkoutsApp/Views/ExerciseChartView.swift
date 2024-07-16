//
//  ExerciseChartView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/14/24.
//

import Charts
import SwiftUI

struct ExerciseChartView: View {
    
    var exerciseSets: [ExerciseSet]
    @Environment(\.calendar) var calendar
    @Binding var selectedDate: Date?
    
    func endOfDay(for date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: date)!
    }
    
    var selectedDateDetails: (weight: Int, reps: Int)? {
        guard let rawSelectedDate = selectedDate else { return nil }
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: rawSelectedDate)!
        
        // Finding the highest weight on the selected date
        let daySets = exerciseSets.filter {
            $0.date >= rawSelectedDate && $0.date < endOfDay
        }
        print("Total exercise sets: \(exerciseSets.count)")
        print("Selected date: \(rawSelectedDate), Matching sets: \(daySets.count)")
        
        if let maxSet = daySets.max(by: { $0.weight < $1.weight }) {
            print("Max weight on day: \(maxSet.weight)")
            return (maxSet.weight, maxSet.reps)
        }
        
        return nil
    }
    
    var body: some View {
        Chart {
            ForEach(exerciseSets) { set in
                BarMark(
                    x: .value("Date", set.date, unit: .day),
                    y: .value("Weight", set.weight)
                )
            }
            .foregroundStyle(.blue)
            
            if let selectedDate {
                RuleMark(
                    x: .value("Selected", selectedDate, unit: .day)
                )
                .foregroundStyle(Color.red.opacity(0.3))
                .offset(yStart: -10)
                .zIndex(0)
                .annotation(
                    position: .top, spacing: 0,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .fit(to: .chart)
                    )
                ) {
                    valueSelectionPopover
                }
            }
        }
        .chartXSelection(value: $selectedDate)
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
    }
    
    
    @ViewBuilder
    var valueSelectionPopover: some View {
        let padding: CGFloat = -4
        if let details = selectedDateDetails, let date = selectedDate {
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
                    Text("\(date, format: .dateTime.year().month().day())")
                    Text("No data available")
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



